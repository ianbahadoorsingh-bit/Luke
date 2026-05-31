import 'package:caribbean_golf_hub/shared/models/course_model.dart';
import 'package:caribbean_golf_hub/shared/models/tournament_model.dart';
import 'package:caribbean_golf_hub/shared/models/registration_model.dart';
import 'package:caribbean_golf_hub/shared/models/special_model.dart';
import 'package:caribbean_golf_hub/shared/models/rule_model.dart';

/// Static demo data used when Firebase is not yet configured.
class MockData {
  static final List<GolfCourse> courses = [
    GolfCourse(
      id: 'moka',
      name: 'St. Andrews Golf Club (Moka)',
      location: 'Maraval, Port of Spain, Trinidad',
      mapLink: 'https://maps.google.com/?q=St+Andrews+Golf+Club+Moka',
      contactNumber: '+1-868-629-2314',
      whatsappNumber: '18686292314',
      amenities: ['Pro Shop', 'Restaurant & Bar', 'Driving Range', 'Putting Green', 'Locker Rooms'],
      description:
          'The oldest and most prestigious golf club in Trinidad and Tobago. '
          'St. Andrews (Moka) is a scenic 18-hole championship layout nestled in '
          'the Maraval Valley, offering stunning Northern Range views.',
      rates: CourseRates(
        local: const RateTier(weekday: 400, weekend: 500, twilight: 250),
        tourist: const RateTier(weekday: 65, weekend: 80, twilight: 45),
        notes: 'Cart hire additional. Junior rates available.',
      ),
    ),
    GolfCourse(
      id: 'millennium',
      name: 'Millennium Lakes Golf & Country Club',
      location: 'Couva, Trinidad',
      contactNumber: '+1-868-636-5177',
      whatsappNumber: '18686365177',
      amenities: ['Pro Shop', 'Restaurant', 'Swimming Pool', 'Tennis Courts', 'Driving Range'],
      description:
          'A modern 18-hole resort-style course in central Trinidad featuring '
          'multiple water hazards and a distinctive links-style back nine.',
      rates: CourseRates(
        local: const RateTier(weekday: 350, weekend: 450, twilight: 220),
        tourist: const RateTier(weekday: 55, weekend: 70, twilight: 40),
        notes: 'Twilight rate starts at 3pm.',
      ),
    ),
    GolfCourse(
      id: 'tobago',
      name: 'Tobago Plantations Golf & Country Club',
      location: 'Lowlands, Tobago',
      contactNumber: '+1-868-631-0000',
      whatsappNumber: '18686310000',
      amenities: ['Resort Hotel', 'Pro Shop', 'Restaurant & Bar', 'Beach Access', 'Spa', 'Golf Academy'],
      description:
          'An internationally acclaimed 18-hole championship course with panoramic '
          'Caribbean Sea views. A true bucket-list golf experience.',
      rates: CourseRates(
        local: const RateTier(weekday: 500, weekend: 650, twilight: 350),
        tourist: const RateTier(weekday: 95, weekend: 120, twilight: 65),
        notes: 'Cart included in green fee.',
      ),
    ),
    GolfCourse(
      id: 'pap',
      name: 'Pointe-a-Pierre Golf Club',
      location: 'Pointe-a-Pierre, Trinidad',
      contactNumber: '+1-868-658-4222',
      whatsappNumber: '18686584222',
      amenities: ['Pro Shop', 'Clubhouse', 'Restaurant', 'Wildlife Reserve Access'],
      description:
          'A unique 9-hole layout bordering the famous Pointe-a-Pierre Wildfowl Trust, '
          'offering an authentic traditional golf experience.',
      rates: CourseRates(
        local: const RateTier(weekday: 200, weekend: 280),
        tourist: const RateTier(weekday: 35, weekend: 50),
      ),
    ),
    GolfCourse(
      id: 'brechin',
      name: 'Brechin Castle Golf Club',
      location: 'Couva, Trinidad',
      contactNumber: '+1-868-679-3858',
      whatsappNumber: '18686793858',
      amenities: ['Clubhouse', 'Pro Shop', 'Bar & Restaurant', 'Locker Rooms'],
      description:
          'A well-maintained 9-hole course set on the grounds of the historic Brechin Castle '
          'estate in Couva, central Trinidad. Popular with local members and open to visitors.',
      rates: CourseRates(
        local: const RateTier(weekday: 250, weekend: 320),
        tourist: const RateTier(weekday: 40, weekend: 55),
        notes: '9-hole course. Weekend replay available.',
      ),
    ),
    GolfCourse(
      id: 'chaguaramas',
      name: 'Chaguaramas Golf Club',
      location: 'Chaguaramas, Trinidad',
      contactNumber: '+1-868-634-4349',
      whatsappNumber: '18686344349',
      amenities: ['Clubhouse', 'Restaurant', 'Bar', 'Scenic Views', 'Public Access'],
      description:
          'A public 9-hole golf course managed by the Chaguaramas Development Authority, '
          'offering affordable golf with scenic views of the Gulf of Paria. '
          'One of Trinidad\'s most accessible courses.',
      rates: CourseRates(
        local: const RateTier(weekday: 200, weekend: 280),
        tourist: const RateTier(weekday: 30, weekend: 45),
        notes: '9-hole public course. No booking required for weekday rounds.',
      ),
    ),
  ];

  static final List<Tournament> tournaments = [
    Tournament(
      id: 't1',
      name: 'T&T Open Championship 2026',
      description:
          'The premier annual open golf championship for Trinidad and Tobago, '
          'open to all amateur golfers with a valid handicap index.',
      courseId: 'moka',
      courseName: 'St. Andrews Golf Club (Moka)',
      startDate: DateTime(2026, 7, 18),
      endDate: DateTime(2026, 7, 20),
      registrationDeadline: DateTime(2026, 7, 10),
      format: 'Strokeplay',
      maxParticipants: 120,
      entryFee: 800,
      feeCurrency: 'TTD',
      registrationOpen: true,
      country: 'TT',
      tags: ['Open', 'Amateur', '72 Holes'],
      registrationCount: 47,
    ),
    Tournament(
      id: 't2',
      name: 'Tobago Invitational Pro-Am 2026',
      description:
          'A prestigious pro-am event at the beautiful Tobago Plantations. '
          'Teams of one professional and three amateurs compete for top honours.',
      courseId: 'tobago',
      courseName: 'Tobago Plantations Golf & Country Club',
      startDate: DateTime(2026, 8, 8),
      endDate: DateTime(2026, 8, 9),
      registrationDeadline: DateTime(2026, 7, 31),
      format: 'Pro-Am',
      maxParticipants: 60,
      entryFee: 1200,
      feeCurrency: 'TTD',
      registrationOpen: true,
      country: 'TT',
      tags: ['Pro-Am', 'Invitational', 'Caribbean'],
      registrationCount: 24,
    ),
    Tournament(
      id: 't3',
      name: 'Caribbean Golf Cup 2026',
      description:
          'A multi-island team competition bringing together the best amateur '
          'golfers from across the Caribbean region.',
      courseId: 'millennium',
      courseName: 'Millennium Lakes Golf & Country Club',
      startDate: DateTime(2026, 9, 12),
      endDate: DateTime(2026, 9, 14),
      registrationDeadline: DateTime(2026, 8, 28),
      format: 'Stableford',
      maxParticipants: 80,
      entryFee: 650,
      feeCurrency: 'TTD',
      registrationOpen: true,
      country: 'TT',
      tags: ['Team Event', 'Caribbean', 'Regional'],
      registrationCount: 15,
    ),
  ];

  static final List<GolfSpecial> specials = [
    GolfSpecial(
      id: 's1',
      courseId: 'tobago',
      courseName: 'Tobago Plantations Golf & Country Club',
      title: 'Tobago Stay & Play Package',
      description:
          '3 nights accommodation + 2 rounds of golf. Includes daily breakfast '
          'and one dinner at the clubhouse restaurant. Valid for 2 guests.',
      validFrom: DateTime.now().subtract(const Duration(days: 2)),
      validTo: DateTime.now().add(const Duration(days: 43)),
      price: 1800,
      originalPrice: 2400,
      currency: 'USD',
      tags: ['Stay & Play', 'Package', 'Tobago'],
      isActive: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GolfSpecial(
      id: 's2',
      courseId: 'moka',
      courseName: 'St. Andrews Golf Club (Moka)',
      title: 'Moka Twilight Special',
      description:
          'Play 9 holes from 3pm onwards at our exclusive twilight rate. '
          'Cart included. Perfect for after-work rounds.',
      validFrom: DateTime.now().subtract(const Duration(days: 5)),
      validTo: DateTime.now().add(const Duration(days: 25)),
      price: 250,
      originalPrice: 400,
      currency: 'TTD',
      tags: ['Twilight', '9 Holes', 'Cart Included'],
      isActive: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    GolfSpecial(
      id: 's3',
      courseId: 'millennium',
      courseName: 'Millennium Lakes Golf & Country Club',
      title: 'Midweek Member Guest Day',
      description:
          'Bring a guest Tuesday–Thursday and they play at local rates. '
          'No surcharge. Two-ball minimum.',
      validFrom: DateTime.now(),
      validTo: DateTime.now().add(const Duration(days: 60)),
      price: 350,
      currency: 'TTD',
      tags: ['Members', 'Guest', 'Midweek'],
      isActive: true,
      publishedAt: DateTime.now(),
    ),
  ];

  static final List<GolfRule> rules = [
    GolfRule(
      id: 'r1',
      category: 'Out of Bounds',
      title: 'Stroke and Distance Relief',
      ruleNumber: '18.2',
      summary: 'Ball OOB? Return to original spot and add one penalty stroke.',
      content:
          '**What is Out of Bounds?**\n\n'
          'Out of bounds is any area outside the course boundary, usually marked '
          'by white stakes or a fence line. A ball is out of bounds only if the '
          'entire ball lies out of bounds.\n\n'
          '**The Procedure**\n\n'
          'When your ball is out of bounds, you must proceed under stroke and distance:\n\n'
          '- Return to the spot of your previous stroke (or as near as possible)\n'
          '- Add one penalty stroke to your score\n'
          '- Play a ball from that spot\n\n'
          '**Example:** You play your tee shot and it crosses the white stakes. '
          'You must re-tee, hitting your third shot with a one-stroke penalty.',
      order: 1,
      tags: ['Stroke & Distance', 'Penalty'],
    ),
    GolfRule(
      id: 'r2',
      category: 'Penalty Areas',
      title: 'Taking Relief from a Red Penalty Area',
      ruleNumber: '17.1d',
      summary: 'Red penalty areas give three relief options with one penalty stroke.',
      content:
          '**Red Penalty Areas (red stakes/lines)**\n\n'
          'A red penalty area gives you three options, all with a one-stroke penalty:\n\n'
          '- **Option 1 — Stroke and Distance:** Play again from where you played your last stroke.\n'
          '- **Option 2 — Back-on-the-Line Relief:** Drop on the line going back from the hole.\n'
          '- **Option 3 — Lateral Relief:** Drop within two club-lengths of the crossing point.\n\n'
          '**Yellow Penalty Areas**\n\n'
          'Yellow areas only allow Options 1 and 2 — no lateral relief.',
      order: 1,
      tags: ['Penalty Area', 'Lateral Relief'],
    ),
    GolfRule(
      id: 'r3',
      category: 'Unplayable Ball',
      title: 'Three Options for an Unplayable Ball',
      ruleNumber: '19.2',
      summary: 'Declare any ball unplayable anywhere (except penalty areas) for one stroke.',
      content:
          '**When to Use**\n\n'
          'You are the sole judge of whether your ball is unplayable. You may declare '
          'it unplayable anywhere on the course except in a penalty area.\n\n'
          '**The Three Relief Options (all add one penalty stroke):**\n\n'
          '- **Option 1 — Stroke and Distance:** Return to where you played your last stroke.\n'
          '- **Option 2 — Back-on-the-Line:** Drop on the line from the hole through the ball.\n'
          '- **Option 3 — Two Club-Length Lateral Relief:** Drop within two club-lengths.\n\n'
          '**In a Bunker**\n\n'
          'If your ball is unplayable in a bunker, Options 1 and 3 require the ball '
          'to be dropped inside the bunker. Option 2 may be taken outside for two strokes.',
      order: 1,
      tags: ['Unplayable', 'Relief'],
    ),
    GolfRule(
      id: 'r4',
      category: 'Scorecard Etiquette',
      title: 'Completing and Certifying Your Scorecard',
      ruleNumber: '3.3b',
      summary: 'Each hole score must be correct and certified before submission.',
      content:
          '**Responsibilities**\n\n'
          'Both the player and the marker share responsibility for the scorecard.\n\n'
          '**The Rules**\n\n'
          '- The player is responsible for the correctness of the score for each hole\n'
          '- The marker must certify the scorecard by signing or initialling it\n'
          '- A wrong score lower than actual = **disqualification**\n'
          '- A wrong score higher than actual = the higher score stands\n\n'
          '**Best Practice**\n\n'
          'Keep a running tally during the round and agree scores verbally with '
          'your marker at the end of each hole before signing and submitting.',
      order: 1,
      tags: ['Scorecard', 'Etiquette'],
    ),
    GolfRule(
      id: 'r5',
      category: 'Local Rules',
      title: 'Caribbean Preferred Lies (Lift, Clean & Place)',
      ruleNumber: 'Local',
      summary: 'Many Caribbean clubs allow preferred lies during wet season.',
      content:
          '**When It Applies**\n\n'
          'During Trinidad and Tobago\'s wet season (June–November), many clubs '
          'adopt a Local Rule allowing preferred lies through the green.\n\n'
          '**The Procedure**\n\n'
          '- Mark your ball position\n'
          '- Lift, clean, and place the ball within one scorecard length (no nearer the hole)\n'
          '- The ball must be placed on a closely mown area\n\n'
          '**Check Your Club\'s Local Rules**\n\n'
          'Always check the notice board at the first tee or ask the pro shop '
          'before your round whether preferred lies are in operation.',
      order: 1,
      tags: ['Local Rules', 'Caribbean', 'Wet Season'],
    ),
  ];
}
