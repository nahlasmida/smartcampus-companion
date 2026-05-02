import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';

class AnimatedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const AnimatedTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        boxShadow: _isFocused
            ? [BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
        )]
            : [],
      ),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          if (_shakeController.isAnimating) {
            final shakeValue = _shakeController.value * 2 * pi;
            return Transform.translate(
              offset: Offset(sin(shakeValue) * 8, 0),
              child: child,
            );
          }
          return child!;
        },
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: AppColors.navy.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            labelStyle: TextStyle(
              color: _isFocused
                  ? AppColors.primary
                  : AppColors.white.withOpacity(0.7),
            ),
            hintStyle: TextStyle(
              color: AppColors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}