import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// Local imports — keep in sync with your project structure
import '../../utils/constants/colors.dart';
import '../widgets/footer.dart'; // reuse Footer from desktop home
import 'lga_detail_screen.dart'; // reuse LGA drill-down from desktop home

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // PRP CAMPAIGN PALETTE (mirrors DesktopHomePage)
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

  static const double _maxContentWidth = 1320.0;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  int _currentGradientIndex = 0;
  late Timer _gradientTimer;
  bool _darkMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  // ---------------------------------------------------------------------------
  // CAMPAIGN DATA (mirrors DesktopHomePage)
  // ---------------------------------------------------------------------------
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

  final List<Map<String, dynamic>> _voterData = [
    {'lga': 'Katagum', 'voters': 188254, 'units': 384, 'wards': 12},
    {'lga': 'Gamawa', 'voters': 147996, 'units': 289, 'wards': 11},
    {'lga': 'Zaki', 'voters': 124366, 'units': 261, 'wards': 11},
    {'lga': 'Itas/Gadau', 'voters': 112314, 'units': 235, 'wards': 10},
    {'lga': 'Shira', 'voters': 108951, 'units': 239, 'wards': 11},
    {'lga': 'Giade', 'voters': 73771, 'units': 145, 'wards': 10},
    {'lga': "Jama'are", 'voters': 64880, 'units': 113, 'wards': 9},
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

  final List<Map<String, dynamic>> _journey = [
    {
      'year': '2023',
      'title': 'The Movement Begins',
      'description':
          'Tilmeez Project 2027 is launched under the Peoples Redemption Party (PRP) as a peoples-first agenda for Bauchi North Senatorial District.',
    },
    {
      'year': '2024',
      'title': 'Community Engagement',
      'description':
          'Grassroots listening tours across all 7 LGAs — Katagum, Gamawa, Zaki, Itas/Gadau, Shira, Giade and Jama\'are — shaping the five-pillar agenda.',
    },
    {
      'year': '2025',
      'title': 'Flagship Programme Pilots',
      'description':
          'Medical outreach, borehole repairs and scholarship pilots roll out in priority wards to prove the model.',
    },
    {
      'year': '2027',
      'title': 'Election Roadmap',
      'description':
          'Contesting the Bauchi North Senatorial seat to deliver inclusive development, protect dignity and restore hope across the district.',
    },
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Aisha Bello',
      'location': 'Azare, Katagum LGA',
      'role': 'Scholarship Beneficiary',
      'quote':
          'The Shehu education endowment changed my life. I am now studying nursing and will give back to Bauchi North.',
      'rating': 5,
    },
    {
      'name': 'Ibrahim Musa',
      'location': 'Katagum LGA',
      'role': 'Surgery Patient',
      'quote':
          'Thanks to the free medical outreach, I received cardiac surgery. Their compassion saved my life.',
      'rating': 5,
    },
    {
      'name': 'Maryam Abubakar',
      'location': 'Gamawa LGA',
      'role': 'Community Leader',
      'quote':
          'The borehole project brought clean water to our village. Shehu truly serves humanity with compassion.',
      'rating': 5,
    },
    {
      'name': 'Usman Garba',
      'location': 'Misau, Shira LGA',
      'role': 'Wheelchair Beneficiary',
      'quote':
          'As a person with disability, the tricycle wheelchair gave me independence and dignity. I am forever grateful.',
      'rating': 4,
    },
  ];

  final List<Map<String, dynamic>> _campaignLeaders = [
    {
      'name': 'Shehu',
      'role': 'PRP Candidate — Bauchi North',
      'icon': Iconsax.crown,
    },
    {
      'name': 'Campaign Directorate',
      'role': 'Strategy & Field Operations',
      'icon': Iconsax.briefcase,
    },
    {
      'name': 'Ward Coordinators',
      'role': '74 Wards Across 7 LGAs',
      'icon': Iconsax.people,
    },
    {
      'name': 'Polling Unit Agents',
      'role': '1,666 Polling Units',
      'icon': Iconsax.flag,
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

    _gradientTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() => _currentGradientIndex = (_currentGradientIndex + 1) % 3);
    });

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

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  TextStyle _displayLarge() => GoogleFonts.poppins(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    color: prpWhite,
    height: 1.05,
    letterSpacing: -2.5,
  );

  TextStyle _headlineLarge() => GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.15,
    letterSpacing: -1.5,
  );

  TextStyle _headlineMedium() => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.2,
    letterSpacing: -1.0,
  );

  TextStyle _headlineSmall() => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.3,
  );

  TextStyle _bodyLarge() => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.75,
  );

  TextStyle _bodyMedium() => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.6,
  );

  // ---------------------------------------------------------------------------
  // HELPERS
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

  Widget _primaryButton(String text, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Iconsax.arrow_right_3, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(String text, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: prpGold.withOpacity(0.7), width: 1.5),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: prpGold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentWrapper({required Widget child, EdgeInsets? padding}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontal = screenWidth < 600
        ? 24.0
        : screenWidth < 1024
        ? 40.0
        : 80.0;
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(vertical: 80, horizontal: horizontal),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: child,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection() {
    final gradients = [
      [prpBlack, const Color(0xFF2A060C), prpRed],
      [prpBlack, prpDarkRed, const Color(0xFF7A0A1A)],
      [const Color(0xFF1A1A1A), prpRed, prpDarkRed],
    ];
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Container(
      height: isMobile ? 520 : (isTablet ? 560 : 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients[_currentGradientIndex],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -120,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: prpGold.withOpacity(0.08), width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prpRed.withOpacity(0.15),
              ),
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        'TILMEEZ PROJECT 2027 FOR SHEHU',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: prpGold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'About the Tilmeez\nProject 2027',
                    style: _displayLarge().copyWith(
                      fontSize: isMobile ? 34 : (isTablet ? 48 : 64),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      'A peoples-first movement for Bauchi North — 7 LGAs, 74 wards and '
                      '1,666 polling units united under one vision: compassion, dignity and '
                      'inclusive development for all.',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 15 : 18,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _primaryButton('Our Priorities', prpRed, () {
                        _scrollController.animateTo(
                          (isMobile ? 520 : 600) * 4,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }),
                      const SizedBox(width: 16),
                      _outlineButton('Join the Movement', () {
                        _scrollController.animateTo(
                          (isMobile ? 520 : 600) * 9,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ABOUT (Who we are + Vision/Mission)
  // ---------------------------------------------------------------------------
  Widget _buildAboutSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final visionMission = Row(
      children: [
        Expanded(
          child: _buildValueTile(
            Iconsax.eye,
            'Vision',
            'Inclusive development and opportunity for every community in Bauchi North — '
                'no ward, no polling unit, no family left behind.',
            prpRed,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildValueTile(
            Iconsax.flag,
            'Mission',
            'Uplift vulnerable communities through sustainable, dignity-restoring programmes '
                'in health, education, water, energy and social inclusion.',
            prpGold,
          ),
        ),
      ],
    );

    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      child: _contentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('THE MOVEMENT'),
            const SizedBox(height: 24),
            Text('Who We Are', style: _headlineLarge()),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Text(
                'The Tilmeez Project 2027 is the campaign movement for Shehu, running to represent '
                'Bauchi North Senatorial District under the Peoples Redemption Party (PRP). '
                'Covering Katagum, Gamawa, Zaki, Itas/Gadau, Shira, Giade and Jama\'are, the project '
                'is a peoples-first agenda built on unwavering compassion, protecting dignity and '
                'restoring hope for the poor, vulnerable and marginalized across all 7 LGAs.',
                style: _bodyLarge(),
              ),
            ),
            const SizedBox(height: 48),
            isMobile
                ? Column(
                    children: [
                      _buildValueTile(
                        Iconsax.eye,
                        'Vision',
                        'Inclusive development and opportunity for every community in Bauchi North.',
                        prpRed,
                      ),
                      const SizedBox(height: 16),
                      _buildValueTile(
                        Iconsax.flag,
                        'Mission',
                        'Uplift vulnerable communities through sustainable, dignity-restoring programmes.',
                        prpGold,
                      ),
                    ],
                  )
                : visionMission,
          ],
        ),
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
          Text(description, style: _bodyMedium().copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMPACT STATS (Bauchi North at a glance)
  // ---------------------------------------------------------------------------
  Widget _buildImpactSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpBlack, prpDarkRed],
        ),
      ),
      child: _contentWrapper(
        child: Column(
          children: [
            Text(
              'Bauchi North at a Glance',
              style: _headlineMedium().copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Key numbers for the Tilmeez Project 2027 across the district',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            isMobile
                ? Column(
                    children: _impactStats
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildImpactStat(s),
                          ),
                        )
                        .toList(),
                  )
                : Row(
                    children: _impactStats.asMap().entries.map((entry) {
                      final i = entry.key;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 10,
                            right: i == _impactStats.length - 1 ? 0 : 10,
                          ),
                          child: _buildImpactStat(entry.value),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),
            Text(
              '29.8% of Bauchi State\'s registered electorate',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white60,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
              fontSize: 30,
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
  // CORE VALUES
  // ---------------------------------------------------------------------------
  Widget _buildCoreValuesSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      child: _contentWrapper(
        child: Column(
          children: [
            _sectionLabel('OUR VALUES'),
            const SizedBox(height: 24),
            Text('Campaign Core Values', style: _headlineLarge()),
            const SizedBox(height: 16),
            Text(
              'The principles that guide the Tilmeez Project 2027',
              style: _bodyLarge(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            isMobile
                ? Column(
                    children: _coreValues.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildValueCard(e.value, e.key + 1),
                      );
                    }).toList(),
                  )
                : Row(
                    children: _coreValues.asMap().entries.map((entry) {
                      final i = entry.key;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 12,
                            right: i == _coreValues.length - 1 ? 0 : 12,
                          ),
                          child: _buildValueCard(entry.value, i + 1),
                        ),
                      );
                    }).toList(),
                  ),
          ],
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
            style: _bodyMedium().copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOCUS / FIVE PILLARS
  // ---------------------------------------------------------------------------
  Widget _buildFocusSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      child: _contentWrapper(
        child: Column(
          children: [
            _sectionLabel('OUR PRIORITIES'),
            const SizedBox(height: 24),
            Text(
              'Five Pillars for Bauchi North',
              style: _headlineLarge(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'Aligned with the needs of all seven LGAs and the UN Sustainable Development Goals — '
                'the Tilmeez Project 2027 agenda.',
                style: _bodyLarge(),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            isMobile
                ? Column(
                    children: _focusAreas
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSDGCard(s),
                          ),
                        )
                        .toList(),
                  )
                : Row(
                    children: _focusAreas.asMap().entries.map((entry) {
                      final i = entry.key;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 8,
                            right: i == _focusAreas.length - 1 ? 0 : 8,
                          ),
                          child: _buildSDGCard(entry.value),
                        ),
                      );
                    }).toList(),
                  ),
          ],
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
            style: _bodyMedium().copyWith(fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LGA ELECTORAL DATA
  // ---------------------------------------------------------------------------
  Widget _buildLgaTableSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final totalVoters = _voterData.fold<int>(
      0,
      (s, r) => s + (r['voters'] as int),
    );
    final totalUnits = _voterData.fold<int>(
      0,
      (s, r) => s + (r['units'] as int),
    );
    final totalWards = _voterData.fold<int>(
      0,
      (s, r) => s + (r['wards'] as int),
    );
    final maxVoters = _voterData
        .map((r) => r['voters'] as int)
        .reduce((a, b) => a > b ? a : b);

    String fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      child: _contentWrapper(
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
                        style: _headlineLarge(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Source: INEC 2023 register — 7 LGAs, 74 wards, 1,666 polling units',
                        style: _bodyMedium(),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
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
                          fmt(totalVoters),
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
            const SizedBox(height: 36),
            if (isMobile)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _darkMode ? prpCharcoal : prpOffWhite,
                      borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(height: 16),
                        ..._voterData.map(
                          (row) => _buildVoterBar(row, maxVoters),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: _darkMode ? prpCharcoal : prpOffWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _darkMode ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: prpRed,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              _tableHeader('LGA', flex: 3),
                              _tableHeader('Voters', flex: 2),
                              _tableHeader('Units', flex: 1),
                            ],
                          ),
                        ),
                        ..._voterData.map((row) => _buildCompactVoterRow(row)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: prpGold.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              _tableCell('TOTAL', bold: true, flex: 3),
                              _tableCell(fmt(totalVoters), bold: true, flex: 2),
                              _tableCell('$totalUnits', bold: true, flex: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
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
                                const SizedBox(width: 16),
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
                                  fmt(totalVoters),
                                  bold: true,
                                  flex: 2,
                                ),
                                _tableCell('$totalUnits', bold: true, flex: 2),
                                _tableCell('$totalWards', bold: true, flex: 1),
                                const SizedBox(width: 16),
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
    );
  }

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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LgaDetailScreen(lgaId: lgaCode, lgaName: lgaName),
          ),
        );
      },
      hoverColor: prpRed.withOpacity(0.04),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row['lga'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _darkMode ? Colors.white : prpDarkGrey,
                  ),
                ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LgaDetailScreen(lgaId: lgaCode, lgaName: lgaName),
            ),
          );
        },
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
              const Icon(Iconsax.arrow_right_3, size: 16, color: prpRed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactVoterRow(Map<String, dynamic> row) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          _tableCell('${row['units']}', flex: 1),
        ],
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
  // TIMELINE / JOURNEY
  // ---------------------------------------------------------------------------
  Widget _buildJourneySection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      child: _contentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('THE ROAD TO 2027'),
            const SizedBox(height: 24),
            Text('From Vision to Impact', style: _headlineLarge()),
            const SizedBox(height: 16),
            Text(
              'Milestones on the Tilmeez Project 2027 roadmap',
              style: _bodyLarge(),
            ),
            const SizedBox(height: 48),
            ...List.generate(_journey.length, (i) {
              final item = _journey[i];
              final isLast = i == _journey.length - 1;
              return _buildTimelineItem(
                year: item['year'],
                title: item['title'],
                description: item['description'],
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prpRed,
                    boxShadow: [
                      BoxShadow(color: prpRed.withOpacity(0.4), blurRadius: 8),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: prpRed.withOpacity(0.3)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 28, left: 12),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _darkMode ? prpCharcoal : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _darkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: prpRed.withOpacity(0.1),
                    ),
                    child: Text(
                      year,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: prpRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _darkMode ? Colors.white : prpBlack,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: _bodyMedium()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEADERSHIP / MOVEMENT STRUCTURE
  // ---------------------------------------------------------------------------
  Widget _buildLeadershipSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      child: _contentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('MOVEMENT STRUCTURE'),
            const SizedBox(height: 24),
            Text('Organised for Every Ward', style: _headlineLarge()),
            const SizedBox(height: 16),
            Text(
              'The Tilmeez Project 2027 is structured from the senatorial campaign down to '
              '1,666 polling units — so every community in Bauchi North has a voice.',
              style: _bodyLarge(),
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 0.82 : 0.9,
              ),
              itemCount: _campaignLeaders.length,
              itemBuilder: (context, index) {
                final member = _campaignLeaders[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _darkMode ? prpCharcoal : prpOffWhite,
                    border: Border.all(
                      color: _darkMode ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              prpRed.withOpacity(0.2),
                              prpGold.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: prpRed.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          member['icon'] as IconData,
                          size: 28,
                          color: prpRed,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _darkMode ? Colors.white : prpBlack,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: prpRed.withOpacity(0.1),
                        ),
                        child: Text(
                          member['role'],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: prpRed,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TESTIMONIALS
  // ---------------------------------------------------------------------------
  Widget _buildTestimonialsSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      child: _contentWrapper(
        child: Column(
          children: [
            _sectionLabel('TESTIMONIALS'),
            const SizedBox(height: 24),
            Text('Impact Stories', style: _headlineLarge()),
            const SizedBox(height: 16),
            Text(
              'Hear from those the Tilmeez Project has served in Bauchi North',
              style: _bodyLarge(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 340,
              child: PageView(
                controller: PageController(
                  viewportFraction: isMobile ? 0.9 : 0.36,
                ),
                padEnds: false,
                children: _testimonials
                    .map((t) => _buildTestimonialCard(t))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _darkMode ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                  fontSize: 14,
                  color: _darkMode ? Colors.white70 : prpDarkGrey,
                  height: 1.65,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _darkMode ? Colors.white : prpBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${testimonial['role']} • ${testimonial['location']}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      child: _contentWrapper(
        padding: EdgeInsets.symmetric(
          vertical: 60,
          horizontal: MediaQuery.of(context).size.width < 600 ? 24 : 80,
        ),
        child: Center(
          child: SizedBox(
            width: 720,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 28 : 48),
              decoration: BoxDecoration(
                color: _darkMode ? prpCharcoal : prpOffWhite,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _darkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Stay Updated',
                    style: _headlineSmall(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Subscribe for Tilmeez Project 2027 updates, rallies and impact stories from Bauchi North.',
                    style: _bodyMedium(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  isMobile
                      ? Column(
                          children: [
                            _buildEmailField(),
                            const SizedBox(height: 12),
                            _primaryButton('Subscribe', prpRed, () {}),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildEmailField()),
                            const SizedBox(width: 12),
                            _primaryButton('Subscribe', prpRed, () {}),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Enter your email address',
        hintStyle: GoogleFonts.inter(
          color: _darkMode ? Colors.white38 : prpGrey,
          fontSize: 15,
        ),
        filled: true,
        fillColor: _darkMode ? Colors.white.withOpacity(0.04) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CTA
  // ---------------------------------------------------------------------------
  Widget _buildCtaSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
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
      child: _contentWrapper(
        padding: EdgeInsets.symmetric(
          vertical: 60,
          horizontal: isMobile ? 24 : 80,
        ),
        child: isMobile
            ? Column(
                children: [
                  Text(
                    'Join the Movement\nfor 2027',
                    style: _headlineMedium().copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Partner with the Tilmeez Project 2027 for Shehu to protect dignity and restore hope '
                    'for vulnerable communities across Bauchi North.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _primaryButton('Get Involved', prpGold, () {}),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join the Movement\nfor 2027',
                          style: _headlineMedium().copyWith(
                            color: Colors.white,
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Text(
                            'Partner with the Tilmeez Project 2027 for Shehu to protect dignity and '
                            'restore hope for vulnerable communities across Bauchi North.',
                            style: GoogleFonts.inter(
                              fontSize: 17,
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
                      _primaryButton('Get Involved', prpGold, () {}),
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
    );
  }

  // ---------------------------------------------------------------------------
  // SCROLL TO TOP
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(child: _buildAboutSection()),
            SliverToBoxAdapter(child: _buildImpactSection()),
            SliverToBoxAdapter(child: _buildCoreValuesSection()),
            SliverToBoxAdapter(child: _buildFocusSection()),
            SliverToBoxAdapter(child: _buildLgaTableSection()),
            SliverToBoxAdapter(child: _buildJourneySection()),
            SliverToBoxAdapter(child: _buildLeadershipSection()),
            SliverToBoxAdapter(child: _buildTestimonialsSection()),
            SliverToBoxAdapter(child: _buildNewsletterSection()),
            SliverToBoxAdapter(child: _buildCtaSection()),
            const SliverToBoxAdapter(child: Footer()),
          ],
        ),
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
