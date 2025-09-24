import 'package:flutter/material.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import 'package:starcapitalventures/core/utils/styles/custom_border_radius.dart';
import '../../widgets/custom_app_bar.dart';
import '../applications/model/application_model.dart';
import 'application_detail_controller/application_detail_controller.dart';
import 'model/application_detail_model.dart';

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.userId,
    required this.applicationId,
  });

  final String userId;
  final String applicationId;

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final _c = ApplicationDetailController();

  @override
  void initState() {
    super.initState();
    _c.fetchDetail(userId: widget.userId, applicationId: widget.applicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Application Detail',
        showBack: true,
      ),
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final d = _c.detail;
          if (d == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(header: d.header),

                SizedBox(height: getVerticalSize(16)),
                Text('Application Progress', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A2036))),

                SizedBox(height: getVerticalSize(10)),
                ...d.progress.map((p) => _ProgressRow(step: p)).toList(),

                SizedBox(height: getVerticalSize(16)),
                Text('Uploaded Documents', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A2036))),
                SizedBox(height: getVerticalSize(10)),
                _DocsGrid(docs: d.documents),

                SizedBox(height: getVerticalSize(16)),
                Text('Action History', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A2036))),
                SizedBox(height: getVerticalSize(10)),
                ...d.activities.map((a) => _ActivityCard(item: a)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.header});
  final ApplicationHeader header;

  @override
  Widget build(BuildContext context) {
    final amount = _inr(header.amount);
    final (label, bg, fg) = _statusChip(header.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: getHorizontalSize(10),
            offset: Offset(0, getVerticalSize(4)),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF5), width: getHorizontalSize(1)),
      ),
      padding: getPadding(all: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  header.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A2036)),
                ),
              ),
              Container(
                padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadii.pill,
                  border: Border.all(color: bg.withOpacity(0.6), width: getHorizontalSize(1)),
                ),
                child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: getVerticalSize(4)),
          Text('${header.loanType} • ₹$amount', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87)),

          SizedBox(height: getVerticalSize(12)),
          Row(
            children: [
              Expanded(child: _InfoPill(title: 'Application ID', value: header.appId)),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(child: _InfoPill(title: 'Applied Date', value: _date(header.appliedDate))),
            ],
          ),
          SizedBox(height: getVerticalSize(12)),
          Row(
            children: [
              Expanded(child: _InfoPill(title: 'Monthly Income', value: '₹${_inr(header.monthlyIncome)}')),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(child: _InfoPill(title: 'Credit Score', value: header.creditScore.toString())),
            ],
          ),
        ],
      ),
    );
  }

  static String _inr(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    while (rest.length > 2) {
      buf.write('${rest.substring(rest.length - 2)},');
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) buf.write(rest);
    final commas = buf.toString().split('').reversed.join();
    return '$commas,$last3';
  }

  static (String, Color, Color) _statusChip(ApplicationStatus st) {
    switch (st) {
      case ApplicationStatus.processing:
        return ('PROCESSING', const Color(0xFFE7F0FF), const Color(0xFF4F8BFF));
      case ApplicationStatus.approved:
        return ('APPROVED', const Color(0xFFE8FFF4), const Color(0xFF22A16B));
      case ApplicationStatus.pending:
        return ('PENDING', const Color(0xFFFFF3D7), const Color(0xFFB78900));
      case ApplicationStatus.rejected:
        return ('REJECTED', const Color(0xFFFFE6E6), const Color(0xFFD22E2E));
    }
  }

  static String _date(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(left: 12, right: 12, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: AppRadii.md,
        border: Border.all(color: const Color(0xFFE3EAF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontWeight: FontWeight.w500)),
          SizedBox(height: getVerticalSize(4)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF1A2036), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.step});
  final ProgressStep step;

  @override
  Widget build(BuildContext context) {
    final isComplete = step.state == ProgressState.complete;
    final isActive = step.state == ProgressState.active;


    final circleColor = isComplete ? const Color(0xFF22A16B) : (isActive ? const Color(0xFF4F8BFF) : const Color(0xFFE0E6F1));
    final textColor = isComplete || isActive ? const Color(0xFF1A2036) : Colors.black54;
    final bullet = isComplete
        ? Icons.check_circle
        : isActive
        ? null
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Index/Marker
        SizedBox(
          width: getHorizontalSize(28),
          child: Column(
            children: [
              Container(
                width: getHorizontalSize(20),
                height: getHorizontalSize(20),
                decoration: BoxDecoration(
                  color: isComplete ? const Color(0xFFE8FFF4) : (isActive ? const Color(0xFFE7F0FF) : const Color(0xFFF2F4F8)),
                  borderRadius: AppRadii.pill,
                  border: Border.all(color: circleColor, width: 2),
                ),
                alignment: Alignment.center,
                child: isComplete
                    ? Icon(Icons.check, size: getHorizontalSize(14), color: const Color(0xFF22A16B))
                    : isActive
                    ? Text('${step.index}', style: TextStyle(fontSize: getFontSize(12), fontWeight: FontWeight.w700, color: const Color(0xFF4F8BFF)))
                    : Text('${step.index}', style: TextStyle(fontSize: getFontSize(12), fontWeight: FontWeight.w600, color: Colors.black45)),
              ),
              // vertical connector line
              Container(
                width: getHorizontalSize(2),
                height: getVerticalSize(22),
                color: const Color(0xFFE0E6F1),
              ),
            ],
          ),
        ),
        SizedBox(width: getHorizontalSize(8)),
        // Title + subtitle
        Expanded(
          child: Padding(
            padding: getPadding(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: textColor)),
                SizedBox(height: getVerticalSize(2)),
                Text(step.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DocsGrid extends StatelessWidget {
  const _DocsGrid({required this.docs});
  final List<UploadDoc> docs;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: getHorizontalSize(12),
        mainAxisSpacing: getVerticalSize(12),
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, i) {
        final d = docs[i];
        return Container(
          decoration: BoxDecoration(
            color: d.uploaded ? const Color(0xFFEFFFF5) : Colors.white,
            borderRadius: AppRadii.lg,
            border: Border.all(
              color: const Color(0xFF16A34A).withOpacity(0.35),
              style: BorderStyle.solid,
            ),
          ),
          padding: getPadding(left: 12, right: 12, top: 12, bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined, color: const Color(0xFF4C5B7E)),
              SizedBox(height: getVerticalSize(10)),
              Text(d.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF1A2036), fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});
  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: getMargin(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: getHorizontalSize(10),
            offset: Offset(0, getVerticalSize(4)),
          ),
        ],
      ),
      padding: getPadding(all: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A2036))),
          SizedBox(height: getVerticalSize(4)),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          SizedBox(height: getVerticalSize(8)),
          Text(_fmt(item.time), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final hour12 = ((d.hour + 11) % 12) + 1;
    final m2 = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} at $hour12:$m2 $ampm';
  }
}
