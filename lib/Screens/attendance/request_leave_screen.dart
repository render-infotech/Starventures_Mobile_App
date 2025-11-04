// lib/Screens/attendance/request_leave_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:starcapitalventures/core/utils/styles/size_utils.dart';

import '../../core/data/api_client/api_client.dart'; // your provided file

// Adjust path to your ApiClient and ApiConstants


// lib/Screens/attendance/request_leave_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import '../../core/data/api_client/api_client.dart';
import '../../core/utils/appTheme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';

class RequestLeaveScreen extends StatefulWidget {
  const RequestLeaveScreen({super.key});

  @override
  State<RequestLeaveScreen> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends State<RequestLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();

  final _api = ApiClient();

  // Leave types state
  List<LeaveType> _leaveTypes = [];
  LeaveType? _selectedLeaveType;
  bool _loadingTypes = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadLeaveTypes();
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _reasonCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveTypes() async {
    setState(() => _loadingTypes = true);
    try {
      final list = await _api.getLeaveTypes();
      final types = list.map((m) => LeaveType.fromJson(m)).toList();
      setState(() {
        _leaveTypes = types;
        _selectedLeaveType = types.isNotEmpty ? types.first : null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load leave types: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingTypes = false);
    }
  } 

  Future<void> _pickDate(TextEditingController target) async {
    final today = DateTime.now();
    final initial = _parseYmd(target.text) ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(today.year - 2),
      lastDate: DateTime(today.year + 2),
      helpText: 'Select date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF4A2B1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      target.text = _fmtYmd(picked);
      if (_startDateCtrl == target && _endDateCtrl.text.isNotEmpty) {
        final s = _parseYmd(_startDateCtrl.text)!;
        final e = _parseYmd(_endDateCtrl.text)!;
        if (e.isBefore(s)) _endDateCtrl.text = _fmtYmd(s);
      }
    }
  } 

  DateTime? _parseYmd(String v) {
    if (v.isEmpty) return null;
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  } 

  String _fmtYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'; 

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _selectedLeaveType == null) return;

    final start = _parseYmd(_startDateCtrl.text.trim());
    final end = _parseYmd(_endDateCtrl.text.trim());
    if (start == null || end == null) return;

    final payload = {
      "leave_type_id": _selectedLeaveType!.id,
      "start_date": _fmtYmd(start),
      "end_date": _fmtYmd(end),
      "leave_reason": _reasonCtrl.text.trim(),
      "remark": _remarkCtrl.text.trim(),
    };

    setState(() => _submitting = true);
    try {
      final ok = await _api.postLeaveRequest(payload);
      if (ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave request submitted')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit leave request')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  } 

  @override
  Widget build(BuildContext context) {
    final pad = getPadding(all: 16);

    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: appTheme.mintygreen,
          useGreeting: false,
          pageTitle: 'Documents',
          showBack: true,
        ) ,     body: SafeArea(
        child: _loadingTypes
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            padding: pad,
            children: [
              _LabeledField(
                label: 'Leave Type',
                child: DropdownButtonFormField<LeaveType>(
                  value: _selectedLeaveType,
                  items: _leaveTypes
                      .map((t) => DropdownMenuItem<LeaveType>(
                    value: t,
                    child: Text(t.title),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedLeaveType = val;
                  }),
                  decoration: _deco('Select leave type'),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              SizedBox(height: getVerticalSize(12)),
              _LabeledField(
                label: 'Start Date',
                child: TextFormField(
                  controller: _startDateCtrl,
                  readOnly: true,
                  decoration: _deco('YYYY-MM-DD').copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(_startDateCtrl),
                    ),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(height: getVerticalSize(12)),
              _LabeledField(
                label: 'End Date',
                child: TextFormField(
                  controller: _endDateCtrl,
                  readOnly: true,
                  decoration: _deco('YYYY-MM-DD').copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(_endDateCtrl),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final s = _parseYmd(_startDateCtrl.text);
                    final e = _parseYmd(v.trim());
                    if (s != null && e != null && e.isBefore(s)) {
                      return 'End date cannot be before start date';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: getVerticalSize(12)),
              _LabeledField(
                label: 'Reason',
                child: TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  decoration: _deco('Describe your reason'),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(height: getVerticalSize(12)),
              _LabeledField(
                label: 'Remark',
                child: TextFormField(
                  controller: _remarkCtrl,
                  maxLines: 2,
                  decoration: _deco('Any additional note'),
                ),
              ),
              SizedBox(height: getVerticalSize(20)),
              SizedBox(
                width: double.infinity,
                height: getVerticalSize(48),
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2B1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(getSize(12)),
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                    height: getSize(20),
                    width: getSize(20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  )
                      : Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getFontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint,
    contentPadding:
    getPadding(left: 12, right: 12, top: 12, bottom: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(getSize(12)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(getSize(12)),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(getSize(12)),
      borderSide: const BorderSide(color: Color(0xFF4A2B1A)),
    ),
  );
}

// Simple model for dropdown
class LeaveType {
  final int id;
  final String title;
  final int? days;
  LeaveType({required this.id, required this.title, this.days});

  factory LeaveType.fromJson(Map<String, dynamic> j) =>
      LeaveType(id: j['id'] ?? 0, title: j['title'] ?? '', days: j['days']); 
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: getFontSize(13),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: getVerticalSize(6)),
        child,
      ],
    );
  }
}
