// lib/Screens/Leads/lead_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../Leads/edit_lead_screen.dart';
import 'lead_detail_controller.dart';

class LeadDetailScreen extends StatefulWidget {
  final String leadId;

  const LeadDetailScreen({
    super.key,
    required this.leadId,
  });

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late final LeadDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(LeadDetailController());
    _controller.fetchLeadDetail(widget.leadId);
  }

  @override
  void dispose() {
    Get.delete<LeadDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Lead Details',
        showBack: true,
      ),
      body: Obx(() {
        // Loading state
        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: appTheme.theme2,
            ),
          );
        }

        // Error state
        if (_controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: appTheme.gray300,
                ),
                SizedBox(height: getVerticalSize(24)),
                Text(
                  'Unable to Load Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: getVerticalSize(8)),
                Padding(
                  padding: getPadding(left: 40, right: 40),
                  child: Text(
                    'Something went wrong while loading the lead details. Please try again.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: getVerticalSize(24)),
                ElevatedButton.icon(
                  onPressed: () => _controller.refreshLeadDetail(widget.leadId),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.theme2,
                    foregroundColor: Colors.white,
                    padding: getPadding(left: 24, right: 24, top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.lg,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Content
        final lead = _controller.leadDetail.value;
        if (lead == null) {
          return Center(
            child: Text(
              'No lead data available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return RefreshIndicator(
          color: appTheme.theme2,
          onRefresh: () => _controller.refreshLeadDetail(widget.leadId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: getPadding(all: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // lib/Screens/leads/lead_detail_screen.dart
// Add this Edit button in your header card (similar to application detail)

                Padding(
                  padding: getMargin(left: 300, bottom: 5),
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
                    onPressed: () {
                      Get.to(() => const EditLeadScreen())?.then((result) {
                        // Refresh the detail screen if edit was successful
                        if (result == true) {
                          _controller.refreshLeadDetail(widget.leadId);
                        }
                      });
                    },
                  ),
                ),

                // Lead Name Card
                Container(
                  width: double.infinity,
                  padding: getPadding(all: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.lg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: appTheme.theme2.withOpacity(0.1),
                        child: Text(
                          lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: appTheme.theme2,
                          ),
                        ),
                      ),
                      SizedBox(width: getHorizontalSize(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: getVerticalSize(6)),
                            Container(
                              padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(lead.status.name).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(lead.status.name).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                lead.status.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(lead.status.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: getVerticalSize(16)),

                // Contact Information
                _buildSectionCard(
                  context,
                  title: 'Contact Information',
                  icon: Icons.contact_phone,
                  children: [
                    _buildInfoRow(context, Icons.phone, 'Phone', lead.phone),
                    _buildInfoRow(context, Icons.email, 'Email', lead.email),
                    _buildInfoRow(context, Icons.source, 'Lead Source', _formatLeadSource(lead.leadSource)),
                  ],
                ),

                SizedBox(height: getVerticalSize(16)),

                // Additional Details
                _buildSectionCard(
                  context,
                  title: 'Additional Details',
                  icon: Icons.info_outline,
                  children: [
                    if (lead.assignedTo != null) ...[
                      _buildInfoRow(
                          context,
                          Icons.person_outline,
                          'Assigned To',
                          lead.assignedTo!.name
                      ),
                      if (lead.assignedTo!.phone.isNotEmpty)
                        _buildInfoRow(
                            context,
                            Icons.phone_android,
                            'Assigned To Phone',
                            lead.assignedTo!.phone
                        ),
                      if (lead.assignedTo!.email.isNotEmpty)
                        _buildInfoRow(
                            context,
                            Icons.email_outlined,
                            'Assigned To Email',
                            lead.assignedTo!.email
                        ),
                      if (lead.assignedTo!.employeeId != null)
                        _buildInfoRow(
                            context,
                            Icons.badge_outlined,
                            'Employee ID',
                            lead.assignedTo!.employeeId!
                        ),
                    ],
                    _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Created At',
                        _formatDate(lead.createdAt)
                    ),
                    _buildInfoRow(
                        context,
                        Icons.update,
                        'Last Updated',
                        _formatDate(lead.updatedAt)
                    ),
                    _buildInfoRow(
                        context,
                        Icons.toggle_on,
                        'Converted',
                        lead.converted == 1 ? 'Yes' : 'No'
                    ),
                  ],
                ),

                SizedBox(height: getVerticalSize(16)),

                // Notes Section - Only show if notes exist
                if (lead.notes != null && lead.notes!.isNotEmpty)
                  _buildSectionCard(
                    context,
                    title: 'Notes',
                    icon: Icons.notes,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: getPadding(all: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          lead.notes!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: getVerticalSize(24)),

                // // Action Button
                // if (lead.converted == 0)
                //   SizedBox(
                //     width: double.infinity,
                //     child: ElevatedButton.icon(
                //       onPressed: () {
                //         // TODO: Implement convert to application
                //         print('Convert lead: ${lead.id}');
                //         Get.snackbar(
                //           'Convert Lead',
                //           'Converting lead to application...',
                //           snackPosition: SnackPosition.BOTTOM,
                //           backgroundColor: appTheme.theme2.withOpacity(0.9),
                //           colorText: Colors.white,
                //         );
                //       },
                //       icon: const Icon(Icons.transform, size: 20),
                //       label: const Text('Convert to Application'),
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: appTheme.theme2,
                //         foregroundColor: Colors.white,
                //         padding: getPadding(top: 16, bottom: 16),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: AppRadii.lg,
                //         ),
                //         elevation: 2,
                //       ),
                //     ),
                //   )
                // else
                //   Container(
                //     width: double.infinity,
                //     padding: getPadding(all: 16),
                //     decoration: BoxDecoration(
                //       color: Colors.green.shade50,
                //       borderRadius: AppRadii.lg,
                //       border: Border.all(
                //         color: Colors.green.shade200,
                //         width: 1,
                //       ),
                //     ),
                //     child: Row(
                //       children: [
                //         Icon(Icons.check_circle, color: Colors.green.shade700),
                //         SizedBox(width: getHorizontalSize(12)),
                //         Expanded(
                //           child: Text(
                //             'This lead has already been converted to an application',
                //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //               color: Colors.green.shade700,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: appTheme.theme2),
              SizedBox(width: getHorizontalSize(8)),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: getVerticalSize(16)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      IconData icon,
      String label,
      String value
      ) {
    return Padding(
      padding: getPadding(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appTheme.theme2.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: appTheme.theme2),
          ),
          SizedBox(width: getHorizontalSize(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: getVerticalSize(4)),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    // Dynamic color mapping based on status from API
    final statusLower = status.toLowerCase();

    if (statusLower.contains('new')) return Colors.blue;
    if (statusLower.contains('contact')) return Colors.orange;
    if (statusLower.contains('qualif')) return Colors.purple;
    if (statusLower.contains('lost') || statusLower.contains('reject')) return Colors.red;
    if (statusLower.contains('won') || statusLower.contains('convert')) return Colors.green;

    return Colors.grey;
  }

  String _formatLeadSource(String source) {
    // Format lead source for display
    return source.split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      // Show relative time for recent dates
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      }

      // Show full date for older dates
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '${months[date.month]} ${date.day}, ${date.year} at $hour:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateStr;
    }
  }
}
