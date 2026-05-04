import 'package:flutter/material.dart';

class ValidationUtils {
  /// Validates email format
  static String? validateEmail(String? email) {
    print('🔍 validateEmail called with: "$email"');

    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates password - Requires 8+ chars, uppercase, number, special char
  static String? validatePassword(String? password) {
    print('🔍 validatePassword called with length: ${password?.length}');

    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character';
    }

    return null;
  }

  /// Validates name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Full name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates phone number (optional)
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Optional field
    }
    final phoneRegex = RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
    if (!phoneRegex.hasMatch(phone) && phone.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}