import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../navigation.dart';
import '../theme/lembar_theme.dart';

class MainTabs extends StatelessWidget {
  const MainTabs({super.key, required this.showAccount, required this.child});

  final bool showAccount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LembarMetrics.maxContent,
            ),
            child: NavigationBar(
              selectedIndex: showAccount ? 1 : 0,
              onDestinationSelected: (index) => context.goNamed(
                index == 0 ? LembarRoutes.catalog : LembarRoutes.account,
              ),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_rounded),
                  label: labels.catalogTitle,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: labels.account,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
