import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../widgets/nav_icon.dart';

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
          FBottomNavigationBarItem(
            icon: NavIcon(
              type: NavIconType.house,
              active: currentIndex == 0,
              color: currentIndex == 0
                  ? colors.primary
                  : colors.mutedForeground,
            ),
            label: const Text(''),
          ),
          FBottomNavigationBarItem(
            icon: NavIcon(
              type: NavIconType.creditCard,
              active: currentIndex == 1,
              color: currentIndex == 1
                  ? colors.primary
                  : colors.mutedForeground,
            ),
            label: const Text(''),
          ),
          FBottomNavigationBarItem(
            icon: NavIcon(
              type: NavIconType.botChat,
              active: currentIndex == 2,
              color: currentIndex == 2
                  ? colors.primary
                  : colors.mutedForeground,
            ),
            label: const Text(''),
          ),
          FBottomNavigationBarItem(
            icon: NavIcon(
              type: NavIconType.chartPie,
              active: currentIndex == 3,
              color: currentIndex == 3
                  ? colors.primary
                  : colors.mutedForeground,
            ),
            label: const Text(''),
          ),
          FBottomNavigationBarItem(
            icon: NavIcon(
              type: NavIconType.user,
              active: currentIndex == 4,
              color: currentIndex == 4
                  ? colors.primary
                  : colors.mutedForeground,
            ),
            label: const Text(''),
          ),
        ],
      ),
      child: navigationShell,
    );
  }
}
