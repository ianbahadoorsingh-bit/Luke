/**
 * Cloud Functions for Caribbean Golf Hub
 * Deploy: firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const messaging = admin.messaging();

/**
 * Triggered when a new special is created.
 * Sends a push notification to all subscribers of the 'new_specials' FCM topic.
 */
exports.onNewSpecialPublished = functions.firestore
  .document('specials/{specialId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();

    // Only notify for active specials that haven't already sent a notification
    if (!data.isActive || data.notificationSent) return null;

    const message = {
      topic: 'new_specials',
      notification: {
        title: `🏌️ New Special: ${data.title}`,
        body: `${data.courseName} — ${data.currency} ${data.price}. Valid until ${
          data.validTo.toDate().toLocaleDateString('en-TT')
        }`,
      },
      data: {
        type: 'new_special',
        specialId: context.params.specialId,
        courseId: data.courseId,
      },
      android: {
        notification: {
          icon: 'ic_golf',
          color: '#1B4332',
          channelId: 'cgh_specials',
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    try {
      await messaging.send(message);
      // Mark as sent to avoid duplicate notifications
      await snap.ref.update({ notificationSent: true });
      console.log(`FCM sent for special: ${data.title}`);
    } catch (err) {
      console.error('FCM send error:', err);
    }

    return null;
  });

/**
 * Triggered when tournament registration count changes.
 * Closes registration automatically when tournament is full.
 */
exports.onRegistrationCreated = functions.firestore
  .document('tournaments/{tournamentId}/registrations/{registrationId}')
  .onCreate(async (snap, context) => {
    const { tournamentId } = context.params;

    const tournamentRef = admin.firestore()
      .collection('tournaments')
      .doc(tournamentId);

    const tournament = await tournamentRef.get();
    if (!tournament.exists) return null;

    const data = tournament.data();
    const count = data.registrationCount || 0;

    if (count >= data.maxParticipants && data.registrationOpen) {
      await tournamentRef.update({ registrationOpen: false });
      console.log(`Tournament ${tournamentId} is now full — registration closed.`);
    }

    return null;
  });

/**
 * HTTP endpoint: Export registrations as CSV (called by admin dashboard as fallback).
 * Requires a valid Firebase ID token in Authorization header.
 */
exports.exportRegistrations = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }

  const { tournamentId } = data;
  if (!tournamentId) {
    throw new functions.https.HttpsError('invalid-argument', 'tournamentId required');
  }

  // Check caller is an admin
  const adminDoc = await admin.firestore()
    .collection('admin_users').doc(context.auth.uid).get();
  if (!adminDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'Not authorised');
  }

  const snap = await admin.firestore()
    .collection('tournaments').doc(tournamentId)
    .collection('registrations')
    .orderBy('submittedAt')
    .get();

  const headers = ['Full Name', 'Email', 'Phone', 'Home Club', 'Handicap Index', 'Status', 'Submitted At'];
  const rows = snap.docs.map(doc => {
    const d = doc.data();
    return [
      d.fullName, d.email, d.phone, d.homeClub,
      d.handicapIndex, d.status,
      d.submittedAt?.toDate().toISOString() || '',
    ];
  });

  const csv = [headers, ...rows]
    .map(row => row.map(c => `"${String(c ?? '').replace(/"/g, '""')}"`).join(','))
    .join('\n');

  return { csv, count: snap.size };
});
