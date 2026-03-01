import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/widgets/cart_banner_overlay.dart';
import 'shared/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  debugPrint('[Main] SUPABASE_URL=$supabaseUrl');
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL/SUPABASE_ANON_KEY in .env',
    );
  }

  // Initialize Stripe with publishable key
  final stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.fashionstore';
    await Stripe.instance.applySettings();
  }

  await SupabaseService.init(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        final locale = ref.watch(localeProvider);
        return MaterialApp.router(
          title: 'Fashion Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: S.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
          builder: (context, child) {
            return CartBannerOverlay(
              routeListenable: router.routeInformationProvider,
              router: router,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
