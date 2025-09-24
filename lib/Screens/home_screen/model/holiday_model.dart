// lib/Screens/home_screen/widgets/holiday_cards.dart
import 'dart:ui';

class HolidayItem {
  HolidayItem({required this.dateLabel, required this.title, required this.stripe});
  final String dateLabel;
  final String title;
  final Color stripe;
}

// Public list (no underscore)
final List<HolidayItem> holidays = [
  HolidayItem(dateLabel: 'Aug 15, 2025', title: 'Independence Day', stripe: const Color(0xFF19A97B)),
  HolidayItem(dateLabel: 'Oct 2, 2025',  title: 'Gandhi Jayanti',   stripe: const Color(0xFFFFA000)),
];
