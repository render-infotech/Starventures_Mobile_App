import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/Leads/leads_screen.dart';
import 'package:starcapitalventures/Screens/add_lead/add_lead_screen.dart';
import 'package:starcapitalventures/Screens/application_detail/application_details_screen.dart';
import 'package:starcapitalventures/Screens/documents/documents_screen.dart';
import 'package:starcapitalventures/Screens/edit_application/edit_application.dart';
import 'package:starcapitalventures/auth/sign_up_screen/create_account_screen.dart';
import 'Screens/application_detail/widgets/add_other_documents.dart';
import 'Screens/applications/application.dart' show Application;
import 'Screens/attendance/request_leave_screen.dart';
import 'Screens/attendance/view_leaves_screen.dart';
import 'Screens/emi_calculator/emi_calculator_screen.dart';
import 'Screens/forgot_password_screen/forgot_password_screen.dart';
import 'Screens/home_screen/attendance_screen.dart';
import 'Screens/home_screen/permission_gate.dart';
import 'Screens/home_screen_Lead/home_screen.dart';
import 'Screens/home_screen_customer/home_screen_customer.dart';
import 'Screens/home_screen_main/HomeScreenMain.dart';
import 'Screens/new_application/new_application_screen.dart';
import 'Screens/profile/profile_screen.dart';
import 'Screens/profile/edit_profile_screen.dart';
import 'auth/sign_in_screen/Sign_In_Screen.dart';
import 'Screens/splash_screen/Splash_Screen.dart';
import 'apply_loan/apply_loan_screen.dart';
import 'auth/sign_in_screen/otp_verification_screen.dart';
import 'auth/sign_in_screen/otp_verification_screen2.dart';
import 'core/services/no_internet_screen.dart';

class AppRoutes {
  static const String intialScreen = '/splash';
  static const String signinscreen = '/signin';
  static const String homeScreenMain = '/homeScreenMain';
  static const String addLead = '/addLead';
  static const String leads = '/Leads';
  static const String newapplication = '/newapplication';
  static const String application = '/application';
  static const String applicationDetails = '/applicationDetails';
  static const String documentsScreen = '/documentsScreen';
  static const String applyLoan = '/applyLoan';
  static const String profileScreen = '/profileScreen';
  static const String homescreenLead = '/homescreenLead';
  static const String forgotPasswordScreen = '/forgotPassword';
  static const String editApplication = '/editApplication';
  static const String createAccountScreen = '/createAccount';
  static const String editProfileScreen = '/editProfile';
  static const String attedenceScreen='/attendanceScreen';
  static const String addOtherDocuments='/addOtherDocuments';
  static const String homeScreenCustomer='/homeScreenCustomer';
  static const String permissionGate = '/permissionGate';
  static const String locationPermissionScreen = '/locationPermissionScreen';
  static const String noInternetScreen = '/no-internet'; // ✅ Add this
  static const String emiCalculatorScreen='/emiCalculatorScreen';
  static const String leaverequestScreen='/leaverequestScreen';
  static const String viewLeaves='/viewLeaves';

  static const String otpVerification = '/otp-verification';
  static const String otpVerification2 = '/otp-verification2';

  static final pages = [
    GetPage(name: intialScreen, page: () => const SplashScreen()),
    GetPage(name: signinscreen, page: () => const SignInScreen()),
    GetPage(name: permissionGate, page: () => const PermissionGate()),
    GetPage(name: noInternetScreen, page: () => NoInternetScreen()), // ✅ Add this
    GetPage(name: homeScreenMain, page: () => HomeScreenMain()),
    GetPage(name: addLead, page: () => AddLeadScreen()),
    GetPage(name: leads, page: () => LeadsScreen()),
    GetPage(name: newapplication, page: () => NewApplicationScreen()),
    GetPage(name: application, page: () => Application()),
    GetPage(
      name: AppRoutes.applicationDetails,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final userId = args['userId'] as String? ?? '';
        final applicationId = args['applicationId'] as String? ?? '';
        return ApplicationDetailScreen(
          userId: userId,
          applicationId: applicationId,
        );
      },
    ),

    GetPage(
      name: otpVerification,
      page: () => OtpVerificationScreen(
        phoneNumber: Get.arguments['phone'] ?? '',
      ),
    ),

    GetPage(
      name: otpVerification2,
      page: () => OtpVerificationScreen2(
        phoneNumber: Get.arguments['phone'] ?? '',
      ),
    ),


    GetPage(name: documentsScreen, page: () => DocumentsScreen()),
    GetPage(name: profileScreen, page: () => ProfileScreen()),
    GetPage(name: homescreenLead, page: () => HomeScreenLead()),
    GetPage(name: forgotPasswordScreen, page: () => UpdatePasswordScreen()),
    GetPage(name: createAccountScreen, page: () => CreateAccountScreen()),
    GetPage(name: editApplication, page: () => EditApplication()),
    GetPage(name: editProfileScreen, page: () => EditProfileScreen()),
    GetPage(name: applyLoan, page: () => ApplyLoanScreen()),
    GetPage(name: attedenceScreen, page: ()=>AttendanceScreen()),
    GetPage(
      name: AppRoutes.addOtherDocuments,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final applicationId = args['applicationId'] as String? ?? '';
        return OtherDocumentsScreen(applicationId: applicationId);
      },
    ),
    GetPage(name: homeScreenCustomer, page: ()=>HomeScreenCustomer()),
    GetPage(name: emiCalculatorScreen, page: ()=>EmiCalculatorScreen()),
    GetPage(name: leaverequestScreen, page: ()=>RequestLeaveScreen()),
    GetPage(name: viewLeaves, page: ()=>const ViewLeavesScreen()),
  ];
}
