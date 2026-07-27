import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_design.dart';
import '../theme/app_tokens.dart';

/// Shows the same feature content using the platform's expected presentation:
/// a rounded Cupertino popup on iOS and a draggable Material 3 sheet on
/// Android. Business logic and returned values remain identical.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final tokens = context.tokens;
  if (context.usesCupertinoDesign) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (sheetContext) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: ColoredBox(
                color: tokens.surface,
                child: builder(sheetContext),
              ),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: builder,
  );
}
