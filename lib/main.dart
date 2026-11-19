import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme/lembar_theme.dart';
import 'auth/demo_session.dart';
import 'l10n/app_localizations.dart';

void main() =>
    runApp(ProviderScope(retry: (_, _) => null, child: const LembarApp()));

class LembarApp extends ConsumerStatefulWidget {
  const LembarApp({super.key, this.initialLocation = '/courses'});
  final String initialLocation;
  @override
  ConsumerState<LembarApp> createState() => _LembarAppState();
}

class _LembarAppState extends ConsumerState<LembarApp> {
  late final _router = createRouter(
    initialLocation: widget.initialLocation,
    isSignedIn: () => ref.read(sessionProvider) != null,
  );

  @override
  void initState() {
    super.initState();
    ref.listenManual(sessionProvider, (_, _) => _router.refresh());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appName,
    routerConfig: _router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: lembarTheme(),
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: child!,
    ),
  );
}
