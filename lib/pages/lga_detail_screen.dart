import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ward_detail_screen.dart';

class LgaDetailScreen extends StatefulWidget {
  final String lgaId;
  final String lgaName;
  const LgaDetailScreen({
    super.key,
    required this.lgaId,
    required this.lgaName,
  });

  @override
  State<LgaDetailScreen> createState() => _LgaDetailScreenState();
}

class _LgaDetailScreenState extends State<LgaDetailScreen> {
  final SupabaseClient _sb = Supabase.instance.client;

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
  static const Color prpBlue = Color(0xFF1E6FD9);
  static const Color prpMagenta = Color(0xFFB4267A);
  static const Color prpGreen = Color(0xFF16A34A);

  static const double _maxContentWidth = 1320.0;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  bool _loading = true;
  String? _error;
  int _currentGradientIndex = 0;
  Timer? _gradientTimer;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  Map<String, dynamic>? _coordinator;
  List<Map<String, dynamic>> _womenLeaders = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _wards = [];

  static const Map<String, Map<String, int>> _lgaSnapshot = {
    'KTG': {'voters': 188254, 'units': 384, 'wards': 12},
    'GMW': {'voters': 147996, 'units': 289, 'wards': 11},
    'ZKI': {'voters': 124366, 'units': 261, 'wards': 11},
    'ITG': {'voters': 112314, 'units': 235, 'wards': 10},
    'SHR': {'voters': 108951, 'units': 239, 'wards': 11},
    'GDE': {'voters': 73771, 'units': 145, 'wards': 10},
    'JMR': {'voters': 64880, 'units': 113, 'wards': 9},
  };

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
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
    _load();
  }

  @override
  void dispose() {
    _gradientTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _sb
            .from('lga_coordinators')
            .select('*')
            .eq('lga_id', widget.lgaId)
            .limit(1),
        _sb
            .from('lga_members')
            .select('*')
            .eq('lga_id', widget.lgaId)
            .order('position', ascending: false)
            .order('full_name'),
        _sb
            .from('wards')
            .select('id, code, name')
            .eq('lga_id', widget.lgaId)
            .order('name'),
      ]);

      final coordinatorRows = results[0] as List<dynamic>;
      final memberRows = (results[1] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final wardRows = (results[2] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      setState(() {
        _coordinator = coordinatorRows.isEmpty
            ? null
            : Map<String, dynamic>.from(coordinatorRows.first as Map);
        _womenLeaders = memberRows
            .where((m) => m['position'] == 'WOMEN_LEADER')
            .toList();
        _members = memberRows.where((m) => m['position'] == 'MEMBER').toList();
        _wards = wardRows;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // TYPOGRAPHY
  // ---------------------------------------------------------------------------
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
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

    final snapshot =
        _lgaSnapshot[widget.lgaId] ?? {'voters': 0, 'units': 0, 'wards': 0};

    String fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

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
                vertical: isMobile ? 20 : 28,
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
                          onTap: () => Navigator.of(context).pop(),
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
                          'BAUCHI NORTH · LGA PROFILE',
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
                  SizedBox(height: isMobile ? 20 : 32),
                  Text(
                    widget.lgaName,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      'Tilmeez Project 2027 — local government area structure, leadership and wards.',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 13 : 15,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 28),
                  isMobile
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _heroPill('VOTERS', fmt(snapshot['voters']!)),
                            _heroPill('WARDS', '${snapshot['wards']}'),
                            _heroPill('UNITS', '${snapshot['units']}'),
                          ],
                        )
                      : Row(
                          children: [
                            _heroPill(
                              'REGISTERED VOTERS',
                              fmt(snapshot['voters']!),
                            ),
                            const SizedBox(width: 12),
                            _heroPill('WARDS', '${snapshot['wards']}'),
                            const SizedBox(width: 12),
                            _heroPill('POLLING UNITS', '${snapshot['units']}'),
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
  // LOADING / ERROR
  // ---------------------------------------------------------------------------
  Widget _buildLoading() {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: prpRed),
            const SizedBox(height: 16),
            Text('Loading LGA data…', style: _bodyMedium()),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return _contentWrapper(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _darkMode ? prpCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: prpRed.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prpRed.withOpacity(0.12),
              ),
              child: const Icon(Iconsax.warning_2, color: prpRed, size: 26),
            ),
            const SizedBox(height: 16),
            Text('Failed to load LGA details', style: _headlineSmall()),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: _bodyMedium(),
            ),
            const SizedBox(height: 20),
            _primaryButton('Retry', prpRed, () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _load();
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------
  Widget _sectionHeader({
    required String label,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(title, style: _headlineMedium())),
            if (trailing != null) trailing,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(subtitle, style: _bodyLarge()),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LEADERSHIP BLOCK — unified premium surface
  // Coordinator LEFT (60%) / Women Leader RIGHT (40%)
  // ---------------------------------------------------------------------------
  Widget _buildLeadershipShowcase() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;

    final womenLeader = _womenLeaders.isNotEmpty ? _womenLeaders.first : null;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            label: 'LEADERSHIP',
            title: 'LGA Leadership',
            subtitle:
                'The Tilmeez Project 2027 leadership team for ${widget.lgaName}.',
          ),
          const SizedBox(height: 24),
          if (_coordinator != null)
            _coordinatorHero(_coordinator!)
          else
            _emptyNote('No coordinator assigned yet', icon: Iconsax.user),
          const SizedBox(height: 16),
          if (womenLeader != null)
            _womenLeaderPanel(womenLeader)
          else
            _emptyNote('No women leader yet', icon: Iconsax.user),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          label: 'LEADERSHIP',
          title: 'LGA Leadership',
          subtitle:
              'The Tilmeez Project 2027 leadership team for ${widget.lgaName}.',
        ),
        const SizedBox(height: 28),
        // Unified leadership surface
        Container(
          decoration: BoxDecoration(
            color: _darkMode ? prpCharcoal : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _darkMode
                  ? Colors.white10
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Coordinator — LEFT
                Expanded(
                  flex: 3,
                  child: _coordinator != null
                      ? _coordinatorHero(_coordinator!, embedded: true)
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: _emptyNote(
                            'No coordinator assigned yet',
                            icon: Iconsax.user,
                          ),
                        ),
                ),
                // Divider
                Container(
                  width: 1,
                  color: _darkMode
                      ? Colors.white10
                      : Colors.black.withOpacity(0.06),
                ),
                // Women Leader — RIGHT
                Expanded(
                  flex: 2,
                  child: womenLeader != null
                      ? _womenLeaderPanel(womenLeader, embedded: true)
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: _emptyNote(
                            'No women leader yet',
                            icon: Iconsax.user,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COORDINATOR — HERO CARD
  // ---------------------------------------------------------------------------
  Widget _coordinatorHero(Map<String, dynamic> row, {bool embedded = false}) {
    final fullName = row['full_name'] as String? ?? 'Unknown';
    final gender = row['gender'] as String? ?? '';
    final age = row['age'];
    final phone = row['phone_number'] as String? ?? '';
    final address = row['residential_address'] as String?;
    final status = row['membership_status'] as String? ?? '';
    final imageUrl = row['image_url'] as String?;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;
    final avatarSize = isMobile ? 108.0 : 140.0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner with badge
        Container(
          height: 84,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [prpRed, prpDarkRed],
            ),
            borderRadius: embedded
                ? const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(0),
                  )
                : BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: 40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prpGold.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: prpGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LGA COORDINATOR',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: prpBlack,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.crown_1, color: prpGold, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            'LEAD',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Body
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar overlapping
              Transform.translate(
                offset: const Offset(0, -46),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _darkMode ? prpCharcoal : Colors.white,
                      ),
                      child: _avatar(
                        imageUrl: imageUrl,
                        gender: gender,
                        accent: prpRed,
                        size: avatarSize,
                        isLeader: true,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _statusChip(status),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: _darkMode ? Colors.white : prpBlack,
                        letterSpacing: -0.6,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (gender.isNotEmpty) gender.toUpperCase(),
                        if (age != null) '$age YEARS',
                      ].join('  •  '),
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _darkMode ? Colors.white54 : prpGrey,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Divider(
                      height: 1,
                      color: _darkMode ? Colors.white10 : Colors.black12,
                    ),
                    const SizedBox(height: 18),
                    if (phone.isNotEmpty)
                      _coordinatorContactRow(
                        icon: Iconsax.call,
                        label: 'Direct Line',
                        value: phone,
                      ),
                    if (address != null && address.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _coordinatorContactRow(
                        icon: Iconsax.location,
                        label: 'Residential Address',
                        value: address,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (embedded) return content;

    return Container(
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: prpRed.withOpacity(0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: prpRed.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }

  Widget _coordinatorContactRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: prpRed),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _darkMode ? Colors.white54 : prpGrey,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _darkMode ? Colors.white : prpDarkGrey,
                  height: 1.4,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WOMEN LEADER — PANEL
  // ---------------------------------------------------------------------------
  Widget _womenLeaderPanel(Map<String, dynamic> row, {bool embedded = false}) {
    final fullName = row['full_name'] as String? ?? 'Unknown';
    final gender = row['gender'] as String? ?? '';
    final age = row['age'];
    final phone = row['phone_number'] as String? ?? '';
    final address = row['residential_address'] as String?;
    final status = row['membership_status'] as String? ?? '';
    final imageUrl = row['image_url'] as String?;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;
    final avatarSize = isMobile ? 88.0 : 104.0;

    final content = Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _avatar(
            imageUrl: imageUrl,
            gender: gender,
            accent: prpGold,
            size: avatarSize,
            isLeader: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: prpGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: prpGold.withOpacity(0.4)),
            ),
            child: Text(
              'WOMEN LEADER',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9A7A00),
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 17 : 19,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
              letterSpacing: -0.3,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (gender.isNotEmpty) gender.toUpperCase(),
              if (age != null) '$age YRS',
              if (status.isNotEmpty) status,
            ].join('  •  '),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white54 : prpGrey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: _darkMode ? Colors.white10 : Colors.black12,
          ),
          const SizedBox(height: 16),
          if (phone.isNotEmpty) _panelInfoRow(icon: Iconsax.call, value: phone),
          if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: 10),
            _panelInfoRow(icon: Iconsax.location, value: address, maxLines: 2),
          ],
        ],
      ),
    );

    if (embedded) return content;

    return Container(
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: prpGold.withOpacity(0.30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: prpGold.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _panelInfoRow({
    required IconData icon,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: prpGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: const Color(0xFF9A7A00)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: _darkMode ? Colors.white70 : prpDarkGrey,
                height: 1.4,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    if (status.isEmpty) return const SizedBox.shrink();
    final isActive = status.toLowerCase().contains('active');
    final color = isActive ? prpGreen : prpGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AVATAR
  // ---------------------------------------------------------------------------
  Widget _avatar({
    required String? imageUrl,
    required String gender,
    required Color accent,
    required double size,
    bool isLeader = false,
  }) {
    final g = gender.toLowerCase();
    final isFemale = g.startsWith('f');
    final isMale = g.startsWith('m');
    final IconData fallbackIcon = isFemale
        ? Iconsax.woman
        : (isMale ? Iconsax.man : Iconsax.user);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: imageUrl == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.25), accent.withOpacity(0.06)],
              )
            : null,
        border: Border.all(
          color: accent.withOpacity(0.4),
          width: isLeader ? 3 : 2,
        ),
        boxShadow: isLeader
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.20),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Icon(fallbackIcon, color: accent, size: size * 0.42)
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // MEMBERS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildMembersSection() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : (width < 1024 ? 2 : 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          label: 'TEAM',
          title: 'LGA Members',
          subtitle:
              'Members supporting the Tilmeez Project in ${widget.lgaName}.',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: prpGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: prpGold.withOpacity(0.30)),
            ),
            child: Text(
              '${_members.length} / 8',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF9A7A00),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (_members.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width < 600 ? 2.4 : 2.2,
            ),
            itemCount: _members.length,
            itemBuilder: (context, index) => _memberCard(_members[index]),
          )
        else
          _emptyNote('No members registered yet', icon: Iconsax.people),
      ],
    );
  }

  Widget _memberCard(Map<String, dynamic> row) {
    final fullName = row['full_name'] as String? ?? 'Unknown';
    final gender = row['gender'] as String? ?? '';
    final age = row['age'];
    final phone = row['phone_number'] as String? ?? '';
    final address = row['residential_address'] as String?;
    final status = row['membership_status'] as String? ?? '';
    final imageUrl = row['image_url'] as String?;

    final g = gender.toLowerCase();
    final accent = g.startsWith('f')
        ? prpMagenta
        : (g.startsWith('m') ? prpBlue : prpRed);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        hoverColor: accent.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _darkMode ? prpCharcoal : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _darkMode ? Colors.white10 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(
                imageUrl: imageUrl,
                gender: gender,
                accent: accent,
                size: 56,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _darkMode ? Colors.white : prpBlack,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: accent.withOpacity(0.30)),
                          ),
                          child: Text(
                            'MEMBER',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (gender.isNotEmpty) gender,
                        if (age != null) '$age yrs',
                        if (status.isNotEmpty) status,
                      ].join('  •  '),
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: _darkMode ? Colors.white54 : prpGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _smallContact(Iconsax.call, phone),
                    ],
                    if (address != null && address.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _smallContact(Iconsax.location, address),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallContact(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 11,
            color: _darkMode ? Colors.white38 : const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: _darkMode ? Colors.white70 : prpDarkGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WARDS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildWardsSection() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : (width < 1024 ? 2 : 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          label: 'STRUCTURE',
          title: 'Wards in ${widget.lgaName}',
          subtitle: 'Tap any ward to drill down into polling units.',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: prpRed.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: prpRed.withOpacity(0.30)),
            ),
            child: Text(
              '${_wards.length} WARDS',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: prpRed,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (_wards.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width < 600 ? 3.4 : 2.6,
            ),
            itemCount: _wards.length,
            itemBuilder: (context, index) => _wardCard(_wards[index]),
          )
        else
          _emptyNote('No wards registered', icon: Iconsax.location),
      ],
    );
  }

  Widget _wardCard(Map<String, dynamic> ward) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WardDetailScreen(
                wardId: ward['id'] as int,
                wardName: ward['name'] as String,
                wardCode: ward['code'] as String,
              ),
            ),
          );
        },
        hoverColor: prpRed.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _darkMode ? prpCharcoal : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _darkMode ? Colors.white10 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: prpRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.location, color: prpRed, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ward['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _darkMode ? Colors.white : prpBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CODE · ${ward['code']}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _darkMode ? Colors.white60 : prpGrey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: prpRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: prpRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY NOTE
  // ---------------------------------------------------------------------------
  Widget _emptyNote(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkMode ? prpCharcoal : prpOffWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _darkMode ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: prpRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: prpRed, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: _bodyMedium().copyWith(fontSize: 13)),
          ),
        ],
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
    return Scaffold(
      backgroundColor: _darkMode ? prpBlack : prpOffWhite,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          if (_loading)
            SliverToBoxAdapter(child: _buildLoading())
          else if (_error != null)
            SliverToBoxAdapter(child: _buildError())
          else ...[
            SliverToBoxAdapter(
              child: _contentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeadershipShowcase(),
                    const SizedBox(height: 64),
                    _buildMembersSection(),
                    const SizedBox(height: 64),
                    _buildWardsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
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
