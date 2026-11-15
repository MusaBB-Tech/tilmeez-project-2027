import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// Local imports
import '../utils/constants/colors.dart';
import '../widgets/footer.dart';
import 'lga_detail_screen.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // CONSTANTS
  // ---------------------------------------------------------------------------
  static const _backgroundChangeDuration = Duration(seconds: 5);
  static const _maxContentWidth = 1320.0;
  static const _sectionPadding = EdgeInsets.symmetric(
    vertical: 100,
    horizontal: 80,
  );
  static const _smallSectionPadding = EdgeInsets.symmetric(
    vertical: 80,
    horizontal: 80,
  );

  // ---------------------------------------------------------------------------
  // PRP CAMPAIGN PALETTE
  // ---------------------------------------------------------------------------
  static const Color prpRed = Color(0xFFC8102E);
  static const Color prpDarkRed = Color(0xFF9E0B22);
  static const Color prpGold = Color(0xFFF5C518);
  static const Color prpBlack = Color(0xFF111111);
  static const Color prpCharcoal = Color(0xFF1E1E1E);
  static const Color prpWhite = Colors.white;
  static const Color prpOffWhite = Color(0xFFF9F7F4);
  static const Color prpGrey = Color(0xFF6B7280);
  static const Color prpDarkGrey = Color(0xFF374151);
  static const Color prpLight = Color(0xFFF3F4F6);
  static const Color prpBlue = Color(0xFF0A1F44);

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  int _currentGradientIndex = 0;
  late Timer _gradientTimer;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _darkMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final double _screenPadding = 80.0;

  // ---------------------------------------------------------------------------
  // CAMPAIGN DATA
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _voterData = [
    {'lga': 'Katagum', 'voters': 188254, 'units': 384, 'wards': 12},
    {'lga': 'Gamawa', 'voters': 147996, 'units': 289, 'wards': 11},
    {'lga': 'Zaki', 'voters': 124366, 'units': 261, 'wards': 11},
    {'lga': 'Itas/Gadau', 'voters': 112314, 'units': 235, 'wards': 10},
    {'lga': 'Shira', 'voters': 108951, 'units': 239, 'wards': 11},
    {'lga': 'Giade', 'voters': 73771, 'units': 145, 'wards': 10},
    {'lga': "Jama'are", 'voters': 64880, 'units': 113, 'wards': 9},
  ];

  final List<Map<String, dynamic>> _impactStats = [
    {
      'icon': Iconsax.global,
      'number': '820,532',
      'label': 'Registered Voters (2023)',
      'color': prpGold,
    },
    {
      'icon': Iconsax.location,
      'number': '7',
      'label': 'Local Government Areas',
      'color': prpRed,
    },
    {
      'icon': Iconsax.element_3,
      'number': '74',
      'label': 'Wards Across the District',
      'color': prpGold,
    },
    {
      'icon': Iconsax.flag,
      'number': '1,666',
      'label': 'Polling Units',
      'color': prpRed,
    },
  ];

  final List<Map<String, dynamic>> _focusAreas = [
    {
      'goal': 'HEALTH',
      'title': 'Free Medical Outreach',
      'description': 'Surgeries, malaria treatment & fumigation',
      'icon': Iconsax.health,
      'color': prpRed,
    },
    {
      'goal': 'EDUCATION',
      'title': 'Scholarships & Schools',
      'description': 'Sponsorships, scholarships & refurbishment',
      'icon': Iconsax.book,
      'color': prpDarkRed,
    },
    {
      'goal': 'WASH',
      'title': 'Clean Water & Sanitation',
      'description': 'Boreholes & school toilet facilities',
      'icon': Iconsax.drop,
      'color': const Color(0xFF1E6FD9),
    },
    {
      'goal': 'ENERGY',
      'title': 'Affordable Clean Energy',
      'description': 'Solar power for mosques & community centres',
      'icon': Iconsax.sun,
      'color': prpGold,
    },
    {
      'goal': 'INCLUSION',
      'title': 'Reduced Inequalities',
      'description': 'Disability support & infrastructure repairs',
      'icon': Iconsax.building,
      'color': const Color(0xFF8E44AD),
    },
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Aisha Bello',
      'location': 'Azare, Katagum LGA',
      'role': 'Scholarship Beneficiary',
      'quote':
          'The Shehu education endowment changed my life. I am now studying nursing and will give back to Bauchi North.',
      'image': 'assets/person.png',
      'rating': 5,
    },
    {
      'name': 'Ibrahim Musa',
      'location': 'Katagum LGA',
      'role': 'Surgery Patient',
      'quote':
          'Thanks to the free medical outreach, I received cardiac surgery. Their compassion saved my life.',
      'image': 'assets/person.png',
      'rating': 5,
    },
    {
      'name': 'Maryam Abubakar',
      'location': 'Gamawa LGA',
      'role': 'Community Leader',
      'quote':
          'The borehole project brought clean water to our village. Shehu truly serves humanity with compassion.',
      'image': 'assets/person.png',
      'rating': 5,
    },
    {
      'name': 'Usman Garba',
      'location': 'Misau, Shira LGA',
      'role': 'Wheelchair Beneficiary',
      'quote':
          'As a person with disability, the tricycle wheelchair gave me independence and dignity. I am forever grateful.',
      'image': 'assets/person.png',
      'rating': 4,
    },
  ];

  final List<Map<String, dynamic>> _coreValues = [
    {
      'title': 'Compassion & Care',
      'description': 'The heartbeat of our service',
      'icon': Iconsax.heart,
      'color': prpRed,
    },
    {
      'title': 'Accountability',
      'description': 'Ensuring resources reach those who need them most',
      'icon': Iconsax.shield_tick,
      'color': prpBlack,
    },
    {
      'title': 'Inclusivity',
      'description':
          'Supporting all marginalized individuals regardless of background',
      'icon': Iconsax.people,
      'color': prpGold,
    },
    {
      'title': 'Sustainability',
      'description':
          'Investing in long-term resilience, not just temporary relief',
      'icon': Iconsax.repeat,
      'color': prpDarkRed,
    },
  ];

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    _startGradientTimer();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _gradientTimer.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startGradientTimer() {
    _gradientTimer = Timer.periodic(_backgroundChangeDuration, (timer) {
      setState(() => _currentGradientIndex = (_currentGradientIndex + 1) % 3);
    });
  }

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  TextStyle _displayLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 72,
    fontWeight: FontWeight.w800,
    color: prpWhite,
    height: 1.05,
    letterSpacing: -2.5,
  );

  TextStyle _headlineLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 52,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.15,
    letterSpacing: -1.5,
  );

  TextStyle _headlineMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.2,
    letterSpacing: -1.0,
  );

  TextStyle _headlineSmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.3,
  );

  TextStyle _bodyLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.75,
  );

  TextStyle _bodyMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.6,
  );

  // ---------------------------------------------------------------------------
  // SECTION LABEL
  // ---------------------------------------------------------------------------
  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: prpRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: prpRed.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: prpRed,
          letterSpacing: 2.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection() {
    final gradientOptions = [
      [prpBlack, const Color(0xFF2A060C), prpRed],
      [prpBlack, prpDarkRed, const Color(0xFF7A0A1A)],
      [const Color(0xFF1A1A1A), prpRed, prpDarkRed],
    ];

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientOptions[_currentGradientIndex],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -120,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: prpGold.withOpacity(0.08), width: 2),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: prpGold.withOpacity(0.12), width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prpRed.withOpacity(0.15),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.025,
              child: CustomPaint(painter: GridPainter()),
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              padding: EdgeInsets.symmetric(horizontal: _screenPadding),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: prpRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PRP',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: prpWhite,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'BAUCHI NORTH SENATORIAL DISTRICT',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: prpGold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Tilmeez Project\nFor Shehu 2027',
                          style: _displayLarge(context),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Text(
                            'A peoples-first movement for Bauchi North — 7 LGAs, '
                            '74 wards and 1,666 polling units united under one vision: '
                            'compassion, dignity and inclusive development for all.',
                            style: GoogleFonts.inter(
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        Row(
                          children: [
                            _buildPrimaryButton('Our Priorities', prpRed, () {
                              _scrollController.animateTo(
                                MediaQuery.of(context).size.height * 3,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutCubic,
                              );
                            }),
                            const SizedBox(width: 20),
                            _buildOutlineButton('Join the Movement', () {
                              _scrollController.animateTo(
                                MediaQuery.of(context).size.height * 8,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutCubic,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.10),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                          border: Border.all(
                            color: prpGold.withOpacity(0.35),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: prpGold.withOpacity(0.15),
                                  ),
                                  child: const Icon(
                                    Iconsax.chart_2,
                                    size: 18,
                                    color: prpGold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'BAUCHI NORTH AT A GLANCE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: prpGold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _heroStat('820,532', 'Registered Voters (2023)'),
                            _heroStat('7', 'Local Government Areas'),
                            _heroStat('74', 'Wards'),
                            _heroStat('1,666', 'Polling Units'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Divider(color: Colors.white12, height: 1),
                            ),
                            Text(
                              '29.8% of Bauchi State\'s registered electorate',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white60,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String number, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: prpWhite,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Iconsax.arrow_right_3, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: prpGold.withOpacity(0.7), width: 1.5),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: prpGold,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ABOUT (with Hon Tilmeez identity card)
  // ---------------------------------------------------------------------------
  Widget _buildAboutSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 620,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/about_shehu.jpg'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: prpRed.withOpacity(0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 25),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      right: -30,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: prpRed,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: prpRed.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2027',
                              style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: prpGold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ELECTION ROADMAP',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -28,
                      left: -28,
                      child: _buildHonTilmeezCard(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 90),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('THE CANDIDATE'),
                    const SizedBox(height: 24),
                    Text(
                      'Shehu for\nBauchi North',
                      style: _headlineLarge(context),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Under the Peoples Redemption Party (PRP), Shehu is running to represent '
                      'Bauchi North Senatorial District — comprising Katagum, Gamawa, Zaki, '
                      'Itas/Gadau, Shira, Giade and Jama\'are. The Tilmeez Project For Shehu 2027 '
                      'is a peoples-first agenda built on unwavering compassion, protecting dignity '
                      'and restoring hope for the poor, vulnerable and marginalized.',
                      style: _bodyLarge(context),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: _buildValueTile(
                            Iconsax.eye,
                            'Vision',
                            'Inclusive development and opportunity for every community in Bauchi North.',
                            prpRed,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildValueTile(
                            Iconsax.flag,
                            'Mission',
                            'Uplift vulnerable communities through sustainable, dignity-restoring programmes.',
                            prpGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HON TILMEEZ — Floating identity card anchored to the Shehu image
  // ---------------------------------------------------------------------------
  Widget _buildHonTilmeezCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: prpGold.withOpacity(0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: prpGold.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: prpGold, width: 2.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/about_tilmeez.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: prpGold.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: prpRed,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'PRP',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TILMEEZ FOR SHEHU 2027',
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: prpGold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Hon Tilmeez',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _darkMode ? Colors.white : prpBlack,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'For Bauchi North',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _darkMode ? Colors.white60 : prpGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueTile(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _darkMode ? Colors.white60 : prpGrey,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CORE VALUES
  // ---------------------------------------------------------------------------
  Widget _buildCoreValuesSection() {
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      padding: _smallSectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            children: [
              _sectionLabel('OUR VALUES'),
              const SizedBox(height: 24),
              Text('Our Core Values', style: _headlineLarge(context)),
              const SizedBox(height: 16),
              Text(
                'The principles that guide our service',
                style: _bodyLarge(context),
              ),
              const SizedBox(height: 60),
              Row(
                children: _coreValues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 12,
                        right: index == _coreValues.length - 1 ? 0 : 12,
                      ),
                      child: _buildValueCard(value, index + 1),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCard(Map<String, dynamic> value, int number) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : prpOffWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: value['color'].withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: value['color'].withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(value['icon'], size: 26, color: value['color']),
              ),
              Text(
                '0$number',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: value['color'].withOpacity(0.25),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value['title'],
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value['description'],
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _darkMode ? Colors.white60 : prpGrey,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOCUS AREAS
  // ---------------------------------------------------------------------------
  Widget _buildFocusSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            children: [
              _sectionLabel('OUR PRIORITIES'),
              const SizedBox(height: 24),
              Text(
                'Five Pillars for Bauchi North',
                style: _headlineLarge(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Aligned with the needs of all seven LGAs and the UN Sustainable Development Goals.',
                  style: _bodyLarge(context),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                children: _focusAreas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sdg = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                        right: index == _focusAreas.length - 1 ? 0 : 8,
                      ),
                      child: _buildSDGCard(sdg),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSDGCard(Map<String, dynamic> sdg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sdg['color'].withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sdg['color'].withOpacity(0.12),
            ),
            child: Icon(sdg['icon'], size: 28, color: sdg['color']),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: sdg['color'],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              sdg['goal'],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            sdg['title'],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            sdg['description'],
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: _darkMode ? Colors.white60 : prpGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMPACT
  // ---------------------------------------------------------------------------
  Widget _buildImpactSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpBlack, prpDarkRed],
        ),
      ),
      padding: _smallSectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            children: [
              Text(
                'Bauchi North — Electoral Summary',
                style: _headlineMedium(context).copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Key numbers for planning and projections across the district',
                style: GoogleFonts.inter(fontSize: 17, color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Row(
                children: _impactStats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 10,
                        right: index == _impactStats.length - 1 ? 0 : 10,
                      ),
                      child: _buildImpactStat(stat),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactStat(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: prpGold.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stat['color'].withOpacity(0.15),
            ),
            child: Icon(stat['icon'], size: 26, color: stat['color']),
          ),
          const SizedBox(height: 20),
          Text(
            stat['number'],
            style: GoogleFonts.poppins(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['label'],
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LGA TABLE
  // ---------------------------------------------------------------------------
  Widget _buildLgaTableSection() {
    final totalVoters = _voterData.fold<int>(
      0,
      (sum, row) => sum + (row['voters'] as int),
    );
    final totalUnits = _voterData.fold<int>(
      0,
      (sum, row) => sum + (row['units'] as int),
    );
    final totalWards = _voterData.fold<int>(
      0,
      (sum, row) => sum + (row['wards'] as int),
    );
    final maxVoters = _voterData
        .map((r) => r['voters'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('ELECTORAL DATA'),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registered Voters\nby LGA (2023)',
                          style: _headlineLarge(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Source: INEC 2023 register — 7 LGAs, 74 wards, 1,666 polling units',
                          style: _bodyMedium(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: prpRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: prpRed.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'DISTRICT TOTAL',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: prpRed,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalVoters.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},',
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _darkMode ? Colors.white : prpBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _darkMode ? prpCharcoal : prpOffWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _darkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VOTER DISTRIBUTION',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: prpRed,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ..._voterData.map(
                            (row) => _buildVoterBar(row, maxVoters),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _darkMode ? prpCharcoal : prpOffWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _darkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: prpRed,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                _tableHeader('LGA', flex: 3),
                                _tableHeader('Voters', flex: 2),
                                _tableHeader('Units', flex: 2),
                                _tableHeader('Wards', flex: 1),
                                const SizedBox(width: 118),
                              ],
                            ),
                          ),
                          ..._voterData.map((row) => _buildVoterRow(row)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: prpGold.withOpacity(0.15),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                _tableCell('TOTAL', bold: true, flex: 3),
                                _tableCell(
                                  totalVoters.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  ),
                                  bold: true,
                                  flex: 2,
                                ),
                                _tableCell(
                                  totalUnits.toString(),
                                  bold: true,
                                  flex: 2,
                                ),
                                _tableCell(
                                  totalWards.toString(),
                                  bold: true,
                                  flex: 1,
                                ),
                                const SizedBox(width: 118),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _darkMode ? prpCharcoal : prpOffWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _darkMode ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: prpGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.info_circle,
                            size: 18,
                            color: prpGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Key Electoral Findings',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _darkMode ? Colors.white : prpBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _findingItem(
                      'Katagum has the highest number of registered voters (188,254).',
                    ),
                    _findingItem('Jama\'are has the lowest (64,880).'),
                    _findingItem(
                      'Katagum, Gamawa and Zaki collectively account for 460,616 voters — '
                      'approximately 56.1% of Bauchi North\'s electorate.',
                    ),
                    _findingItem(
                      'Bauchi North represents approximately 29.8% of Bauchi State\'s registered voters.',
                    ),
                    _findingItem(
                      'INEC reported ~41,973 newly registered voters across Bauchi State in the '
                      '2025 phase 1 exercise; LGA-level figures for Bauchi North require INEC confirmation.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VOTER BAR (with visible "View Wards" button)
  // ---------------------------------------------------------------------------
  Widget _buildVoterBar(Map<String, dynamic> row, int maxVoters) {
    final percent = (row['voters'] as int) / maxVoters;

    const nameToCode = {
      'Katagum': 'KTG',
      'Gamawa': 'GMW',
      'Itas/Gadau': 'ITG',
      "Jama'are": 'JMR',
      'Shira': 'SHR',
      'Zaki': 'ZKI',
      'Giade': 'GDE',
    };
    final lgaName = row['lga'] as String;
    final lgaCode = nameToCode[lgaName] ?? lgaName;

    void openLga() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LgaDetailScreen(lgaId: lgaCode, lgaName: lgaName),
        ),
      );
    }

    return InkWell(
      onTap: openLga,
      hoverColor: prpRed.withOpacity(0.04),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row['lga'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _darkMode ? Colors.white : prpDarkGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  (row['voters'] as int).toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: prpRed,
                  ),
                ),
                const SizedBox(width: 10),
                _buildViewWardsButton(openLga, compact: true),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: _darkMode
                    ? Colors.white10
                    : Colors.black.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(prpRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool bold = false, required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: bold
              ? (_darkMode ? prpGold : prpRed)
              : (_darkMode ? Colors.white : prpDarkGrey),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VOTER ROW (with visible "View Wards" button)
  // ---------------------------------------------------------------------------
  Widget _buildVoterRow(Map<String, dynamic> row) {
    final lgaName = row['lga'] as String;

    const nameToCode = {
      'Katagum': 'KTG',
      'Gamawa': 'GMW',
      'Itas/Gadau': 'ITG',
      "Jama'are": 'JMR',
      'Shira': 'SHR',
      'Zaki': 'ZKI',
      'Giade': 'GDE',
    };
    final lgaCode = nameToCode[lgaName] ?? lgaName;

    void openLga() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LgaDetailScreen(lgaId: lgaCode, lgaName: lgaName),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openLga,
        hoverColor: prpRed.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _darkMode ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _tableCell(row['lga'], bold: true, flex: 3),
              _tableCell(
                (row['voters'] as int).toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]},',
                ),
                flex: 2,
              ),
              _tableCell((row['units'] as int).toString(), flex: 2),
              _tableCell((row['wards'] as int).toString(), flex: 1),
              const SizedBox(width: 12),
              _buildViewWardsButton(openLga),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VISIBLE "VIEW WARDS" BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildViewWardsButton(VoidCallback onTap, {bool compact = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: prpRed.withOpacity(0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.element_3, size: compact ? 12 : 14, color: prpRed),
              SizedBox(width: compact ? 4 : 6),
              Text(
                'View Wards',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 10 : 11.5,
                  fontWeight: FontWeight.w700,
                  color: prpRed,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: compact ? 4 : 6),
              Icon(
                Iconsax.arrow_right_3,
                size: compact ? 12 : 14,
                color: prpRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _findingItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Iconsax.tick_circle, size: 16, color: prpRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: _darkMode ? Colors.white70 : prpDarkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TESTIMONIALS
  // ---------------------------------------------------------------------------
  Widget _buildTestimonialsSection() {
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            children: [
              _sectionLabel('TESTIMONIALS'),
              const SizedBox(height: 24),
              Text('Impact Stories', style: _headlineLarge(context)),
              const SizedBox(height: 16),
              Text(
                'Hear from those we\'ve served in Bauchi North',
                style: _bodyLarge(context),
              ),
              const SizedBox(height: 60),
              CarouselSlider(
                options: CarouselOptions(
                  height: 420,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.2,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.36,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                ),
                items: _testimonials
                    .map((t) => _buildTestimonialCard(t))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : prpOffWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _darkMode ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: prpRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_quote,
                    color: prpRed,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 15,
                      color: i < testimonial['rating']
                          ? prpGold
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Text(
                testimonial['quote'],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: _darkMode ? Colors.white70 : prpDarkGrey,
                  height: 1.65,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: prpRed.withOpacity(0.12),
                  child: const Icon(Icons.person, color: prpRed, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _darkMode ? Colors.white : prpBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${testimonial['role']} • ${testimonial['location']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _darkMode ? Colors.white60 : prpGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NEWSLETTER
  // ---------------------------------------------------------------------------
  Widget _buildNewsletterSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: _smallSectionPadding,
      child: Center(
        child: SizedBox(
          width: 720,
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: _darkMode ? prpCharcoal : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _darkMode ? Colors.white10 : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Stay Updated',
                  style: _headlineSmall(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Subscribe for campaign updates, rallies and impact stories from Bauchi North.',
                  style: _bodyMedium(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.inter(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: GoogleFonts.inter(
                            color: _darkMode ? Colors.white38 : prpGrey,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: _darkMode
                              ? Colors.white.withOpacity(0.04)
                              : prpOffWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildPrimaryButton('Subscribe', prpRed, () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CTA
  // ---------------------------------------------------------------------------
  Widget _buildCtaSection() {
    return Container(
      padding: _smallSectionPadding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpRed, prpDarkRed],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join Us in Serving\nHumanity',
                      style: _headlineMedium(
                        context,
                      ).copyWith(color: Colors.white, fontSize: 48),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Text(
                        'Partner with the Tilmeez Project For Shehu 2027 to protect dignity and restore hope '
                        'for vulnerable communities across Bauchi North.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Column(
                children: [
                  _buildPrimaryButton('Get Involved', prpGold, () {}),
                  const SizedBox(height: 16),
                  Text(
                    'Together we can make a difference',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCROLL
  // ---------------------------------------------------------------------------
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    _darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection()),
          SliverToBoxAdapter(child: _buildAboutSection()),
          SliverToBoxAdapter(child: _buildLgaTableSection()),
          SliverToBoxAdapter(child: _buildCoreValuesSection()),
          SliverToBoxAdapter(child: _buildFocusSection()),
          SliverToBoxAdapter(child: _buildImpactSection()),
          SliverToBoxAdapter(child: _buildTestimonialsSection()),
          SliverToBoxAdapter(child: _buildNewsletterSection()),
          SliverToBoxAdapter(child: _buildCtaSection()),
          const SliverToBoxAdapter(child: Footer()),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: prpRed.withOpacity(0.35),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: prpRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: const Icon(Iconsax.arrow_up_2, size: 24),
              ),
            )
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// GRID PAINTER
// -----------------------------------------------------------------------------
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
