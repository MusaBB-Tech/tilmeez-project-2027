import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// ENTRY SCREEN — one screen for LGA / Ward / PU management
// =============================================================================
class LeadershipManagementScreen extends StatefulWidget {
  /// Which level to manage: 'LGA', 'WARD', or 'PU'
  final String level;

  /// Required based on level:
  /// - LGA: lgaId + lgaName
  /// - WARD: wardId + wardName (+ optional lgaName for breadcrumb)
  /// - PU: puId + puName (+ optional wardName for breadcrumb)
  final String? lgaId;
  final String? lgaName;
  final int? wardId;
  final String? wardName;
  final int? puId;
  final String? puName;

  const LeadershipManagementScreen({
    super.key,
    required this.level,
    this.lgaId,
    this.lgaName,
    this.wardId,
    this.wardName,
    this.puId,
    this.puName,
  });

  @override
  State<LeadershipManagementScreen> createState() =>
      _LeadershipManagementScreenState();
}

class _LeadershipManagementScreenState
    extends State<LeadershipManagementScreen> {
  final SupabaseClient _sb = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // PRP PALETTE
  // ---------------------------------------------------------------------------
  static const Color prpRed = Color(0xFFC8102E);
  static const Color prpGold = Color(0xFFF5C518);
  static const Color prpBlack = Color(0xFF111111);
  static const Color prpOffWhite = Color(0xFFF9F7F4);
  static const Color prpGoldText = Color(0xFF9A7A00);
  static const Color prpMagenta = Color(0xFFB4267A);
  static const Color prpBlue = Color(0xFF1E6FD9);

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _coordinator;
  Map<String, dynamic>? _womenLeader;
  List<Map<String, dynamic>> _members = [];

  // ---------------------------------------------------------------------------
  // CONFIG DERIVED FROM LEVEL
  // ---------------------------------------------------------------------------
  String get _table {
    switch (widget.level) {
      case 'LGA':
        return 'lga_members';
      case 'WARD':
        return 'wrd_members';
      default:
        return 'pu_members';
    }
  }

  String get _fkColumn {
    switch (widget.level) {
      case 'LGA':
        return 'lga_id';
      case 'WARD':
        return 'ward_id';
      default:
        return 'polling_unit_id';
    }
  }

  dynamic get _fkValue {
    switch (widget.level) {
      case 'LGA':
        return widget.lgaId;
      case 'WARD':
        return widget.wardId;
      default:
        return widget.puId;
    }
  }

  int get _maxMembers {
    switch (widget.level) {
      case 'LGA':
        return 8;
      case 'WARD':
        return 5;
      default:
        return 13;
    }
  }

  String get _titleName {
    switch (widget.level) {
      case 'LGA':
        return widget.lgaName ?? 'LGA';
      case 'WARD':
        return widget.wardName ?? 'Ward';
      default:
        return widget.puName ?? 'Polling Unit';
    }
  }

  String get _levelLabel {
    switch (widget.level) {
      case 'LGA':
        return 'LGA';
      case 'WARD':
        return 'WARD';
      default:
        return 'POLLING UNIT';
    }
  }

  // Suffix used to build position type strings e.g. 'LGA_COORDINATOR'
  String _posType(String kind) => '${widget.level}_$kind';

  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _sb
          .from(_table)
          .select('*')
          .eq(_fkColumn, _fkValue)
          .order('position', ascending: false)
          .order('full_name');

      final list = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final coord = list.where((m) => m['position'] == 'COORDINATOR').toList();
      final women = list.where((m) => m['position'] == 'WOMEN_LEADER').toList();

      setState(() {
        _coordinator = coord.isNotEmpty ? coord.first : null;
        _womenLeader = women.isNotEmpty ? women.first : null;
        _members = list.where((m) => m['position'] == 'MEMBER').toList();
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
  // FORM DIALOG (inline) — Add / Edit
  // ---------------------------------------------------------------------------
  Future<void> _openForm({
    required String position, // 'COORDINATOR' | 'WOMEN_LEADER' | 'MEMBER'
    Map<String, dynamic>? existing,
  }) async {
    // Guard single-instance roles
    if (existing == null) {
      if (position == 'COORDINATOR' && _coordinator != null) {
        _snack('A coordinator already exists. Edit or delete it first.');
        return;
      }
      if (position == 'WOMEN_LEADER' && _womenLeader != null) {
        _snack('A women leader already exists. Edit or delete it first.');
        return;
      }
      if (position == 'MEMBER' && _members.length >= _maxMembers) {
        _snack('Maximum of $_maxMembers members reached.');
        return;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MemberFormDialog(
        position: position,
        existing: existing,
        table: _table,
        fkColumn: _fkColumn,
        fkValue: _fkValue,
        levelLabel: _levelLabel,
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(Map<String, dynamic> row, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: prpRed.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: prpRed, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete $label',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${row['full_name']}? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: prpRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _sb.from(_table).delete().eq('id', row['id']);
      _snack('$label deleted');
      _load();
    } catch (e) {
      _snack('Delete failed: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: prpBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? prpBlack : prpOffWhite,
      appBar: _appBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: prpRed))
          : _error != null
          ? _errorView()
          : _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left_2),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage $_levelLabel',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkMode ? Colors.white : prpBlack,
            ),
          ),
          Text(
            _titleName.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: prpRed,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _load,
          icon: Icon(
            Iconsax.refresh,
            color: _darkMode ? Colors.white : prpBlack,
          ),
        ),
      ],
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, color: prpRed, size: 40),
            const SizedBox(height: 12),
            Text('Failed to load', style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(backgroundColor: prpRed),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width < 600 ? 16.0 : (width < 1024 ? 32.0 : 64.0);

    return RefreshIndicator(
      onRefresh: _load,
      color: prpRed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('LEADERSHIP'),
                const SizedBox(height: 14),
                _leaderSlotCard(
                  title: '$_levelLabel Coordinator',
                  subtitle: 'One coordinator per $_levelLabel',
                  leader: _coordinator,
                  icon: Iconsax.crown_1,
                  accent: prpRed,
                  onAdd: () => _openForm(position: 'COORDINATOR'),
                  onEdit: () => _openForm(
                    position: 'COORDINATOR',
                    existing: _coordinator,
                  ),
                  onDelete: () => _delete(_coordinator!, 'Coordinator'),
                ),
                const SizedBox(height: 14),
                _leaderSlotCard(
                  title: '$_levelLabel Women Leader',
                  subtitle: 'One women leader per $_levelLabel',
                  leader: _womenLeader,
                  icon: Iconsax.woman,
                  accent: prpGoldText,
                  onAdd: () => _openForm(position: 'WOMEN_LEADER'),
                  onEdit: () => _openForm(
                    position: 'WOMEN_LEADER',
                    existing: _womenLeader,
                  ),
                  onDelete: () => _delete(_womenLeader!, 'Women Leader'),
                ),
                const SizedBox(height: 32),
                _sectionTitle(
                  'MEMBERS',
                  trailing: _countBadge('${_members.length}/$_maxMembers'),
                ),
                const SizedBox(height: 14),
                if (_members.isEmpty)
                  _emptyMembersCard()
                else
                  ..._members.map(_memberRow),
                const SizedBox(height: 12),
                if (_members.length < _maxMembers) _addMemberButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------
  Widget _sectionTitle(String t, {Widget? trailing}) => Row(
    children: [
      Container(width: 18, height: 2, color: prpRed),
      const SizedBox(width: 8),
      Text(
        t,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: prpRed,
          letterSpacing: 2.2,
        ),
      ),
      const Spacer(),
      if (trailing != null) trailing,
    ],
  );

  Widget _countBadge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: prpGold.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: prpGold.withOpacity(0.4)),
    ),
    child: Text(
      t,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: prpGoldText,
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // LEADER SLOT CARD
  // ---------------------------------------------------------------------------
  Widget _leaderSlotCard({
    required String title,
    required String subtitle,
    required Map<String, dynamic>? leader,
    required VoidCallback onAdd,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required Color accent,
    required IconData icon,
  }) {
    final isDark = _darkMode;
    final hasLeader = leader != null;
    final name = leader?['full_name'] as String? ?? '';
    final phone = leader?['phone_number'] as String? ?? '';
    final gender = leader?['gender'] as String? ?? '';
    final age = leader?['age'];
    final address = leader?['residential_address'] as String?;
    final status = leader?['membership_status'] as String? ?? '';
    final imageUrl = leader?['image_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasLeader
              ? accent.withOpacity(0.30)
              : (isDark ? Colors.white10 : Colors.black12),
          width: hasLeader ? 1.5 : 1,
        ),
        boxShadow: hasLeader
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : prpBlack,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasLeader) ...[
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Iconsax.edit_2, size: 18),
                  color: accent,
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(Iconsax.trash, size: 18),
                  color: prpRed,
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (!hasLeader)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.add, color: accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Assign $title',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(
                  imageUrl: imageUrl,
                  gender: gender,
                  accent: accent,
                  size: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : prpBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (gender.isNotEmpty) gender.toUpperCase(),
                          if (age != null) '$age YRS',
                          if (status.isNotEmpty) status.toUpperCase(),
                        ].join('  •  '),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _infoRow(Iconsax.call, phone),
                      ],
                      if (address != null && address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _infoRow(Iconsax.location, address),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MEMBER ROW
  // ---------------------------------------------------------------------------
  Widget _memberRow(Map<String, dynamic> m) {
    final isDark = _darkMode;
    final name = m['full_name'] as String? ?? '';
    final phone = m['phone_number'] as String? ?? '';
    final address = m['residential_address'] as String?;
    final gender = m['gender'] as String? ?? '';
    final age = m['age'];
    final status = m['membership_status'] as String? ?? '';
    final imageUrl = m['image_url'] as String?;

    final g = gender.toLowerCase();
    final accent = g.startsWith('f')
        ? prpMagenta
        : (g.startsWith('m') ? prpBlue : prpRed);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(imageUrl: imageUrl, gender: gender, accent: accent, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : prpBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _infoRow(Iconsax.call, phone),
                ],
                if (address != null && address.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  _infoRow(Iconsax.location, address),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => _openForm(position: 'MEMBER', existing: m),
                icon: Icon(Iconsax.edit_2, size: 17, color: accent),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _delete(m, 'Member'),
                icon: const Icon(Iconsax.trash, size: 17, color: prpRed),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 11, color: Colors.grey),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _avatar({
    required String? imageUrl,
    required String gender,
    required Color accent,
    required double size,
  }) {
    final g = gender.toLowerCase();
    final icon = g.startsWith('f')
        ? Iconsax.woman
        : (g.startsWith('m') ? Iconsax.man : Iconsax.user);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: imageUrl == null
            ? LinearGradient(
                colors: [accent.withOpacity(0.25), accent.withOpacity(0.05)],
              )
            : null,
        border: Border.all(color: accent.withOpacity(0.4), width: 2),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Icon(icon, color: accent, size: size * 0.4)
          : null,
    );
  }

  Widget _emptyMembersCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            child: const Icon(Iconsax.people, color: prpRed, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No members yet. Add up to $_maxMembers members.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addMemberButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openForm(position: 'MEMBER'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: prpRed.withOpacity(0.30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.user_add, color: prpRed, size: 18),
              const SizedBox(width: 8),
              Text(
                'Add Member',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: prpRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MEMBER FORM DIALOG (inline — Add/Edit for any position)
// =============================================================================
class _MemberFormDialog extends StatefulWidget {
  final String position; // 'COORDINATOR' | 'WOMEN_LEADER' | 'MEMBER'
  final Map<String, dynamic>? existing;
  final String table;
  final String fkColumn;
  final dynamic fkValue;
  final String levelLabel;

  const _MemberFormDialog({
    required this.position,
    required this.existing,
    required this.table,
    required this.fkColumn,
    required this.fkValue,
    required this.levelLabel,
  });

  @override
  State<_MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient _sb = Supabase.instance.client;

  static const Color prpRed = Color(0xFFC8102E);
  static const Color prpGold = Color(0xFFF5C518);

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _imageUrlCtrl;

  String _gender = 'MALE';
  String _status = 'ACTIVE';
  bool _saving = false;
  String? _error;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?['full_name'] ?? '');
    _phoneCtrl = TextEditingController(text: e?['phone_number'] ?? '');
    _addressCtrl = TextEditingController(text: e?['residential_address'] ?? '');
    _ageCtrl = TextEditingController(text: e?['age']?.toString() ?? '');
    _imageUrlCtrl = TextEditingController(text: e?['image_url'] ?? '');
    _gender = (e?['gender'] as String?)?.toUpperCase() ?? 'MALE';
    _status = (e?['membership_status'] as String?)?.toUpperCase() ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _ageCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  String get _prettyPosition {
    switch (widget.position) {
      case 'COORDINATOR':
        return '${widget.levelLabel} Coordinator';
      case 'WOMEN_LEADER':
        return '${widget.levelLabel} Women Leader';
      default:
        return '${widget.levelLabel} Member';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final payload = <String, dynamic>{
        widget.fkColumn: widget.fkValue,
        'full_name': _nameCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim(),
        'residential_address': _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        'age': _ageCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_ageCtrl.text.trim()),
        'gender': _gender,
        'membership_status': _status,
        'position': widget.position,
        'image_url': _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
      };

      if (isEdit) {
        await _sb
            .from(widget.table)
            .update(payload)
            .eq('id', widget.existing!['id']);
      } else {
        await _sb.from(widget.table).insert(payload);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width < 600 ? width * 0.92 : 520.0;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [prpRed, Color(0xFF9E0B22)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.user_add, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Record' : 'Add New Record',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _prettyPosition.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white70,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Full Name'),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _inputDeco(isDark, 'e.g. John Doe'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Gender'),
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: _inputDeco(isDark, ''),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'MALE',
                                      child: Text('Male'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'FEMALE',
                                      child: Text('Female'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _gender = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Age'),
                                TextFormField(
                                  controller: _ageCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDeco(isDark, 'e.g. 35'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _label('Phone Number'),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDeco(isDark, 'e.g. 08012345678'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      _label('Residential Address'),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: _inputDeco(isDark, 'Street, area, town'),
                      ),
                      const SizedBox(height: 14),
                      _label('Membership Status'),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: _inputDeco(isDark, ''),
                        items: const [
                          DropdownMenuItem(
                            value: 'ACTIVE',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'INACTIVE',
                            child: Text('Inactive'),
                          ),
                          DropdownMenuItem(
                            value: 'PENDING',
                            child: Text('Pending'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 14),
                      _label('Photo URL (optional)'),
                      TextFormField(
                        controller: _imageUrlCtrl,
                        decoration: _inputDeco(isDark, 'https://…'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: prpRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: prpRed.withOpacity(0.3)),
                          ),
                          child: Text(
                            _error!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: prpRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: prpRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdit ? 'Update' : 'Create',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    ),
  );

  InputDecoration _inputDeco(bool isDark, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    filled: true,
    fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: prpRed, width: 1.5),
    ),
  );
}
