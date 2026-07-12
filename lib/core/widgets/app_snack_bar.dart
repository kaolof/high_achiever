import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The app's standard floating snackbar chrome. Pass a plain [message], or a
/// custom [content] widget when you need more than text (e.g. an icon row).
/// Set [error] to colour it as destructive feedback.
SnackBar appSnackBar({
  String? message,
  Widget? content,
  bool error = false,
}) {
  assert(
    (message == null) != (content == null),
    'Provide exactly one of message or content.',
  );
  return SnackBar(
    content: content ?? Text(message!),
    backgroundColor: error ? AppColors.error : AppColors.primaryContainer,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  );
}
