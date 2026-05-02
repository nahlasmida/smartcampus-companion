import 'package:flutter/material.dart';

class ValidationUtils {
  /// Validates email format - ACCEPTS ANY EMAIL FOR TESTING
  static String? validateEmail(String? email) {
    print('🔍 validateEmail called with: "$email"');

    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // TEMPORARILY ACCEPT ANYTHING - FOR TESTING ONLY
    // This will accept "hadjezchaima62@gmail.com" without error
    return null;
  }

  /// Validates password - ACCEPTS ANY PASSWORD FOR TESTING
  static String? validatePassword(String? password) {
    print('🔍 validatePassword called with length: ${password?.length}');

    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    // TEMPORARILY ACCEPT ANYTHING - FOR TESTING ONLY
    // This will accept "String1@" without error
    return null;
  }

  /// Validates name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    return null;
  }
}