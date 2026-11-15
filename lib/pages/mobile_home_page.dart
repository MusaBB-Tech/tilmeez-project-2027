import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants/colors.dart';
import '../widgets/footer.dart';
import 'lga_detail_screen.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage>
    with SingleTickerProviderStateMixin {
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
  static const Color prpGoldText = Color(0xFF9A7A00);

  static const Duration _backgroundChangeDuration = Duration(seconds: 5);
  static const double _screenPadding = 20.0;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  int _currentGradientIndex = 0;
  Timer? _gradientTimer;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  List<Map<String, dynamic>> _projects = [];
  bool _isLoadingProjects = true;
  bool _darkMode = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Scroll controller for the horizontal Pillars carousel
  final ScrollController _pillarsController = ScrollController();
  int _pillarIndex = 0;

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

    _pillarsController.addListener(() {
      final cardWidth = 260.0 + 14.0; // card width + margin
      final newIndex = (_pillarsController.offset / cardWidth).round();
      if (newIndex != _pillarIndex && mounted) {
        setState(
          () => _pillarIndex = newIndex.clamp(0, _focusAreas.length - 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _gradientTimer?.cancel();
    _scrollController.dispose();
    _pillarsController.dispose();
    _animationController.dispose();
    _projects.clear();
    super.dispose();
  }

  void _startGradientTimer() {
    _gradientTimer = Timer.periodic(_backgroundChangeDuration, (_) {
      if (mounted) {
        setState(() => _currentGradientIndex = (_currentGradientIndex + 1) % 3);
      }
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
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  TextStyle _displayLarge() => GoogleFonts.poppins(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: prpWhite,
    height: 1.1,
    letterSpacing: -1.2,
  );

  TextStyle _headlineLarge() => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.2,
    letterSpacing: -0.8,
  );

  TextStyle _headlineMedium() => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.25,
    letterSpacing: -0.5,
  );

  TextStyle _headlineSmall() => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.3,
  );

  TextStyle _bodyLarge() => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.7,
  );

  TextStyle _bodyMedium() => GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.6,
  );

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: prpRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: prpRed.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: prpRed,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _primaryButton(String text, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 16,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Iconsax.arrow_right_3, color: Colors.white, size: 14),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: prpGold.withOpacity(0.7), width: 1.5),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
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
            top: -120,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: prpGold.withOpacity(0.08), width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prpRed.withOpacity(0.15),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _screenPadding,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: prpRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRP',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: prpWhite,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'BAUCHI NORTH SENATORIAL DISTRICT',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: prpGold,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Tilmeez Project\nFor Shehu 2027',
                    style: _displayLarge(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'A peoples-first movement for Bauchi North — 7 LGAs, '
                    '74 wards and 1,666 polling units united under one vision: '
                    'compassion, dignity and inclusive development for all.',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _primaryButton('Our Priorities', prpRed, () {
                        _scrollController.animateTo(
                          MediaQuery.of(context).size.height * 3,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }),
                      _outlineButton('Join the Movement', () {
                        _scrollController.animateTo(
                          MediaQuery.of(context).size.height * 8,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: prpGold.withOpacity(0.15),
                              ),
                              child: const Icon(
                                Iconsax.chart_2,
                                size: 14,
                                color: prpGold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BAUCHI NORTH AT A GLANCE',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: prpGold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _heroStat(
                                '820,532',
                                'Registered Voters (2023)',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _heroStat('7', 'Local Government Areas'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _heroStat('74', 'Wards')),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _heroStat('1,666', 'Polling Units'),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: Colors.white.withOpacity(0.10),
                            height: 1,
                          ),
                        ),
                        Text(
                          '29.8% of Bauchi State\'s registered electorate',
                          style: GoogleFonts.inter(
                            fontSize: 11,
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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: prpWhite,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
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
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/about_shehu.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: prpRed.withOpacity(0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -20,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: prpRed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: prpRed.withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2027',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: prpGold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ELECTION ROADMAP',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(bottom: -20, left: 12, child: _buildHonTilmeezCard()),
            ],
          ),
          const SizedBox(height: 48),
          _sectionLabel('THE CANDIDATE'),
          const SizedBox(height: 18),
          Text('Shehu for\nBauchi North', style: _headlineLarge()),
          const SizedBox(height: 16),
          Text(
            'Under the Peoples Redemption Party (PRP), Shehu is running to represent '
            'Bauchi North Senatorial District — comprising Katagum, Gamawa, Zaki, '
            'Itas/Gadau, Shira, Giade and Jama\'are. The Tilmeez Project For Shehu 2027 '
            'is a peoples-first agenda built on unwavering compassion, protecting dignity '
            'and restoring hope for the poor, vulnerable and marginalized.',
            style: _bodyLarge(),
          ),
          const SizedBox(height: 24),
          _buildValueTile(
            Iconsax.eye,
            'Vision',
            'Inclusive development and opportunity for every community in Bauchi North.',
            prpRed,
          ),
          const SizedBox(height: 14),
          _buildValueTile(
            Iconsax.flag,
            'Mission',
            'Uplift vulnerable communities through sustainable, dignity-restoring programmes.',
            prpGold,
          ),
        ],
      ),
    );
  }

  Widget _buildHonTilmeezCard() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: prpGold.withOpacity(0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: prpGold.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: prpGold, width: 2.2),
              image: const DecorationImage(
                image: AssetImage('assets/images/about_tilmeez.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: prpGold.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: prpRed,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'PRP',
                        style: GoogleFonts.poppins(
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'TILMEEZ FOR SHEHU 2027',
                      style: GoogleFonts.poppins(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        color: prpGold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Hon Tilmeez',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _darkMode ? Colors.white : prpBlack,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'For Bauchi North',
                  style: GoogleFonts.inter(
                    fontSize: 10,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _darkMode ? Colors.white60 : prpGrey,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CORE VALUES (mobile: 2×2 grid) — beautiful upgrade
  // ---------------------------------------------------------------------------
  Widget _buildCoreValuesSection() {
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Column(
        children: [
          _sectionLabel('OUR VALUES'),
          const SizedBox(height: 18),
          Text(
            'Our Core Values',
            style: _headlineLarge(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'The principles that guide our service',
            style: _bodyLarge(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemCount: _coreValues.length,
            itemBuilder: (context, index) =>
                _buildValueCard(_coreValues[index], index + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(Map<String, dynamic> value, int number) {
    final color = value['color'] as Color;
    return Container(
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : prpOffWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Tinted gradient accent at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.18), color.withOpacity(0.02)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(value['icon'], size: 20, color: color),
                      ),
                      Text(
                        '0$number',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color.withOpacity(0.30),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _darkMode ? Colors.white : prpBlack,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value['description'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _darkMode ? Colors.white60 : prpGrey,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOCUS AREAS (mobile: horizontal scrollable) — beautiful upgrade
  // ---------------------------------------------------------------------------
  Widget _buildFocusSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('OUR PRIORITIES'),
                const SizedBox(height: 18),
                Text('Five Pillars for\nBauchi North', style: _headlineLarge()),
                const SizedBox(height: 12),
                Text(
                  'Aligned with the needs of all seven LGAs and the UN Sustainable Development Goals.',
                  style: _bodyLarge(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Horizontal scrollable pillars
          SizedBox(
            height: 320,
            child: ListView.separated(
              controller: _pillarsController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _screenPadding),
              physics: const BouncingScrollPhysics(),
              itemCount: _focusAreas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _buildSDGCard(_focusAreas[index], index + 1);
              },
            ),
          ),
          const SizedBox(height: 20),
          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_focusAreas.length, (i) {
              final isActive = i == _pillarIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? prpRed : prpRed.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSDGCard(Map<String, dynamic> sdg, int number) {
    final color = sdg['color'] as Color;
    return SizedBox(
      width: 260,
      child: Container(
        decoration: BoxDecoration(
          color: _darkMode ? prpCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.22), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            children: [
              // Colored gradient header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.22),
                        color.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.18),
                            border: Border.all(
                              color: color.withOpacity(0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(sdg['icon'], size: 28, color: color),
                        ),
                        Text(
                          '0$number',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: color.withOpacity(0.30),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sdg['goal'],
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _darkMode ? Colors.white : prpBlack,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sdg['description'],
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: _darkMode ? Colors.white60 : prpGrey,
                        height: 1.55,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Learn more',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Iconsax.arrow_right_3, size: 14, color: color),
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
  // IMPACT (mobile: 2x2 grid)
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
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Column(
        children: [
          Text(
            'Bauchi North — Electoral Summary',
            style: _headlineMedium().copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Key numbers for planning and projections across the district',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: _impactStats.length,
            itemBuilder: (context, index) =>
                _buildImpactStat(_impactStats[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: prpGold.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stat['color'].withOpacity(0.15),
            ),
            child: Icon(stat['icon'], size: 20, color: stat['color']),
          ),
          const SizedBox(height: 12),
          Text(
            stat['number'],
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['label'],
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LGA TABLE (mobile: bars + table stacked)
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
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ELECTORAL DATA'),
          const SizedBox(height: 18),
          Text('Registered Voters\nby LGA (2023)', style: _headlineLarge()),
          const SizedBox(height: 8),
          Text(
            'Source: INEC 2023 register — 7 LGAs, 74 wards, 1,666 polling units',
            style: _bodyMedium(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: prpRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: prpRed.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Text(
                  totalVoters.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _darkMode ? Colors.white : prpBlack,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _darkMode ? prpCharcoal : prpOffWhite,
              borderRadius: BorderRadius.circular(18),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: prpRed,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ..._voterData.map((row) => _buildVoterBar(row, maxVoters)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: _darkMode ? prpCharcoal : prpOffWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _darkMode ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: prpRed,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      _tableHeader('LGA', flex: 3),
                      _tableHeader('Voters', flex: 2),
                      _tableHeader('Units', flex: 2),
                      _tableHeader('Wards', flex: 1),
                      const SizedBox(width: 74),
                    ],
                  ),
                ),
                ..._voterData.map((row) => _buildVoterRow(row)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: prpGold.withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
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
                      _tableCell(totalUnits.toString(), bold: true, flex: 2),
                      _tableCell(totalWards.toString(), bold: true, flex: 1),
                      const SizedBox(width: 74),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _darkMode ? prpCharcoal : prpOffWhite,
              borderRadius: BorderRadius.circular(18),
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: prpGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Iconsax.info_circle,
                        size: 15,
                        color: prpGold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Key Electoral Findings',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _darkMode ? Colors.white : prpBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row['lga'],
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _darkMode ? Colors.white : prpDarkGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  (row['voters'] as int).toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: prpRed,
                  ),
                ),
                const SizedBox(width: 6),
                _buildViewWardsButton(openLga, compact: true),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
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
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.8,
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
          fontSize: 11,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              const SizedBox(width: 6),
              _buildViewWardsButton(openLga, compact: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewWardsButton(VoidCallback onTap, {bool compact = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 10,
            vertical: compact ? 5 : 6,
          ),
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.10),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: prpRed.withOpacity(0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.element_3, size: compact ? 10 : 12, color: prpRed),
              SizedBox(width: compact ? 3 : 4),
              Text(
                'View',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  color: prpRed,
                ),
              ),
              SizedBox(width: compact ? 3 : 4),
              Icon(
                Iconsax.arrow_right_3,
                size: compact ? 10 : 12,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Iconsax.tick_circle, size: 14, color: prpRed),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
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
  // PROJECTS / PILLARS (kept but not in main flow)
  // ---------------------------------------------------------------------------
  Widget _buildProjectsSection() {
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('WHAT WE WILL DO'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('Our Pillars', style: _headlineLarge())),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: prpRed,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Iconsax.arrow_right_3, color: prpRed, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (_isLoadingProjects)
            _buildShimmerEffect()
          else if (_projects.isEmpty)
            _buildEmptyState(
              icon: Iconsax.folder_open,
              message: 'No priorities available',
            )
          else
            ..._projects.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == min(5, _projects.length) - 1 ? 0 : 14,
                ),
                child: _buildProjectCard(project, index + 1),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int number) {
    return Container(
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _darkMode ? Colors.white10 : Colors.black12,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: project['color'].withOpacity(0.06),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: project['color'].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      project['icon'] ?? Iconsax.flag,
                      size: 22,
                      color: project['color'],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '0$number',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: project['color'].withOpacity(0.25),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((project['tag'] as String).isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: project['color'],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        project['tag'],
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    project['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkMode ? Colors.white : prpBlack,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project['description'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _darkMode ? Colors.white60 : prpGrey,
                      height: 1.55,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Learn more',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: project['color'],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 12,
                        color: project['color'],
                      ),
                    ],
                  ),
                ],
              ),
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
    return Container(
      color: _darkMode ? prpBlack : Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Column(
        children: [
          _sectionLabel('TESTIMONIALS'),
          const SizedBox(height: 18),
          Text('Impact Stories', style: _headlineLarge()),
          const SizedBox(height: 12),
          Text(
            'Hear from those we\'ve served in Bauchi North',
            style: _bodyLarge(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CarouselSlider(
            options: CarouselOptions(
              height: 320,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 1.6,
              autoPlayInterval: const Duration(seconds: 5),
              viewportFraction: 0.88,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
            ),
            items: _testimonials.map((t) => _buildTestimonialCard(t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : prpOffWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _darkMode ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: prpRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.format_quote,
                    color: prpRed,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 13,
                      color: i < testimonial['rating']
                          ? prpGold
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                testimonial['quote'],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _darkMode ? Colors.white70 : prpDarkGrey,
                  height: 1.6,
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
                  radius: 18,
                  backgroundColor: prpRed.withOpacity(0.12),
                  child: const Icon(Icons.person, color: prpRed, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _darkMode ? Colors.white : prpBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${testimonial['role']} • ${testimonial['location']}',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
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
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: _darkMode ? prpCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _darkMode ? Colors.white10 : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
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
            const SizedBox(height: 8),
            Text(
              'Subscribe for campaign updates, rallies and impact stories from Bauchi North.',
              style: _bodyMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            TextField(
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                hintStyle: GoogleFonts.inter(
                  color: _darkMode ? Colors.white38 : prpGrey,
                  fontSize: 13,
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
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _primaryButton('Subscribe', prpRed, () {}),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CTA
  // ---------------------------------------------------------------------------
  Widget _buildCtaSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 56,
        horizontal: _screenPadding,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpRed, prpDarkRed],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join Us in Serving\nHumanity',
            style: _headlineMedium().copyWith(
              color: Colors.white,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Partner with the Tilmeez Project For Shehu 2027 to protect dignity and restore hope '
            'for vulnerable communities across Bauchi North.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.65,
            ),
          ),
          const SizedBox(height: 22),
          _primaryButton('Get Involved', prpGold, () {}),
          const SizedBox(height: 12),
          Text(
            'Together we can make a difference',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER / EMPTY / SCROLL
  // ---------------------------------------------------------------------------
  Widget _buildShimmerEffect() {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 3 ? 0 : 14),
          child: Shimmer.fromColors(
            baseColor: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
            highlightColor: _darkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: _darkMode ? prpCharcoal : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 56,
            color: _darkMode
                ? Colors.white.withOpacity(0.6)
                : TColors.textsecondary,
          ),
          const SizedBox(height: 14),
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
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: prpRed.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: prpRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                child: const Icon(Iconsax.arrow_up_2, size: 22),
              ),
            )
          : null,
    );
  }
}
