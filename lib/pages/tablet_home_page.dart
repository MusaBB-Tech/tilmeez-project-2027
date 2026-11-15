import 'dart:async';
import 'dart:math';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Local imports
import '../utils/constants/colors.dart';
import '../widgets/footer.dart';
import 'lga_detail_screen.dart';

class TabletHomePage extends StatefulWidget {
  const TabletHomePage({super.key});

  @override
  State<TabletHomePage> createState() => _TabletHomePageState();
}

class _TabletHomePageState extends State<TabletHomePage>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // CONSTANTS (tablet-tuned)
  // ---------------------------------------------------------------------------
  static const _backgroundChangeDuration = Duration(seconds: 5);
  static const _maxContentWidth = 980.0;
  static const _sectionPadding = EdgeInsets.symmetric(
    vertical: 72,
    horizontal: 40,
  );
  static const _smallSectionPadding = EdgeInsets.symmetric(
    vertical: 56,
    horizontal: 40,
  );

  // ---------------------------------------------------------------------------
  // PRP CAMPAIGN PALETTE (identical to DesktopHomePage)
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
  List<Map<String, dynamic>> _projects = [];
  bool _isLoadingProjects = true;
  bool _darkMode = false;
  final SupabaseClient _supabase = Supabase.instance.client;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ---------------------------------------------------------------------------
  // CAMPAIGN DATA (mirrors DesktopHomePage)
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

  final List<Map<String, dynamic>> _campaignPillars = [
    {
      'title': 'Free Medical Outreach',
      'description':
          'Malaria treatment, funded surgeries (oncology, cardiology, orthopaedics) and community fumigation across the seven LGAs.',
      'icon': Iconsax.health,
      'color': prpRed,
      'tag': 'HEALTH',
    },
    {
      'title': 'Education Endowment',
      'description':
          'Medical & nursing scholarships, orphan sponsorship and refurbishment of dilapidated schools in Bauchi North.',
      'icon': Iconsax.book,
      'color': prpDarkRed,
      'tag': 'EDUCATION',
    },
    {
      'title': 'Water & Sanitation',
      'description':
          'Construction and repair of boreholes, plus clean toilet facilities for schools to improve public health.',
      'icon': Iconsax.drop,
      'color': const Color(0xFF1E6FD9),
      'tag': 'WASH',
    },
    {
      'title': 'Clean Energy',
      'description':
          'Solar power installations for mosques and community centres to drive sustainable, affordable energy.',
      'icon': Iconsax.sun,
      'color': prpGold,
      'tag': 'ENERGY',
    },
    {
      'title': 'Social Inclusion',
      'description':
          'Empowering persons with disabilities through tricycle wheelchairs and community infrastructure repairs.',
      'icon': Iconsax.people,
      'color': const Color(0xFF8E44AD),
      'tag': 'INCLUSION',
    },
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
    _fetchProjects();

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
    _projects.clear();
    super.dispose();
  }

  void _startGradientTimer() {
    _gradientTimer = Timer.periodic(_backgroundChangeDuration, (timer) {
      setState(() => _currentGradientIndex = (_currentGradientIndex + 1) % 3);
    });
  }

  // ---------------------------------------------------------------------------
  // DATA FETCH
  // ---------------------------------------------------------------------------
  Future<void> _fetchProjects() async {
    try {
      final response = await _supabase
          .from('projects')
          .select('*')
          .order('created_at');

      setState(() {
        if (response.isNotEmpty) {
          _projects = response.map(_parseProjectData).toList();
        } else {
          _projects = _campaignPillars;
        }
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() {
        _projects = _campaignPillars;
        _isLoadingProjects = false;
      });
      debugPrint('Error fetching projects: $e');
    }
  }

  Map<String, dynamic> _parseProjectData(Map<String, dynamic> project) {
    return {
      'id': project['id'],
      'title': project['title'] ?? 'Untitled Priority',
      'description': project['description'] ?? 'No description',
      'image': project['image_url'] ?? '',
      'icon': _getProjectIcon(project['title']),
      'color': _getProjectColor(project['title']),
      'tag': project['sdg'] ?? project['tag'] ?? '',
    };
  }

  IconData _getProjectIcon(String? title) {
    if (title == null) return Iconsax.flag;
    final t = title.toLowerCase();
    if (t.contains('health') || t.contains('medical')) return Iconsax.health;
    if (t.contains('education')) return Iconsax.book;
    if (t.contains('water')) return Iconsax.drop;
    if (t.contains('energy') || t.contains('solar')) return Iconsax.sun;
    if (t.contains('social') || t.contains('inclusion')) return Iconsax.people;
    return Iconsax.flag;
  }

  Color _getProjectColor(String? title) {
    if (title == null) return prpRed;
    final t = title.toLowerCase();
    if (t.contains('health') || t.contains('medical')) return prpRed;
    if (t.contains('education')) return prpDarkRed;
    if (t.contains('water')) return const Color(0xFF1E6FD9);
    if (t.contains('energy') || t.contains('solar')) return prpGold;
    if (t.contains('social') || t.contains('inclusion')) {
      return const Color(0xFF8E44AD);
    }
    return prpRed;
  }

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY (tablet-tuned sizes)
  // ---------------------------------------------------------------------------
  TextStyle _displayLarge() => GoogleFonts.poppins(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: prpWhite,
    height: 1.08,
    letterSpacing: -2,
  );

  TextStyle _headlineLarge() => GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.15,
    letterSpacing: -1.2,
  );

  TextStyle _headlineMedium() => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.2,
    letterSpacing: -0.8,
  );

  TextStyle _headlineSmall() => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.3,
  );

  TextStyle _bodyLarge() => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.7,
  );

  TextStyle _bodyMedium() => GoogleFonts.inter(
    fontSize: 13.5,
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: prpRed,
          letterSpacing: 2.2,
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
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
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 40,
      ),
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
              width: 500,
              height: 500,
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
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prpRed.withOpacity(0.15),
              ),
            ),
          ),
          // Tablet: vertical stack (text on top, stats card below)
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: prpGold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Tilmeez Project\n2027 for Shehu',
                    style: _displayLarge(),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      'A peoples-first movement for Bauchi North — 7 LGAs, '
                      '74 wards and 1,666 polling units united under one vision: '
                      'compassion, dignity and inclusive development for all.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.65,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _primaryButton('Our Priorities', prpRed, () {
                        _scrollController.animateTo(
                          MediaQuery.of(context).size.height * 3,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }),
                      const SizedBox(width: 16),
                      _outlineButton('Join the Movement', () {
                        _scrollController.animateTo(
                          MediaQuery.of(context).size.height * 8,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Tablet: stat card full-width, horizontal
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
                                shape: BoxShape.circle,
                                color: prpGold.withOpacity(0.15),
                              ),
                              child: const Icon(
                                Iconsax.chart_2,
                                size: 16,
                                color: prpGold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'BAUCHI NORTH AT A GLANCE',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: prpGold,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Tablet uses 2-column grid for hero stats
                        Row(
                          children: [
                            Expanded(
                              child: _heroStat(
                                '820,532',
                                'Registered Voters (2023)',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _heroStat('7', 'Local Government Areas'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _heroStat('74', 'Wards')),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _heroStat('1,666', 'Polling Units'),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                            color: Colors.white.withOpacity(0.10),
                            height: 1,
                          ),
                        ),
                        Text(
                          '29.8% of Bauchi State\'s registered electorate',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                            height: 1.5,
                          ),
                        ),
                      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: prpWhite,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ABOUT
  // ---------------------------------------------------------------------------
  Widget _buildAboutSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tablet: image on top, text below
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/about_shehu.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: prpRed.withOpacity(0.22),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: prpRed,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: prpRed.withOpacity(0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2027',
                            style: GoogleFonts.poppins(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: prpGold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ELECTION ROADMAP',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 56),
              _sectionLabel('THE CANDIDATE'),
              const SizedBox(height: 20),
              Text('Shehu for\nBauchi North', style: _headlineLarge()),
              const SizedBox(height: 18),
              Text(
                'Under the Peoples Redemption Party (PRP), Shehu is running to represent '
                'Bauchi North Senatorial District — comprising Katagum, Gamawa, Zaki, '
                'Itas/Gadau, Shira, Giade and Jama\'are. The Tilmeez Project 2027 is a '
                'peoples-first agenda built on unwavering compassion, protecting dignity '
                'and restoring hope for the poor, vulnerable and marginalized.',
                style: _bodyLarge(),
              ),
              const SizedBox(height: 28),
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
                  const SizedBox(width: 16),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: _darkMode ? Colors.white60 : prpGrey,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CORE VALUES (tablet: 2x2 grid)
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
              const SizedBox(height: 20),
              Text('Our Core Values', style: _headlineLarge()),
              const SizedBox(height: 14),
              Text(
                'The principles that guide our service',
                style: _bodyLarge(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 44),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.55,
                ),
                itemCount: _coreValues.length,
                itemBuilder: (context, index) =>
                    _buildValueCard(_coreValues[index], index + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCard(Map<String, dynamic> value, int number) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: value['color'].withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(value['icon'], size: 24, color: value['color']),
              ),
              Text(
                '0$number',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: value['color'].withOpacity(0.25),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value['title'],
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value['description'],
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: _darkMode ? Colors.white60 : prpGrey,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOCUS AREAS (tablet: 2-col + 3-col hybrid via Wrap)
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
              const SizedBox(height: 20),
              Text(
                'Five Pillars for Bauchi North',
                style: _headlineLarge(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  'Aligned with the needs of all seven LGAs and the UN Sustainable Development Goals.',
                  style: _bodyLarge(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 44),
              // Tablet: 2-col grid (last item centered via Wrap-like approach)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.05,
                ),
                itemCount: _focusAreas.length,
                itemBuilder: (context, index) =>
                    _buildSDGCard(_focusAreas[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSDGCard(Map<String, dynamic> sdg) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sdg['color'].withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sdg['color'].withOpacity(0.12),
            ),
            child: Icon(sdg['icon'], size: 26, color: sdg['color']),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          Text(
            sdg['title'],
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            sdg['description'],
            style: GoogleFonts.inter(
              fontSize: 12,
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
  // IMPACT (tablet: 2x2 grid)
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
                style: _headlineMedium().copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Key numbers for planning and projections across the district',
                style: GoogleFonts.inter(fontSize: 15, color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 44),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                itemCount: _impactStats.length,
                itemBuilder: (context, index) =>
                    _buildImpactStat(_impactStats[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactStat(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: prpGold.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stat['color'].withOpacity(0.15),
            ),
            child: Icon(stat['icon'], size: 22, color: stat['color']),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat['number'],
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat['label'],
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LGA TABLE (tablet: stacked — bars above, table below)
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
              const SizedBox(height: 20),
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
                        const SizedBox(height: 10),
                        Text(
                          'Source: INEC 2023 register — 7 LGAs, 74 wards, 1,666 polling units',
                          style: _bodyMedium(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
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
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: prpRed,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalVoters.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},',
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
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
              // Tablet: bars on top, table below
              Container(
                padding: const EdgeInsets.all(24),
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
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._voterData.map((row) => _buildVoterBar(row, maxVoters)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
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
                        vertical: 14,
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
                        vertical: 14,
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
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
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
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: prpGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.info_circle,
                            size: 16,
                            color: prpGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Key Electoral Findings',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _darkMode ? Colors.white : prpBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row['lga'],
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: prpRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 7,
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
          fontSize: 10.5,
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
          fontSize: 13,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              const Icon(Iconsax.arrow_right_3, size: 15, color: prpRed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _findingItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Iconsax.tick_circle, size: 15, color: prpRed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.55,
                color: _darkMode ? Colors.white70 : prpDarkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROJECTS / PILLARS (tablet: 2-col grid)
  // ---------------------------------------------------------------------------
  Widget _buildProjectsSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('WHAT WE WILL DO'),
                        const SizedBox(height: 16),
                        Text('Our Pillars', style: _headlineLarge()),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: prpRed,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Iconsax.arrow_right_3,
                          color: prpRed,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              if (_isLoadingProjects)
                _buildShimmerEffect()
              else if (_projects.isEmpty)
                _buildEmptyState(
                  icon: Iconsax.folder_open,
                  message: 'No priorities available',
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.86,
                  ),
                  itemCount: min(5, _projects.length),
                  itemBuilder: (context, index) {
                    return _buildProjectCard(_projects[index], index + 1);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int number) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: _darkMode ? prpCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _darkMode ? Colors.white10 : Colors.black12,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: project['color'].withOpacity(0.06),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: project['color'].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            project['icon'] ?? Iconsax.flag,
                            size: 24,
                            color: project['color'],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '0$number',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: project['color'].withOpacity(0.25),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((project['tag'] as String).isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: project['color'],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                project['tag'],
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            project['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _darkMode ? Colors.white : prpBlack,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              project['description'],
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: _darkMode ? Colors.white60 : prpGrey,
                                height: 1.55,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Learn more',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: project['color'],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 13,
                                color: project['color'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TESTIMONIALS (tablet: viewport 0.65)
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
              const SizedBox(height: 20),
              Text('Impact Stories', style: _headlineLarge()),
              const SizedBox(height: 14),
              Text(
                'Hear from those we\'ve served in Bauchi North',
                style: _bodyLarge(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 44),
              CarouselSlider(
                options: CarouselOptions(
                  height: 380,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.62,
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
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : prpOffWhite,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: prpRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_quote,
                    color: prpRed,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 14,
                      color: i < testimonial['rating']
                          ? prpGold
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: prpRed.withOpacity(0.12),
                  child: const Icon(Icons.person, color: prpRed, size: 20),
                ),
                const SizedBox(width: 10),
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
                          fontSize: 11.5,
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
          width: 640,
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: _darkMode ? prpCharcoal : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _darkMode ? Colors.white10 : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Stay Updated',
                  style: _headlineSmall(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Subscribe for campaign updates, rallies and impact stories from Bauchi North.',
                  style: _bodyMedium(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: GoogleFonts.inter(
                            color: _darkMode ? Colors.white38 : prpGrey,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: _darkMode
                              ? Colors.white.withOpacity(0.04)
                              : prpOffWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _primaryButton('Subscribe', prpRed, () {}),
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
  // CTA (tablet: stacked)
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
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Us in Serving\nHumanity',
                style: _headlineMedium().copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  'Partner with the Tilmeez Project 2027 for Shehu to protect dignity and restore hope '
                  'for vulnerable communities across Bauchi North.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.65,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  _primaryButton('Get Involved', prpGold, () {}),
                  const SizedBox(width: 14),
                  Text(
                    'Together we can make a difference',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
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
  // SHIMMER / EMPTY / SCROLL
  // ---------------------------------------------------------------------------
  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.86,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
        highlightColor: _darkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: _darkMode ? prpCharcoal : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: _darkMode
                ? Colors.white.withOpacity(0.6)
                : TColors.textsecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: _bodyMedium().copyWith(
              color: _darkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

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
          SliverToBoxAdapter(child: _buildCoreValuesSection()),
          SliverToBoxAdapter(child: _buildFocusSection()),
          SliverToBoxAdapter(child: _buildImpactSection()),
          SliverToBoxAdapter(child: _buildLgaTableSection()),
          SliverToBoxAdapter(child: _buildProjectsSection()),
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
// GRID PAINTER (kept for reuse if added back to hero)
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
