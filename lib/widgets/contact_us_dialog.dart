import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tilmeez_project_2027/widgets/customToast.dart';

import '../utils/helpers/helper_functions.dart';
import '../widgets/custom_loading.dart';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({super.key});

  @override
  State<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog> {
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  // Supabase client — safe to grab once; the instance is a singleton.
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------------------
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]+$').hasMatch(email);
  }

  // ---------------------------------------------------------------------------
  // SUBMIT — Supabase insert
  // ---------------------------------------------------------------------------
  Future<void> _submitContactForm() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    // --- Client-side validation -------------------------------------------
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      CustomToast.warning(context, 'Please fill all fields');
      return;
    }
    if (!_isValidEmail(email)) {
      CustomToast.warning(context, 'Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Insert into Supabase.
      // `submitted_at` is omitted on purpose — let the DB default (now())
      // handle it. If your column is nullable text, add it back manually.
      await _supabase.from('contact_submissions').insert({
        'name': name,
        'email': email,
        'message': message,
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
      });

      // insert() throws PostgrestException on failure, so reaching here = success.
      if (!mounted) return;
      Navigator.of(context).pop();
      CustomToast.success(context, 'Your message has been sent successfully!');
    } on PostgrestException catch (e) {
      // Supabase-specific error (RLS, constraint violation, etc.)
      debugPrint(
        '[ContactUsDialog] PostgrestException: ${e.message} '
        '| code: ${e.code} | details: ${e.details}',
      );
      if (!mounted) return;
      CustomToast.error(
        context,
        'Could not send message (${e.code ?? 'error'}). Please try again.',
      );
    } catch (e) {
      // Network / unexpected
      debugPrint('[ContactUsDialog] Unexpected error: $e');
      if (!mounted) return;
      CustomToast.error(context, 'Failed to send message. Please try again.');
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
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: dark
                    ? prpCharcoal.withOpacity(0.97)
                    : Colors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(28),
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
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildContactForm(dark),
                          const SizedBox(height: 20),
                          _buildContactInfo(dark),
                          const SizedBox(height: 24),
                          _buildSubmitButton(dark),
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
  // HEADER — PRP branded
  // ---------------------------------------------------------------------------
  Widget _buildHeader(bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prpRed, prpDarkRed],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative ring
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
                width: 48,
                height: 48,
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
                      'Contact Our Team',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
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
  // FORM
  // ---------------------------------------------------------------------------
  Widget _buildContactForm(bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _field(
          controller: _nameController,
          hint: 'Your Name',
          icon: Iconsax.user,
          dark: dark,
        ),
        const SizedBox(height: 12),
        _field(
          controller: _emailController,
          hint: 'Email Address',
          icon: Iconsax.sms,
          dark: dark,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _field(
          controller: _messageController,
          hint: 'Your Message',
          icon: Iconsax.message_text,
          dark: dark,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool dark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: dark ? Colors.white : prpBlack,
      ),
      cursorColor: prpRed,
      decoration: InputDecoration(
        hintText: hint,
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
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 40,
        ),
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
        filled: true,
        fillColor: dark ? Colors.white.withOpacity(0.04) : prpOffWhite,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTACT INFO
  // ---------------------------------------------------------------------------
  Widget _buildContactInfo(bool dark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.03) : prpOffWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoTile(
              icon: Iconsax.call,
              label: 'Call',
              value: '+234 812 345 6789',
              dark: dark,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: dark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _infoTile(
              icon: Iconsax.sms,
              label: 'Email',
              value: 'support@tilmeez.com',
              dark: dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool dark,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: prpRed.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: prpRed),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: dark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.4),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : prpBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton(bool dark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : () => Navigator.of(context).pop(),
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
                    'Cancel',
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
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _submitContactForm,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [prpRed, prpDarkRed]),
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
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Send Message',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
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
    );
  }
}
