import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;
import '../../utils/constants/colors.dart';
import '../responsive.dart';
import '../widgets/customToast.dart';
import '../widgets/custom_loading.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  List<Map<String, dynamic>> _similarProducts = [];
  bool _loadingSimilarProducts = false;
  bool _isAnimating = false;

  // Animation controllers for pan & drop
  late AnimationController _panDropController;
  late Animation<Offset> _panAnimation;
  late Animation<double> _dropScaleAnimation;
  late Animation<double> _dropRotationAnimation;
  late Animation<double> _dropOpacityAnimation;
  final GlobalKey _addToCartKey = GlobalKey();
  final GlobalKey _bottomBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSimilarProducts();
  }

  void _initializeAnimations() {
    _panDropController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _panAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.8, -1.2)).animate(
          CurvedAnimation(
            parent: _panDropController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _dropScaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _panDropController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _dropRotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi * 2)
        .animate(
          CurvedAnimation(
            parent: _panDropController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        );

    _dropOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _panDropController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _panDropController.dispose();
    super.dispose();
  }

  double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is num) return price.toDouble();
    if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _loadSimilarProducts() async {
    if (mounted) {
      setState(() {
        _loadingSimilarProducts = true;
      });
    }

    try {
      final currentCategory = widget.product['category'];
      if (currentCategory == null) return;

      final response = await _supabase
          .from('products')
          .select()
          .eq('category', currentCategory)
          .neq('id', widget.product['id'])
          .limit(8); // Limit to 8 similar products for better UX

      if (mounted) {
        setState(() {
          _similarProducts = (response as List).cast<Map<String, dynamic>>();
          _similarProducts.shuffle();
          _loadingSimilarProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSimilarProducts = false;
        });
      }
    }
  }

  Future<void> _addToCartWithAnimation({
    required Map<String, dynamic> product,
    required int quantity,
    GlobalKey? buttonKey,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        CustomToast.error(context, "Please sign in to add to cart");
      }
      return;
    }

    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    try {
      // Animation setup
      final screenSize = MediaQuery.of(context).size;
      Offset startOffset = Offset.zero;
      Offset endOffset = Offset(0.9, 1.0);

      RenderBox? buttonBox =
          buttonKey?.currentContext?.findRenderObject() as RenderBox?;
      RenderBox? targetBox =
          _bottomBarKey.currentContext?.findRenderObject() as RenderBox?;

      if (buttonBox != null && targetBox != null) {
        final buttonPosition = buttonBox.localToGlobal(Offset.zero);
        final targetPosition = targetBox.localToGlobal(Offset.zero);

        startOffset = Offset(
          (buttonPosition.dx + buttonBox.size.width / 2) / screenSize.width,
          (buttonPosition.dy + buttonBox.size.height / 2) / screenSize.height,
        );

        endOffset = Offset(
          (targetPosition.dx + targetBox.size.width * 0.8) / screenSize.width,
          (targetPosition.dy + targetBox.size.height * 0.5) / screenSize.height,
        );
      }

      // Create overlay for animation
      OverlayEntry? overlayEntry = OverlayEntry(
        builder: (context) =>
            _buildPanDropOverlay(product, startOffset, endOffset),
      );
      Overlay.of(context).insert(overlayEntry);

      // Start animation
      _panDropController.reset();
      _panDropController.forward().then((_) {
        overlayEntry.remove();
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      });

      // Database operation
      final price = _parsePrice(product['price']) ?? 0.0;

      final existingCartItem = await _supabase
          .from('cart')
          .select()
          .eq('user_id', userId)
          .eq('product_id', product['id'] ?? '')
          .maybeSingle();

      if (existingCartItem != null) {
        await _supabase
            .from('cart')
            .update({
              'quantity': (existingCartItem['quantity'] ?? 0) + quantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingCartItem['id']);
      } else {
        await _supabase.from('cart').insert({
          'user_id': userId,
          'product_id': product['id'] ?? '',
          'name': product['name'] ?? 'Unknown Product',
          'price': price,
          'image1': product['image1'] ?? '',
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        CustomToast.success(
          context,
          'Added ${quantity > 1 ? '$quantity ' : ''}${product['name'] ?? 'item'} to cart',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.error(context, 'Error adding to cart');
      }
    } finally {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    }
  }

  Widget _buildPanDropOverlay(
    Map<String, dynamic> product,
    Offset startOffset,
    Offset endOffset,
  ) {
    return AnimatedBuilder(
      animation: _panDropController,
      builder: (context, child) {
        final progress = _panDropController.value;
        Offset currentOffset;
        double scale = 1.0;
        double rotation = 0.0;
        double opacity = 1.0;

        if (progress < 0.7) {
          final panProgress = progress / 0.7;
          currentOffset = Offset.lerp(startOffset, endOffset, panProgress)!;
          opacity = 1.0;
        } else {
          currentOffset = endOffset;
          final dropProgress = (progress - 0.7) / 0.3;
          scale = 1.0 - (dropProgress * 0.8);
          rotation = dropProgress * (2 * math.pi * 2);
          opacity = 1.0 - dropProgress;
          opacity = opacity.clamp(0.0, 1.0);
        }

        return Positioned(
          left: 0,
          top: 0,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(
                currentOffset.dx * MediaQuery.of(context).size.width,
                currentOffset.dy * MediaQuery.of(context).size.height,
              )
              ..scale(scale)
              ..rotateZ(rotation),
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: scale > 0.5 ? 80 : 60,
                height: scale > 0.5 ? 80 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: TColors.primary.withOpacity(
                        0.6 * scale.clamp(0.0, 1.0),
                      ),
                      blurRadius: 20 * scale.clamp(0.0, 1.0),
                      spreadRadius: 5 * scale.clamp(0.0, 1.0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(scale > 0.5 ? 40 : 30),
                  child: product['image1']?.isNotEmpty == true
                      ? Image.network(
                          product['image1'],
                          fit: BoxFit.cover,
                          width: scale > 0.5 ? 80 : 60,
                          height: scale > 0.5 ? 80 : 60,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.white.withOpacity(0.9),
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: TColors.primary,
                                  size: scale > 0.5 ? 40 : 30,
                                ),
                              ),
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.9),
                          child: Icon(
                            Icons.shopping_bag,
                            color: TColors.primary,
                            size: scale > 0.5 ? 40 : 30,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addToCartMain() => _addToCartWithAnimation(
    product: widget.product,
    quantity: _quantity,
    buttonKey: _addToCartKey,
  );

  void _addSimilarToCart(Map<String, dynamic> product) =>
      _addToCartWithAnimation(product: product, quantity: 1);

  void _incrementQuantity() => setState(() => _quantity++);

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _toggleFavorite() => setState(() => _isFavorite = !_isFavorite);

  void _navigateToProductDetails(Map<String, dynamic> product) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Responsive design constants
    final double screenPadding = isDesktop
        ? 32
        : isTablet
        ? 24
        : 16;
    final double imageHeight = isDesktop
        ? 500
        : isTablet
        ? 400
        : 350;
    final double productNameFontSize = isDesktop
        ? 28
        : isTablet
        ? 24
        : 20;
    final double priceFontSize = isDesktop
        ? 26
        : isTablet
        ? 22
        : 18;
    final double descriptionFontSize = isDesktop
        ? 16
        : isTablet
        ? 14
        : 13;
    final double buttonFontSize = isDesktop
        ? 16
        : isTablet
        ? 14
        : 13;
    final double buttonHeight = isDesktop
        ? 56
        : isTablet
        ? 52
        : 48;

    List images = [
      widget.product['image1'] ?? '',
      widget.product['image2'] ?? '',
      widget.product['image3'] ?? '',
    ].where((image) => image.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.light,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageHeight + statusBarHeight,
            floating: false,
            pinned: true,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: null,
            actions: [],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    _buildImageCarousel(
                      context,
                      dark,
                      images,
                      imageHeight,
                      statusBarHeight,
                      isDesktop,
                    ),
                    Positioned(
                      top: statusBarHeight + 8,
                      left: 8,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Iconsax.arrow_left_2,
                            color: dark ? Colors.white : Colors.black87,
                            size: isDesktop ? 22 : 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: statusBarHeight + 8,
                      right: 8,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite
                                ? Colors.red
                                : (dark ? Colors.white : Colors.black87),
                            size: isDesktop ? 22 : 18,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenPadding),
              child: isMobile
                  ? _buildMobileContent(
                      dark,
                      productNameFontSize,
                      priceFontSize,
                      descriptionFontSize,
                      screenPadding,
                    )
                  : _buildTabletDesktopContent(
                      dark,
                      productNameFontSize,
                      priceFontSize,
                      descriptionFontSize,
                      screenPadding,
                      isDesktop,
                    ),
            ),
          ),
          if (_similarProducts.isNotEmpty || _loadingSimilarProducts)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  screenPadding,
                  0,
                  screenPadding,
                  screenPadding,
                ),
                child: _buildSimilarProductsSection(
                  dark,
                  descriptionFontSize,
                  isMobile,
                  isTablet,
                  isDesktop,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        dark,
        buttonHeight,
        buttonFontSize,
        _isAnimating,
        screenPadding,
        isMobile,
      ),
    );
  }

  Widget _buildImageCarousel(
    BuildContext context,
    bool dark,
    List images,
    double imageHeight,
    double statusBarHeight,
    bool isDesktop,
  ) {
    return Stack(
      children: [
        Container(
          height: imageHeight + statusBarHeight,
          decoration: BoxDecoration(
            gradient: dark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  )
                : null,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: images.isEmpty
                      ? Container(
                          color: dark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: isDesktop ? 100 : 80,
                              color: TColors.grey,
                            ),
                          ),
                        )
                      : Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: TColors.primary,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: dark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: isDesktop ? 100 : 80,
                                    color: TColors.grey,
                                  ),
                                ),
                              ),
                        ),
                ),
              );
            },
          ),
        ),
        Container(
          height: statusBarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: dark ? Colors.black54 : Colors.white54,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotColor: TColors.primary,
                    dotColor: dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    spacing: 6,
                    expansionFactor: 3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileContent(
    bool dark,
    double productNameFontSize,
    double priceFontSize,
    double descriptionFontSize,
    double screenPadding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildProductHeader(dark, productNameFontSize, priceFontSize),
        const SizedBox(height: 24),
        _buildProductStats(dark),
        const SizedBox(height: 24),
        _buildDescriptionSection(dark, descriptionFontSize),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildTabletDesktopContent(
    bool dark,
    double productNameFontSize,
    double priceFontSize,
    double descriptionFontSize,
    double screenPadding,
    bool isDesktop,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader(dark, productNameFontSize, priceFontSize),
              const SizedBox(height: 24),
              _buildProductStats(dark),
              const SizedBox(height: 24),
              _buildDescriptionSection(dark, descriptionFontSize),
            ],
          ),
        ),
        SizedBox(width: screenPadding),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
        ),
      ],
    );
  }

  Widget _buildProductHeader(
    bool dark,
    double nameFontSize,
    double priceFontSize,
  ) {
    final price = _parsePrice(widget.product['price']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product['name'] ?? 'Unknown Product',
          style: GoogleFonts.poppins(
            fontSize: nameFontSize,
            fontWeight: FontWeight.w700,
            color: dark ? TColors.white : TColors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₦${price != null ? price.toStringAsFixed(2) : 'N/A'}',
          style: GoogleFonts.poppins(
            fontSize: priceFontSize,
            fontWeight: FontWeight.w700,
            color: TColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductStats(bool dark) {
    final rating = widget.product['rating']?.toDouble() ?? 0.0;
    final stock = widget.product['stock'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.inventory_2_outlined,
            value: '$stock',
            label: 'In Stock',
            dark: dark,
          ),
          _buildStatItem(
            icon: Icons.star,
            value: rating.toStringAsFixed(1),
            label: 'Rating',
            dark: dark,
            iconColor: Colors.amber,
          ),
          _buildStatItem(
            icon: Icons.local_shipping,
            value: 'Free',
            label: 'Delivery',
            dark: dark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool dark,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? (dark ? TColors.grey : TColors.textsecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: TColors.grey),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(bool dark, double descriptionFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? TColors.darkContainer : TColors.lightContainer,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Text(
            widget.product['description'] ?? 'No description available.',
            style: GoogleFonts.poppins(
              fontSize: descriptionFontSize,
              color: dark
                  ? TColors.white.withOpacity(0.9)
                  : TColors.textsecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProductsSection(
    bool dark,
    double fontSize,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Similar Products',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop
                      ? 24
                      : isTablet
                      ? 20
                      : 18,
                  fontWeight: FontWeight.w700,
                  color: dark ? TColors.white : TColors.black,
                ),
              ),
              if (_similarProducts.isNotEmpty)
                Text(
                  '${_similarProducts.length} items',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 14 : 12,
                    color: TColors.grey,
                  ),
                ),
            ],
          ),
        ),
        if (_loadingSimilarProducts)
          _buildSimilarProductsShimmer(dark, isMobile, isTablet, isDesktop)
        else if (_similarProducts.isEmpty)
          _buildNoSimilarProducts(dark)
        else
          _buildSimilarProductsList(
            dark,
            fontSize,
            isMobile,
            isTablet,
            isDesktop,
          ),
      ],
    );
  }

  Widget _buildSimilarProductsShimmer(
    bool dark,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final crossAxisCount = isDesktop
        ? 4
        : isTablet
        ? 3
        : 2;
    final cardHeight = isDesktop
        ? 220
        : isTablet
        ? 200
        : 180;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isDesktop
            ? 20
            : isTablet
            ? 16
            : 12,
        mainAxisSpacing: isDesktop
            ? 20
            : isTablet
            ? 16
            : 12,
        childAspectRatio: isDesktop
            ? 0.85
            : isTablet
            ? 0.8
            : 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: dark
              ? TColors.darkGrey.withOpacity(0.5)
              : TColors.softgrey,
          highlightColor: dark
              ? TColors.grey.withOpacity(0.3)
              : TColors.grey.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: dark ? TColors.darkContainer : TColors.lightContainer,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoSimilarProducts(bool dark) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: TColors.grey),
            const SizedBox(height: 12),
            Text(
              'No similar products found',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarProductsList(
    bool dark,
    double fontSize,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final crossAxisCount = isDesktop
        ? 4
        : isTablet
        ? 3
        : 2;
    final cardHeight = isDesktop
        ? 220
        : isTablet
        ? 200
        : 180;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isDesktop
            ? 20
            : isTablet
            ? 16
            : 12,
        mainAxisSpacing: isDesktop
            ? 20
            : isTablet
            ? 16
            : 12,
        childAspectRatio: isDesktop
            ? 0.85
            : isTablet
            ? 0.8
            : 0.75,
      ),
      itemCount: _similarProducts.length,
      itemBuilder: (context, index) {
        final product = _similarProducts[index];
        final price = _parsePrice(product['price']);
        return _buildSimilarProductCard(
          product,
          dark,
          price,
          fontSize,
          isMobile,
          isTablet,
          isDesktop,
        );
      },
    );
  }

  Widget _buildSimilarProductCard(
    Map<String, dynamic> product,
    bool dark,
    double? price,
    double fontSize,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final GlobalKey cardKey = GlobalKey();
    final cardPadding = isDesktop
        ? 12.0
        : isTablet
        ? 10.0
        : 8.0;
    final iconSize = isDesktop
        ? 18.0
        : isTablet
        ? 16.0
        : 14.0;
    final titleFontSize = isDesktop
        ? 14
        : isTablet
        ? 13
        : 12;
    final priceFontSize = isDesktop
        ? 16
        : isTablet
        ? 14
        : 13;

    return GestureDetector(
      onTap: () => _navigateToProductDetails(product),
      child: Container(
        key: cardKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: dark ? TColors.darkContainer : TColors.lightContainer,
          border: Border.all(
            color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: dark ? Colors.grey.shade900 : Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child:
                          product['image1'] != null &&
                              product['image1'].isNotEmpty
                          ? Image.network(
                              product['image1'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 30,
                                        color: TColors.grey,
                                      ),
                                    ),
                                  ),
                            )
                          : Container(
                              color: dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 30,
                                  color: TColors.grey,
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Stock indicator
                  if (product['stock'] != null && product['stock'] <= 5)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Low Stock',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Quick Add Button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _isAnimating
                            ? null
                            : () => _addToCartWithAnimation(
                                product: product,
                                quantity: 1,
                                buttonKey: cardKey,
                              ),
                        icon: Icon(
                          Icons.add_shopping_cart,
                          size: iconSize,
                          color: TColors.primary,
                        ),
                        padding: EdgeInsets.all(isDesktop ? 8 : 6),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Details
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] ?? 'Unknown Product',
                    style: GoogleFonts.poppins(
                      // fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: dark ? TColors.white : TColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${price != null ? price.toStringAsFixed(2) : 'N/A'}',
                        style: GoogleFonts.poppins(
                          // fontSize: priceFontSize,
                          fontWeight: FontWeight.w700,
                          color: TColors.primary,
                        ),
                      ),
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: iconSize - 2,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            (product['rating']?.toStringAsFixed(1) ?? '0.0'),
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize - 2,
                              fontWeight: FontWeight.w500,
                              color: dark
                                  ? TColors.lightgrey
                                  : TColors.darkGrey,
                            ),
                          ),
                        ],
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

  Widget _buildBottomBar(
    bool dark,
    double buttonHeight,
    double fontSize,
    bool isAnimating,
    double screenPadding,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.all(screenPadding * 0.5),
      child: Container(
        key: _bottomBarKey,
        padding: EdgeInsets.all(screenPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TColors.primary.withOpacity(0.6),
              TColors.primary.withOpacity(0.3),
              Colors.purple.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(isMobile ? 30 : 40),
          border: Border.all(
            color: dark
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              _buildQuantitySelector(dark, buttonHeight),
              SizedBox(width: screenPadding),
              Expanded(
                child: ElevatedButton(
                  key: _addToCartKey,
                  onPressed: isAnimating ? null : _addToCartMain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.white,
                    foregroundColor: TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: TColors.primary.withOpacity(0.3),
                    elevation: isAnimating ? 0 : 8,
                    minimumSize: Size(double.infinity, buttonHeight),
                  ),
                  child: isAnimating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomLoadingWidget(),
                            ),
                            SizedBox(width: screenPadding * 0.5),
                            Text(
                              'Adding...',
                              style: GoogleFonts.poppins(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: fontSize + 2,
                              color: TColors.primary,
                            ),
                            SizedBox(width: screenPadding * 0.5),
                            Text(
                              'Add to Cart',
                              style: GoogleFonts.poppins(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(bool dark, double buttonHeight) {
    return Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(buttonHeight / 2),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _decrementQuantity,
            icon: Icon(Icons.remove, size: 20, color: TColors.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TColors.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: _incrementQuantity,
            icon: Icon(Icons.add, size: 20, color: TColors.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
