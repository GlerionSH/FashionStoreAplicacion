import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/editorial/editorial_assets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/exceptions/failure.dart';
import '../../../../shared/widgets/fs_product_card.dart';
import '../../../../shared/widgets/fs_section_header.dart';
import '../../../flash_offers/presentation/widgets/flash_banner.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/products_filter.dart';
import '../../../products/presentation/providers/products_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _homeFilter = ProductsFilter(page: 0);
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAv = ref.watch(productsProvider(_homeFilter));
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFF000000),
        edgeOffset: 0,
        onRefresh: () async {
          ref.invalidate(productsProvider(_homeFilter));
          ref.invalidate(flashProductsProvider);
        },
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── Pinned header bar (stays visible on scroll) ──
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 0,
              toolbarHeight: 56,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0.5,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Image.asset(
                'assets/icon/logo3.png',
                height: 26,
                color: Colors.black,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, _, _) => const Text(
                  'FASHION STORE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 3.5,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search,
                      color: Colors.black, size: 22),
                  onPressed: () => context.go('/productos'),
                ),
                IconButton(
                  icon: const Icon(Icons.monitor_heart_outlined,
                      color: Colors.black54, size: 20),
                  tooltip: t.homeTooltipDiagnostics,
                  onPressed: () => context.go('/diagnostics'),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Hero ────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenH * 0.85,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Parallax editorial image from EditorialAssets
                    AnimatedBuilder(
                      animation: _scrollCtrl,
                      builder: (context, _) {
                        final offset = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
                        return Positioned(
                          top: -offset * 0.3,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            EditorialAssets.homeHero,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, _, _) => Container(
                              color: EditorialAssets.fallbackColor,
                            ),
                          ),
                        );
                      },
                    ),
                    // Flat black overlay — no gradients
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                    // Hero copy — centred like Astro HeroEditorial
                    Positioned.fill(
                      child: _FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        slidePixels: 18,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.homeHeroLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 3.0,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              t.homeHeroTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2.0,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.homeHeroSubtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => context.go('/productos'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 14),
                                    color: Colors.white,
                                    child: Text(
                                      t.homeViewProducts,
                                      style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => context.go('/carrito'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                    ),
                                    child: Text(
                                      t.homeViewCart,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Category blocks (matches Astro) ─────────────
            SliverToBoxAdapter(
              child: _FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CategoryBlock(
                          assetPath: EditorialAssets.categoryNewIn,
                          subtitle: t.homeCategoryLabel,
                          title: 'NEW IN',
                          onTap: () => context.go('/productos'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CategoryBlock(
                          assetPath: EditorialAssets.categoryBasics,
                          subtitle: t.homeCategoryLabel,
                          title: 'BASICS',
                          onTap: () => context.go('/productos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Flash offers (only if active) ───────────────
            SliverToBoxAdapter(
              child: _FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: const FlashBanner(),
              ),
            ),

            // ── Featured section ────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlideIn(
                delay: const Duration(milliseconds: 450),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: FsSectionHeader(
                    title: t.homeFeatured,
                    actionLabel: t.homeViewAll,
                    onAction: () => context.go('/productos'),
                  ),
                ),
              ),
            ),

            // ── Products grid (max 4, matching Astro) ───────
            productsAv.when(
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text('Error: $e',
                        style: theme.textTheme.bodySmall),
                  ),
                ),
              ),
              data: (either) => either.fold(
                (failure) => SliverToBoxAdapter(
                  child: _FailureBody(
                    failure: failure,
                    onRetry: () =>
                        ref.invalidate(productsProvider(_homeFilter)),
                  ),
                ),
                (products) => products.isEmpty
                    ? SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(t.homeNoProducts,
                                style: theme.textTheme.bodySmall),
                          ),
                        ),
                      )
                    : _ProductsGridSliver(
                        products: products.take(4).toList()),
              ),
            ),

            // ── Lookbook image ──────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlideIn(
                delay: const Duration(milliseconds: 550),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: Image.asset(
                      EditorialAssets.lookbook,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Container(
                        color: EditorialAssets.fallbackColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── CTA Ver todo ────────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: FilledButton(
                    onPressed: () => context.go('/productos'),
                    child: Text(t.homeViewCatalog),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category block — mirrors Astro's CategoryBlock.astro
// ---------------------------------------------------------------------------
class _CategoryBlock extends StatelessWidget {
  final String assetPath;
  final String subtitle;
  final String title;
  final VoidCallback onTap;

  const _CategoryBlock({
    required this.assetPath,
    required this.subtitle,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: EditorialAssets.fallbackColor,
              ),
            ),
            ColoredBox(color: Colors.black.withValues(alpha: 0.25)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Staggered product grid (max 4, no infinite scroll)
// ---------------------------------------------------------------------------
class _ProductsGridSliver extends StatelessWidget {
  final List<Product> products;
  const _ProductsGridSliver({required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _FadeSlideIn(
            delay: Duration(milliseconds: 500 + i * 80),
            child: FsProductCard(product: products[i]),
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable fade + slide animation (pixel-based)
// ---------------------------------------------------------------------------
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double slidePixels;

  const _FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.slidePixels = 14,
  });

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    final curve =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _opacity = curve;
    _translate = Tween<double>(
      begin: widget.slidePixels,
      end: 0,
    ).animate(curve);
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translate.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Failure body (CORS / RLS / generic)
// ---------------------------------------------------------------------------
class _FailureBody extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const _FailureBody({required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;
    final isCors = failure is CorsFailure;
    final isRls = failure is RlsFailure;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCors
                ? Icons.wifi_off
                : isRls
                    ? Icons.lock_outline
                    : Icons.error_outline,
            size: 40,
            color: const Color(0xFF9E9E9E),
          ),
          const SizedBox(height: 20),
          Text(
            isCors
                ? t.homeErrorConnection
                : isRls
                    ? t.homeErrorPermission
                    : t.homeErrorLoad,
            style: theme.textTheme.titleSmall?.copyWith(letterSpacing: 2.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(failure.message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center),
          if (isRls && (failure as RlsFailure).sqlHint != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF5F5F5),
              child: SelectableText(
                (failure as RlsFailure).sqlHint!,
                style:
                    const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: FilledButton(
              onPressed: onRetry,
              child: Text(t.generalRetry),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 200,
            child: OutlinedButton(
              onPressed: () => context.go('/diagnostics'),
              child: Text(t.homeDiagnostics),
            ),
          ),
        ],
      ),
    );
  }
}
