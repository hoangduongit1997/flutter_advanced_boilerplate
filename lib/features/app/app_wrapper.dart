import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_boilerplate/features/app/blocs/app_cubit.dart';
import 'package:flutter_advanced_boilerplate/features/auth/login/blocs/auth_cubit.dart';
import 'package:flutter_advanced_boilerplate/modules/dependency_injection/di.dart';
import 'package:flutter_advanced_boilerplate/utils/router.gr.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangePlatformBrightness() async {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

/*     if (AdaptiveTheme.of(context).mode == AdaptiveThemeMode.system) {
      final lightTheme = await createTheme(brightness: Brightness.light);
      final darkTheme = await createTheme(brightness: Brightness.dark);

      if (!mounted) return;
      AdaptiveTheme.of(context).setTheme(
        light: lightTheme,
        dark: darkTheme,
      );
      SystemChrome.setSystemUIOverlayStyle(
        createOverlayStyle(
          brightness: isDark ? Brightness.light : Brightness.dark,
          colors: isDark ? darkTheme.colorScheme : lightTheme.colorScheme,
        ),
      );
    } */

    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AppCubit>()),
        BlocProvider(create: (context) => getIt<AuthCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Remove splash screen after initialization.
          FlutterNativeSplash.remove();

          state.whenOrNull(
            authenticated: (_) {
              context.router.replaceAll([const AppNavigatorRoute()]);
            },
            unauthenticated: () {
              context.router.replaceAll([LoginScreenRoute()]);
            },
          );
        },
        child: RepaintBoundary(
          key: _key,
          child: const AutoRouter(),
        ),
      ),
    );
  }
}
