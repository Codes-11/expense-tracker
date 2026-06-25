import 'package:flutter/material.dart';

enum CustomButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonVariant variant;
  final IconData? icon;
  final double height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.filled,
    this.icon,
    this.height = 52,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: variant == CustomButtonVariant.filled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    switch (variant) {
      case CustomButtonVariant.filled:
        return SizedBox(
          width: double.infinity,
          height: height,
          child: FilledButton(
            onPressed: disabled ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: child,
          ),
        );
      case CustomButtonVariant.outlined:
        return SizedBox(
          width: double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color ?? theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: child,
          ),
        );
      case CustomButtonVariant.text:
        return SizedBox(
          height: height,
          child: TextButton(
            onPressed: disabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: color ?? theme.colorScheme.primary,
            ),
            child: child,
          ),
        );
    }
  }
}