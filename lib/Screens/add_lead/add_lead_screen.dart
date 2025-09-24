import 'package:flutter/services.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart'; // if not already exported via app_export
import '../../widgets/custom_elevated_button.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Dropdown
  final _sources = const [
    'Walk-in',
    'Referral',
    'Website',
    'Social Media',
    'Phone Call',
    'Email',
  ];
  String? _selectedSource;

  // Form key
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Add Lead',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Full Name'),
              CustomTextFormField(
                controller: _nameCtrl,
                hintText: 'Enter customer name',
                textInputType: TextInputType.name,
                contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                filled: true,
                fillColor: Colors.white,
                margin: getMargin(top: 8, bottom: 16),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
              ),

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
                validator: (v) => (v == null || v.length != 10) ? 'Enter 10-digit phone' : null,
              ),

              _FieldLabel('Email Address'),
              CustomTextFormField(
                controller: _emailCtrl,
                hintText: 'customer@email.com',
                textInputType: TextInputType.emailAddress,
                contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                filled: true,
                fillColor: Colors.white,
                margin: getMargin(top: 8, bottom: 16),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
                  return ok ? null : 'Enter a valid email';
                },
              ),

              _FieldLabel('Lead Source'),
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
                      'Select source',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black45,
                      ),
                    ),
                    value: _selectedSource,
                    items: _sources
                        .map((s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(
                        s,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSource = v),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
              ),

              _FieldLabel('Interest/Requirements'),
              Container(
                margin: getMargin(top: 8, bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: appTheme.blueGray10001, width: 1),
                ),
                child: TextFormField(
                  controller: _notesCtrl,
                  minLines: 4,
                  maxLines: 6,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Describe customer's loan requirements and preferences...",
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black45),
                    isDense: true,
                    contentPadding: getPadding(left: 14, right: 14, top: 14, bottom: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // CTA
              CustomElevatedButton(
                text: 'Add Lead',
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
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    // TODO: persist lead
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lead added')),
    );
    Navigator.of(context).maybePop();
  }
}

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
