// lib/controllers/create_application_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../applications/controller/application_controller.dart';
import '../../home_screen_main/controller/home_screen_controller.dart';
import '../model/create_application_model.dart';

class CreateApplicationController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final amountController = TextEditingController();
  final incomeController = TextEditingController();
  final notesController = TextEditingController();
  final coApplicantNameController = TextEditingController(); // ✅ ADD THIS

  // Observable variables
  var isSubmitting = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  // File management observables
  var aadhaarFile = Rx<File?>(null);
  var panFile = Rx<File?>(null);
  var aadhaarFileName = Rx<String?>(null);
  var panFileName = Rx<String?>(null);

  // Dropdown selections - Fixed: Store string names instead of maps
  var selectedLoanType = Rx<String?>(null);


  @override
  void onInit() {
    super.onInit();
    _clearMessages();
  }

  // Get loan type ID from selected name - Fixed: Proper mapping
  int getLoanTypeId(String loanTypeName) {
    switch (loanTypeName) {
      case 'Home Loan':
        return 1;
      case 'Personal Loan':
        return 2;
      case 'Car Loan':
        return 3;
      case 'Education Loan':
        return 4;
      default:
        return 1; // Default to Home Loan
    }
  }

  // File picking methods with compression check
  Future<void> pickImage(ImageSource source, bool isAadhaar) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = file.lengthSync();

        print('Original image size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

        if (isAadhaar) {
          aadhaarFile.value = file;
          aadhaarFileName.value = pickedFile.name;
        } else {
          panFile.value = file;
          panFileName.value = pickedFile.name;
        }
      }
    } catch (e) {
      _setErrorMessage('Error picking image: $e');
    }
  }

  Future<void> pickPDF(bool isAadhaar) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;

        final fileSize = platformFile.size; // ✅ SAFE (no direct file access)
        final file = File(platformFile.path!); // Only needed for upload

        print('PDF file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

        if (isAadhaar) {
          aadhaarFile.value = file;
          aadhaarFileName.value = platformFile.name;
        } else {
          panFile.value = file;
          panFileName.value = platformFile.name;
        }
      }
    } catch (e) {
      _setErrorMessage('Error picking PDF: $e');
    }
  }

  // Helper methods for file management
  IconData getFileIcon(String? fileName) {
    if (fileName == null) return Icons.upload_file;
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    }
    return Icons.photo;
  }

  String getFileTypeText(String? fileName) {
    if (fileName == null) return '';
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return ' (PDF)';
    }
    return ' (Image)';
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter customer name';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter loan amount';
    }
    return null;
  }

  // Form validation
  bool validateForm({
    required int? applicationTypeId,
    required int? applicationStatusId,
    required int? agentId,
    required bool requireAgent, // add this
    required int? bankId, // ✅ Added
    required int? employeeId, // ✅ Added

    required bool requireEmployee, // ✅ Added

  }) {
    _clearMessages();

    // Validate text fields
    if (validateName(nameController.text) != null) {
      _setErrorMessage(validateName(nameController.text)!);
      return false;
    }
    if (requireEmployee && employeeId == null) {
      _setErrorMessage('Please select an employee');
      return false;
    }
    if (validatePhone(phoneController.text) != null) {
      _setErrorMessage(validatePhone(phoneController.text)!);
      return false;
    }

    if (validateEmail(emailController.text) != null) {
      _setErrorMessage(validateEmail(emailController.text)!);
      return false;
    }

    if (validateAmount(amountController.text) != null) {
      _setErrorMessage(validateAmount(amountController.text)!);
      return false;
    }

    // Remove the selectedLoanType validation


    if (bankId == null) {
      _setErrorMessage('Please select a bank');
      return false;
    }
    if (applicationTypeId == null) {
      _setErrorMessage('Please select application type');
      return false;
    }

    if (applicationStatusId == null) {
      _setErrorMessage('Please select application status');
      return false;
    }
    if (requireEmployee && employeeId == null) {
      _setErrorMessage('Please select an employee');
      return false;
    }
    if (requireAgent && agentId == null) {
      _setErrorMessage('Please select an agent');
      return false;
    }

    // Validate file uploads
    if (aadhaarFile.value == null) {
      _setErrorMessage('Please upload Aadhaar card');
      return false;
    }

    if (panFile.value == null) {
      _setErrorMessage('Please upload PAN card');
      return false;
    }

    return true;
  }


  Future<void> submitApplication({
    required int? applicationTypeId,
    required int? applicationStatusId,
    int? agentId,
    required bool requireAgent,
    int? bankId,
    int? employeeId,
    required bool requireEmployee,
  }) async {
    if (!validateForm(
      applicationTypeId: applicationTypeId,
      applicationStatusId: applicationStatusId,
      agentId: agentId,
      requireAgent: requireAgent,
      bankId: bankId,
      employeeId: employeeId,
      requireEmployee: requireEmployee,
    )) {
      return;
    }

    try {
      isSubmitting(true);
      _clearMessages();

      final applicationData = CreateApplicationModel(
        customerName: nameController.text.trim(),
        coApplicantName: coApplicantNameController.text.trim().isNotEmpty
            ? coApplicantNameController.text.trim()
            : null, // ✅ ADD THIS
        phoneNumber: phoneController.text.trim(),
        email: emailController.text.trim(),
        loanAmount: amountController.text.trim(),
        loanTypeId: applicationTypeId!,
        statusId: applicationStatusId!,
        agentId: requireAgent ? agentId : null,
        monthlyIncome: incomeController.text.trim(),
        notes: notesController.text.trim(),
        aadhaarFile: aadhaarFile.value,
        panCardFile: panFile.value,
        bankId: bankId,
        employeeId: requireEmployee ? employeeId : null,
      );

      final response = await _apiClient.createApplication(applicationData);
      print('Submitting application with Agent ID: $agentId');

      if (response.success) {
        _setSuccessMessage(response.message.isNotEmpty
            ? response.message
            : 'Application submitted successfully!');

        _clearForm();

        // ✅ STEP 1: Refresh ApplicationListController
        print('🔄 Refreshing applications list...');
        if (Get.isRegistered<ApplicationListController>()) {
          final appController = Get.find<ApplicationListController>();
          await appController.refreshApplications();
          print('✅ Applications list refreshed');
        } else {
          print('⚠️ ApplicationListController not registered');
        }

        // ✅ STEP 2: Show success dialog
        Get.dialog(
          AlertDialog(
            backgroundColor: appTheme.whiteA700,
            title: const Text('Success'),
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Application submitted successfully!'),
            actions: [
              CustomElevatedButton(
                text: 'OK',
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Close form screen

                  // ✅ STEP 3: Navigate to Applications tab
                  if (Get.isRegistered<HomeOneContainer1Controller>()) {
                    final homeController = Get.find<HomeOneContainer1Controller>();
                    homeController.selectedIndex.value = 2; // Applications tab
                    print('📱 Navigated to Applications tab');
                  }
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.theme,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                buttonTextStyle: Theme.of(Get.context!).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                height: 36,
                width: 80,
              ),
            ],
          ),
        );
      } else {
        _setErrorMessage(response.message.isNotEmpty
            ? response.message
            : 'Failed to submit application');
      }

    } catch (e) {
      _setErrorMessage('Failed to submit application: $e');
      print('Error submitting application: $e');
    } finally {
      isSubmitting(false);
    }
  }


  // Clear form data
  void _clearForm() {
    nameController.clear();
    coApplicantNameController.clear(); // ✅ ADD THIS

    phoneController.clear();
    emailController.clear();
    amountController.clear();
    incomeController.clear();
    notesController.clear();

    selectedLoanType.value = null;
    aadhaarFile.value = null;
    panFile.value = null;
    aadhaarFileName.value = null;
    panFileName.value = null;
  }

  // Message management
  void _setErrorMessage(String message) {
    errorMessage.value = message;
    successMessage.value = '';
  }

  void _setSuccessMessage(String message) {
    successMessage.value = message;
    errorMessage.value = '';
  }

  void _clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Refresh method for pull-to-refresh
  Future<void> refreshForm() async {
    _clearForm();
    _clearMessages();
  }

  @override
  void onClose() {
    // Dispose text controllers
    nameController.dispose();
    phoneController.dispose();
    coApplicantNameController.dispose(); // ✅ ADD THIS

    emailController.dispose();
    amountController.dispose();
    incomeController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
