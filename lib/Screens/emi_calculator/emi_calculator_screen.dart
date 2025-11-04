import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../core/utils/styles/size_utils.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _amountController = TextEditingController();
  final _tenureController = TextEditingController();
  final _rateController = TextEditingController();

  String selectedLoanType = 'Home';
  String tenureUnit = 'Yr';
  double? emi;
  double? totalInterest;
  double? totalPayment;

  void _calculateEmi() {
    final p = double.tryParse(_amountController.text.replaceAll(',', '').replaceAll('₹', '').trim()) ?? 0;
    final nInput = double.tryParse(_tenureController.text.trim()) ?? 0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0;

    if (p <= 0 || nInput <= 0 || r <= 0) {
      setState(() {
        emi = null;
        totalInterest = null;
        totalPayment = null;
      });
      return;
    }

    // Convert tenure to months
    final n = tenureUnit == 'Yr' ? (nInput * 12).round() : nInput.round();

    // Monthly rate
    final i = r / 12 / 100;

    // EMI formula: E = P * i * (1+i)^n / ((1+i)^n - 1)
    final pow = (1 + i);
    final factor = (powTo(pow, n));
    final e = p * i * factor / (factor - 1);

    final tp = e * n;
    final ti = tp - p;

    setState(() {
      emi = e;
      totalPayment = tp;
      totalInterest = ti;
    });
  }

  // Fast power for double
  double powTo(double a, int n) {
    double res = 1.0, base = a;
    int exp = n;
    while (exp > 0) {
      if (exp & 1 == 1) res *= base;
      base *= base;
      exp >>= 1;
    }
    return res;
  }

  String _money(num v) {
    return v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  // Custom Indian numbering system converter
  String _convertAmountToWords(double amount) {
    try {
      int wholeAmount = amount.round();

      if (wholeAmount == 0) return 'Zero Rupees Only';

      // Indian numbering system breakdown
      int crores = (wholeAmount / 10000000).floor();
      int lakhs = ((wholeAmount % 10000000) / 100000).floor();
      int thousands = ((wholeAmount % 100000) / 1000).floor();
      int hundreds = ((wholeAmount % 1000) / 100).floor();
      int remainder = wholeAmount % 100;

      List<String> parts = [];

      if (crores > 0) {
        parts.add('${_numberToWords(crores)} Crore${crores > 1 ? 's' : ''}');
      }

      if (lakhs > 0) {
        parts.add('${_numberToWords(lakhs)} Lakh${lakhs > 1 ? 's' : ''}');
      }

      if (thousands > 0) {
        parts.add('${_numberToWords(thousands)} Thousand');
      }

      if (hundreds > 0) {
        parts.add('${_numberToWords(hundreds)} Hundred');
      }

      if (remainder > 0) {
        parts.add(_numberToWords(remainder));
      }

      return '${parts.join(' ')} Rupees Only';

    } catch (e) {
      return 'Amount conversion error';
    }
  }

  // Convert numbers 1-99 to words
  String _numberToWords(int number) {
    if (number == 0) return '';

    List<String> ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];

    List<String> tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    if (number < 20) {
      return ones[number];
    } else if (number < 100) {
      int ten = number ~/ 10;
      int one = number % 10;
      return '${tens[ten]}${one > 0 ? ' ${ones[one]}' : ''}';
    } else {
      return number.toString();
    }
  }

  void _selectLoanType(String type) {
    setState(() {
      selectedLoanType = type;
    });
  }

  void _selectTenureUnit(String unit) {
    setState(() {
      tenureUnit = unit;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tenureController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: appTheme.theme,
        pageTitle: "Loan EMI Calculator",
        useGreeting: false,
        showBack: false,
      ),
      backgroundColor: appTheme.whiteA700,

      // SCROLLABLE BODY
      body: SingleChildScrollView(
        padding: getPadding(left: 16, right: 16, top: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getVerticalSize(12)),

            Text("Loan Amount",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
            SizedBox(height: getVerticalSize(8)),
            CustomTextFormField(
              controller: _amountController,
              hintText: "₹ 50,00,000",
              textInputType: TextInputType.number,
              prefix: Padding(
                padding: EdgeInsets.only(
                    left: getHorizontalSize(10), right: getHorizontalSize(6)),
                child: Text("₹", style: TextStyle(fontSize: getFontSize(18))),
              ),
              prefixConstraints: BoxConstraints(
                minWidth: getHorizontalSize(24),
                minHeight: getVerticalSize(24),
              ),
            ),
            SizedBox(height: getVerticalSize(24)),

            Text("Loan Tenure",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
            SizedBox(height: getVerticalSize(8)),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _tenureController,
                    hintText: "10",
                    textInputType: TextInputType.number,
                  ),
                ),
                SizedBox(width: getHorizontalSize(8)),
                _buildUnitPill("Yr", tenureUnit == "Yr"),
                SizedBox(width: getHorizontalSize(8)),
                _buildUnitPill("Mo", tenureUnit == "Mo"),
              ],
            ),
            SizedBox(height: getVerticalSize(24)),

            Text("Interest Rate",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
            SizedBox(height: getVerticalSize(8)),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _rateController,
                    hintText: "9.5",
                    textInputType: TextInputType.number,
                  ),
                ),
                SizedBox(width: getHorizontalSize(8)),
                Container(
                  height: getVerticalSize(48),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text("%",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ],
            ),

            if (emi != null) ...[
              SizedBox(height: getVerticalSize(20)),
              Container(
                padding: EdgeInsets.all(getHorizontalSize(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _resultRow(context, 'Monthly EMI', '₹ ${_money(emi!)}'),
                    SizedBox(height: getVerticalSize(8)),
                    _resultRow(context, 'Total Interest', '₹ ${_money(totalInterest!)}'),
                    SizedBox(height: getVerticalSize(8)),
                    _resultRow(context, 'Total Payment', '₹ ${_money(totalPayment!)}'),

                    // Amount in words section
                    SizedBox(height: getVerticalSize(16)),
                    Divider(color: const Color(0xFFE5E7EB), thickness: 1),
                    SizedBox(height: getVerticalSize(12)),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(getHorizontalSize(12)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: appTheme.theme.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Payment in Words',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontSize: getFontSize(12),
                            ),
                          ),
                          SizedBox(height: getVerticalSize(6)),
                          Text(
                            _convertAmountToWords(totalPayment!),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appTheme.theme,
                              fontWeight: FontWeight.bold ,
                              fontSize: getFontSize(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // extra bottom padding so last content not hidden behind CTA
            SizedBox(height: getVerticalSize(90)),
          ],
        ),
      ),

      // FIXED CTA
      bottomNavigationBar: Padding(
        padding: getPadding(left: 16, right: 16, bottom: 16),
        child: CustomElevatedButton(
          text: "Calculate EMI",
          height: getVerticalSize(54),
          width: double.infinity,
          onPressed: _calculateEmi,
          buttonStyle: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: appTheme.theme,
          ),
          buttonTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTypePill(String type, IconData icon) {
    final isSelected = selectedLoanType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectLoanType(type),
        child: Container(
          height: getVerticalSize(48),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFFF5F6FA),
            border: Border.all(
              color: isSelected ? const Color(0xFF002366) : const Color(0xFFE5E7EB),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF002366) : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFF002366) : Colors.black54,
                  fontSize: getFontSize(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54, fontWeight: FontWeight.w600)),
        Text(value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black87, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildUnitPill(String unit, bool selected) {
    return GestureDetector(
      onTap: () => _selectTenureUnit(unit),
      child: Container(
        width: getHorizontalSize(44),
        height: getVerticalSize(44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? appTheme.theme : Colors.white,
          border: Border.all(
            color: selected ? appTheme.theme : const Color(0xFFE5E7EB),
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: getFontSize(14),
          ),
        ),
      ),
    );
  }
}
