/**
 * Seed script for Caribbean Golf Hub — Firestore initial data.
 * Run with: node seed_data.js
 * Requires: firebase-admin SDK + a serviceAccountKey.json in this directory.
 *
 * Usage:
 *   npm install firebase-admin
 *   node seed_data.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Add your key here

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── COURSES ────────────────────────────────────────────────────────────────

const courses = [
  {
    id: 'moka',
    name: "St. Andrews Golf Club (Moka)",
    location: "Maraval, Port of Spain, Trinidad",
    mapLink: "https://maps.google.com/?q=St.+Andrews+Golf+Club+Moka+Trinidad",
    latitude: 10.6867,
    longitude: -61.5237,
    contactNumber: "+1-868-629-2314",
    whatsappNumber: "18686292314",
    amenities: ["Pro Shop", "Restaurant & Bar", "Driving Range", "Putting Green", "Locker Rooms", "Function Room", "Caddie Service"],
    imageUrl: null,
    description: "The oldest and most prestigious golf club in Trinidad and Tobago, St. Andrews (Moka) is a scenic 18-hole championship layout nestled in the Maraval Valley. Founded in 1947, the club offers challenging fairways lined with mahogany and immortelle trees, with stunning Northern Range views.",
    rates: {
      local: { weekday: 400, weekend: 500, twilight: 250 },
      tourist: { weekday: 65, weekend: 80, twilight: 45 },
      currency_local: "TTD",
      currency_tourist: "USD",
      notes: "Cart hire additional. Junior rates available. Dress code strictly enforced."
    },
    isActive: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'millennium',
    name: "Millennium Lakes Golf & Country Club",
    location: "Couva, Trinidad",
    mapLink: "https://maps.google.com/?q=Millennium+Lakes+Golf+Couva+Trinidad",
    latitude: 10.4167,
    longitude: -61.4833,
    contactNumber: "+1-868-636-5177",
    whatsappNumber: "18686365177",
    amenities: ["Pro Shop", "Restaurant", "Swimming Pool", "Tennis Courts", "Driving Range", "Conference Facilities"],
    imageUrl: null,
    description: "Millennium Lakes is a modern 18-hole resort-style course in central Trinidad. The course features multiple water hazards and a links-style back nine, offering a distinctive challenge for golfers of all skill levels.",
    rates: {
      local: { weekday: 350, weekend: 450, twilight: 220 },
      tourist: { weekday: 55, weekend: 70, twilight: 40 },
      currency_local: "TTD",
      currency_tourist: "USD",
      notes: "Twilight rate starts at 3pm. Cart compulsory on weekends."
    },
    isActive: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'pointe_a_pierre',
    name: "Pointe-a-Pierre Golf Club",
    location: "Pointe-a-Pierre, Trinidad",
    mapLink: "https://maps.google.com/?q=Pointe-a-Pierre+Golf+Club+Trinidad",
    latitude: 10.3167,
    longitude: -61.4667,
    contactNumber: "+1-868-658-4222",
    whatsappNumber: "18686584222",
    amenities: ["Pro Shop", "Clubhouse", "Restaurant", "Wildlife Reserve Access"],
    imageUrl: null,
    description: "Set within the Petrotrin oil refinery estate, Pointe-a-Pierre Golf Club is a unique 9-hole layout bordering the famous Pointe-a-Pierre Wildfowl Trust. The course offers an authentic, traditional golf experience surrounded by rich biodiversity.",
    rates: {
      local: { weekday: 200, weekend: 280, twilight: null },
      tourist: { weekday: 35, weekend: 50, twilight: null },
      currency_local: "TTD",
      currency_tourist: "USD",
      notes: "Members play free on weekdays. Guest fees apply."
    },
    isActive: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'tobago_plantations',
    name: "Tobago Plantations Golf & Country Club",
    location: "Lowlands, Tobago",
    mapLink: "https://maps.google.com/?q=Tobago+Plantations+Golf+Club",
    latitude: 11.1672,
    longitude: -60.8377,
    contactNumber: "+1-868-631-0000",
    whatsappNumber: "18686310000",
    amenities: ["Resort Hotel", "Pro Shop", "Restaurant & Bar", "Swimming Pool", "Beach Access", "Spa", "Driving Range", "Putting Green", "Golf Academy"],
    imageUrl: null,
    description: "The jewel of Caribbean resort golf. Tobago Plantations Golf & Country Club is an internationally acclaimed 18-hole championship course offering panoramic views of the Caribbean Sea and Bon Accord Lagoon. Designed with lush tropical landscapes and dramatic elevation changes, this is a bucket-list experience for visiting golfers.",
    rates: {
      local: { weekday: 500, weekend: 650, twilight: 350 },
      tourist: { weekday: 95, weekend: 120, twilight: 65 },
      currency_local: "TTD",
      currency_tourist: "USD",
      notes: "Resort guests receive preferential rates. Stay & Play packages available. Cart included in green fee."
    },
    isActive: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ── RULES ──────────────────────────────────────────────────────────────────

const rules = [
  {
    category: "Out of Bounds",
    title: "Stroke and Distance Relief",
    ruleNumber: "18.2",
    summary: "Ball OOB? Return to original spot and add one penalty stroke.",
    content: `**What is Out of Bounds?**

Out of bounds (OOB) is any area outside the course boundary, usually marked by white stakes or a fence line. A ball is out of bounds only if the entire ball lies out of bounds.

**The Procedure**

When your ball is out of bounds, you must proceed under stroke and distance:

- Return to the spot of your previous stroke (or as near as possible)
- Add one penalty stroke to your score
- Play a ball from that spot

**Example:** You play your tee shot and it crosses the white stakes. You must re-tee, hitting your third shot with a one-stroke penalty.

**Local Rule Alternative**

- Many clubs adopt the Local Rule allowing you to drop on the edge of the fairway nearest to where the ball went OOB, with a two-stroke penalty (instead of returning to the tee)
- Check your club's Local Rules before your round`,
    imageUrls: [],
    order: 1,
    tags: ["Stroke & Distance", "Penalty", "OOB"],
  },
  {
    category: "Penalty Areas",
    title: "Taking Relief from a Red Penalty Area",
    ruleNumber: "17.1d",
    summary: "Red penalty areas give you three relief options with one penalty stroke.",
    content: `**Red Penalty Areas (marked with red stakes/lines)**

A red penalty area gives you three options, all with a one-stroke penalty:

- **Option 1 — Stroke and Distance:** Play again from where you played your last stroke.

- **Option 2 — Back-on-the-Line Relief:** Drop a ball anywhere on the line going back from the hole through the point where the ball last crossed the edge of the penalty area (no limit on how far back).

- **Option 3 — Lateral Relief:** Drop within two club-lengths of where the ball last crossed the edge of the penalty area, no closer to the hole.

**Yellow Penalty Areas**

Yellow penalty areas only allow Options 1 and 2 — there is no lateral relief option.

**Important Notes**

- You may play the ball as it lies in a penalty area without penalty
- Relief must be taken outside the penalty area
- The nearest point of complete relief applies when taking free relief from ground under repair inside a penalty area`,
    imageUrls: [],
    order: 1,
    tags: ["Penalty Area", "Lateral Relief", "Water Hazard"],
  },
  {
    category: "Unplayable Ball",
    title: "Three Options for an Unplayable Ball",
    ruleNumber: "19.2",
    summary: "You can declare any ball unplayable anywhere (except a penalty area) for one stroke.",
    content: `**When to Use**

You are the sole judge of whether your ball is unplayable. You may declare it unplayable anywhere on the course except in a penalty area (where penalty area rules apply instead).

**The Three Relief Options (all add one penalty stroke):**

- **Option 1 — Stroke and Distance:** Return to where you played your last stroke and play again.

- **Option 2 — Back-on-the-Line:** Drop a ball on the line running from the hole through your ball's position, going as far back as you wish.

- **Option 3 — Two Club-Length Lateral Relief:** Drop within two club-lengths of where the ball lies, no closer to the hole.

**In a Bunker**

If your ball is in a bunker and you declare it unplayable:

- Options 1 and 3 — the ball must be dropped in the bunker
- Option 2 — the ball may be dropped in the bunker or outside the bunker on the back-on-line, but for a **two-stroke penalty** if dropped outside the bunker`,
    imageUrls: [],
    order: 1,
    tags: ["Unplayable", "Relief", "Bunker"],
  },
  {
    category: "Scorecard Etiquette",
    title: "Completing and Certifying Your Scorecard",
    ruleNumber: "3.3b",
    summary: "Each hole score must be correct and certified by your marker before submission.",
    content: `**Responsibilities**

Both the player and the marker (another player who records the score) share responsibility for the scorecard.

**The Rules**

- The player is responsible for the correctness of the score for each hole
- The marker must certify the scorecard by signing or initialling it
- The player must also sign the scorecard
- A wrong score lower than actual = **disqualification**
- A wrong score higher than actual = the higher score stands

**Key Points**

- You do not need to add up your total — the committee handles this
- If you have a handicap and net scores are used, your handicap must appear on the card
- Once submitted, a scorecard cannot be changed

**Stableford / Local Scoring**

In Stableford competitions, a hole with no points (net double bogey or worse) does not require a gross score on the card, but you must ensure your net score is at least recorded.

**Best Practice**

- Keep a running tally during the round
- Agree scores verbally with your marker at the end of each hole
- Find a quiet area to review before signing and submitting`,
    imageUrls: [],
    order: 1,
    tags: ["Scorecard", "Etiquette", "Handicap"],
  },
];

// ── SPECIALS SAMPLE ────────────────────────────────────────────────────────

const specials = [
  {
    courseId: "tobago_plantations",
    courseName: "Tobago Plantations Golf & Country Club",
    title: "Tobago Stay & Play Package",
    description: "3 nights accommodation + 2 rounds of golf at Tobago Plantations. Includes daily breakfast and one dinner at the clubhouse restaurant. Valid for 2 guests.",
    imageUrl: null,
    validFrom: new Date(),
    validTo: new Date(Date.now() + 45 * 24 * 60 * 60 * 1000), // 45 days
    price: 1800,
    originalPrice: 2400,
    currency: "USD",
    tags: ["Stay & Play", "Package", "Tobago"],
    isActive: true,
    publishedAt: admin.firestore.FieldValue.serverTimestamp(),
    notificationSent: false,
  },
  {
    courseId: "moka",
    courseName: "St. Andrews Golf Club (Moka)",
    title: "Moka Twilight Special",
    description: "Play 9 holes from 3pm onwards at our exclusive twilight rate. Cart included. Perfect for after-work rounds.",
    imageUrl: null,
    validFrom: new Date(),
    validTo: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    price: 250,
    originalPrice: 400,
    currency: "TTD",
    tags: ["Twilight", "9 Holes", "Cart Included"],
    isActive: true,
    publishedAt: admin.firestore.FieldValue.serverTimestamp(),
    notificationSent: false,
  },
];

// ── SEED FUNCTION ──────────────────────────────────────────────────────────

async function seed() {
  console.log('🌴 Seeding Caribbean Golf Hub data...\n');

  // Courses
  for (const course of courses) {
    const { id, ...data } = course;
    await db.collection('courses').doc(id).set(data);
    console.log(`✅ Course: ${data.name}`);
  }

  // Rules
  for (const rule of rules) {
    await db.collection('rules').add(rule);
    console.log(`✅ Rule: [${rule.ruleNumber}] ${rule.title}`);
  }

  // Specials
  for (const special of specials) {
    await db.collection('specials').add({
      ...special,
      validFrom: admin.firestore.Timestamp.fromDate(special.validFrom),
      validTo: admin.firestore.Timestamp.fromDate(special.validTo),
    });
    console.log(`✅ Special: ${special.title}`);
  }

  console.log('\n🏌️  Seed complete!');
  process.exit(0);
}

seed().catch((e) => {
  console.error('❌ Seed failed:', e);
  process.exit(1);
});
