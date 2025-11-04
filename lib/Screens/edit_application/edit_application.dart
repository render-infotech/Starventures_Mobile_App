// lib/Screens/edit_application/edit_application_screen.dart
import '../../app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_text_form_field.dart';
import '../new_application/model/bank_model.dart';
import 'controller/edit_application_controller.dart';
import '../../widgets/custom_elevated_button.dart';

class EditApplication extends StatefulWidget {
  const EditApplication({super.key});

  @override
  State<EditApplication> createState() => _EditApplicationState();
}

class _EditApplicationState extends State<EditApplication> {
  final EditApplicationController controller = Get.put(EditApplicationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Edit Application',
        showBack: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Name
                _FieldLabel('Customer Name'),
                CustomTextFormField(
                  controller: controller.nameController,
                  hintText: 'Enter full name',
                  textInputType: TextInputType.name,
                  validator: controller.validateName,
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),

// ✅ Co-Applicant Name (ADD THIS SECTION)
                _FieldLabel('Co-Applicant Name (Optional)'),
                CustomTextFormField(
                  controller: controller.coApplicantNameController,
                  hintText: 'Enter name (comma-separated)',
                  textInputType: TextInputType.name,
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),

                // Phone Number
                // Phone Number
                _FieldLabel('Phone Number'),
                CustomTextFormField(
                  controller: controller.phoneController,
                  hintText: '+91 XXXXX XXXXX',
                  textInputType: TextInputType.phone,
                  validator: controller.validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13), // ✅ Changed from 10 to 12
                  ],
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),

                // Email Address
                _FieldLabel('Email Address'),
                CustomTextFormField(
                  controller: controller.emailController,
                  hintText: 'customer@email.com',
                  textInputType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),

                // Loan Amount
                _FieldLabel('Loan Amount'),
                CustomTextFormField(
                  controller: controller.amountController,
                  hintText: 'Enter amount in ₹',
                  textInputType: const TextInputType.numberWithOptions(decimal: false),
                  validator: controller.validateAmount,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),
                // ✅ Bank Dropdown (NEW - Add this section)
                _FieldLabel('Select Bank'),
                Obx(() {
                  return Container(
                    margin: getMargin(top: 8, bottom: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.lg,
                      border: Border.all(color: appTheme.blueGray10001, width: 1),
                    ),
                    padding: getPadding(left: 10, right: 10),
                    child: controller.bankController.isLoading.value
                        ? Padding(
                      padding: getPadding(all: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(appTheme.navyBlue),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Loading banks...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                        : DropdownButtonHideUnderline(
                      child: DropdownButton<BankModel>(
                        dropdownColor: appTheme.whiteA700,
                        isExpanded: true,
                        hint: Text(
                          'Select bank',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                        value: controller.bankController.selectedBank.value,
                        items: controller.bankController.banks
                            .map(
                              (bank) => DropdownMenuItem<BankModel>(
                            value: bank,
                            child: Row(
                              children: [
                                // Bank logo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    bank.bankLogo,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.account_balance,
                                        color: appTheme.navyBlue,
                                        size: 24,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    bank.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (BankModel? value) {
                          controller.bankController.selectBank(value);
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  );
                }),
// ✅ Agent Dropdown (NEW)
                // Replace the Agent dropdown section with this:

// ✅ Agent Dropdown (Conditional - Hide for customer and agent roles)
                if (controller.shouldShowAgentDropdown) ...[
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
                    child: controller.agentsController.isLoading.value
                        ? Padding(
                      padding: getPadding(all: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(appTheme.navyBlue),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Loading agents...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                        : DropdownButtonHideUnderline(
                      child: DropdownButton(
                        dropdownColor: appTheme.whiteA700,
                        isExpanded: true,
                        hint: Text(
                          'Select agent',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                        value: controller.agentsController.selectedAgent.value,
                        items: controller.agentsController.agents
                            .map(
                              (agent) => DropdownMenuItem(
                            value: agent,
                            child: Text(
                              agent.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          controller.agentsController.selectAgent(value);
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  )),
                ],

// ✅ Employee Dropdown (Conditional - Hide for customer, agent, and employee roles)
                if (controller.shouldShowEmployeeDropdown) ...[
                  _FieldLabel('Assign To Employee'),
                  Obx(() => Container(
                    margin: getMargin(top: 8, bottom: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.lg,
                      border: Border.all(color: appTheme.blueGray10001, width: 1),
                    ),
                    padding: getPadding(left: 10, right: 10),
                    child: controller.employeeController.isLoading.value
                        ? Padding(
                      padding: getPadding(all: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(appTheme.navyBlue),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Loading employees...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                        : DropdownButtonHideUnderline(
                      child: DropdownButton(
                        dropdownColor: appTheme.whiteA700,
                        isExpanded: true,
                        hint: Text(
                          'Select employee',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                        value: controller.employeeController.selectedEmployee.value,
                        items: controller.employeeController.employees
                            .map(
                              (employee) => DropdownMenuItem(
                            value: employee,
                            child: Text(
                              employee.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          controller.employeeController.selectEmployee(value);
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  )),
                ],

                // Loan Type Drop
                // Loan Type Dropdown
                _FieldLabel('Loan Type'),
                Obx(() => Container(
                  margin: getMargin(top: 8, bottom: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.lg,
                    border: Border.all(color: appTheme.blueGray10001, width: 1),
                  ),
                  padding: getPadding(left: 10, right: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isExpanded: true,
                      hint: Text(
                        'Select loan type',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black45,
                        ),
                      ),
                      value: controller.applicationTypeController.selectedApplicationType.value,
                      items: controller.applicationTypeController.applicationTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.applicationTypeController.selectApplicationType(value);
                      },
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                )),

                // Application Status - Read-only for Customer
                // Application Status Dropdown
// ✅ Only show for non-customer and non-agent roles
                if (!(controller.isCustomer || controller.isAgent)) ...[
                  _FieldLabel('Application Status'),
                  Obx(() {
                    return Container(
                      margin: getMargin(top: 8, bottom: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.lg,
                        border: Border.all(color: appTheme.blueGray10001, width: 1),
                      ),
                      padding: getPadding(left: 10, right: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: Text(
                            'Select application status',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                          value: controller.applicationStatusController.selectedApplicationStatus.value,
                          items: controller.applicationStatusController.applicationStatuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.applicationStatusController.selectApplicationStatus(value);
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                    );
                  }),
                ],

                // Monthly Income
                _FieldLabel('Monthly Income'),
                CustomTextFormField(
                  controller: controller.incomeController,
                  hintText: 'Enter monthly income',
                  textInputType: const TextInputType.numberWithOptions(decimal: false),
                  validator: controller.validateIncome,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),

                // Notes
                _FieldLabel('Notes (Optional)'),
                CustomTextFormField(
                  controller: controller.notesController,
                  hintText: 'Enter additional notes',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
                  contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                  filled: true,
                  fillColor: Colors.white,
                  margin: getMargin(top: 8, bottom: 16),
                ),

                // Document Uploads Section
                _SectionTitle('Document Uploads'),
                SizedBox(height: getVerticalSize(10)),

                // Aadhaar Card Upload
                _FieldLabel('Aadhaar Card'),
                Obx(() => GestureDetector(
                  onTap: () => _showPickerOptions('aadhaar'),
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
                          controller.getFileIcon(controller.aadhaarFileName.value),
                          color: appTheme.navyBlue,
                          size: 20,
                        ),
                        SizedBox(width: getHorizontalSize(10)),
                        Expanded(
                          child: Text(
                            controller.aadhaarFileName.value != null
                                ? '${controller.aadhaarFileName.value!}${controller.getFileTypeText(controller.aadhaarFileName.value)}'
                                : 'Upload Aadhaar Card (Image/PDF)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: controller.aadhaarFileName.value != null ? Colors.black87 : Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (controller.aadhaarFileName.value != null) ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: getHorizontalSize(8)),
                          GestureDetector(
                            onTap: () => controller.removeDocument('aadhaar'),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),

                // PAN Card Upload
                _FieldLabel('PAN Card'),
                Obx(() => GestureDetector(
                  onTap: () => _showPickerOptions('pan'),
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
                          controller.getFileIcon(controller.panFileName.value),
                          color: appTheme.navyBlue,
                          size: 20,
                        ),
                        SizedBox(width: getHorizontalSize(10)),
                        Expanded(
                          child: Text(
                            controller.panFileName.value != null
                                ? '${controller.panFileName.value!}${controller.getFileTypeText(controller.panFileName.value)}'
                                : 'Upload PAN Card (Image/PDF)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: controller.panFileName.value != null ? Colors.black87 : Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (controller.panFileName.value != null) ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: getHorizontalSize(8)),
                          GestureDetector(
                            onTap: () => controller.removeDocument('pan'),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),

                // Payslip Upload
                _FieldLabel('Payslip (Optional)'),
                Obx(() => GestureDetector(
                  onTap: () => _showPickerOptions('payslip'),
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
                          controller.getFileIcon(controller.payslipFileName.value),
                          color: appTheme.navyBlue,
                          size: 20,
                        ),
                        SizedBox(width: getHorizontalSize(10)),
                        Expanded(
                          child: Text(
                            controller.payslipFileName.value != null
                                ? '${controller.payslipFileName.value!}${controller.getFileTypeText(controller.payslipFileName.value)}'
                                : 'Upload Payslip (Image/PDF)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: controller.payslipFileName.value != null ? Colors.black87 : Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (controller.payslipFileName.value != null) ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: getHorizontalSize(8)),
                          GestureDetector(
                            onTap: () => controller.removeDocument('payslip'),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),

                // Bank Statement Upload
                _FieldLabel('Bank Statement (Optional)'),
                Obx(() => GestureDetector(
                  onTap: () => _showPickerOptions('bankStatement'),
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
                          controller.getFileIcon(controller.bankStatementFileName.value),
                          color: appTheme.navyBlue,
                          size: 20,
                        ),
                        SizedBox(width: getHorizontalSize(10)),
                        Expanded(
                          child: Text(
                            controller.bankStatementFileName.value != null
                                ? '${controller.bankStatementFileName.value!}${controller.getFileTypeText(controller.bankStatementFileName.value)}'
                                : 'Upload Bank Statement (Image/PDF)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: controller.bankStatementFileName.value != null ? Colors.black87 : Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (controller.bankStatementFileName.value != null) ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: getHorizontalSize(8)),
                          GestureDetector(
                            onTap: () => controller.removeDocument('bankStatement'),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),

                // Submit Button
                Obx(() => CustomElevatedButton(
                  text: controller.isSubmitting.value ? 'Updating...' : 'Update Application',
                  height: getVerticalSize(48),
                  width: double.infinity,
                  buttonStyle: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, getVerticalSize(48)),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                    backgroundColor: controller.isSubmitting.value
                        ? Colors.grey
                        : appTheme.theme2,
                    foregroundColor: Colors.white,
                  ),
                  buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.submitEditApplication,
                )),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Method to show picker options with PDF and Image support
  Future<void> _showPickerOptions(String documentType) async {
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
                    controller.pickImage(ImageSource.camera, documentType);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Choose Image'),
                  subtitle: const Text('Select from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery, documentType);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Choose PDF'),
                  subtitle: const Text('Select PDF document'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickPDF(documentType);
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

  Widget _SectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A2036),
        fontSize: getFontSize(16),
      ),
    );
  }
}

// Field label widget
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
