// lib/Screens/attendance/view_leaves_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/core/utils/styles/size_utils.dart';
import '../../core/data/api_client/api_client.dart';
import '../../core/utils/appTheme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import 'model/monthly_leave.dart';

class ViewLeavesScreen extends StatefulWidget {
  const ViewLeavesScreen({super.key});

  @override
  State<ViewLeavesScreen> createState() => _ViewLeavesScreenState();
}

class _ViewLeavesScreenState extends State<ViewLeavesScreen> {
  final _api = ApiClient();
  bool _loading = false;
  List<MonthlyLeave> _items = [];

  late int _year;
  int _month = DateTime.now().month;

  final List<int> _years = List<int>.generate(7, (i) => DateTime.now().year - 3 + i);

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final raw = await _api.getMonthlyLeaves(month: _month, year: _year);
      final data = raw.map((e) => MonthlyLeave.fromJson(e)).toList();
      setState(() => _items = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load leaves: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'reject': // 🔥 FIX for API value
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final pad = getPadding(all: 16);
    final months = const [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];

    return Scaffold(
      appBar: CustomAppBar(
        useGreeting: false,
        pageTitle: 'Attendance',
        showBack: true,
        onBack: () => Get.back(),
        backgroundColor: appTheme.theme,


        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: pad,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _month,
                    items: List.generate(12, (i) {
                      final m = i + 1;
                      return DropdownMenuItem<int>(
                        value: m,
                        child: Text(months[i]),
                      );
                    }),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _month = v);
                      _fetch();
                    },
                    decoration: _deco('Month'),
                  ),
                ),
                SizedBox(width: getHorizontalSize(12)),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _year,
                    items: _years
                        .map((y) => DropdownMenuItem<int>(
                      value: y,
                      child: Text('$y'),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _year = v);
                      _fetch();
                    },
                    decoration: _deco('Year'),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? const Center(child: Text('No leaves found'))
                : ListView.builder(
              padding: pad.copyWith(top: 0),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final it = _items[i];
                return Container(
                  margin: EdgeInsets.only(bottom: getVerticalSize(12)),
                  padding: getPadding(all: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(getSize(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Status chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              it.leaveTypeTitle.isEmpty ? 'Leave' : it.leaveTypeTitle,
                              style: TextStyle(
                                fontSize: getFontSize(16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getHorizontalSize(10),
                              vertical: getVerticalSize(4),
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(it.status).withOpacity(0.12),
                              border: Border.all(color: _statusColor(it.status)),
                              borderRadius: BorderRadius.circular(getSize(20)),
                            ),
                            child: Text(
                              it.status,
                              style: TextStyle(
                                color: _statusColor(it.status),
                                fontSize: getFontSize(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: getVerticalSize(8)),

                      // Dates row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _kv('From', _fmt(it.startDate)),
                          _kv('To', _fmt(it.endDate)),
                          _kv('Days', it.totalLeaveDays),
                        ],
                      ),

                      if (it.reason.isNotEmpty) ...[
                        SizedBox(height: getVerticalSize(8)),
                        Text(
                          it.reason,
                          style: TextStyle(
                            fontSize: getFontSize(13),
                            color: Colors.black87,
                          ),
                        ),
                      ],

                      if (it.remark.isNotEmpty) ...[
                        SizedBox(height: getVerticalSize(4)),
                        Text(
                          'Remark: ${it.remark}',
                          style: TextStyle(
                            fontSize: getFontSize(12),
                            color: Colors.black54,
                          ),
                        ),
                      ],

                      SizedBox(height: getVerticalSize(6)),
                      Text(
                        'Applied on: ${_fmt(it.appliedOn)}',
                        style: TextStyle(
                          fontSize: getFontSize(11),
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k,
            style: TextStyle(
              fontSize: getFontSize(11),
              color: Colors.black54,
            )),
        SizedBox(height: getVerticalSize(2)),
        Text(v,
            style: TextStyle(
              fontSize: getFontSize(13),
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
