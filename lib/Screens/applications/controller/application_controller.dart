import 'package:flutter/foundation.dart';
import '../../../app_export/app_export.dart';
import '../model/application_model.dart';

class ApplicationListController extends ChangeNotifier {
  final List<ApplicationItem> _items = [
    ApplicationItem(
      applicationId: 'A1',
      userId: 'U123',
      applicantName: 'Rahul Sharma',
      loanType: 'Personal Loan',
      amount: 500000,
      appliedAgo: 'Applied 2 days ago',
      appIdCode: 'PL001',
      status: ApplicationStatus.processing,
      accentColor: const Color(0xFF4F8BFF),
    ),
    ApplicationItem(
      applicationId: 'A2',
      userId: 'U234',
      applicantName: 'Priya Patel',
      loanType: 'Home Loan',
      amount: 2500000,
      appliedAgo: 'Applied 1 week ago',
      appIdCode: 'HL002',
      status: ApplicationStatus.approved,
      accentColor: const Color(0xFF3FC2A2),
    ),
    ApplicationItem(
      applicationId: 'A3',
      userId: 'U345',
      applicantName: 'Amit Kumar',
      loanType: 'Business Loan',
      amount: 1000000,
      appliedAgo: 'Applied 3 days ago',
      appIdCode: 'BL003',
      status: ApplicationStatus.pending,
      accentColor: const Color(0xFFFFC85C),
    ),
    ApplicationItem(
      applicationId: 'A4',
      userId: 'U456',
      applicantName: 'Kavita Singh',
      loanType: 'Vehicle Loan',
      amount: 800000,
      appliedAgo: 'Applied 1 week ago',
      appIdCode: 'VL004',
      status: ApplicationStatus.rejected,
      accentColor: const Color(0xFFFF8080),
    ),
  ];

  List<ApplicationItem> get items => List.unmodifiable(_items);

  // API-ready stub
  Future<void> fetch({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }
}
