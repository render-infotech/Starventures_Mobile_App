import 'package:starcapitalventures/Screens/Leads/widgets/LeadCard.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final leads = const [
    (
    name: 'Rajesh Kumar',
    source: 'Website',
    phone: '+91 98765 43210',
    email: 'rajesh@email.com',
    note: 'Interested in home loan for 2BHK apartment in Pune. Budget around 50L.',
    when: 'Added 2 days ago',
    color: Color(0xFF3FC2A2),
    ),
    (
    name: 'Asha Verma',
    source: 'Referral',
    phone: '+91 98765 11122',
    email: 'asha@email.com',
    note: 'Looking for car loan for a new sedan; tenure 5 years.',
    when: 'Added 1 day ago',
    color: Color(0xFFFFA000),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Lead Management',
      ),
      body: ListView.builder(
        padding: getPadding(left: 16, right: 16, top: 16, bottom: 16),
        itemCount: leads.length,
        itemBuilder: (context, i) {
          final l = leads[i];
          return LeadCard(
            name: l.name,
            source: l.source,
            phone: l.phone,
            email: l.email,
            note: l.note,
            addedWhen: l.when,
            accentColor: l.color,
            onConvert: () {
              // TODO: navigate to convert flow
            },
          );
        },
      ),
    );
  }
}
