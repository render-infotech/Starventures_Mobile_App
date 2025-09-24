import 'package:flutter/material.dart';

class LeadUpdateItem {
  LeadUpdateItem({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.timeAgo,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final String timeAgo;
}

final List<LeadUpdateItem> leadUpdates = [
  LeadUpdateItem(
    title: 'Application Approved',
    subtitle: 'Priya Patel - Home Loan',
    statusLabel: 'SUCCESS',
    statusBg: const Color(0xFFE8FFF4),
    statusFg: const Color(0xFF22A16B),
    timeAgo: '2 hours ago',
  ),
  LeadUpdateItem(
    title: 'New Lead Added',
    subtitle: 'Rajesh Kumar - Personal Loan',
    statusLabel: 'NEW',
    statusBg: const Color(0xFFFFF4E0),
    statusFg: const Color(0xFFB78900),
    timeAgo: '5 hours ago',
  ),
];
