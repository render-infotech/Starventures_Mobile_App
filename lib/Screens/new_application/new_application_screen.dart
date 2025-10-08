// lib/screens/new_application_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:starcapitalventures/Screens/new_application/model/agents_model.dart';
import '../../app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_text_form_field.dart';
import 'package:image_picker/image_picker.dart';

import 'controller/agents_controller.dart';
import 'controller/application_status_controller.dart';
import 'controller/application_type_controller.dart';
import 'controller/create_application_controller.dart';
import 'model/application_status_model.dart';
import 'model/application_type_model.dart';

class NewApplicationScreen extends StatefulWidget {
  const NewApplicationScreen({super.key});

  @override
  State<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  // GetX Controllers
  final ApplicationStatusController _statusController = Get.put(ApplicationStatusController());
  final ApplicationTypeController _typeController = ApplicationTypeController.to;
  final CreateApplicationController _createController = Get.put(CreateApplicationController());
  final AgentsController _agentsController = Get.put(AgentsController());
  @override
  void initState() {
    super.initState();

    // Handle pre-selected application type from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['selectedApplicationType'] != null) {
      final selectedType = arguments['selectedApplicationType'] as ApplicationTypeModel;
      _typeController.preSelectApplicationType(selectedType);
    }
  }

  @override
  void dispose() {
    // Clean up GetX controllers
    Get.delete<ApplicationStatusController>();
    Get.delete<ApplicationTypeController>();
    Get.delete<CreateApplicationController>();
    super.dispose();
  }

  // Method to show picker options with PDF and Image support
  Future<void> _showPickerOptions(bool isAadhaar) async {
    showModalBottomSheet(
      backgroundColor: appTheme.whiteA700,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Document Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Capture with camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _createController.pickImage(ImageSource.camera, isAadhaar);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Choose Image'),
                  subtitle: const Text('Select from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _createController.pickImage(ImageSource.gallery, isAadhaar);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Choose PDF'),
                  subtitle: const Text('Select PDF document'),
                  onTap: () {
                    Navigator.pop(context);
                    _createController.pickPDF(isAadhaar);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'New Application',
        showBack: true,
      ),
      body: Obx(() => SingleChildScrollView(
        padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show error message if any
            if (_createController.errorMessage.value.isNotEmpty)
              Container(
                margin: getMargin(bottom: 16),
                padding: getPadding(all: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _createController.errorMessage.value,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            // Show success message if any
            if (_createController.successMessage.value.isNotEmpty)
              Container(
                margin: getMargin(bottom: 16),
                padding: getPadding(all: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _createController.successMessage.value,
                        style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            // Customer Name
            _FieldLabel('Customer Name'),
            CustomTextFormField(
              controller: _createController.nameController,
              hintText: 'Enter full name',
              textInputType: TextInputType.name,
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 16),
            ),

            // Phone Number
            _FieldLabel('Phone Number'),
            CustomTextFormField(
              controller: _createController.phoneController,
              hintText: '+91 XXXXX XXXXX',
              textInputType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 16),
            ),

            // Email Address
            _FieldLabel('Email Address'),
            CustomTextFormField(
              controller: _createController.emailController,
              hintText: 'customer@email.com',
              textInputType: TextInputType.emailAddress,
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 16),
            ),

            // Loan Amount
            _FieldLabel('Loan Amount'),
            CustomTextFormField(
              controller: _createController.amountController,
              hintText: 'Enter amount in ₹',
              textInputType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 16),
            ),


            // Change this section in NewApplicationScreen
            _FieldLabel('Loan Type'), // Changed from 'Application Type'
            Obx(() => Container(
              margin: getMargin(top: 8, bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(color: appTheme.blueGray10001, width: 1),
              ),
              padding: getPadding(left: 10, right: 10),
              child: _typeController.isLoading.value
                  ? Padding(
                padding: getPadding(all: 14),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appTheme.navyBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Loading loan types...', // Changed text
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              )
                  : DropdownButtonHideUnderline(
                child: DropdownButton<ApplicationTypeModel>(
                  dropdownColor: appTheme.whiteA700,
                  isExpanded: true,
                  hint: Text(
                    'Select loan type', // Changed hint text
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black45,
                    ),
                  ),
                  value: _typeController.selectedApplicationType.value,
                  items: _typeController.applicationTypes
                      .map((type) => DropdownMenuItem<ApplicationTypeModel>(
                    value: type,
                    child: Text(
                      type.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (ApplicationTypeModel? value) {
                    _typeController.selectApplicationType(value);
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
            )),

            // Application Status (GetX Dynamic Dropdown)
            _FieldLabel('Application Status'),
            Obx(() => Container(
              margin: getMargin(top: 8, bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(color: appTheme.blueGray10001, width: 1),
              ),
              padding: getPadding(left: 10, right: 10),
              child: _statusController.isLoading.value
                  ? Padding(
                padding: getPadding(all: 14),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appTheme.navyBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Loading application statuses...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              )
                  : DropdownButtonHideUnderline(
                child: DropdownButton<ApplicationStatusModel>(
                  dropdownColor: appTheme.whiteA700,
                  isExpanded: true,
                  hint: Text(
                    'Select application status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black45,
                    ),
                  ),
                  value: _statusController.selectedApplicationStatus.value,
                  items: _statusController.applicationStatuses
                      .map((status) => DropdownMenuItem<ApplicationStatusModel>(
                    value: status,
                    child: Text(
                      status.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (ApplicationStatusModel? value) {
                    _statusController.selectApplicationStatus(value);
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
            )),

            // Monthly Income

            _FieldLabel('Select Agent'),
            Obx(() => Container(
              margin: getMargin(top: 8, bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(color: appTheme.blueGray10001, width: 1),
              ),
              padding: getPadding(left: 10, right: 10),
              child: _agentsController.isLoading.value
                  ? Padding(
                padding: getPadding(all: 14),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(appTheme.navyBlue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Loading agents...'),
                  ],
                ),
              )
                  : DropdownButtonHideUnderline(
                child: DropdownButton<AgentModel>(
                  dropdownColor: appTheme.whiteA700,
                  isExpanded: true,
                  hint: Text('Select an agent',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black45,
                    ),),
                  value: _agentsController.selectedAgent.value,
                  items: _agentsController.agents
                      .map((agent) => DropdownMenuItem<AgentModel>(
                    value: agent,
                    child: Text('${agent.name} ',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Colors.black87,)
                    ),
                  ))
                      .toList(),
                  onChanged: (AgentModel? value) {
                    _agentsController.selectAgent(value);
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
            )),
            _FieldLabel('Monthly Income'),
            CustomTextFormField(
              controller: _createController.incomeController,
              hintText: 'Enter monthly income',
              textInputType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 16),
            ),

            // Notes Field
            _FieldLabel('Additional Notes'),
            CustomTextFormField(
              controller: _createController.notesController,
              hintText: 'Add your notes here',
              textInputType: TextInputType.multiline,
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 16),
              maxLines: 4,
            ),

            // Aadhaar Card Upload
            _FieldLabel('Aadhaar Card'),
            Obx(() => GestureDetector(
              onTap: () => _showPickerOptions(true),
              child: Container(
                margin: getMargin(top: 8, bottom: 16),
                width: double.infinity,
                padding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: appTheme.blueGray10001, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _createController.getFileIcon(_createController.aadhaarFileName.value),
                      color: appTheme.navyBlue,
                      size: 20,
                    ),
                    SizedBox(width: getHorizontalSize(10)),
                    Expanded(
                      child: Text(
                        _createController.aadhaarFileName.value != null
                            ? '${_createController.aadhaarFileName.value!}${_createController.getFileTypeText(_createController.aadhaarFileName.value)}'
                            : 'Upload Aadhaar Card (Image/PDF)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _createController.aadhaarFileName.value != null ? Colors.black87 : Colors.black45,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_createController.aadhaarFileName.value != null)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ),
            )),

            // PAN Card Upload
            _FieldLabel('PAN Card'),
            Obx(() => GestureDetector(
              onTap: () => _showPickerOptions(false),
              child: Container(
                margin: getMargin(top: 8, bottom: 24),
                width: double.infinity,
                padding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: appTheme.blueGray10001, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _createController.getFileIcon(_createController.panFileName.value),
                      color: appTheme.navyBlue,
                      size: 20,
                    ),
                    SizedBox(width: getHorizontalSize(10)),
                    Expanded(
                      child: Text(
                        _createController.panFileName.value != null
                            ? '${_createController.panFileName.value!}${_createController.getFileTypeText(_createController.panFileName.value)}'
                            : 'Upload PAN Card (Image/PDF)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _createController.panFileName.value != null ? Colors.black87 : Colors.black45,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_createController.panFileName.value != null)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ),
            )),

            // Submit CTA - Fixed: Handle null safety properly
            Obx(() => CustomElevatedButton(
              text: _createController.isSubmitting.value
                  ? 'Submitting...'
                  : 'Submit Application',
              height: getVerticalSize(48),
              width: double.infinity,
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, getVerticalSize(48)),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                backgroundColor: _createController.isSubmitting.value
                    ? Colors.grey
                    : appTheme.theme,
                foregroundColor: Colors.white,
              ),
              buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              onPressed: _createController.isSubmitting.value
                  ? null
                  : () {
                _createController.submitApplication(
                  applicationTypeId: _typeController.getSelectedApplicationTypeId(),
                  applicationStatusId: _statusController.getSelectedApplicationStatusId(),
                  agentId: _agentsController.getSelectedAgentId(),
                );

              },
            )),
          ],
        ),
      )),
    );
  }
}

// Small helper for section labels
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: getFontSize(13),
      ),
    );
  }
}
