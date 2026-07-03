import 'package:flutter/material.dart';

class AdminApplicant {
  const AdminApplicant({
    required this.initials,
    required this.name,
    required this.role,
    required this.avatarColor,
  });

  final String initials;
  final String name;
  final String role;
  final Color avatarColor;
}
