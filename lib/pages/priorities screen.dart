import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants/colors.dart';
import '../widgets/customToast.dart';

class PrioritiesScreen extends StatefulWidget {
  const PrioritiesScreen({super.key});

  @override
  State<PrioritiesScreen> createState() => _PrioritiesScreenState();
}

class _PrioritiesScreenState extends State<PrioritiesScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // PRP PALETTE
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

  static const double _maxContentWidth = 1320.0;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _priorities = [];
  bool _isLoading = true;
  String _activeFilter = 'All';
  int _currentGradientIndex = 0;
  Timer? _gradientTimer;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filters = [
    'All',
    'Healthcare',
    'Education',
    'Water & Sanitation',
    'Clean Energy',
    'Social Inclusion',
  ];

  // ---------------------------------------------------------------------------
  // FALLBACK PRIORITIES DATA (mirrors DesktopHomePage campaign pillars)
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _prioritiesData = [
    {
      'title': 'Healthcare Initiatives',
      'subtitle': 'Free Medical Outreach & Funded Surgeries',
      'description':
          'Our healthcare pillar delivers free medical consultations, malaria treatment, and funds surgical interventions for oncology, cardiology, and orthopedic patients across the seven LGAs of Bauchi North. We also run community fumigation and health awareness campaigns to prevent disease outbreaks.',
      'icon': Iconsax.health,
      'color': prpRed,
      'sdg': 'SDG 3',
      'category': 'Healthcare',
      'stats': {
        'beneficiaries': '500+',
        'surgeries': '50+',
        'outreaches': '20+',
      },
      'features': [
        'Free medical consultations',
        'Surgical intervention funding',
        'Community fumigation programs',
        'Health awareness campaigns',
        'Malaria prevention and treatment',
      ],
    },
    {
      'title': 'Education Endowment',
      'subtitle': 'Scholarships & School Development',
      'description':
          'We believe education is the foundation for sustainable development. Our education pillar offers medical and nursing scholarships, sponsors orphan education, and refurbishes dilapidated school facilities to create conducive learning environments across Bauchi North.',
      'icon': Iconsax.book,
      'color': prpDarkRed,
      'sdg': 'SDG 4',
      'category': 'Education',
      'stats': {'scholarships': '200+', 'schools': '15+', 'students': '840+'},
      'features': [
        'Medical & nursing scholarships',
        'Orphan sponsorship programs',
        'School facility refurbishment',
        'Educational materials provision',
        'Teacher support programs',
      ],
    },
    {
      'title': 'Water & Sanitation',
      'subtitle': 'Clean Water & Hygiene Facilities',
      'description':
          'Access to clean water is a fundamental human right. We construct and repair boreholes in communities and provide clean toilet facilities for schools, significantly improving hygiene standards and reducing waterborne diseases across the district.',
      'icon': Iconsax.drop,
      'color': const Color(0xFF1E6FD9),
      'sdg': 'SDG 6',
      'category': 'Water & Sanitation',
      'stats': {'boreholes': '30+', 'toilets': '50+', 'communities': '25+'},
      'features': [
        'Borehole construction & repair',
        'School toilet facilities',
        'Hygiene education programs',
        'Water quality testing',
        'Community maintenance training',
      ],
    },
    {
      'title': 'Clean Energy',
      'subtitle': 'Affordable Solar Power Installations',
      'description':
          'Promoting sustainable energy use, we install solar power systems for mosques and community centers. This initiative ensures reliable electricity for essential services and reduces dependence on fossil fuels.',
      'icon': Iconsax.sun,
      'color': prpGold,
      'sdg': 'SDG 7',
      'category': 'Clean Energy',
      'stats': {'installations': '15+', 'mosques': '10+', 'centers': '5+'},
      'features': [
        'Solar panel installations',
        'Community center electrification',
        'Mosque solar power systems',
        'Renewable energy advocacy',
        'Maintenance and support',
      ],
    },
    {
      'title': 'Social Inclusion',
      'subtitle': 'Disability Support & Infrastructure',
      'description':
          'We empower persons with disabilities through the provision of tricycle wheelchairs and assist in community infrastructure repairs. Our programs ensure that marginalized groups are fully included in development across Bauchi North.',
      'icon': Iconsax.people,
      'color': const Color(0xFF8E44AD),
      'sdg': 'SDG 10 & 11',
      'category': 'Social Inclusion',
      'stats': {
        'wheelchairs': '100+',
        'infrastructures': '20+',
        'beneficiaries': '300+',
      },
      'features': [
        'Tricycle wheelchair provision',
        'Infrastructure repairs',
        'Disability advocacy programs',
        'Community inclusion initiatives',
        'Support for marginalized groups',
      ],
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

    _gradientTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) {
        setState(() => _currentGradientIndex = (_currentGradientIndex + 1) % 3);
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });

    _fetchPriorities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradientTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // DATA LOAD
  // ---------------------------------------------------------------------------
  Future<void> _fetchPriorities() async {
    try {
      final response = await _supabase
          .from('programs')
          .select('*')
          .order('created_at');

      if (mounted) {
        setState(() {
          if (response.isNotEmpty) {
            _priorities = List<Map<String, dynamic>>.from(
              response,
            ).map(_parsePriority).toList();
          } else {
            _priorities = _prioritiesData;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _priorities = _prioritiesData;
          _isLoading = false;
        });
      }
      debugPrint('Error fetching priorities: $e');
    }
  }

  Map<String, dynamic> _parsePriority(Map<String, dynamic> row) {
    return {
      'title': row['title'] ?? 'Untitled Priority',
      'subtitle': row['subtitle'] ?? 'Campaign Pillar',
      'description': row['description'] ?? '',
      'icon': _iconFor(row['category'] ?? row['title'] ?? ''),
      'color': _colorFor(row['category'] ?? row['title'] ?? ''),
      'sdg': row['sdg'] ?? '',
      'category': row['category'] ?? 'Other',
      'stats': row['stats'] is Map ? row['stats'] : <String, dynamic>{},
      'features': (row['features'] as List?)?.cast<String>() ?? <String>[],
    };
  }

  IconData _iconFor(String s) {
    final t = s.toLowerCase();
    if (t.contains('health') || t.contains('medical')) return Iconsax.health;
    if (t.contains('education')) return Iconsax.book;
    if (t.contains('water')) return Iconsax.drop;
    if (t.contains('energy') || t.contains('solar')) return Iconsax.sun;
    if (t.contains('social') || t.contains('inclusion')) return Iconsax.people;
    return Iconsax.flag;
  }

  Color _colorFor(String s) {
    final t = s.toLowerCase();
    if (t.contains('health') || t.contains('medical')) return prpRed;
    if (t.contains('education')) return prpDarkRed;
    if (t.contains('water')) return const Color(0xFF1E6FD9);
    if (t.contains('energy') || t.contains('solar')) return prpGold;
    if (t.contains('social') || t.contains('inclusion')) {
      return const Color(0xFF8E44AD);
    }
    return prpRed;
  }

  List<Map<String, dynamic>> _getFilteredPriorities() {
    if (_activeFilter == 'All') return _priorities;
    return _priorities.where((p) => p['category'] == _activeFilter).toList();
  }

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  TextStyle _headlineMedium() => GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.2,
    letterSpacing: -0.8,
  );

  TextStyle _headlineSmall() => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: _darkMode ? prpWhite : prpBlack,
    height: 1.3,
    letterSpacing: -0.4,
  );

  TextStyle _bodyLarge() => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.65,
  );

  TextStyle _bodyMedium() => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: _darkMode ? const Color(0xFFD1D5DB) : prpGrey,
    height: 1.55,
  );

  // ---------------------------------------------------------------------------
  // SHARED WIDGETS
  // ---------------------------------------------------------------------------
  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 18, height: 2, color: prpRed),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: prpRed,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }

  Widget _contentWrapper({required Widget child, EdgeInsets? padding}) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width < 600 ? 20.0 : (width < 1024 ? 40.0 : 80.0);
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(vertical: 72, horizontal: horizontal),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: child,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
              const SizedBox(width: 8),
              const Icon(Iconsax.arrow_right_3, color: Colors.white, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader() {
    final gradients = [
      [prpBlack, const Color(0xFF2A060C), prpRed],
      [prpBlack, prpDarkRed, const Color(0xFF7A0A1A)],
      [const Color(0xFF1A1A1A), prpRed, prpDarkRed],
    ];
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients[_currentGradientIndex],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -160,
              right: -140,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: prpGold.withOpacity(0.08),
                    width: 2,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: prpRed.withOpacity(0.15),
                ),
              ),
            ),
            _contentWrapper(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 32 : 48,
                horizontal: isMobile ? 20 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Icon(
                              Iconsax.arrow_left_2,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: prpWhite,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TILMEEZ 2027 · OUR PRIORITIES',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 9.5 : 11,
                            fontWeight: FontWeight.w600,
                            color: prpGold,
                            letterSpacing: 1.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 28 : 40),
                  Text(
                    'Five Pillars\nfor Bauchi North',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 34 : 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      'Aligned with the needs of all seven LGAs and the UN Sustainable Development Goals — '
                      'our priorities for a compassionate, inclusive and dignified Bauchi North.',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 13 : 15,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.65,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 32),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _heroPill('PRIORITIES', '${_priorities.length}'),
                      _heroPill('LGAs COVERED', '7'),
                      _heroPill('UN SDGs', '6'),
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

  Widget _heroPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: prpGold.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: prpGold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER SECTION
  // ---------------------------------------------------------------------------
  Widget _buildFilterSection() {
    final filteredCount = _getFilteredPriorities().length;
    return Container(
      color: _darkMode ? prpBlack : prpOffWhite,
      child: _contentWrapper(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width < 600 ? 20 : 28,
          horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _filters.map((filter) {
                  final isActive = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _activeFilter = filter),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? prpRed
                                : (_darkMode
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? prpRed
                                  : (_darkMode
                                        ? Colors.white10
                                        : Colors.black12),
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: prpRed.withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : (_darkMode ? Colors.white70 : prpDarkGrey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$filteredCount '
              'priorit${filteredCount == 1 ? 'y' : 'ies'} found',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: _darkMode ? Colors.white54 : prpGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRIORITY CARD
  // ---------------------------------------------------------------------------
  Widget _buildPriorityCard(Map<String, dynamic> priority, int index) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final accent = priority['color'] as Color;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: _darkMode ? prpCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _darkMode ? Colors.white10 : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              height: isMobile ? 200 : 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent.withOpacity(0.65)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: isMobile ? 96 : 120,
                      height: isMobile ? 96 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.30),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        priority['icon'] as IconData,
                        size: isMobile ? 44 : 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if ((priority['sdg'] as String).isNotEmpty)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                          ),
                        ),
                        child: Text(
                          priority['sdg'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (priority['category'] as String).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priority['title'],
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 20 : 26,
                      fontWeight: FontWeight.w800,
                      color: _darkMode ? Colors.white : prpBlack,
                      letterSpacing: -0.6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priority['subtitle'],
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(priority['description'], style: _bodyLarge()),
                  const SizedBox(height: 24),
                  if ((priority['stats'] as Map).isNotEmpty) ...[
                    _buildStatsRow(priority['stats'] as Map, accent),
                    const SizedBox(height: 26),
                  ],
                  Text(
                    'Key Focus Areas',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkMode ? Colors.white : prpBlack,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...(priority['features'] as List<String>).map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.10),
                            ),
                            child: Icon(
                              Iconsax.tick_circle,
                              size: 15,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                height: 1.5,
                                color: _darkMode ? Colors.white70 : prpDarkGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: _primaryButton('Support This Priority', accent, () {
                      CustomToast.success(
                        context,
                        'Learn more about ${priority['title']}',
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map stats, Color accent) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: _darkMode ? Colors.white.withOpacity(0.03) : prpOffWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _darkMode ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.entries.map<Widget>((stat) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  '${stat.value}',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  stat.key.toString().replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _darkMode ? Colors.white54 : prpGrey,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER / EMPTY / CTA
  // ---------------------------------------------------------------------------
  Widget _buildShimmerGrid() {
    return _contentWrapper(
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Shimmer.fromColors(
              baseColor: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
              highlightColor: _darkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: _darkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return _contentWrapper(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _darkMode ? Colors.white.withOpacity(0.05) : prpOffWhite,
              border: Border.all(
                color: _darkMode ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Icon(
              Iconsax.folder_open,
              size: 44,
              color: _darkMode ? Colors.white54 : prpGrey,
            ),
          ),
          const SizedBox(height: 24),
          Text('No priorities found', style: _headlineSmall()),
          const SizedBox(height: 8),
          Text('Try selecting a different category', style: _bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildCtaSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpRed, prpDarkRed],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: prpRed.withOpacity(0.30),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.14),
              ),
              child: const Icon(Iconsax.heart, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 22),
            Text(
              'Want to Support Our Priorities?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 22 : 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.6,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                'Your support can help us deliver on the Tilmeez Project 2027 agenda and '
                'make a lasting impact across Bauchi North.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.white.withOpacity(0.90),
                  height: 1.65,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Donate Now',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: prpRed,
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Partner With Us',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
    final filtered = _getFilteredPriorities();
    final width = MediaQuery.of(context).size.width;
    final horizontal = width < 600 ? 20.0 : (width < 1024 ? 40.0 : 80.0);

    return Scaffold(
      backgroundColor: _darkMode ? prpBlack : prpOffWhite,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          SliverToBoxAdapter(child: _buildFilterSection()),
          if (_isLoading)
            SliverToBoxAdapter(child: _buildShimmerGrid())
          else if (filtered.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildPriorityCard(filtered[index], index),
                  childCount: filtered.length,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: _buildCtaSection(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: prpRed.withOpacity(0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
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
