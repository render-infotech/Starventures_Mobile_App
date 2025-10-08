import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:starcapitalventures/app_routes.dart';
import 'package:starcapitalventures/core/utils/appTheme/app_theme.dart';
import 'package:starcapitalventures/core/utils/loading_service.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import 'package:starcapitalventures/core/utils/styles/custom_border_radius.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_app_bar.dart';
import '../applications/model/application_model.dart';
import 'action_history_widget.dart';
import 'application_detail_controller/application_detail_controller.dart';
import 'model/application_detail_model.dart';
import '../../../core/utils/loading_service.dart';

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
  final ApplicationDetailController _controller = Get.put(ApplicationDetailController());

  @override
  void initState() {
    super.initState();
    _controller.fetchApplicationDetail(widget.applicationId);
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
      body: Obx(() {
        if (_controller.isLoading.value) {
          return LoadingService.widget(
            message: 'Loading application details...',
          );
        }


        if (_controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                SizedBox(height: getVerticalSize(16)),
                Text(
                  'Failed to load application details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: getVerticalSize(8)),
                Text(
                  _controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: getVerticalSize(16)),
                ElevatedButton(
                  onPressed: () => _controller.refreshApplicationDetail(widget.applicationId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final detail = _controller.applicationDetail.value;
        if (detail == null) {
          return const Center(
            child: Text('No application details found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _controller.refreshApplicationDetail(widget.applicationId),
          child: SingleChildScrollView(
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(

                  padding: getMargin(left: 300,bottom: 5),
                  child: CustomElevatedButton(
                    text: 'Edit',
                    height: 30,
                    width: 60,
                    buttonStyle: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.sm,
                      ),
                      backgroundColor: appTheme.theme2,
                      foregroundColor: Colors.white,
                    ),
                    buttonTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    // In your ApplicationDetailScreen, update the Edit button onPressed:
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.editApplication,
                        arguments: {'applicationId': widget.applicationId},
                      )?.then((result) {
                        // Refresh the detail screen if edit was successful
                        if (result == true) {
                          _controller.refreshApplicationDetail(widget.applicationId);
                        }
                      });
                    },

                  ),
                ),
                _HeaderCard(detail: detail),
                SizedBox(height: getVerticalSize(16)),

                if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                  _SectionTitle('Notes'),
                  SizedBox(height: getVerticalSize(10)),
                  _NotesCard(notes: detail.notes!),
                  SizedBox(height: getVerticalSize(16)),
                ],

                _ApplicationProgressSection(currentStatus: detail.status),
                SizedBox(height: getVerticalSize(16)),
                _SectionTitle('Uploaded Documents'),
                SizedBox(height: getVerticalSize(10)),
                _DocumentsGrid(detail: detail),
                SizedBox(height: getVerticalSize(10)),

                _SectionTitle('Other Documents'),
                SizedBox(height: getVerticalSize(10)),

// Fixed Row with Expanded widgets for equal width buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        text: 'Add More Documents',
                        height: 40, // Increased height for better touch area
                        buttonStyle: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.lg,
                          ),
                          backgroundColor: appTheme.theme2,
                          foregroundColor: Colors.white,
                        ),
                        buttonTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () {
                      Get.toNamed(AppRoutes.addOtherDocuments);
                        },
                      ),
                    ),
                    SizedBox(width: getHorizontalSize(12)), // Spacing between buttons
                    Expanded(
                      child: CustomElevatedButton(
                        text: 'View Documents',
                        height: 40,
                        buttonStyle: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.lg,
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: appTheme.theme2,
                          side: BorderSide(color: appTheme.theme2, width: 1), // Add border for outline style
                        ),
                        buttonTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: appTheme.theme2,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () {
                          // Add your navigation logic here
                          print('View Documents pressed');
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: getVerticalSize(16)),

                SizedBox(height: getVerticalSize(16)),
                _SectionTitle('Assignment Information'),
                SizedBox(height: getVerticalSize(10)),
                _AssignmentCard(detail: detail),
                _SectionTitle('Action History'),

                ActionHistoryWidget(
                  applicationId: widget.applicationId,
                  onUpdate: () {
                    // Refresh the main application detail when history is updated
                    _controller.refreshApplicationDetail(widget.applicationId);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _SectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A2036),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.detail});
  final ApplicationDetailData detail;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _statusChip(detail.statusEnum);
    final formattedDate = DateFormat('MMM dd, yyyy').format(detail.createdAt);

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
      padding: getPadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.customerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2036),
                  ),
                ),
              ),
              Container(
                padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadii.pill,
                  border: Border.all(color: bg.withOpacity(0.6), width: getHorizontalSize(1)),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getVerticalSize(8)),
          Text(
            '${detail.loanType} • ${detail.formattedAmount}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: getVerticalSize(4)),
          Text(
            'Phone: ${detail.phone}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),

          SizedBox(height: getVerticalSize(4)),
          Text(
            'Email: ${detail.email}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),

          SizedBox(height: getVerticalSize(16)),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  title: 'Application ID',
                  value: detail.id,
                ),
              ),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(
                child: _InfoPill(
                  title: 'Applied Date',
                  value: formattedDate,
                ),
              ),
            ],
          ),

          SizedBox(height: getVerticalSize(12)),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  title: 'Monthly Income',
                  value: detail.formattedMonthlyIncome,
                ),
              ),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(
                child: _InfoPill(
                  title: 'Loan Type',
                  value: detail.loanType,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color, Color) _statusChip(ApplicationStatus st) {
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
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: getVerticalSize(4)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1A2036),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
      ),
      child: Text(
        notes,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF1A2036),
        ),
      ),
    );
  }
}

class _DocumentsGrid extends StatelessWidget {
  const _DocumentsGrid({required this.detail});
  final ApplicationDetailData detail;

  @override
  Widget build(BuildContext context) {
    final documents = [
      if (detail.aadhaarFileUrl != null)
        DocumentItem(name: 'Aadhar Card', url: detail.aadhaarFileUrl!, uploaded: true),
      if (detail.panCardFileUrl != null)
        DocumentItem(name: 'PAN Card', url: detail.panCardFileUrl!, uploaded: true),
      if (detail.payslipFileUrl != null)
        DocumentItem(name: 'Payslip', url: detail.payslipFileUrl!, uploaded: true)
      else
        DocumentItem(name: 'Payslip', url: '', uploaded: false),
      if (detail.bankStatementFileUrl != null)
        DocumentItem(name: 'Bank Statement', url: detail.bankStatementFileUrl!, uploaded: true)
      else
        DocumentItem(name: 'Bank Statement', url: '', uploaded: false),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: getHorizontalSize(12),
        mainAxisSpacing: getVerticalSize(12),
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, i) {
        final doc = documents[i];
        return Container(
          decoration: BoxDecoration(
            color: doc.uploaded ? const Color(0xFFEFFFF5) : const Color(0xFFFFF3D7),
            borderRadius: AppRadii.lg,
            border: Border.all(
              color: doc.uploaded
                  ? const Color(0xFF16A34A).withOpacity(0.35)
                  : const Color(0xFFB78900).withOpacity(0.35),
            ),
          ),
          padding: getPadding(all: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                doc.uploaded ? Icons.check_circle : Icons.upload_file,
                color: doc.uploaded ? const Color(0xFF16A34A) : const Color(0xFFB78900),
              ),
              SizedBox(height: getVerticalSize(8)),
              Text(
                doc.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF1A2036),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.detail});
  final ApplicationDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.assignedTo != null) ...[
            Text(
              'Assigned To',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: getVerticalSize(4)),
            Text(
              detail.assignedTo!.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1A2036),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: getVerticalSize(12)),
          ],

          if (detail.createdBy != null) ...[
            Text(
              'Created By',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: getVerticalSize(4)),
            Text(
              detail.createdBy!.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1A2036),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DocumentItem {
  final String name;
  final String url;
  final bool uploaded;

  DocumentItem({
    required this.name,
    required this.url,
    required this.uploaded,
  });
}
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({super.key, required this.step});
  final ProgressStep step;

  @override
  Widget build(BuildContext context) {
    final isComplete = step.state == ProgressState.complete;
    final isActive = step.state == ProgressState.active;
    final isPending = step.state == ProgressState.pending;

    // Color scheme based on state
    final circleColor = isComplete
        ? const Color(0xFF22A16B)  // Green for completed
        : isActive
        ? const Color(0xFF4F8BFF)  // Blue for current/active
        : const Color(0xFFE0E6F1); // Gray for pending

    final backgroundColor = isComplete
        ? const Color(0xFFE8FFF4)  // Light green background
        : isActive
        ? const Color(0xFFE7F0FF)  // Light blue background
        : const Color(0xFFF2F4F8); // Light gray background

    final textColor = isComplete || isActive
        ? const Color(0xFF1A2036)
        : Colors.black54;

    return Padding(
      padding: getPadding(bottom: step.index == 8 ? 0 : 16), // No padding for last item
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          SizedBox(
            width: getHorizontalSize(32),
            child: Column(
              children: [
                Container(
                  width: getHorizontalSize(24),
                  height: getHorizontalSize(24),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: AppRadii.pill,
                    border: Border.all(color: circleColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: isComplete
                      ? Icon(
                      Icons.check,
                      size: getHorizontalSize(16),
                      color: const Color(0xFF22A16B)
                  )
                      : isActive
                      ? Container(
                    width: getHorizontalSize(8),
                    height: getHorizontalSize(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F8BFF),
                      shape: BoxShape.circle,
                    ),
                  )
                      : Text(
                      '${step.index}',
                      style: TextStyle(
                          fontSize: getFontSize(11),
                          fontWeight: FontWeight.w600,
                          color: Colors.black45
                      )
                  ),
                ),
                // Connector line (except for last item)
                if (step.index < 8) ...[
                  SizedBox(height: getVerticalSize(4)),
                  Container(
                    width: getHorizontalSize(2),
                    height: getVerticalSize(32),
                    color: isComplete
                        ? const Color(0xFF22A16B).withOpacity(0.3)
                        : const Color(0xFFE0E6F1),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: getHorizontalSize(12)),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    step.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor
                    )
                ),
                SizedBox(height: getVerticalSize(2)),
                Text(
                    step.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54
                    )
                ),
                // Status badge for current step
                if (isActive) ...[
                  SizedBox(height: getVerticalSize(4)),
                  Container(
                    padding: getPadding(bottom: 8, top: 8, left: 12, right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F8BFF).withOpacity(0.1),
                      borderRadius: AppRadii.sm,
                      border: Border.all(
                        color: const Color(0xFF4F8BFF).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Processing',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4F8BFF),
                        fontWeight: FontWeight.w500,
                        fontSize: getFontSize(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationProgressSection extends StatelessWidget {
  const _ApplicationProgressSection({required this.currentStatus});

  final String currentStatus;

  List<ProgressStep> _buildProgressSteps() {
    // Status order from your API response
    final statusOrder = [
      {'name': 'Login', 'subtitle': 'Application submitted'},
      {'name': 'Technical', 'subtitle': 'Technical verification'},
      {'name': 'FI-Legal', 'subtitle': 'Financial & legal check'},
      {'name': 'PD', 'subtitle': 'Personal discussion'},
      {'name': 'Saction', 'subtitle': 'Sanction process'},
      {'name': 'Agreement', 'subtitle': 'Agreement signing'},
      {'name': 'MODT-Registration', 'subtitle': 'MODT & registration'},
      {'name': 'Disbursement', 'subtitle': 'Amount disbursement'},
    ];

    // Find current status index
    int currentIndex = statusOrder.indexWhere((status) => status['name'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Default to first if not found

    return statusOrder.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> status = entry.value;

      ProgressState state;
      if (index < currentIndex) {
        state = ProgressState.complete;
      } else if (index == currentIndex) {
        state = ProgressState.active;
      } else {
        state = ProgressState.pending;
      }

      return ProgressStep(
        index: index + 1,
        title: status['name']!,
        subtitle: status['subtitle']!,
        state: state,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildProgressSteps();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE9EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: getPadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Progress',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2036),
            ),
          ),
          SizedBox(height: getVerticalSize(4)),
          Text(
            'Track your application status',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
          SizedBox(height: getVerticalSize(16)),
          Column(
            children: steps.map((step) => _ProgressRow(step: step)).toList(),
          ),
        ],
      ),
    );
  }
}

// At the top of your file, add:
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

/*import 'package:flutter/material.dart';
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
*/