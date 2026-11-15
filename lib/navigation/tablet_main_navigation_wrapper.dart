import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tilmeez_project_2027/pages/admin_panel.dart';
import 'package:tilmeez_project_2027/pages/priorities%20screen.dart';
import 'package:tilmeez_project_2027/widgets/customToast.dart';
import 'package:tilmeez_project_2027/widgets/membership_dialog.dart';

import '../pages/about_us_page.dart';
import '../pages/cart_screen.dart';
import '../pages/home_page.dart';
import '../pages/profile_screen.dart';
import '../utils/helpers/helper_functions.dart';
import '../widgets/contact_us_dialog.dart';

class TabletMainNavigationWrapper extends StatefulWidget {
  final bool? isAdmin;
  final bool isAuthenticated;
  final SupabaseClient supabase;

  const TabletMainNavigationWrapper({
    super.key,
    required this.isAdmin,
    required this.isAuthenticated,
    required this.supabase,
  });

  @override
  State<TabletMainNavigationWrapper> createState() =>
      _TabletMainNavigationWrapperState();
}

class _TabletMainNavigationWrapperState
    extends State<TabletMainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // PRP PALETTE (identical to Desktop)
  // ---------------------------------------------------------------------------
  static const Color prpRed = Color(0xFFC8102E);
  static const Color prpDarkRed = Color(0xFF9E0B22);
  static const Color prpGold = Color(0xFFF5C518);
  static const Color prpBlack = Color(0xFF111111);
  static const Color prpCharcoal = Color(0xFF1E1E1E);
  static const Color prpWhite = Colors.white;
  static const Color prpOffWhite = Color(0xFFF9F7F4);
  static const Color prpGrey = Color(0xFF6B7280);

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final Map<String, bool> _dropdownOpenStates = {};
  bool _isThemeDropdownOpen = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  OverlayEntry? _dropdownOverlay;
  OverlayEntry? _themeDropdownOverlay;
  String? _currentDropdown;

  late AnimationController _scrollAnimationController;
  late Animation<double> _scrollAnimation;

  // ---------------------------------------------------------------------------
  // PAGES (identical to Desktop)
  // ---------------------------------------------------------------------------
  final List<Widget> _pages = const [
    HomePage(),
    PrioritiesScreen(),
    CartScreen(),
    ProfileScreen(),
    AdminPanel(),
    AboutUsScreen(),
  ];

  // ---------------------------------------------------------------------------
  // NAV ITEMS (identical to Desktop)
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _navItems = [
    {'label': 'Home', 'icon': Iconsax.home_2, 'index': 0, 'hasDropdown': true},
    {
      'label': 'Priorities',
      'icon': Iconsax.heart_circle,
      'index': 1,
      'hasDropdown': true,
    },
    {
      'label': 'Data',
      'icon': Iconsax.chart_success,
      'index': 0,
      'hasDropdown': false,
    },
    {
      'label': 'Candidate',
      'icon': Iconsax.info_circle,
      'index': 5,
      'hasDropdown': true,
    },
  ];

  // ---------------------------------------------------------------------------
  // MEGA MENU (identical to Desktop)
  // ---------------------------------------------------------------------------
  final Map<String, List<Map<String, dynamic>>> _megaMenuItems = {
    'Home': [
      {
        'title': 'Welcome',
        'subtitle': 'Tilmeez Project 2027 for Shehu',
        'icon': Iconsax.heart,
        'color': prpRed,
        'action': 'navigate',
        'index': 0,
      },
      {
        'title': 'Latest News',
        'subtitle': 'Campaign updates from Bauchi North',
        'icon': Iconsax.note_2,
        'color': const Color(0xFF1E6FD9),
        'action': 'navigate',
        'index': 0,
      },
      {
        'title': 'Events',
        'subtitle': 'Rallies, outreaches & town halls',
        'icon': Iconsax.calendar_2,
        'color': prpGold,
        'action': 'navigate',
        'index': 0,
      },
    ],
    'Priorities': [
      {
        'title': 'Healthcare',
        'subtitle': 'Free medical outreach & surgeries',
        'icon': Iconsax.health,
        'color': prpRed,
        'action': 'navigate',
        'index': 1,
      },
      {
        'title': 'Education',
        'subtitle': 'Scholarships & school refurbishment',
        'icon': Iconsax.book,
        'color': prpDarkRed,
        'action': 'navigate',
        'index': 1,
      },
      {
        'title': 'Water & Sanitation',
        'subtitle': 'Boreholes & toilet facilities',
        'icon': Iconsax.drop,
        'color': const Color(0xFF1E6FD9),
        'action': 'navigate',
        'index': 1,
      },
      {
        'title': 'Clean Energy',
        'subtitle': 'Solar power for mosques & centres',
        'icon': Iconsax.sun,
        'color': prpGold,
        'action': 'navigate',
        'index': 1,
      },
      {
        'title': 'Social Inclusion',
        'subtitle': 'Disability support & infrastructure',
        'icon': Iconsax.people,
        'color': const Color(0xFF8E44AD),
        'action': 'navigate',
        'index': 1,
      },
    ],
    'Candidate': [
      {
        'title': 'Who Is Shehu',
        'subtitle': 'Meet the PRP flag-bearer',
        'icon': Iconsax.people,
        'color': prpRed,
        'action': 'navigate',
        'index': 5,
      },
      {
        'title': 'Campaign Council',
        'subtitle': 'Patrons, BOT & leadership',
        'icon': Iconsax.profile_2user,
        'color': prpBlack,
        'action': 'navigate',
        'index': 5,
      },
      {
        'title': 'Our Partners',
        'subtitle': 'Organisations supporting the movement',
        'icon': Iconsax.briefcase,
        'color': const Color(0xFF0FA958),
        'action': 'navigate',
        'index': 5,
      },
      {
        'title': 'Core Values',
        'subtitle': 'Compassion, accountability, inclusion',
        'icon': Iconsax.heart,
        'color': prpGold,
        'action': 'navigate',
        'index': 5,
      },
    ],
  };

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scrollAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _scrollAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _removeDropdown();
    _removeThemeDropdown();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------
  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: MembershipFormDialog(supabase: widget.supabase),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await widget.supabase.auth.signOut();
      setState(() => _currentIndex = 0);
      CustomToast.success(context, 'Signed out successfully');
    } catch (e) {
      CustomToast.error(context, 'Sign-out failed');
    }
  }

  // ---------------------------------------------------------------------------
  // MEGA MENU OVERLAY
  // ---------------------------------------------------------------------------
  void _showMegaMenu(String label, RenderBox renderBox, double screenWidth) {
    _removeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _dropdownOpenStates[label] = true;
      _currentDropdown = label;
    });

    // Tablet-tuned overlay width
    final dropdownWidth = screenWidth < 900 ? screenWidth * 0.9 : 560.0;
    final leftPosition = (position.dx + dropdownWidth > screenWidth)
        ? screenWidth - dropdownWidth - 20
        : position.dx;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: leftPosition,
        top: position.dy + size.height + 10,
        width: dropdownWidth,
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 180),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -16 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: THelperFunctions.isDarkMode(context)
                    ? prpCharcoal.withOpacity(0.98)
                    : Colors.white.withOpacity(0.98),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: THelperFunctions.isDarkMode(context)
                      ? prpGold.withOpacity(0.18)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: _buildMegaMenuContent(label),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  Widget _buildMegaMenuContent(String label) {
    final items = _megaMenuItems[label] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: prpRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getNavIcon(label), size: 18, color: prpRed),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const Spacer(),
            if (label == 'Priorities')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: prpGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: prpGold.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.global, size: 12, color: prpGold),
                    const SizedBox(width: 5),
                    Text(
                      'UN SDG Aligned',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: prpGold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: label == 'Priorities' ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: label == 'Priorities' ? 5.4 : 3.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildMegaMenuItem(items[index]),
        ),
      ],
    );
  }

  Widget _buildMegaMenuItem(Map<String, dynamic> item) {
    final dark = THelperFunctions.isDarkMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item['action'] == 'navigate') {
            _removeDropdown();
            setState(() => _currentIndex = item['index']);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: dark
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.02),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 20,
                  color: item['color'] as Color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dark ? Colors.white : Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: dark
                            ? Colors.white.withOpacity(0.55)
                            : Colors.black.withOpacity(0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Iconsax.arrow_right_3,
                size: 14,
                color: dark
                    ? Colors.white.withOpacity(0.35)
                    : Colors.black.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNavIcon(String label) {
    switch (label) {
      case 'Home':
        return Iconsax.home_2;
      case 'Priorities':
        return Iconsax.heart_circle;
      case 'Candidate':
      case 'The Candidate':
        return Iconsax.info_circle;
      default:
        return Iconsax.category;
    }
  }

  // ---------------------------------------------------------------------------
  // THEME DROPDOWN
  // ---------------------------------------------------------------------------
  void _showThemeDropdown(RenderBox renderBox, double screenWidth) {
    _removeDropdown();
    _removeThemeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() => _isThemeDropdownOpen = true);

    _themeDropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        right: MediaQuery.of(context).size.width - position.dx - size.width,
        top: position.dy + size.height + 10,
        width: 190,
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: THelperFunctions.isDarkMode(context)
                  ? prpCharcoal
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: THelperFunctions.isDarkMode(context)
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption('Light', Iconsax.sun_1, ThemeMode.light),
                  _buildThemeOption('Dark', Iconsax.moon, ThemeMode.dark),
                  _buildThemeOption(
                    'System',
                    Iconsax.monitor,
                    ThemeMode.system,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_themeDropdownOverlay!);
  }

  Widget _buildThemeOption(String title, IconData icon, ThemeMode mode) {
    final isSelected = _currentThemeMode == mode;
    final dark = THelperFunctions.isDarkMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentThemeMode = mode;
            _isThemeDropdownOpen = false;
          });
          _removeThemeDropdown();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? prpRed.withOpacity(0.08) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? prpRed
                    : dark
                    ? Colors.white70
                    : Colors.black54,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? prpRed
                        : dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Iconsax.tick_circle, size: 16, color: prpRed),
            ],
          ),
        ),
      ),
    );
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    _currentDropdown = null;
    if (mounted) setState(() => _dropdownOpenStates.clear());
  }

  void _removeThemeDropdown() {
    _themeDropdownOverlay?.remove();
    _themeDropdownOverlay = null;
    if (mounted) setState(() => _isThemeDropdownOpen = false);
  }

  // ---------------------------------------------------------------------------
  // NAV BAR — tablet-tuned
  // ---------------------------------------------------------------------------
  Widget _buildModernNavBar(bool dark, double screenWidth) {
    // Tablet breakpoints: compact < 900, veryCompact < 760
    final compact = screenWidth < 900;
    final veryCompact = screenWidth < 760;
    final horizontalPad = compact ? 20.0 : 32.0;

    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
      decoration: BoxDecoration(
        color: dark
            ? prpBlack.withOpacity(0.96)
            : Colors.white.withOpacity(0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: dark ? prpGold.withOpacity(0.25) : prpRed.withOpacity(0.12),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------------
          // LOGO
          // ---------------------------------------------------------------
          InkWell(
            onTap: () => setState(() => _currentIndex = 0),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [prpRed, prpDarkRed],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: prpRed.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Iconsax.flag, size: 22, color: prpGold),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compact ? 'TILMEEZ 2027' : 'TILMEEZ PROJECT 2027',
                        style: TextStyle(
                          fontSize: compact ? 13 : 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: dark ? prpWhite : prpBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
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
                            child: const Text(
                              'PRP',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: prpWhite,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              veryCompact
                                  ? 'Bauchi North'
                                  : 'Bauchi North • For Shehu',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: prpRed,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          // ---------------------------------------------------------------
          // NAV LINKS
          // ---------------------------------------------------------------
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _navItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildNavItem(
                          item['label'],
                          item['icon'],
                          item['index'],
                          hasDropdown: item['hasDropdown'] ?? false,
                          dark: dark,
                          compact: compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          // ---------------------------------------------------------------
          // ACTION BUTTONS
          // ---------------------------------------------------------------
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme toggle
              Builder(
                builder: (context) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final renderBox =
                            context.findRenderObject() as RenderBox;
                        if (_isThemeDropdownOpen) {
                          _removeThemeDropdown();
                        } else {
                          _showThemeDropdown(
                            renderBox,
                            MediaQuery.of(context).size.width,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: dark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04),
                          border: Border.all(
                            color: dark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Icon(
                          _currentThemeMode == ThemeMode.light
                              ? Iconsax.sun_1
                              : _currentThemeMode == ThemeMode.dark
                              ? Iconsax.moon
                              : Iconsax.monitor,
                          size: 18,
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              // Auth button — compact on narrow tablets
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigation intentionally disabled for "Join Movement".
                    // Uncomment the line below to restore the original behaviour:
                    // widget.isAuthenticated ? _signOut() : _showSignInDialog();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: veryCompact ? 12 : 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: widget.isAuthenticated
                            ? [Colors.grey.shade700, Colors.grey.shade600]
                            : [prpRed, prpDarkRed],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isAuthenticated ? Colors.grey : prpRed)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isAuthenticated
                              ? Iconsax.logout
                              : Iconsax.user_add,
                          size: 16,
                          color: Colors.white,
                        ),
                        if (!veryCompact) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.isAuthenticated ? 'Logout' : 'Join Movement',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon,
    int index, {
    bool hasDropdown = false,
    required bool dark,
    bool compact = false,
  }) {
    final isSelected = _currentIndex == index;
    final isHovered = _currentDropdown == label;

    return Builder(
      builder: (context) {
        return MouseRegion(
          onEnter: hasDropdown
              ? (_) {
                  final renderBox = context.findRenderObject() as RenderBox;
                  _showMegaMenu(
                    label,
                    renderBox,
                    MediaQuery.of(context).size.width,
                  );
                }
              : null,
          onExit: hasDropdown
              ? (_) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (_currentDropdown == label) {
                      _removeDropdown();
                    }
                  });
                }
              : null,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _removeDropdown();
                setState(() => _currentIndex = index);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 9 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected
                      ? prpRed.withOpacity(0.10)
                      : isHovered
                      ? (dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03))
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected
                          ? prpRed
                          : isHovered
                          ? (dark ? Colors.white : prpBlack)
                          : (dark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: compact ? 12 : 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? prpRed
                            : isHovered
                            ? (dark ? Colors.white : prpBlack)
                            : (dark ? Colors.white : Colors.black87),
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (hasDropdown) ...[
                      const SizedBox(width: 3),
                      Icon(
                        Iconsax.arrow_down_1,
                        size: 11,
                        color: isSelected
                            ? prpRed
                            : (dark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: prpRed,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: prpRed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _currentThemeMode,
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () {
          _removeDropdown();
          _removeThemeDropdown();
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: dark ? prpBlack : prpOffWhite,
          extendBody: true,
          body: Column(
            children: [
              _buildModernNavBar(dark, screenWidth),
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: prpRed.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const ContactUsDialog(),
              ),
              backgroundColor: prpRed,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.message_text),
              label: const Text('Contact Us'),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
