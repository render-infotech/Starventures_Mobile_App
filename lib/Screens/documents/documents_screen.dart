import 'package:flutter/material.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Dummy docs
  final _docs = const [
    _DocItem(title: 'Current Payslip', ext: 'PDF', sizeLabel: '1.2 MB'),
    _DocItem(title: 'Offer Letter', ext: 'PDF', sizeLabel: '0.8 MB'),
    _DocItem(title: 'Appointment Letter', ext: 'PDF', sizeLabel: '0.5 MB'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Documents',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing documents list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.lg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: getHorizontalSize(10),
                    offset: Offset(0, getVerticalSize(4)),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE9EDF5), width: getHorizontalSize(1)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _docs.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: const Color(0xFFE9EDF5)),
                itemBuilder: (context, i) {
                  final d = _docs[i];
                  return Padding(
                    padding: getPadding(left: 12, right: 12, top: 12, bottom: 12),
                    child: Row(
                      children: [
                        _DocIcon(),
                        SizedBox(width: getHorizontalSize(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A2036),
                                ),
                              ),
                              SizedBox(height: getVerticalSize(2)),
                              Text(
                                '${d.ext} • ${d.sizeLabel}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        _GhostPillButton(
                          label: 'Download',
                          onTap: () {
                            // TODO: implement download
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: getVerticalSize(16)),

            // Upload dropzone
            _DropZoneCard(
              onTap: () {
                // TODO: pick files
              },
            ),

            SizedBox(height: getVerticalSize(16)),

            // Bottom CTA
            _PrimaryWideButton(
              text: 'Upload Documents',
              onPressed: () {
                // TODO: upload selected files
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DocItem {
  const _DocItem({required this.title, required this.ext, required this.sizeLabel});
  final String title;
  final String ext;
  final String sizeLabel;
}

class _DocIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: getHorizontalSize(36),
      height: getHorizontalSize(36),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: AppRadii.md,
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.description_outlined, color: const Color(0xFF4C5B7E), size: getHorizontalSize(20)),
    );
  }
}

class _GhostPillButton extends StatelessWidget {
  const _GhostPillButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.pill,
      onTap: onTap,
      child: Container(
        padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FA),
          borderRadius: AppRadii.pill,
          border: Border.all(color: const Color(0xFFE1E6EF), width: getHorizontalSize(1)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4C5B7E),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DropZoneCard extends StatelessWidget {
  const _DropZoneCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.lg,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: getPadding(top: 24, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: const Color(0xFF16A34A).withOpacity(0.35),
            width: getHorizontalSize(2),
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: getHorizontalSize(6),
              offset: Offset(0, getVerticalSize(2)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file, size: getHorizontalSize(28), color: const Color(0xFF1A2036)),
            SizedBox(height: getVerticalSize(10)),
            Text(
              'Upload New Documents',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1A2036),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: getVerticalSize(4)),
            Text(
              'PDF, JPG, PNG supported (Max 5MB)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryWideButton extends StatelessWidget {
  const _PrimaryWideButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getVerticalSize(48),
      child: CustomElevatedButton(
        text: text, // pass the label string
        height: getVerticalSize(48),
        width: double.infinity,
        buttonStyle: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, getVerticalSize(48)),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          backgroundColor:appTheme.theme2,
          foregroundColor: Colors.white,
        ),
        buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        onPressed: onPressed, // use onPressed (or onTap works too)
      ),
    );
  }
}
