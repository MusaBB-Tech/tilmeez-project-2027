import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final dark = theme.brightness == Brightness.dark;

    // ---------------------------------------------------------------------
    // PRP CAMPAIGN BRAND COLORS
    // ---------------------------------------------------------------------
    const prpRed = Color(0xFFC8102E);
    const prpDarkRed = Color(0xFF9E0B22);
    const prpGold = Color(0xFFF5C518);
    const prpBlack = Color(0xFF111111);
    const prpWhite = Colors.white;
    // kept for reference/aliases
    const prpGreen = Color(0xFF0FA958);
    const prpBlue = Color(0xFF0A1F44);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? [prpBlack, const Color(0xFF0B0B0B)]
              : [const Color(0xFFFDFBF7), const Color(0xFFF1ECE4)],
        ),
        border: Border(
          top: BorderSide(
            color: dark ? prpGold.withOpacity(0.15) : prpRed.withOpacity(0.15),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Main Footer Content
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? 24
                  : isTablet
                  ? 40
                  : 80,
              vertical: isMobile ? 48 : 64,
            ),
            child: isMobile
                ? _buildMobileFooter(theme, dark, prpRed, prpGold)
                : _buildDesktopFooter(
                    theme,
                    dark,
                    isTablet,
                    prpRed,
                    prpGold,
                    prpBlack,
                  ),
          ),

          // Bottom Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 80,
              vertical: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '© ${DateTime.now().year} Tilmeez Project 2027 for Shehu • Peoples Redemption Party (PRP) • '
                    'Bauchi North Senatorial District, Nigeria',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: dark ? Colors.white54 : Colors.black54,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      _buildBottomLink('Privacy Policy', () {}, dark, prpRed),
                      const SizedBox(width: 24),
                      _buildBottomLink('Terms of Service', () {}, dark, prpRed),
                      const SizedBox(width: 24),
                      _buildBottomLink('Contact Campaign', () {}, dark, prpRed),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP
  // ---------------------------------------------------------------------------
  Widget _buildDesktopFooter(
    ThemeData theme,
    bool dark,
    bool isTablet,
    Color red,
    Color gold,
    Color black,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Column
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & Name
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [red, red.withOpacity(0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Iconsax.flag,
                        size: 26,
                        color: Color(0xFFF5C518),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tilmeez Project 2027',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Text(
                            'For Shehu • PRP',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: red,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'A peoples-first movement for Bauchi North Senatorial District — '
                '7 LGAs, 74 wards and 1,666 polling units united under one vision: '
                'compassion, dignity and inclusive development for all.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: dark ? Colors.white70 : Colors.black54,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              // Contact Info
              Row(
                children: [
                  Icon(Iconsax.location, size: 16, color: red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Campaign Office • Azare, Bauchi North, Nigeria',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: dark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Iconsax.call, size: 16, color: red),
                  const SizedBox(width: 8),
                  Text(
                    '+234 (0) 800 000 2027',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: dark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Iconsax.sms, size: 16, color: red),
                  const SizedBox(width: 8),
                  Text(
                    'campaign@tilmeez2027.org',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: dark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Newsletter
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: dark
                      ? Colors.white.withOpacity(0.03)
                      : red.withOpacity(0.04),
                  border: Border.all(
                    color: dark
                        ? gold.withOpacity(0.15)
                        : red.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Updated',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? Colors.white : Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subscribe for campaign updates, rallies and impact stories from Bauchi North.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: dark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: dark ? Colors.white38 : Colors.black38,
                              ),
                              filled: true,
                              fillColor: dark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white,
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
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [red, red.withOpacity(0.8)],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Handle campaign newsletter subscription
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                child: const Icon(
                                  Iconsax.send_2,
                                  size: 20,
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
            ],
          ),
        ),
        const SizedBox(width: 48),
        // Links Columns
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFooterColumn(
                  'The Campaign',
                  [
                    'Meet Shehu',
                    'Our Vision & Mission',
                    'Core Values',
                    'Campaign Council',
                    'Contact Us',
                  ],
                  dark,
                  red,
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildFooterColumn(
                  'Our Priorities',
                  [
                    'Healthcare (SDG 3)',
                    'Education (SDG 4)',
                    'Water & Sanitation (SDG 6)',
                    'Clean Energy (SDG 7)',
                    'Social Inclusion (SDG 10 & 11)',
                  ],
                  dark,
                  red,
                ),
              ),
              if (!isTablet) ...[
                const SizedBox(width: 32),
                Expanded(
                  child: _buildFooterColumn(
                    'Join the Movement',
                    [
                      'Volunteer',
                      'Become a Member',
                      'Donate',
                      'Electoral Data',
                      'FAQs',
                    ],
                    dark,
                    red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE
  // ---------------------------------------------------------------------------
  Widget _buildMobileFooter(ThemeData theme, bool dark, Color red, Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [red, red.withOpacity(0.8)]),
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Iconsax.flag, size: 34, color: Color(0xFFF5C518)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tilmeez Project 2027 for Shehu',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRP',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Bauchi North • Serving Humanity',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: red,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Links in Wrap
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: [
            _buildFooterColumn(
              'The Campaign',
              ['Meet Shehu', 'Vision & Mission', 'Campaign Council'],
              dark,
              red,
              isMobile: true,
            ),
            _buildFooterColumn(
              'Priorities',
              ['Healthcare', 'Education', 'Water & Sanitation'],
              dark,
              red,
              isMobile: true,
            ),
            _buildFooterColumn(
              'Join Movement',
              ['Volunteer', 'Become a Member', 'Contact Campaign'],
              dark,
              red,
              isMobile: true,
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Social Links
        _buildSocialLinks(dark, red),
        const SizedBox(height: 24),
        // Newsletter
        TextField(
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Subscribe for campaign updates',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: dark ? Colors.white38 : Colors.black38,
            ),
            filled: true,
            fillColor: dark ? Colors.white.withOpacity(0.05) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: Icon(Iconsax.send_2, color: red, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COLUMNS
  // ---------------------------------------------------------------------------
  Widget _buildFooterColumn(
    String title,
    List<String> items,
    bool dark,
    Color red, {
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark ? Colors.white : Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: dark ? Colors.white70 : Colors.black54,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SOCIAL LINKS
  // ---------------------------------------------------------------------------
  Widget _buildSocialLinks(bool dark, Color red) {
    final socialLinks = <_SocialLink>[
      const _SocialLink(FontAwesomeIcons.facebookF, Color(0xFF1877F2), ''),
      const _SocialLink(FontAwesomeIcons.xTwitter, Colors.black, ''),
      const _SocialLink(FontAwesomeIcons.instagram, Color(0xFFE4405F), ''),
      const _SocialLink(FontAwesomeIcons.linkedinIn, Color(0xFF0A66C2), ''),
      const _SocialLink(FontAwesomeIcons.whatsapp, Color(0xFF25D366), ''),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialLinks.map((social) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: Border.all(
                  color: dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Center(
                child: FaIcon(social.icon, size: 18, color: social.color),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM LINK
  // ---------------------------------------------------------------------------
  Widget _buildBottomLink(
    String text,
    VoidCallback onTap,
    bool dark,
    Color red,
  ) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: dark ? Colors.white38 : Colors.black38,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STRONGLY-TYPED SOCIAL LINK
// ---------------------------------------------------------------------------
/// Holds a Font Awesome icon, its brand color, and target URL.
///
/// Uses [FaIconData] which is the icon type exposed by
/// `font_awesome_flutter` v11+. On earlier versions this is a subtype of
/// [IconData], so the code compiles cleanly across versions.
class _SocialLink {
  final FaIconData icon;
  final Color color;
  final String url;

  const _SocialLink(this.icon, this.color, this.url);
}
