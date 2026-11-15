import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/helpers/helper_functions.dart';
import '../widgets/customToast.dart';

class MembershipFormDialog extends StatefulWidget {
  final SupabaseClient supabase;
  final VoidCallback? onSuccess;

  const MembershipFormDialog({
    super.key,
    required this.supabase,
    this.onSuccess,
  });

  @override
  State<MembershipFormDialog> createState() => _MembershipFormDialogState();
}

class _MembershipFormDialogState extends State<MembershipFormDialog> {
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

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wardController = TextEditingController();
  final _pollingUnitController = TextEditingController();
  final _occupationController = TextEditingController();
  final _ninController = TextEditingController();
  final _vinController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedGender;
  String? _selectedState;
  String? _selectedLGA;
  DateTime? _selectedDateOfBirth;
  String? _passportPhotoPath;
  String? _passportPhotoUrl;

  final Map<String, List<String>> _statesAndLGAs = {
    'Bauchi': [
      'Alkaleri',
      'Bauchi',
      'Bogoro',
      'Dambam',
      'Darazo',
      'Dass',
      'Gamawa',
      'Ganjuwa',
      'Giade',
      'Itas/Gadau',
      "Jama'are",
      'Katagum',
      'Kirfi',
      'Misau',
      'Ningi',
      'Shira',
      'Tafawa Balewa',
      'Toro',
      'Warji',
      'Zaki',
    ],
    'Kano': [
      'Ajingi',
      'Albasu',
      'Bagwai',
      'Bebeji',
      'Bichi',
      'Bunkure',
      'Dala',
      'Dambatta',
      'Dawakin Kudu',
      'Dawakin Tofa',
      'Doguwa',
      'Fagge',
      'Gabasawa',
      'Garko',
      'Garun Mallam',
      'Gaya',
      'Gezawa',
      'Gwale',
      'Gwarzo',
      'Kabo',
      'Kano Municipal',
      'Karaye',
      'Kibiya',
      'Kiru',
      'Kumbotso',
      'Kunchi',
      'Kura',
      'Madobi',
      'Makoda',
      'Minjibir',
      'Nasarawa',
      'Rano',
      'Rimin Gado',
      'Rogo',
      'Shanono',
      'Sumaila',
      'Takai',
      'Tarauni',
      'Tofa',
      'Tsanyawa',
      'Tudun Wada',
      'Ungogo',
      'Warawa',
      'Wudil',
    ],
    'Kaduna': [
      'Birnin Gwari',
      'Chikun',
      'Giwa',
      'Igabi',
      'Ikara',
      'Jaba',
      "Jema'a",
      'Kachia',
      'Kaduna North',
      'Kaduna South',
      'Kagarko',
      'Kajuru',
      'Kaura',
      'Kauru',
      'Kubau',
      'Kudan',
      'Lere',
      'Makarfi',
      'Sabon Gari',
      'Sanga',
      'Soba',
      'Zangon Kataf',
      'Zaria',
    ],
    'Lagos': [
      'Agege',
      'Ajeromi-Ifelodun',
      'Alimosho',
      'Amuwo-Odofin',
      'Apapa',
      'Badagry',
      'Epe',
      'Eti-Osa',
      'Ibeju-Lekki',
      'Ifako-Ijaiye',
      'Ikeja',
      'Ikorodu',
      'Kosofe',
      'Lagos Island',
      'Lagos Mainland',
      'Mushin',
      'Ojo',
      'Oshodi-Isolo',
      'Shomolu',
      'Surulere',
    ],
    'FCT': [
      'Abaji',
      'Bwari',
      'Gwagwalada',
      'Kuje',
      'Kwali',
      'Municipal Area Council',
    ],
  };

  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _wardController.dispose();
    _pollingUnitController.dispose();
    _occupationController.dispose();
    _ninController.dispose();
    _vinController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: prpRed,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF111111),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  Future<void> _pickPassportPhoto() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Passport Photograph'),
        content: const Text(
          'Camera/Gallery selection would be implemented here',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _passportPhotoPath = 'selected');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: prpRed),
            child: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      CustomToast.error(context, 'Please accept the terms and conditions');
      return;
    }
    if (_passportPhotoPath == null) {
      CustomToast.error(context, 'Please upload a passport photograph');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final memberData = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'date_of_birth': _selectedDateOfBirth?.toIso8601String(),
        'state_of_origin': _selectedState,
        'lga': _selectedLGA,
        'ward': _wardController.text.trim(),
        'polling_unit': _pollingUnitController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'nin': _ninController.text.trim(),
        'vin': _vinController.text.trim(),
        'reason': _reasonController.text.trim(),
        'passport_photo_url': _passportPhotoUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await widget.supabase.from('members').insert(memberData).select();

      if (mounted) {
        CustomToast.success(
          context,
          'Membership application submitted successfully!',
        );
        widget.onSuccess?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.error(
          context,
          'Failed to submit application: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 800),
              decoration: BoxDecoration(
                color: dark
                    ? prpCharcoal.withOpacity(0.97)
                    : Colors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: dark
                      ? prpGold.withOpacity(0.18)
                      : prpRed.withOpacity(0.10),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(dark),
                  _buildProgressIndicator(dark),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        children: [
                          _buildPersonalInfoPage(dark),
                          _buildLocationPage(dark),
                          _buildAdditionalInfoPage(dark),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomSection(dark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpRed, prpDarkRed],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.20),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(Iconsax.flag, color: prpGold, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'TILMEEZ 2027',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: prpWhite,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: prpGold,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'PRP',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: prpBlack,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Become a Member • Join the Movement',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Iconsax.close_circle,
                      size: 18,
                      color: prpWhite,
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

  // ---------------------------------------------------------------------------
  // STEPPER
  // ---------------------------------------------------------------------------
  Widget _buildProgressIndicator(bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStepLabel('Personal', 0, dark),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _currentPage >= 1
                    ? prpRed
                    : (dark ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildStepLabel('Location', 1, dark),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _currentPage >= 2
                    ? prpRed
                    : (dark ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildStepLabel('Extra', 2, dark),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step, bool dark) {
    final isActive = step <= _currentPage;
    final isDone = step < _currentPage;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? prpRed
                : (dark ? Colors.white12 : Colors.grey.shade200),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: prpRed.withOpacity(0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Iconsax.tick_circle, color: Colors.white, size: 14)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : (dark ? Colors.white54 : Colors.grey),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? (dark ? Colors.white : prpBlack)
                : (dark ? Colors.white54 : Colors.grey),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE 1 — Personal
  // ---------------------------------------------------------------------------
  Widget _buildPersonalInfoPage(bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPassportPhoto,
              child: Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: prpRed.withOpacity(0.35), width: 2),
                  color: dark ? Colors.white.withOpacity(0.04) : prpOffWhite,
                ),
                child: _passportPhotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          color: prpRed.withOpacity(0.10),
                          child: const Icon(
                            Iconsax.gallery,
                            size: 40,
                            color: prpRed,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.camera,
                            size: 30,
                            color: prpRed.withOpacity(0.7),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Upload\nPhoto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: prpRed.withOpacity(0.8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Passport Photograph',
              style: TextStyle(
                fontSize: 11.5,
                color: dark ? Colors.white54 : prpGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Iconsax.user,
            dark: dark,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter your full name' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'your@email.com',
            icon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            dark: dark,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+234 800 000 0000',
            icon: Iconsax.call,
            keyboardType: TextInputType.phone,
            dark: dark,
            validator: (v) => (v == null || v.isEmpty)
                ? 'Please enter your phone number'
                : null,
          ),
          const SizedBox(height: 14),
          _buildDropdownField(
            value: _selectedGender,
            label: 'Gender',
            hint: 'Select gender',
            icon: Iconsax.user_tag,
            items: _genders,
            onChanged: (v) => setState(() => _selectedGender = v),
            dark: dark,
          ),
          const SizedBox(height: 14),
          _buildDateField(
            label: 'Date of Birth',
            value: _selectedDateOfBirth,
            icon: Iconsax.calendar_1,
            onTap: _selectDateOfBirth,
            dark: dark,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE 2 — Location
  // ---------------------------------------------------------------------------
  Widget _buildLocationPage(bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Location Information', Iconsax.location, dark),
          const SizedBox(height: 16),
          _buildDropdownField(
            value: _selectedState,
            label: 'State of Origin/Residence',
            hint: 'Select your state',
            icon: Iconsax.map,
            items: _statesAndLGAs.keys.toList(),
            onChanged: (v) {
              setState(() {
                _selectedState = v;
                _selectedLGA = null;
              });
            },
            dark: dark,
          ),
          const SizedBox(height: 14),
          _buildDropdownField(
            value: _selectedLGA,
            label: 'Local Government Area',
            hint: 'Select your LGA',
            icon: Iconsax.building_3,
            items: _selectedState != null
                ? _statesAndLGAs[_selectedState]!
                : [],
            onChanged: (v) => setState(() => _selectedLGA = v),
            dark: dark,
            isEnabled: _selectedState != null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _wardController,
            label: 'Ward',
            hint: 'Enter your ward',
            icon: Iconsax.home,
            dark: dark,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _pollingUnitController,
            label: 'Polling Unit',
            hint: 'Enter your polling unit',
            icon: Iconsax.location,
            dark: dark,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE 3 — Additional
  // ---------------------------------------------------------------------------
  Widget _buildAdditionalInfoPage(bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Additional Information',
            Iconsax.document_text,
            dark,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation',
            hint: 'Enter your occupation',
            icon: Iconsax.briefcase,
            dark: dark,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _ninController,
            label: 'National Identity Number (NIN)',
            hint: 'Enter your 11-digit NIN',
            icon: Iconsax.card,
            keyboardType: TextInputType.number,
            dark: dark,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _vinController,
            label: 'Voters Identification Number (VIN)',
            hint: 'Enter your VIN',
            icon: Iconsax.card_edit,
            dark: dark,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _reasonController,
            label: 'Reason for Joining',
            hint: 'Tell us why you want to join Tilmeez Project 2027',
            icon: Iconsax.message_question,
            maxLines: 3,
            dark: dark,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHARED WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader(String title, IconData icon, bool dark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: prpRed),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white : prpBlack,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool dark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white70 : prpGrey,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: dark ? Colors.white : prpBlack,
          ),
          cursorColor: prpRed,
          decoration: _inputDecoration(hint, icon, dark, maxLines),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String hintText,
    IconData icon,
    bool dark, [
    int maxLines = 1,
  ]) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: dark
            ? Colors.white.withOpacity(0.45)
            : Colors.black.withOpacity(0.45),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: maxLines > 1 ? 14 : 12,
        horizontal: 14,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 8,
          top: maxLines > 1 ? 12 : 0,
          bottom: maxLines > 1 ? 12 : 0,
        ),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.10),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: prpRed),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 40),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: prpRed.withOpacity(0.5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: prpRed, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: prpRed, width: 1.5),
      ),
      filled: true,
      fillColor: dark ? Colors.white.withOpacity(0.04) : prpOffWhite,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required bool dark,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white70 : prpGrey,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration(hint, icon, dark),
          dropdownColor: dark ? prpCharcoal : Colors.white,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: dark ? Colors.white : prpBlack,
          ),
          icon: const Icon(Iconsax.arrow_down_1, size: 18, color: prpRed),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: isEnabled ? onChanged : null,
          disabledHint: Text(
            'Select state first',
            style: TextStyle(
              color: dark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white70 : prpGrey,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: dark ? Colors.white.withOpacity(0.04) : prpOffWhite,
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: prpRed.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 14, color: prpRed),
                ),
                const SizedBox(width: 10),
                Text(
                  value != null
                      ? DateFormat('dd MMMM, yyyy').format(value)
                      : 'Select date of birth',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: value != null
                        ? (dark ? Colors.white : prpBlack)
                        : (dark ? Colors.white54 : Colors.black54),
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
  // BOTTOM
  // ---------------------------------------------------------------------------
  Widget _buildBottomSection(bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: dark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  activeColor: prpRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11.5,
                      color: dark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: prpRed,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: prpRed,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (_currentPage > 0) ...[
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.10),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: dark ? Colors.white70 : prpBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading
                        ? null
                        : () {
                            if (_currentPage < 2) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _submitForm();
                            }
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [prpRed, prpDarkRed],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: prpRed.withOpacity(0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentPage < 2
                                        ? 'Next'
                                        : 'Submit Application',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Iconsax.arrow_right_3,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
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
}
