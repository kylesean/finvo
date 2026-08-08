import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/layout/widgets/nav_icon.dart';
import 'package:finvo/i18n/strings.g.dart';

/// The five fixed bottom-navigation destinations, in render order.
///
/// Using an enum instead of raw int indices removes the magic-number tab
/// indices (previously 0..4) scattered across the page and makes reordering or
/// adding a destination type-safe: each item's index derives from
/// [BottomTab.values], so the highlight and the navigation branch can never
/// drift apart.
enum BottomTab {
  home,
  budget,
  chat,
  statistics,
  profile;

  NavIconType get icon => switch (this) {
    BottomTab.home => NavIconType.house,
    BottomTab.budget => NavIconType.creditCard,
    BottomTab.chat => NavIconType.botChat,
    BottomTab.statistics => NavIconType.chartPie,
    BottomTab.profile => NavIconType.user,
  };

  String label() => switch (this) {
    BottomTab.home => t.navigation.home,
    BottomTab.budget => t.navigation.budget,
    BottomTab.chat => t.navigation.chat,
    BottomTab.statistics => t.navigation.statistics,
    BottomTab.profile => t.navigation.profile,
  };
}

/// Bottom navigation page - using Forui design system
///
/// Combines FScaffold + FBottomNavigationBar, following Forui best practices.
/// Icons use [NavIcon] (inline SVG via flutter_svg) to achieve the
/// outline → filled state switch that Lucide font icons cannot provide.
class BottomPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final currentIndex = navigationShell.currentIndex;

    return FScaffold(
      childPad: false,
      footer: FBottomNavigationBar(
        index: currentIndex,
        onChange: (index) => navigationShell.goBranch(index),
        children: [
          for (final tab in BottomTab.values)
            FBottomNavigationBarItem(
              icon: NavIcon(
                type: tab.icon,
                active: currentIndex == tab.index,
                color: currentIndex == tab.index
                    ? colors.primary
                    : colors.mutedForeground,
              ),
              semanticsLabel: tab.label(),
            ),
        ],
      ),
      child: navigationShell,
    );
  }
}
