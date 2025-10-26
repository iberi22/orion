import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized user feedback system for the Orion app
class FeedbackManager {
  static final FeedbackManager _instance = FeedbackManager._internal();
  factory FeedbackManager() => _instance;
  FeedbackManager._internal();

  // Global scaffold messenger key for showing snackbars
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show success message to user
  static void showSuccess(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: FeedbackType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show error message to user
  static void showError(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: FeedbackType.error,
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  /// Show warning message to user
  static void showWarning(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: FeedbackType.warning,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Show info message to user
  static void showInfo(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: FeedbackType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show custom snackbar
  static void _showSnackBar({
    required String message,
    required FeedbackType type,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    // Clear any existing snackbars
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_getIconForType(type), color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColorForType(type),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      action:
          actionLabel != null && onActionPressed != null
              ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed,
              )
              : null,
    );

    messenger.showSnackBar(snackBar);
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              title,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: GoogleFonts.lato(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  cancelText,
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDestructive ? Colors.red[600] : Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  confirmText,
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// Show input dialog
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    required String hint,
    String? initialValue,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              title,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                keyboardType: keyboardType,
                maxLength: maxLength,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: validator,
                autofocus: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  cancelText,
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? true) {
                    Navigator.of(context).pop(controller.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  confirmText,
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    controller.dispose();
    return result;
  }

  /// Provide haptic feedback
  static void hapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Get icon for feedback type
  static IconData _getIconForType(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
    }
  }

  /// Get color for feedback type
  static Color _getColorForType(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Colors.green[600]!;
      case FeedbackType.error:
        return Colors.red[600]!;
      case FeedbackType.warning:
        return Colors.orange[600]!;
      case FeedbackType.info:
        return Colors.blue[600]!;
    }
  }
}

/// Feedback types
enum FeedbackType { success, error, warning, info }

/// Haptic feedback types
enum HapticFeedbackType { light, medium, heavy, selection }
