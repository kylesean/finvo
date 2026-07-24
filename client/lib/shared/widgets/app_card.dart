import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A wrapper around [FCard] that restores automatic padding behavior.
///
/// In forui >= 0.24, FCard no longer applies `style.padding` to its child.
/// This widget reads the resolved style's padding and wraps the child
/// accordingly, maintaining backward-compatible behavior.
class AppCard extends StatelessWidget {
  final FCardStyleDelta style;
  final Clip clipBehavior;
  final Widget? child;

  const AppCard({
    super.key,
    this.style = const .context(),
    this.clipBehavior = Clip.none,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: style,
      clipBehavior: clipBehavior,
      builder: (context, cardStyle, child) {
        return Padding(padding: cardStyle.padding, child: child);
      },
      child: child,
    );
  }
}
