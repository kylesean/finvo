import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Bottom-sheet anchor-day picker for the budget form.
///
/// M-28: extracted from `_AnchorDayPicker` inside `budget_form_page` so the
/// page stays focused on form state while this helper owns the day-wheel UI.
class BudgetAnchorDayPicker extends StatefulWidget {
  final int selectedDay;
  final ValueChanged<int> onSelected;

  const BudgetAnchorDayPicker({
    super.key,
    required this.selectedDay,
    required this.onSelected,
  });

  @override
  State<BudgetAnchorDayPicker> createState() => _BudgetAnchorDayPickerState();
}

class _BudgetAnchorDayPickerState extends State<BudgetAnchorDayPicker> {
  late FPickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FPickerController(indexes: [widget.selectedDay - 1]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              t.budget.selectAnchorDay,
              style: AppTextStyles.dialogTitle(theme),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FPicker(
                control: .managed(controller: _controller),
                children: [
                  FPickerWheel(
                    loop: false,
                    children: List.generate(31, (index) {
                      final day = index + 1;
                      return Center(
                        child: Text(
                          t.budget.dayOfMonth(day: day.toString()),
                          style: AppTextStyles.pickerItem(theme),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: .outline,
                      onPress: () => Navigator.pop(context),
                      child: Text(t.common.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FButton(
                      onPress: () {
                        final index = _controller.value[0];
                        widget.onSelected(index + 1);
                      },
                      child: Text(t.common.confirm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
