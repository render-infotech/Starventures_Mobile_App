import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/appTheme/app_theme.dart';
import '../../new_application/controller/application_type_controller.dart';
import '../../new_application/model/application_type_model.dart';

class ApplicationTypeBottomSheet extends StatelessWidget {
  const ApplicationTypeBottomSheet({super.key});

  static Future<ApplicationTypeModel?> show(BuildContext context) {
    return showModalBottomSheet<ApplicationTypeModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ApplicationTypeBottomSheet(),
    );
  }

  // Map application types to appropriate icons
  IconData _getIconForApplicationType(String applicationTypeName) {
    final name = applicationTypeName.toLowerCase();

    if (name.contains('mortgage') || name.contains('home loan')) {
      return Icons.home;
    } else if (name.contains('personal')) {
      return Icons.person;
    } else if (name.contains('business')) {
      return Icons.business;
    } else if (name.contains('car') || name.contains('vehicle') || name.contains('auto')) {
      return Icons.directions_car;
    } else if (name.contains('construction') || name.contains('building')) {
      return Icons.construction;
    } else if (name.contains('education') || name.contains('student')) {
      return Icons.school;
    } else if (name.contains('gold')) {
      return Icons.star;
    } else if (name.contains('property') || name.contains('real estate')) {
      return Icons.location_city;
    } else if (name.contains('agriculture') || name.contains('farm')) {
      return Icons.agriculture;
    } else if (name.contains('medical') || name.contains('health')) {
      return Icons.medical_services;
    } else {
      return Icons.description; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final ApplicationTypeController controller = ApplicationTypeController.to; // Changed this line

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Apply for a Loan or Service',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Content
          Flexible(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: appTheme.theme,
                    ),
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error Loading Application Types',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.refreshApplicationTypes(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.mintygreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.applicationTypes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Application Types Found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.applicationTypes.length,
                itemBuilder: (context, index) {
                  final applicationType = controller.applicationTypes[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appTheme.theme,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForApplicationType(applicationType.name),
                          color: appTheme.whiteA700,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        applicationType.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                      onTap: () {
                        controller.selectApplicationType(applicationType);
                        Navigator.pop(context, applicationType);
                      },
                    ),
                  );
                },
              );
            }),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
