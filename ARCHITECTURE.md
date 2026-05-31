# Caribbean Golf Hub — Architecture & Design Document

## Overview

Caribbean Golf Hub is a cross-platform mobile application built with Flutter targeting
iOS and Android. It serves as the premier digital hub for golf in Trinidad & Tobago and
the wider Caribbean — covering course discovery, tournament management, club promotions,
and rules reference.

---

## Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Mobile Frontend | Flutter 3.x (Dart) | Single codebase, native performance, premium UI control |
| Backend / DB | Firebase (Firestore + Auth + Storage + FCM) | Real-time sync, offline support, managed infrastructure |
| Admin Dashboard | Vanilla HTML/CSS/JS + Firebase Web SDK | Zero-friction deployment, no build step for club staff |
| Hosting (Admin) | Firebase Hosting | CDN-backed, SSL, single `firebase deploy` |
| Push Notifications | Firebase Cloud Messaging (FCM) | Cross-platform, free, integrates with Firestore triggers |
| CSV Export | Dart `csv` package (mobile) / JS (admin) | Organizers download registrations without app access |

---

## Firestore Data Model

### Collection: `courses`
```
/courses/{courseId}
  name:            string       // "St. Andrews Golf Club (Moka)"
  location:        string       // "Maraval, Trinidad"
  mapLink:         string       // Google Maps URL
  latitude:        number
  longitude:       number
  contactNumber:   string       // "+1-868-629-2314"
  whatsappNumber:  string       // "+18686292314" (digits only for wa.me link)
  amenities:       string[]     // ["Pro Shop", "Restaurant", "Driving Range", ...]
  imageUrl:        string       // Firebase Storage URL
  description:     string
  rates: {
    local: {
      weekday:  number          // TTD amount
      weekend:  number
      twilight: number | null
    }
    tourist: {
      weekday:  number          // USD amount
      weekend:  number
      twilight: number | null
    }
    currency_local:  string     // "TTD"
    currency_tourist: string    // "USD"
    notes:           string     // "Cart mandatory on weekends"
  }
  isActive:  boolean
  updatedAt: timestamp
```

### Collection: `tournaments`
```
/tournaments/{tournamentId}
  name:                 string
  description:          string
  courseId:             string    // ref to /courses
  courseName:           string    // denormalized for list performance
  startDate:            timestamp
  endDate:              timestamp
  registrationDeadline: timestamp
  format:               string    // "Strokeplay", "Stableford", "Match Play"
  maxParticipants:      number
  entryFee:             number
  feeCurrency:          string
  imageUrl:             string
  registrationOpen:     boolean
  country:              string    // "TT", "BB", "JM", etc.
  tags:                 string[]  // ["Open", "Amateur", "Charity"]
  createdAt:            timestamp
  updatedAt:            timestamp
```

### Sub-collection: `tournaments/{tournamentId}/registrations`
```
/tournaments/{tournamentId}/registrations/{registrationId}
  fullName:       string
  email:          string
  phone:          string
  homeClub:       string
  handicapIndex:  number         // e.g. 14.2
  status:         string         // "pending" | "confirmed" | "waitlisted"
  submittedAt:    timestamp
  notes:          string | null
```

### Collection: `specials`
```
/specials/{specialId}
  courseId:      string
  courseName:    string          // denormalized
  title:         string         // "Moka Twilight Special"
  description:   string
  imageUrl:      string
  validFrom:     timestamp
  validTo:       timestamp
  price:         number
  originalPrice: number | null
  currency:      string
  tags:          string[]        // ["Twilight", "Stay & Play", "Members"]
  isActive:      boolean
  publishedAt:   timestamp
  notificationSent: boolean
```

### Collection: `rules`
```
/rules/{ruleId}
  category:    string     // "Penalty Areas", "Out of Bounds", "Unplayable Ball"
  title:       string     // "Taking Relief from a Penalty Area"
  ruleNumber:  string     // "17.1"
  summary:     string     // one-line plain-English summary
  content:     string     // full markdown text
  imageUrls:   string[]   // diagram URLs from Firebase Storage
  order:       number     // sort within category
  tags:        string[]
```

### Collection: `admin_users`
```
/admin_users/{uid}
  email:     string
  name:      string
  role:      string      // "super_admin" | "club_admin"
  courseId:  string | null  // null for super_admin
  createdAt: timestamp
```

---

## Application Modules

### 1. Course Directory
- `CoursesListScreen` — searchable, filterable card list
- `CourseDetailScreen` — full detail with rates, amenities, map link, dial/WhatsApp CTAs

### 2. Tournament & Calendar
- `TournamentsScreen` — chronological list with country filter chips
- `TournamentDetailScreen` — full info, registration status, participant count
- `RegistrationFormScreen` — validated form, Firestore write, confirmation

### 3. Specials Marketplace
- `SpecialsScreen` — real-time feed, active-only, sorted by newest
- `SpecialDetailScreen` — full detail with validity countdown
- FCM push notifications on new special publish (Cloud Function trigger)

### 4. Rules Reference
- `RulesScreen` — category browser with accordion sections
- `RuleDetailScreen` — full rule text with image diagrams

### 5. Admin Dashboard (Web)
- Login with Firebase Auth (email/password)
- Role-based access: super_admin sees all clubs, club_admin sees own club only
- Manage: course details, publish specials, view/export registrations as CSV

---

## Navigation Structure (Bottom Nav)

```
HomeScreen
├── Tab 0: Courses   → CoursesListScreen → CourseDetailScreen
├── Tab 1: Tournaments → TournamentsScreen → TournamentDetailScreen → RegistrationFormScreen
├── Tab 2: Specials  → SpecialsScreen → SpecialDetailScreen
└── Tab 3: Rules     → RulesScreen → RuleDetailScreen
```

---

## Security Model

**Firestore Rules:**
- Public read on `courses`, `specials`, `rules`, `tournaments`
- Authenticated write only (admin users) for `courses`, `specials`, `tournaments`
- `registrations` sub-collection: write-allowed for any authenticated user, read restricted to admin of that tournament's course
- `admin_users` collection: readable only by the owner UID and super_admins

---

## Scalability Notes

- Firestore compound indexes on `specials` (isActive + publishedAt desc)
- Firestore compound indexes on `tournaments` (registrationOpen + startDate asc)
- Pagination using `startAfterDocument` cursors for specials feed
- Firebase Storage rules restrict upload to authenticated admin users
- Cloud Function `onWrite` trigger on `/specials/{id}` sends FCM topic message `new_specials`

---

## Deployment Checklist (MVP Launch)

- [ ] Replace `google-services.json` / `GoogleService-Info.plist` with production Firebase project
- [ ] Set FCM topic subscription in app (`new_specials`)
- [ ] Deploy Firestore security rules (`firebase deploy --only firestore:rules`)
- [ ] Deploy admin dashboard (`firebase deploy --only hosting`)
- [ ] Seed initial course data (run `firebase/seed_data.js` via Firebase Admin SDK)
- [ ] Configure App Store / Play Store listings
