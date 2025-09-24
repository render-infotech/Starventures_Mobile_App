import '../../app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom_text_form_field.dart';

class NewApplicationScreen extends StatefulWidget {
  const NewApplicationScreen({super.key});

  @override
  State<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();

  // Dropdown
  final _loanTypes = const [
    'Home Loan',
    'Personal Loan',
    'Car Loan',
    'Education Loan',
  ];
  String? _selectedLoanType;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _amountCtrl.dispose();
    _incomeCtrl.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name
            _FieldLabel('Customer Name'),
            CustomTextFormField(
              controller: _nameCtrl,
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
              controller: _phoneCtrl,
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
              controller: _emailCtrl,
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
              controller: _amountCtrl,
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

            // Loan Type (Dropdown styled like field)
            _FieldLabel('Loan Type'),
            Container(
              margin: getMargin(top: 8, bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(color: appTheme.blueGray10001, width: 1),
              ),
              padding: getPadding(left: 10, right: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select loan type',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black45,
                    ),
                  ),
                  value: _selectedLoanType,
                  items: _loanTypes
                      .map(
                        (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(
                        t,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLoanType = v),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
            ),

            // Monthly Income
            _FieldLabel('Monthly Income'),
            CustomTextFormField(
              controller: _incomeCtrl,
              hintText: 'Enter monthly income',
              textInputType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
              filled: true,
              fillColor: Colors.white,
              margin: getMargin(top: 8, bottom: 24),
            ),

            // Submit CTA
            CustomElevatedButton(
              text: 'Submit Application',
              height: getVerticalSize(48),
              width: double.infinity,
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, getVerticalSize(48)),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                backgroundColor: appTheme.navyBlue,
                foregroundColor: Colors.white,
              ),
              buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    // Basic local validation example
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }
    // TODO: add full form validation / submission
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
