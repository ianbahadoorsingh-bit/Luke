/**
 * Caribbean Golf Hub — Pro Shop Admin Dashboard
 * Replace the firebaseConfig below with your project's config from
 * Firebase Console → Project Settings → Your apps → Web app.
 */

// ── Firebase Config (replace before deploying) ────────────────────────────
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
};

firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// ── State ─────────────────────────────────────────────────────────────────
let currentUser = null;
let adminData = null;
let selectedTournamentId = null;

// ── Auth ──────────────────────────────────────────────────────────────────

auth.onAuthStateChanged(async (user) => {
  if (user) {
    currentUser = user;
    await loadAdminData();
    showDashboard();
  } else {
    currentUser = null;
    adminData = null;
    showLogin();
  }
});

document.getElementById('login-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('login-email').value.trim();
  const password = document.getElementById('login-password').value;
  const btn = document.getElementById('login-btn');
  const errEl = document.getElementById('login-error');

  btn.textContent = 'Signing in...';
  btn.disabled = true;
  errEl.classList.add('hidden');

  try {
    await auth.signInWithEmailAndPassword(email, password);
  } catch (err) {
    errEl.textContent = friendlyAuthError(err.code);
    errEl.classList.remove('hidden');
    btn.textContent = 'Sign In';
    btn.disabled = false;
  }
});

document.getElementById('logout-btn').addEventListener('click', () => auth.signOut());

async function loadAdminData() {
  const doc = await db.collection('admin_users').doc(currentUser.uid).get();
  if (doc.exists) {
    adminData = doc.data();
  }
}

// ── Screen Management ─────────────────────────────────────────────────────

function showLogin() {
  document.getElementById('login-screen').classList.remove('hidden');
  document.getElementById('dashboard-screen').classList.add('hidden');
  document.getElementById('login-btn').textContent = 'Sign In';
  document.getElementById('login-btn').disabled = false;
}

function showDashboard() {
  document.getElementById('login-screen').classList.add('hidden');
  document.getElementById('dashboard-screen').classList.remove('hidden');

  const name = adminData?.name || currentUser.email;
  const role = adminData?.role === 'super_admin' ? 'Super Admin' : 'Club Admin';
  document.getElementById('user-label').textContent = `${name} · ${role}`;

  loadOverview();
  loadSpecials();
  loadTournamentSelector();
  if (adminData?.courseId) loadCourseForm(adminData.courseId);
}

// ── Tab Navigation ────────────────────────────────────────────────────────

document.querySelectorAll('.nav-item').forEach((item) => {
  item.addEventListener('click', () => switchTab(item.dataset.tab));
});

function switchTab(tab) {
  document.querySelectorAll('.nav-item').forEach((el) => el.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach((el) => el.classList.add('hidden'));
  document.querySelector(`.nav-item[data-tab="${tab}"]`).classList.add('active');
  document.getElementById(`tab-${tab}`).classList.remove('hidden');

  const titles = { overview: 'Overview', course: 'My Course', specials: 'Specials', registrations: 'Registrations' };
  document.getElementById('page-title').textContent = titles[tab] || tab;
}

// ── Overview ──────────────────────────────────────────────────────────────

async function loadOverview() {
  try {
    const [courses, tournaments, specials] = await Promise.all([
      db.collection('courses').where('isActive', '==', true).get(),
      db.collection('tournaments').where('registrationOpen', '==', true).get(),
      db.collection('specials').where('isActive', '==', true).get(),
    ]);
    document.getElementById('stat-courses').textContent = courses.size;
    document.getElementById('stat-tournaments').textContent = tournaments.size;
    document.getElementById('stat-specials').textContent = specials.size;

    // Count registrations for own tournament if club admin
    let regCount = '—';
    if (adminData?.courseId) {
      const regsSnap = await db.collectionGroup('registrations').get();
      regCount = regsSnap.size;
    }
    document.getElementById('stat-regs').textContent = regCount;
  } catch (e) {
    console.error('Overview error:', e);
  }
}

// ── Course Form ───────────────────────────────────────────────────────────

async function loadCourseForm(courseId) {
  const container = document.getElementById('course-form-container');
  try {
    const doc = await db.collection('courses').doc(courseId).get();
    const data = doc.exists ? doc.data() : {};

    container.innerHTML = `
      <form id="course-form" style="margin-top:16px">
        <div class="form-grid">
          <div class="field-group">
            <label>Course Name</label>
            <input type="text" id="cf-name" value="${esc(data.name || '')}" required />
          </div>
          <div class="field-group">
            <label>Location</label>
            <input type="text" id="cf-location" value="${esc(data.location || '')}" required />
          </div>
          <div class="field-group">
            <label>Contact Number</label>
            <input type="tel" id="cf-phone" value="${esc(data.contactNumber || '')}" />
          </div>
          <div class="field-group">
            <label>WhatsApp Number (digits only)</label>
            <input type="tel" id="cf-whatsapp" value="${esc(data.whatsappNumber || '')}" />
          </div>
          <div class="field-group">
            <label>Google Maps Link</label>
            <input type="url" id="cf-map" value="${esc(data.mapLink || '')}" />
          </div>
          <div class="field-group">
            <label>Amenities (comma-separated)</label>
            <input type="text" id="cf-amenities" value="${esc((data.amenities || []).join(', '))}" />
          </div>
          <div class="field-group span-2">
            <label>Description</label>
            <textarea id="cf-description" rows="3">${esc(data.description || '')}</textarea>
          </div>
          <div class="field-group">
            <label>Local Weekday Rate (TTD)</label>
            <input type="number" id="cf-local-wd" value="${data.rates?.local?.weekday || ''}" />
          </div>
          <div class="field-group">
            <label>Local Weekend Rate (TTD)</label>
            <input type="number" id="cf-local-we" value="${data.rates?.local?.weekend || ''}" />
          </div>
          <div class="field-group">
            <label>Tourist Weekday Rate (USD)</label>
            <input type="number" id="cf-tourist-wd" value="${data.rates?.tourist?.weekday || ''}" />
          </div>
          <div class="field-group">
            <label>Tourist Weekend Rate (USD)</label>
            <input type="number" id="cf-tourist-we" value="${data.rates?.tourist?.weekend || ''}" />
          </div>
          <div class="field-group span-2">
            <label>Rate Notes</label>
            <input type="text" id="cf-notes" value="${esc(data.rates?.notes || '')}" placeholder="e.g. Cart mandatory on weekends" />
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
        <p id="course-form-msg" class="hidden" style="margin-top:10px;"></p>
      </form>
    `;

    document.getElementById('course-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      await saveCourse(courseId);
    });
  } catch (err) {
    container.innerHTML = `<p class="error-msg">Failed to load course: ${err.message}</p>`;
  }
}

async function saveCourse(courseId) {
  const msgEl = document.getElementById('course-form-msg');
  try {
    const updates = {
      name: document.getElementById('cf-name').value.trim(),
      location: document.getElementById('cf-location').value.trim(),
      contactNumber: document.getElementById('cf-phone').value.trim(),
      whatsappNumber: document.getElementById('cf-whatsapp').value.trim(),
      mapLink: document.getElementById('cf-map').value.trim(),
      amenities: document.getElementById('cf-amenities').value.split(',').map(s => s.trim()).filter(Boolean),
      description: document.getElementById('cf-description').value.trim(),
      rates: {
        local: {
          weekday: parseFloat(document.getElementById('cf-local-wd').value) || null,
          weekend: parseFloat(document.getElementById('cf-local-we').value) || null,
        },
        tourist: {
          weekday: parseFloat(document.getElementById('cf-tourist-wd').value) || null,
          weekend: parseFloat(document.getElementById('cf-tourist-we').value) || null,
        },
        currency_local: 'TTD',
        currency_tourist: 'USD',
        notes: document.getElementById('cf-notes').value.trim(),
      },
      updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection('courses').doc(courseId).set(updates, { merge: true });
    showToast('Course updated successfully!', 'success');
  } catch (err) {
    showToast('Save failed: ' + err.message, 'error');
  }
}

// ── Specials ──────────────────────────────────────────────────────────────

async function loadSpecials() {
  const listEl = document.getElementById('specials-list');
  const courseId = adminData?.courseId;
  try {
    let query = db.collection('specials').orderBy('publishedAt', 'desc').limit(20);
    if (courseId && adminData.role !== 'super_admin') {
      query = db.collection('specials').where('courseId', '==', courseId).orderBy('publishedAt', 'desc');
    }
    const snap = await query.get();

    if (snap.empty) {
      listEl.innerHTML = '<p class="text-muted" style="padding:16px 0">No specials yet. Publish one to get started!</p>';
      return;
    }

    const now = new Date();
    listEl.innerHTML = snap.docs.map(doc => {
      const d = doc.data();
      const validTo = d.validTo?.toDate ? d.validTo.toDate() : new Date(d.validTo);
      const expired = validTo < now;
      const badgeClass = expired ? 'badge-red' : 'badge-green';
      const badgeLabel = expired ? 'Expired' : 'Live';
      return `
        <div class="special-item">
          <div>
            <div class="special-name">${esc(d.title)}</div>
            <div class="special-meta">${esc(d.courseName)} · ${d.currency} ${d.price} · Valid until ${validTo.toLocaleDateString()}</div>
          </div>
          <div style="display:flex;gap:8px;align-items:center">
            <span class="badge ${badgeClass}">${badgeLabel}</span>
            <button class="btn btn-sm btn-danger" onclick="deactivateSpecial('${doc.id}')">Remove</button>
          </div>
        </div>
      `;
    }).join('');
  } catch (e) {
    listEl.innerHTML = `<p class="error-msg">Error loading specials: ${e.message}</p>`;
  }
}

document.getElementById('new-special-btn').addEventListener('click', () => {
  document.getElementById('special-form-card').classList.remove('hidden');
  // Set today as default validFrom
  const today = new Date().toISOString().split('T')[0];
  document.getElementById('sp-valid-from').value = today;
});

document.getElementById('cancel-special-btn').addEventListener('click', () => {
  document.getElementById('special-form-card').classList.add('hidden');
  document.getElementById('special-form').reset();
});

document.getElementById('special-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const errEl = document.getElementById('special-form-error');
  const btn = document.getElementById('submit-special-btn');
  errEl.classList.add('hidden');
  btn.textContent = 'Publishing...';
  btn.disabled = true;

  try {
    const courseId = adminData?.courseId || '';
    let courseName = '';
    if (courseId) {
      const cdoc = await db.collection('courses').doc(courseId).get();
      courseName = cdoc.data()?.name || '';
    }

    const validFrom = new Date(document.getElementById('sp-valid-from').value);
    const validTo = new Date(document.getElementById('sp-valid-to').value);
    if (validTo <= validFrom) throw new Error('Valid Until must be after Valid From');

    const tags = document.getElementById('sp-tags').value
      .split(',').map(s => s.trim()).filter(Boolean);

    await db.collection('specials').add({
      courseId,
      courseName,
      title: document.getElementById('sp-title').value.trim(),
      description: document.getElementById('sp-description').value.trim(),
      price: parseFloat(document.getElementById('sp-price').value) || 0,
      originalPrice: parseFloat(document.getElementById('sp-original-price').value) || null,
      currency: 'TTD',
      validFrom: firebase.firestore.Timestamp.fromDate(validFrom),
      validTo: firebase.firestore.Timestamp.fromDate(validTo),
      tags,
      isActive: true,
      imageUrl: null,
      publishedAt: firebase.firestore.FieldValue.serverTimestamp(),
      notificationSent: false,
    });

    showToast('Special published successfully!', 'success');
    document.getElementById('special-form-card').classList.add('hidden');
    document.getElementById('special-form').reset();
    loadSpecials();
  } catch (err) {
    errEl.textContent = err.message;
    errEl.classList.remove('hidden');
  } finally {
    btn.textContent = 'Publish Special';
    btn.disabled = false;
  }
});

async function deactivateSpecial(id) {
  if (!confirm('Remove this special?')) return;
  try {
    await db.collection('specials').doc(id).update({ isActive: false });
    showToast('Special removed.', 'success');
    loadSpecials();
  } catch (e) {
    showToast('Error: ' + e.message, 'error');
  }
}

// ── Registrations ─────────────────────────────────────────────────────────

async function loadTournamentSelector() {
  const sel = document.getElementById('tournament-select');
  try {
    const snap = await db.collection('tournaments').orderBy('startDate').get();
    snap.docs.forEach(doc => {
      const d = doc.data();
      const opt = document.createElement('option');
      opt.value = doc.id;
      opt.textContent = `${d.name} (${d.startDate?.toDate().toLocaleDateString() || '—'})`;
      sel.appendChild(opt);
    });
  } catch (e) {
    console.error('Tournament selector error:', e);
  }
}

document.getElementById('tournament-select').addEventListener('change', (e) => {
  selectedTournamentId = e.target.value;
  const exportBtn = document.getElementById('export-csv-btn');
  exportBtn.disabled = !selectedTournamentId;
  if (selectedTournamentId) loadRegistrations(selectedTournamentId);
});

async function loadRegistrations(tournamentId) {
  const wrap = document.getElementById('registrations-table-wrap');
  wrap.innerHTML = '<div class="spinner-wrap"><div class="spinner"></div></div>';
  try {
    const snap = await db.collection('tournaments').doc(tournamentId)
      .collection('registrations').orderBy('submittedAt').get();

    if (snap.empty) {
      wrap.innerHTML = '<p class="text-muted text-center" style="padding:2rem">No registrations yet.</p>';
      return;
    }

    const rows = snap.docs.map(doc => {
      const d = doc.data();
      const date = d.submittedAt?.toDate ? d.submittedAt.toDate().toLocaleDateString() : '—';
      const statusBadge = d.status === 'confirmed'
        ? `<span class="badge badge-green">Confirmed</span>`
        : d.status === 'waitlisted'
          ? `<span class="badge badge-gold">Waitlisted</span>`
          : `<span class="badge">Pending</span>`;
      return `
        <tr>
          <td>${esc(d.fullName)}</td>
          <td>${esc(d.email)}</td>
          <td>${esc(d.phone)}</td>
          <td>${esc(d.homeClub)}</td>
          <td style="text-align:center">${d.handicapIndex ?? '—'}</td>
          <td>${statusBadge}</td>
          <td>${date}</td>
        </tr>
      `;
    }).join('');

    wrap.innerHTML = `
      <table class="reg-table">
        <thead>
          <tr>
            <th>Full Name</th><th>Email</th><th>Phone</th>
            <th>Home Club</th><th>HCP</th><th>Status</th><th>Submitted</th>
          </tr>
        </thead>
        <tbody>${rows}</tbody>
      </table>
      <p class="text-muted" style="margin-top:10px">${snap.size} registration(s)</p>
    `;
  } catch (e) {
    wrap.innerHTML = `<p class="error-msg">Error: ${e.message}</p>`;
  }
}

// CSV Export
document.getElementById('export-csv-btn').addEventListener('click', async () => {
  if (!selectedTournamentId) return;
  try {
    const tourneyDoc = await db.collection('tournaments').doc(selectedTournamentId).get();
    const tourneyName = tourneyDoc.data()?.name || selectedTournamentId;
    const snap = await db.collection('tournaments').doc(selectedTournamentId)
      .collection('registrations').orderBy('submittedAt').get();

    const headers = ['Full Name', 'Email', 'Phone', 'Home Club', 'Handicap Index', 'Status', 'Submitted At'];
    const rows = snap.docs.map(doc => {
      const d = doc.data();
      const date = d.submittedAt?.toDate ? d.submittedAt.toDate().toISOString() : '';
      return [d.fullName, d.email, d.phone, d.homeClub, d.handicapIndex, d.status, date];
    });

    const csvContent = [
      [`Tournament: ${tourneyName}`],
      [`Exported: ${new Date().toISOString()}`],
      [],
      headers,
      ...rows,
    ].map(row => row.map(cell => `"${String(cell ?? '').replace(/"/g, '""')}"`).join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `registrations-${tourneyName.replace(/\s+/g, '_')}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    showToast('CSV exported!', 'success');
  } catch (e) {
    showToast('Export failed: ' + e.message, 'error');
  }
});

// ── Utilities ─────────────────────────────────────────────────────────────

function esc(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}

function showToast(message, type = 'success') {
  const existing = document.querySelector('.toast');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.textContent = message;
  document.body.appendChild(toast);
  requestAnimationFrame(() => {
    requestAnimationFrame(() => toast.classList.add('show'));
  });
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

function friendlyAuthError(code) {
  const messages = {
    'auth/user-not-found': 'No account found with this email.',
    'auth/wrong-password': 'Incorrect password.',
    'auth/invalid-email': 'Please enter a valid email address.',
    'auth/too-many-requests': 'Too many attempts. Please try again later.',
    'auth/network-request-failed': 'Network error. Check your connection.',
  };
  return messages[code] || 'Sign in failed. Please try again.';
}
