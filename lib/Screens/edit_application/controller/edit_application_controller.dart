// lib/Screens/edit_application/controller/edit_application_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../../../core/data/api_client/api_client.dart';
import '../../../widgets/success_dialog.dart';
import '../../new_application/controller/agents_controller.dart';
import '../../new_application/controller/bank_controller.dart';
import '../../new_application/controller/employee_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../model/edit_application_model.dart';
import '../../application_detail/model/application_detail_model.dart';
import '../../new_application/controller/application_type_controller.dart';
import '../../new_application/controller/application_status_controller.dart';

class EditApplicationController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final coApplicantNameController = TextEditingController(); // ✅ ADD THIS

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final amountController = TextEditingController();
  final incomeController = TextEditingController();
  final notesController = TextEditingController();

  // Controllers for dropdowns - ✅ Non-nullable with late
  late ApplicationTypeController applicationTypeController;
  late ApplicationStatusController applicationStatusController;
  late BankController bankController;
  late AgentsController agentsController;
  late EmployeeController employeeController;
  // ✅ Add ProfileController to get user role
  final ProfileController profileController = Get.find<ProfileController>();

  // Observable variables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var errorMessage = ''.obs;
  var applicationId = ''.obs;
  var bankId = Rx<int?>(null);

  // File uploads with filenames
  var aadhaarFile = Rx<File?>(null);
  var panCardFile = Rx<File?>(null);
  var payslipFile = Rx<File?>(null);
  var bankStatementFile = Rx<File?>(null);

  // File names for display
  var aadhaarFileName = Rx<String?>(null);
  var panFileName = Rx<String?>(null);
  var payslipFileName = Rx<String?>(null);
  var bankStatementFileName = Rx<String?>(null);

  final ImagePicker _picker = ImagePicker();
  // ✅ Add helper methods to check user role
  bool get isCustomer => profileController.role.value.toLowerCase() == 'customer';
  bool get isAgent => profileController.role.value.toLowerCase() == 'agent';
  bool get isEmployee => profileController.role.value.toLowerCase() == 'employee';

  // ✅ Determine if dropdowns should be shown
  bool get shouldShowAgentDropdown => !isCustomer && !isAgent;
  bool get shouldShowEmployeeDropdown => !isCustomer && !isAgent && !isEmployee;

  @override
  void onInit() {
    super.onInit();

    // ✅ Initialize all controllers immediately
    applicationTypeController = Get.put(ApplicationTypeController(), tag: 'edit_app_type');
    applicationStatusController = Get.put(ApplicationStatusController(), tag: 'edit_app_status');
    bankController = Get.put(BankController(), tag: 'edit_bank');
    agentsController = Get.put(AgentsController(), tag: 'edit_agents');
    employeeController = Get.put(EmployeeController(), tag: 'edit_employee');

    // Get application ID from arguments
    final args = Get.arguments;
    if (args != null && args['applicationId'] != null) {
      applicationId.value = args['applicationId'];
      _initializeAndFetch();
    }
  }

  // ✅ Wait for all controllers to be ready
  Future<void> _initializeAndFetch() async {
    try {
      isLoading(true);

      // Wait for all controllers to fetch their data
      await Future.wait([
        applicationTypeController.fetchApplicationTypes(),
        applicationStatusController.fetchApplicationStatuses(),
        bankController.fetchBanks(),
        agentsController.fetchAgents(),
        employeeController.fetchEmployees(),
      ]);

      // Now that all data is loaded, fetch and populate the form
      await fetchAndPopulateData();

    } catch (e) {
      print('❌ Error initializing controllers: $e');
      errorMessage('Failed to initialize form data: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Fetch application detail and populate form
  Future<void> fetchAndPopulateData() async {
    try {
      errorMessage('');

      final response = await _apiClient.fetchApplicationDetail(applicationId.value);
      final detailResponse = ApplicationDetailResponse.fromJson(response);
      final detail = detailResponse.data;

      // Populate form fields
      nameController.text = detail.customerName ?? '';
      phoneController.text = detail.phone ?? '';
      emailController.text = detail.email ?? '';
      amountController.text = detail.loanAmount.toString() == '0.0' ? '' : detail.loanAmount.toStringAsFixed(0);
      incomeController.text = detail.monthlyIncome.toString() == '0.0' ? '' : detail.monthlyIncome.toStringAsFixed(0);
      notesController.text = detail.notes ?? '';
      coApplicantNameController.text = detail.coApplicantName ?? ''; // ✅ ADD THIS

      // ✅ Set selected bank
      if (detail.bank != null && bankController.banks.isNotEmpty) {
        final matchingBank = bankController.banks.firstWhereOrNull(
              (bank) => bank.id == detail.bank!.id,
        );
        if (matchingBank != null) {
          bankController.selectBank(matchingBank);
        }
      }

      // Store bank_id
      if (detail.bank != null) {
        bankId.value = detail.bank!.id;
      }

      // ✅ Set selected agent
      if (detail.agentAssigned != null && agentsController.agents.isNotEmpty) {
        final matchingAgent = agentsController.agents.firstWhereOrNull(
              (agent) => agent.id == detail.agentAssigned!.id,
        );
        if (matchingAgent != null) {
          agentsController.selectAgent(matchingAgent);
        }
      }

      // ✅ Set selected employee
      if (detail.assignedTo != null && employeeController.employees.isNotEmpty) {
        final matchingEmployee = employeeController.employees.firstWhereOrNull(
              (employee) => employee.id == detail.assignedTo!.id,
        );
        if (matchingEmployee != null) {
          employeeController.selectEmployee(matchingEmployee);
        }
      }

      // Set existing file names if available
      if (detail.aadhaarFileUrl != null && detail.aadhaarFileUrl!.isNotEmpty) {
        aadhaarFileName.value = 'Current Aadhaar Document';
      }
      if (detail.panCardFileUrl != null && detail.panCardFileUrl!.isNotEmpty) {
        panFileName.value = 'Current PAN Document';
      }
      if (detail.payslipFileUrl != null && detail.payslipFileUrl!.isNotEmpty) {
        payslipFileName.value = 'Current Payslip Document';
      }
      if (detail.bankStatementFileUrl != null && detail.bankStatementFileUrl!.isNotEmpty) {
        bankStatementFileName.value = 'Current Bank Statement';
      }

      // Set selected loan type
      if (detail.loanType.isNotEmpty && applicationTypeController.applicationTypes.isNotEmpty) {
        final matchingType = applicationTypeController.applicationTypes.firstWhereOrNull(
              (type) => type.name.toLowerCase() == detail.loanType.toLowerCase(),
        );
        if (matchingType != null) {
          applicationTypeController.selectApplicationType(matchingType);
        }
      }

      // Set selected status
      if (detail.status.isNotEmpty && applicationStatusController.applicationStatuses.isNotEmpty) {
        final matchingStatus = applicationStatusController.applicationStatuses.firstWhereOrNull(
              (status) => status.name.toLowerCase() == detail.status.toLowerCase(),
        );
        if (matchingStatus != null) {
          applicationStatusController.selectApplicationStatus(matchingStatus);
        }
      }

    } catch (e) {
      errorMessage('Failed to fetch application data: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load application data',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Submit form
  Future<void> submitEditApplication() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the errors in the form',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (applicationTypeController.selectedApplicationType.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a loan type',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (bankController.selectedBank.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a bank',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (applicationStatusController.selectedApplicationStatus.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select an application status',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    try {
      isSubmitting(true);
      errorMessage('');

      final editModel = EditApplicationModel(
        customerName: nameController.text.trim(),
        coApplicantName: coApplicantNameController.text.trim().isNotEmpty
            ? coApplicantNameController.text.trim()
            : null, // ✅ ADD THIS
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        loanAmount: double.parse(amountController.text.trim()),
        loanTypeId: applicationTypeController.getSelectedApplicationTypeId(),
        statusId: applicationStatusController.getSelectedApplicationStatusId(),
        bankId: bankController.selectedBank.value!.id,
        agentId: agentsController.getSelectedAgentId(),
        employeeId: employeeController.getSelectedEmployeeId(),
        monthlyIncome: double.parse(incomeController.text.trim()),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        aadhaarFile: aadhaarFile.value,
        panCardFile: panCardFile.value,
        payslipFile: payslipFile.value,
        bankStatementFile: bankStatementFile.value,
      );

      final response = await _apiClient.editApplication(applicationId.value, editModel);

      if (response.success) {
        isSubmitting(false);

        showSuccessDialog(
          title: 'Application Updated!',
          message: 'The application has been successfully updated with all the new information.',
          onClose: () {
            Get.back(result: true);
          },
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      isSubmitting(false);
      errorMessage('Failed to update application: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to update application: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // File picker methods
  Future<void> pickImage(ImageSource source, String documentType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String fileName = path.basename(imageFile.path);

        _setDocumentFile(documentType, imageFile, fileName);

        Get.snackbar(
          'Success',
          'Image selected successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> pickPDF(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final File pdfFile = File(result.files.first.path!);
        final String fileName = result.files.first.name;

        _setDocumentFile(documentType, pdfFile, fileName);

        Get.snackbar(
          'Success',
          'PDF selected successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick PDF: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _setDocumentFile(String documentType, File file, String fileName) {
    switch (documentType) {
      case 'aadhaar':
        aadhaarFile.value = file;
        aadhaarFileName.value = fileName;
        break;
      case 'pan':
        panCardFile.value = file;
        panFileName.value = fileName;
        break;
      case 'payslip':
        payslipFile.value = file;
        payslipFileName.value = fileName;
        break;
      case 'bankStatement':
        bankStatementFile.value = file;
        bankStatementFileName.value = fileName;
        break;
    }
  }

  IconData getFileIcon(String? fileName) {
    if (fileName == null) return Icons.upload_file;

    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String getFileTypeText(String? fileName) {
    if (fileName == null) return '';

    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return ' (PDF)';
      case '.jpg':
      case '.jpeg':
      case '.png':
        return ' (Image)';
      default:
        return '';
    }
  }

  void removeDocument(String documentType) {
    switch (documentType) {
      case 'aadhaar':
        aadhaarFile.value = null;
        aadhaarFileName.value = null;
        break;
      case 'pan':
        panCardFile.value = null;
        panFileName.value = null;
        break;
      case 'payslip':
        payslipFile.value = null;
        payslipFileName.value = null;
        break;
      case 'bankStatement':
        bankStatementFile.value = null;
        bankStatementFileName.value = null;
        break;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Customer name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    // Remove any non-digit characters for validation
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedPhone.length != 10 && cleanedPhone.length != 12) {
      return 'Phone number must be 10 or 12 digits';
    }
    return null;
  }


  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Loan amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  String? validateIncome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Monthly income is required';
    }
    final income = double.tryParse(value);
    if (income == null || income <= 0) {
      return 'Please enter a valid income';
    }
    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    coApplicantNameController.dispose(); // ✅ ADD THIS

    phoneController.dispose();
    emailController.dispose();
    amountController.dispose();
    incomeController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
