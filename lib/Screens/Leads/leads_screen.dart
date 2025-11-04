// lib/Screens/Leads/leads_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/Leads/widgets/LeadCard.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../lead_detail/lead_detail_screen.dart';
import 'leads_controller.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  late final LeadsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(LeadsController());
  }

  @override
  void dispose() {
    Get.delete<LeadsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Lead Management',
      ),
      body: Obx(() {
        // Loading state
        if (_controller.isLoading.value && _controller.leads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme.theme),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading leads...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }

        // Error state
        if (_controller.hasError.value) {
          return Center(
            child: Padding(
              padding: getPadding(all: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.blue.shade100,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.cloud_off_outlined,
                      size: 56,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Unable to load leads',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2036),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _controller.refreshLeads(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.theme,
                      foregroundColor: Colors.white,
                      padding: getPadding(
                          left: 24, right: 24, top: 14, bottom: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (_controller.leads.isEmpty) {
          return Center(
            child: Padding(
              padding: getPadding(all: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade50,
                          Colors.grey.shade100,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_alt_outlined,
                      size: 56,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'No leads yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2036),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Leads list
        return RefreshIndicator(
          onRefresh: () => _controller.refreshLeads(),
          color: appTheme.theme,
          child: Column(
            children: [


              // Leads list
              Expanded(
                child: // In your LeadsScreen - Update the ListView.builder
                ListView.builder(
                  padding: getPadding(left: 16, right: 16, top: 8, bottom: 16),
                  itemCount: _controller.leads.length,
                  itemBuilder: (context, index) {
                    final lead = _controller.leads[index];
                    return InkWell(
                      onTap: () {
                        // Navigate to lead detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LeadDetailScreen(
                              leadId: lead.id.toString(),
                            ),
                          ),
                        );
                      },
                      child: LeadCard(
                        leadId: lead.id.toString(),  // Pass lead ID
                        name: lead.name,
                        source: lead.leadSource,
                        phone: lead.phone,
                        email: lead.email,
                        note: lead.notes ?? 'No notes available',
                        addedWhen: lead.formattedDate,
                        accentColor: lead.sourceColor,
                        onConvert: () {
                          print('Convert lead: ${lead.id}');
                        },
                      ),
                    );
                  },

                ),

              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
