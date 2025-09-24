import 'package:flutter/material.dart';

enum ApplicationStatus { processing, approved, pending, rejected }

class ApplicationItem {
  ApplicationItem({
    required this.applicationId,
    required this.userId,
    required this.applicantName,
    required this.loanType,
    required this.amount,
    required this.appliedAgo,
    required this.appIdCode,

    required this.status,
    this.accentColor = const Color(0xFF3FC2A2),
  });

  final String applicationId; // internal id for detail API
  final String userId;        // user id to pass to detail
  final String applicantName;
  final String loanType;
  final int amount;
  final String appliedAgo;    // e.g., 'Applied 2 days ago'
  final String appIdCode;     // e.g., 'PL001'
  final ApplicationStatus status;
  final Color accentColor;
  String get appId => appIdCode; // alias so old UI code still compiles
  factory ApplicationItem.fromJson(Map<String, dynamic> j) {
    return ApplicationItem(
      applicationId: j['applicationId'] as String,
      userId: j['userId'] as String,
      applicantName: j['applicantName'] as String,
      loanType: j['loanType'] as String,
      amount: j['amount'] as int,
      appliedAgo: j['appliedAgo'] as String,
      appIdCode: j['appIdCode'] as String,
      status: ApplicationStatus.values.firstWhere(
            (e) => e.name == (j['status'] as String),
        orElse: () => ApplicationStatus.processing,
      ),
      accentColor: Color(j['accentColor'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
    'applicationId': applicationId,
    'userId': userId,
    'applicantName': applicantName,
    'loanType': loanType,
    'amount': amount,
    'appliedAgo': appliedAgo,
    'appIdCode': appIdCode,
    'status': status.name,
    'accentColor': accentColor.value,
  };
}
