import 'package:flutter/material.dart';

import '../../applications/model/application_model.dart';

class ApplicationDetail {
  ApplicationDetail({
    required this.header,
    required this.progress,
    required this.documents,
    required this.activities,
  });

  final ApplicationHeader header;
  final List<ProgressStep> progress;
  final List<UploadDoc> documents;
  final List<ActivityItem> activities;

  factory ApplicationDetail.fromJson(Map<String, dynamic> j) {
    return ApplicationDetail(
      header: ApplicationHeader.fromJson(j['header'] as Map<String, dynamic>),
      progress: (j['progress'] as List<dynamic>)
          .map((e) => ProgressStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (j['documents'] as List<dynamic>)
          .map((e) => UploadDoc.fromJson(e as Map<String, dynamic>))
          .toList(),
      activities: (j['activities'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApplicationHeader {
  ApplicationHeader({
    required this.name,
    required this.loanType,
    required this.amount,
    required this.status,
    required this.appId,
    required this.appliedDate,
    required this.monthlyIncome,
    required this.creditScore,
  });

  final String name;
  final String loanType;
  final int amount;
  final ApplicationStatus status;
  final String appId;
  final DateTime appliedDate;
  final int monthlyIncome;
  final int creditScore;

  factory ApplicationHeader.fromJson(Map<String, dynamic> j) {
    return ApplicationHeader(
      name: j['name'] as String,
      loanType: j['loanType'] as String,
      amount: j['amount'] as int,
      status: ApplicationStatus.values.firstWhere(
            (e) => e.name == (j['status'] as String),
        orElse: () => ApplicationStatus.processing,
      ),
      appId: j['appId'] as String,
      appliedDate: DateTime.parse(j['appliedDate'] as String),
      monthlyIncome: j['monthlyIncome'] as int,
      creditScore: j['creditScore'] as int,
    );
  }
}

// Define your custom enum once
enum ProgressState { complete, active, pending, indexed }

class ProgressStep {
  ProgressStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final int index;
  final String title;
  final String subtitle;
  final ProgressState state; // <- use ProgressState

  factory ProgressStep.fromJson(Map<String, dynamic> j) {
    return ProgressStep(
      index: j['index'] as int,
      title: j['title'] as String,
      subtitle: j['subtitle'] as String,
      state: ProgressState.values.firstWhere(
            (e) => e.name == (j['state'] as String),
        orElse: () => ProgressState.indexed,
      ),
    );
  }
}

class UploadDoc {
  UploadDoc({required this.name, required this.uploaded});
  final String name;
  final bool uploaded;

  factory UploadDoc.fromJson(Map<String, dynamic> j) {
    return UploadDoc(
      name: j['name'] as String,
      uploaded: j['uploaded'] as bool,
    );
  }
}

class ActivityItem {
  ActivityItem({required this.title, required this.subtitle, required this.time});
  final String title;
  final String subtitle;
  final DateTime time;

  factory ActivityItem.fromJson(Map<String, dynamic> j) {
    return ActivityItem(
      title: j['title'] as String,
      subtitle: j['subtitle'] as String,
      time: DateTime.parse(j['time'] as String),
    );
  }
}
