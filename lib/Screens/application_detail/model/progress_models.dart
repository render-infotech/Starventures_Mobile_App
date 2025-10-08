// lib/models/progress_models.dart
enum ProgressState { complete, active, pending }

class ProgressStep {
  final int index;
  final String title;
  final String subtitle;
  final ProgressState state;

  ProgressStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.state,
  });
}
