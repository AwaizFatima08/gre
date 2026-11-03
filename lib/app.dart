import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_prep/l10n/gen/app_localizations.dart';
import 'package:gre_prep/router.dart';
import 'package:gre_prep/ui/theme.dart';

class GreApp extends ConsumerWidget {
  const GreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    routerConfig: ref.watch(routerProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
