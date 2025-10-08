import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/appTheme/app_theme.dart';
import '../../new_application/controller/application_type_controller.dart';
import '../../new_application/model/application_type_model.dart';
import '../../../app_routes.dart';

class LoanCategoryHorizontalList extends StatelessWidget {
  const LoanCategoryHorizontalList({super.key});

  // Map application types to appropriate icons
  IconData _getIconForApplicationType(String applicationTypeName) {
    final name = applicationTypeName.toLowerCase();

    if (name.contains('home') || name.contains('mortgage')) {
      return Icons.home;
    } else if (name.contains('car') || name.contains('vehicle') || name.contains('auto')) {
      return Icons.directions_car;
    } else if (name.contains('personal')) {
      return Icons.person;
    } else if (name.contains('credit') || name.contains('card')) {
      return Icons.credit_card;
    } else if (name.contains('business')) {
      return Icons.business;
    } else if (name.contains('education') || name.contains('student')) {
      return Icons.school;
    } else if (name.contains('gold')) {
      return Icons.star;
    } else if (name.contains('property') || name.contains('real estate')) {
      return Icons.location_city;
    } else if (name.contains('construction') || name.contains('building')) {
      return Icons.construction;
    } else if (name.contains('agriculture') || name.contains('farm')) {
      return Icons.agriculture;
    } else {
      return Icons.account_balance; // Default banking icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final ApplicationTypeController controller = ApplicationTypeController.to; // Changed this line

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "Choose your Loan" and "View All"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose your Loan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show all application types in bottom sheet
                  _showAllApplicationTypes(context, controller);
                },
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appTheme.theme,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal scrollable list - CHANGED: Show ALL items instead of just 4
        SizedBox(
          height: 100,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[400],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Failed to load',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.applicationTypes.isEmpty) {
              return Center(
                child: Text(
                  'No loan types available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              );
            }

            // UPDATED: Show ALL items in horizontal scroll instead of limiting to 4
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.applicationTypes.length, // Show ALL items
              itemBuilder: (context, index) {
                final applicationType = controller.applicationTypes[index];

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => _onLoanTypeSelected(applicationType),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: appTheme.theme,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconForApplicationType(applicationType.name),
                            color: appTheme.whiteA700,
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Application type name
                        Text(
                          _formatLoanTypeName(applicationType.name),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // Format loan type name for display (truncate if too long)
  String _formatLoanTypeName(String name) {
    if (name.length <= 12) return name;

    // Try to truncate at word boundary
    final words = name.split(' ');
    if (words.length > 1) {
      String result = words[0];
      for (int i = 1; i < words.length; i++) {
        if ((result + ' ' + words[i]).length <= 12) {
          result += ' ' + words[i];
        } else {
          break;
        }
      }
      return result;
    }

    return name.substring(0, 9) + '...';
  }

  // Handle loan type selection
  void _onLoanTypeSelected(ApplicationTypeModel applicationType) {
    Get.toNamed(
      AppRoutes.newapplication,
      arguments: {'selectedApplicationType': applicationType},
    );
  }

  // Show all application types in bottom sheet (keeping this as backup option)
  void _showAllApplicationTypes(BuildContext context, ApplicationTypeController controller) {
    showModalBottomSheet<ApplicationTypeModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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

            // All application types list
            Flexible(
              child: Obx(() => ListView.builder(
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
                        Navigator.pop(context);
                        _onLoanTypeSelected(applicationType);
                      },
                    ),
                  );
                },
              )),
            ),

            // Safe area bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
