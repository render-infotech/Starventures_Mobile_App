import 'package:flutter/foundation.dart';
import '../../applications/model/application_model.dart';
import '../model/application_detail_model.dart'; // where ProgressState lives

class ApplicationDetailController extends ChangeNotifier {
  ApplicationDetail? _detail;
  ApplicationDetail? get detail => _detail;

  Future<void> fetchDetail({
    required String userId,
    required String applicationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _detail = ApplicationDetail(
      header: ApplicationHeader(
        name: 'Rahul Sharma',
        loanType: 'Personal Loan',
        amount: 500000,
        status: ApplicationStatus.processing,
        appId: 'PL001',
        appliedDate: DateTime(2025, 8, 2),
        monthlyIncome: 75000,
        creditScore: 750,
      ),
      progress: [
        ProgressStep(index: 1, title: 'Application Submitted',  subtitle: 'Basic details and documents received',   state: ProgressState.complete),
        ProgressStep(index: 2, title: 'Document Verification',  subtitle: 'All documents verified successfully',   state: ProgressState.complete),
        ProgressStep(index: 3, title: 'Credit Check',           subtitle: 'Credit assessment in progress',        state: ProgressState.active),
        ProgressStep(index: 4, title: 'Final Approval',         subtitle: 'Management approval pending',          state: ProgressState.pending),
        ProgressStep(index: 5, title: 'Disbursement',           subtitle: 'Loan amount transfer',                 state: ProgressState.pending),
      ],
      documents: [
        UploadDoc(name: 'Aadhar Card', uploaded: true),
        UploadDoc(name: 'PAN Card',    uploaded: true),
        UploadDoc(name: 'Salary Slip', uploaded: true),
        UploadDoc(name: 'Bank Statement', uploaded: false),
      ],
      activities: [
        ActivityItem(title: 'Document Verification Completed', subtitle: 'All submitted documents verified by back office team', time: DateTime(2025, 8, 3, 14, 30)),
        ActivityItem(title: 'Application Submitted',           subtitle: 'Initial application form submitted with basic documents', time: DateTime(2025, 8, 2, 10, 15)),
      ],
    );
    notifyListeners();
  }
}
