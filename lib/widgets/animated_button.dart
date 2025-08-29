import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const AnimatedButton({
    super.key,
    required this.label,
    required this.icon,
    this.isLoading = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isLoading ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.primary,
            foregroundColor: textColor ?? Colors.white,
            elevation: 8,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 24),
          label: Text(isLoading ? 'Please wait...' : label),
        ),
      ),
    );
  }
}
