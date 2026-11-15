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

class MobileMainNavigationWrapper extends StatefulWidget {
  final bool? isAdmin;
  final bool isAuthenticated;
  final SupabaseClient supabase;

  const MobileMainNavigationWrapper({
    super.key,
    required this.isAdmin,
    required this.isAuthenticated,
    required this.supabase,
  });

  @override
  State<MobileMainNavigationWrapper> createState() =>
      _MobileMainNavigationWrapperState();
}

class _MobileMainNavigationWrapperState
    extends State<MobileMainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // PRP PALETTE (identical to Desktop/Tablet)
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
  bool _isThemeDropdownOpen = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  OverlayEntry? _themeDropdownOverlay;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  int _selectedDrawerIndex = -1;

  // ---------------------------------------------------------------------------
  // PAGES (identical to Desktop/Tablet)
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
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        insetPadding: const EdgeInsets.all(16),
        child: MembershipFormDialog(supabase: widget.supabase),
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
  // THEME DROPDOWN
  // ---------------------------------------------------------------------------
  void _showThemeDropdown(RenderBox renderBox, double screenWidth) {
    _removeThemeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() => _isThemeDropdownOpen = true);

    final dropdownWidth = screenWidth * 0.5;

    _themeDropdownOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeThemeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  top: position.dy + size.height - 70,
                  width: dropdownWidth,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: Material(
                      elevation: 0,
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: THelperFunctions.isDarkMode(context)
                                  ? prpCharcoal.withOpacity(0.97)
                                  : Colors.white.withOpacity(0.97),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: THelperFunctions.isDarkMode(context)
                                    ? prpGold.withOpacity(0.18)
                                    : Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildThemeDropdownItem(
                                  'Light',
                                  Iconsax.sun_1,
                                  ThemeMode.light,
                                ),
                                _divider(),
                                _buildThemeDropdownItem(
                                  'Dark',
                                  Iconsax.moon,
                                  ThemeMode.dark,
                                ),
                                _divider(),
                                _buildThemeDropdownItem(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_themeDropdownOverlay!);
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: THelperFunctions.isDarkMode(context)
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.04),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  void _removeThemeDropdown() {
    _themeDropdownOverlay?.remove();
    _themeDropdownOverlay = null;
    if (mounted) setState(() => _isThemeDropdownOpen = false);
  }

  Widget _buildThemeDropdownItem(
    String title,
    IconData icon,
    ThemeMode themeMode,
  ) {
    final isSelected = _currentThemeMode == themeMode;
    final dark = THelperFunctions.isDarkMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _currentThemeMode = themeMode);
          _removeThemeDropdown();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? prpRed.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? prpRed.withOpacity(0.16)
                      : dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? prpRed
                      : dark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
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

  // ---------------------------------------------------------------------------
  // DRAWER ITEM
  // ---------------------------------------------------------------------------
  void _onDrawerItemTapped(int index) {
    setState(() => _selectedDrawerIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _selectedDrawerIndex = -1);
    });
  }

  Widget _createNavigationItem({
    required int index,
    required IconData icon,
    required String text,
    String? subtitle,
    required GestureTapCallback onTap,
    required bool dark,
    bool isAuthItem = false,
    bool isSignedIn = false,
  }) {
    final bool isSelected = _selectedDrawerIndex == index;
    final Color primaryColor = isAuthItem
        ? (isSignedIn ? Colors.redAccent : prpRed)
        : prpRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? primaryColor.withOpacity(0.22)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.16)
                        : dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? primaryColor
                        : dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? primaryColor
                              : dark
                              ? Colors.white
                              : Colors.black87,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: dark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Iconsax.arrow_right_3, size: 15, color: primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DRAWER
  // ---------------------------------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final session = widget.supabase.auth.currentSession;
    final firstName = session?.user?.userMetadata?['first_name'] ?? 'Guest';
    final email = session?.user?.email ?? '';
    final userInitials = session != null && firstName != 'Guest'
        ? firstName.substring(0, 1).toUpperCase()
        : 'G';

    return Drawer(
      backgroundColor: Colors.transparent,
      width: MediaQuery.of(context).size.width * 0.72,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            prpBlack.withOpacity(0.98),
                            prpCharcoal.withOpacity(0.96),
                            prpBlack.withOpacity(0.94),
                          ]
                        : [
                            prpOffWhite.withOpacity(0.98),
                            Colors.white.withOpacity(0.96),
                            prpOffWhite.withOpacity(0.94),
                          ],
                  ),
                  border: Border(
                    right: BorderSide(
                      color: dark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.04),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 24,
                      spreadRadius: 3,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // -------------------------------------------------------
                    // Header
                    // -------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: dark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.03),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Iconsax.close_circle,
                                color: dark
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Brand
                          Row(
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
                                      color: prpRed.withOpacity(0.30),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Iconsax.flag,
                                    size: 22,
                                    color: prpGold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TILMEEZ 2027',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        color: dark ? prpWhite : prpBlack,
                                      ),
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
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
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
                                        const Flexible(
                                          child: Text(
                                            'Bauchi North • For Shehu',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w500,
                                              color: prpRed,
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
                          const SizedBox(height: 18),
                          // User profile
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [prpRed, prpDarkRed],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: prpRed.withOpacity(0.25),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    userInitials,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, $firstName',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: dark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      email.isNotEmpty ? email : 'Guest User',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: dark
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.black.withOpacity(0.5),
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

                    // -------------------------------------------------------
                    // Navigation
                    // -------------------------------------------------------
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                        child: ListView(
                          children: [
                            // Section label
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 2,
                                    color: prpRed,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'NAVIGATE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: prpRed,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _createNavigationItem(
                              index: 0,
                              icon: Iconsax.home_2,
                              text: 'Home',
                              subtitle: 'Welcome to the movement',
                              onTap: () {
                                _onDrawerItemTapped(0);
                                setState(() => _currentIndex = 0);
                                Navigator.of(context).pop();
                              },
                              dark: dark,
                            ),
                            _createNavigationItem(
                              index: 1,
                              icon: Iconsax.heart_circle,
                              text: 'Priorities',
                              subtitle: 'Five pillars for Bauchi North',
                              onTap: () {
                                _onDrawerItemTapped(1);
                                setState(() => _currentIndex = 1);
                                Navigator.of(context).pop();
                              },
                              dark: dark,
                            ),
                            _createNavigationItem(
                              index: 2,
                              icon: Iconsax.chart_success,
                              text: 'Data',
                              subtitle: 'Electoral & campaign data',
                              onTap: () {
                                _onDrawerItemTapped(2);
                                setState(() => _currentIndex = 0);
                                Navigator.of(context).pop();
                              },
                              dark: dark,
                            ),
                            _createNavigationItem(
                              index: 5,
                              icon: Iconsax.info_circle,
                              text: 'Candidate',
                              subtitle: 'Shehu for Bauchi North',
                              onTap: () {
                                _onDrawerItemTapped(5);
                                setState(() => _currentIndex = 5);
                                Navigator.of(context).pop();
                              },
                              dark: dark,
                            ),

                            Divider(
                              height: 28,
                              color: dark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.04),
                              thickness: 1,
                            ),

                            // Authed-only items
                            if (widget.isAuthenticated) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 2,
                                      color: prpRed,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'YOUR ACCOUNT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: prpRed,
                                        letterSpacing: 1.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _createNavigationItem(
                                index: 3,
                                icon: Iconsax.shopping_cart,
                                text: 'Cart',
                                onTap: () {
                                  _onDrawerItemTapped(3);
                                  setState(() => _currentIndex = 2);
                                  Navigator.of(context).pop();
                                },
                                dark: dark,
                              ),
                              _createNavigationItem(
                                index: 4,
                                icon: Iconsax.profile_circle,
                                text: 'Account',
                                onTap: () {
                                  _onDrawerItemTapped(4);
                                  setState(() => _currentIndex = 3);
                                  Navigator.of(context).pop();
                                },
                                dark: dark,
                              ),
                              if (widget.isAdmin == true)
                                _createNavigationItem(
                                  index: 6,
                                  icon: Iconsax.setting_2,
                                  text: 'Admin Panel',
                                  onTap: () {
                                    _onDrawerItemTapped(6);
                                    setState(() => _currentIndex = 4);
                                    Navigator.of(context).pop();
                                  },
                                  dark: dark,
                                ),
                              const SizedBox(height: 4),
                            ],

                            Divider(
                              height: 28,
                              color: dark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.04),
                              thickness: 1,
                            ),

                            // Appearance
                            _createNavigationItem(
                              index: 7,
                              icon: _currentThemeMode == ThemeMode.light
                                  ? Iconsax.sun_1
                                  : _currentThemeMode == ThemeMode.dark
                                  ? Iconsax.moon
                                  : Iconsax.monitor,
                              text: 'Appearance',
                              subtitle: _currentThemeMode == ThemeMode.light
                                  ? 'Light'
                                  : _currentThemeMode == ThemeMode.dark
                                  ? 'Dark'
                                  : 'System',
                              onTap: () {
                                _onDrawerItemTapped(7);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final renderBox =
                                      context.findRenderObject() as RenderBox?;
                                  if (renderBox != null) {
                                    _showThemeDropdown(
                                      renderBox,
                                      MediaQuery.of(context).size.width,
                                    );
                                  }
                                });
                              },
                              dark: dark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // -------------------------------------------------------
                    // Bottom — Auth + footer
                    // -------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: dark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.03),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          _createNavigationItem(
                            index: 8,
                            icon: widget.isAuthenticated
                                ? Iconsax.logout
                                : Iconsax.user_add,
                            text: widget.isAuthenticated
                                ? 'Sign Out'
                                : 'Join Movement',
                            subtitle: widget.isAuthenticated
                                ? 'End your session'
                                : 'Register for the campaign',
                            onTap: () {
                              _onDrawerItemTapped(8);
                              if (widget.isAuthenticated) {
                                _signOut();
                              } else {
                                _showSignInDialog();
                              }
                              Navigator.of(context).pop();
                            },
                            dark: dark,
                            isAuthItem: true,
                            isSignedIn: widget.isAuthenticated,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tilmeez Project 2027 · Bauchi North © ${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: dark
                                  ? Colors.white.withOpacity(0.35)
                                  : Colors.black.withOpacity(0.35),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR TITLE
  // ---------------------------------------------------------------------------
  Widget _buildAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [prpRed, prpDarkRed],
            ),
            boxShadow: [
              BoxShadow(
                color: prpRed.withOpacity(0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Iconsax.flag, size: 18, color: prpGold),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TILMEEZ 2027',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1.2,
                  ),
                  decoration: BoxDecoration(
                    color: prpRed,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  child: const Text(
                    'PRP',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: prpWhite,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Bauchi North',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: prpRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // THEME SWITCHER (App bar)
  // ---------------------------------------------------------------------------
  Widget _buildThemeSwitcher(bool dark) {
    return Builder(
      builder: (context) {
        final key = GlobalKey();
        return GestureDetector(
          onTap: () {
            final renderBox =
                key.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              if (_isThemeDropdownOpen) {
                _removeThemeDropdown();
              } else {
                _showThemeDropdown(
                  renderBox,
                  MediaQuery.of(context).size.width,
                );
              }
            }
          },
          child: Container(
            key: key,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _isThemeDropdownOpen
                  ? prpRed.withOpacity(0.12)
                  : dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              border: Border.all(
                color: _isThemeDropdownOpen
                    ? prpRed.withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              _currentThemeMode == ThemeMode.light
                  ? Iconsax.sun_1
                  : _currentThemeMode == ThemeMode.dark
                  ? Iconsax.moon
                  : Iconsax.monitor,
              size: 18,
              color: _isThemeDropdownOpen
                  ? prpRed
                  : dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // AUTH BUTTON (App bar)
  // ---------------------------------------------------------------------------
  Widget _buildAuthButton(bool dark) {
    if (widget.isAuthenticated) {
      return GestureDetector(
        onTap: _signOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: dark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            border: Border.all(
              color: dark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.logout,
                size: 15,
                color: dark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _showSignInDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [prpRed, prpDarkRed]),
          boxShadow: [
            BoxShadow(
              color: prpRed.withOpacity(0.30),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.user_add, size: 15, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Join Movement',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: dark ? prpBlack : prpOffWhite,
        appBar: AppBar(
          automaticallyImplyLeading: _currentIndex != 0,
          leading: _currentIndex == 0
              ? null
              : IconButton(
                  icon: Icon(
                    Iconsax.arrow_left_2,
                    color: dark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    if (_currentIndex > 0) {
                      setState(() => _currentIndex = 0);
                    }
                  },
                ),
          toolbarHeight: 66,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: dark
                      ? prpBlack.withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: dark
                          ? prpGold.withOpacity(0.20)
                          : prpRed.withOpacity(0.10),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 1,
          title: _buildAppBarTitle(),
          actions: [
            _buildThemeSwitcher(dark),
            const SizedBox(width: 8),
            _buildAuthButton(dark),
            const SizedBox(width: 4),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: dark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.04),
                    ),
                    child: Icon(
                      Iconsax.menu_1,
                      size: 18,
                      color: dark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: _pages[_currentIndex],
        drawer: _buildDrawer(context),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: prpRed.withOpacity(0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const ContactUsDialog(),
            ),
            backgroundColor: prpRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: const Icon(Iconsax.message_text),
          ),
        ),
      ),
    );
  }
}
