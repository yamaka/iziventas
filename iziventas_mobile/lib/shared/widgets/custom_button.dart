import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? label; // Optional label
  final Widget? child; // Optional child
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  }) : assert(label != null || child != null, 'Either label or child must be provided.');

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: child ??
          Text(
            label!,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
    );
  }
}