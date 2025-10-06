  import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/Leads/leads_screen.dart';
import 'package:starcapitalventures/Screens/add_lead/add_lead_screen.dart';
import 'package:starcapitalventures/Screens/application_detail/application_details_screen.dart';
import 'package:starcapitalventures/Screens/documents/documents_screen.dart';
import 'package:starcapitalventures/Screens/edit_application/edit_application.dart';
import 'Screens/applications/application.dart' show Application;
import 'Screens/forgot_password_screen/forgot_password_screen.dart';
import 'Screens/home_screen_Lead/home_screen.dart';
import 'Screens/home_screen_main/HomeScreenMain.dart';
import 'Screens/new_application/new_application_screen.dart';
import 'Screens/profile/profile_screen.dart';
import 'Screens/sign_in_screen/Sign_In_Screen.dart';
  import 'Screens/splash_screen/Splash_Screen.dart';

  class AppRoutes {
    static const String intialScreen = '/splash';
    static const String signinscreen = '/signin';
    static const String homeScreenMain ='/homeScreenMain';
    static const  String addLead='/addLead';
    static const  String leads='/Leads';
    static const String newapplication='/newapplication'; //newapplication
    static const String application='/application'; //newapplication
    static const String applicationDetails='/applicationDetails'; //newapplication
    static const String documentsScreen='/documentsScreen';
    static const String profileScreen='/profileScreen';
    static const String homescreenLead='/homescreenLead';
    static const String forgotPasswordScreen='/forgotPassword';
    static const String editApplication='/editApplication';

    static final pages = [
      GetPage(
        name: intialScreen,
        page: () => const SplashScreen(),
      ),

      GetPage(name: signinscreen,
          page: () => const SignInScreen()),

      GetPage(name: homeScreenMain, page:()=> HomeScreenMain()),

      GetPage(name: addLead, page: ()=>AddLeadScreen()),
      GetPage(name: leads, page: ()=>LeadsScreen()),
      GetPage(name: newapplication,page:()=>NewApplicationScreen()),
      GetPage(name: application,page:()=>Application()),
      GetPage(
        name: AppRoutes.applicationDetails,
        page: () {
          final args = Get.arguments as Map<String, dynamic>? ?? {};
          final userId = args['userId'] as String? ?? '';
          final applicationId = args['applicationId'] as String? ?? '';
          return ApplicationDetailScreen(userId: userId, applicationId: applicationId);
        },
      ),

      GetPage(name: documentsScreen, page: ()=>DocumentsScreen()),
      GetPage(name: profileScreen, page: ()=>ProfileScreen()),
      GetPage(name: homescreenLead, page: ()=>HomeScreenLead()),
      GetPage(name: forgotPasswordScreen, page: ()=>ForgotPasswordScreen()),
      GetPage(name: editApplication, page: ()=>EditApplication()),

    ];
  }
