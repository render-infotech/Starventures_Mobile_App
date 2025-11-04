// lib/Screens/documents/documents_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../profile/controller/profile_controller.dart';  // ✅ Import ProfileController
import 'controller/documents_controller.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentsController _controller = Get.put(DocumentsController());
  late final ProfileController _profile;  // ✅ Add ProfileController

  @override
  void initState() {
    super.initState();
    // ✅ Initialize ProfileController
    _profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray100,
      appBar: CustomAppBar(
        backgroundColor: appTheme.mintygreen,
        useGreeting: false,
        pageTitle: 'Documents',
        showBack: true,
      ),
      body: Obx(() {
        if (_controller.loading.value) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: appTheme.whiteA700,
              color: appTheme.theme,
            ),
          );
        }

        // ✅ Check user role
        final isAgent = _profile.role.value.toLowerCase() == 'agent';

        return RefreshIndicator(
          onRefresh: _controller.fetchDocuments,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: getPadding(left: 16, right: 16, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Only show document type buttons if NOT agent
                if (!isAgent) ...[
                  // Three buttons in a row with equal width
                  Row(
                    children: [
                      Expanded(
                        child: _DocumentTypeButton(
                          label: 'Salary Slip',
                          icon: Icons.receipt_long_outlined,
                          onTap: () => _controller.viewSalarySlip(),
                        ),
                      ),
                      SizedBox(width: getHorizontalSize(8)),
                      Expanded(
                        child: _DocumentTypeButton(
                          label: 'Joining Letter',
                          icon: Icons.work_outline,
                          onTap: () => _controller.viewJoiningLetter(),
                        ),
                      ),
                      SizedBox(width: getHorizontalSize(8)),
                      Expanded(
                        child: _DocumentTypeButton(
                          label: 'NOC',
                          icon: Icons.verified_outlined,
                          onTap: () => _controller.viewNoc(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getVerticalSize(20)),
                ],

                // Existing documents list
                if (_controller.documents.isNotEmpty)
                  _buildDocumentsList()
                else
                  _buildEmptyState(),

                SizedBox(height: getVerticalSize(16)),

                // Selected files preview
                if (_controller.selectedFiles.isNotEmpty) ...[
                  _buildSelectedFilesList(),
                  SizedBox(height: getVerticalSize(16)),
                ],

                // Upload dropzone
                _DropZoneCard(
                  onTap: _controller.pickFiles,
                ),

                SizedBox(height: getVerticalSize(16)),

                // Bottom CTA
                _PrimaryWideButton(
                  text: 'Upload Documents',
                  onPressed: _controller.uploadDocuments,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDocumentsList() {
    return Container(
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
        border: Border.all(
          color: const Color(0xFFE9EDF5),
          width: getHorizontalSize(1),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _controller.documents.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: const Color(0xFFE9EDF5),
        ),
        itemBuilder: (context, i) {
          final doc = _controller.documents[i];
          return Padding(
            padding: getPadding(left: 12, right: 12, top: 12, bottom: 12),
            child: Row(
              children: [
                _DocIcon(extension: doc.extension),
                SizedBox(width: getHorizontalSize(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2036),
                        ),
                      ),
                      SizedBox(height: getVerticalSize(2)),
                      Text(
                        '${doc.extension} • ${doc.fileSize}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // View Button Only
                _GhostPillButton(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  onTap: () => _controller.viewDocument(doc),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: const Color(0xFFE9EDF5),
          width: getHorizontalSize(1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: getSize(48),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: getVerticalSize(12)),
          Text(
            'No Documents Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: getVerticalSize(4)),
          Text(
            'Upload your first document to get started',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: appTheme.theme2?.withOpacity(0.3) ?? Colors.brown.withOpacity(0.3),
          width: getHorizontalSize(1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: getPadding(all: 12),
            child: Text(
              'Selected Files (${_controller.selectedFiles.length})',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2036),
              ),
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE9EDF5)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _controller.selectedFiles.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: const Color(0xFFE9EDF5),
            ),
            itemBuilder: (context, i) {
              final file = _controller.selectedFiles[i];
              final fileName = path.basename(file.path);
              final fileSize = _controller.formatFileSize(file.lengthSync());
              final extension = path.extension(file.path).replaceAll('.', '').toUpperCase();

              return Padding(
                padding: getPadding(left: 12, right: 12, top: 8, bottom: 8),
                child: Row(
                  children: [
                    _DocIcon(extension: extension),
                    SizedBox(width: getHorizontalSize(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A2036),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$extension • $fileSize',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                              fontSize: getFontSize(11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: getSize(20),
                        color: Colors.red,
                      ),
                      onPressed: () => _controller.removeSelectedFile(i),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ✅ Keep all your existing widget classes unchanged below
class _DocIcon extends StatelessWidget {
  final String extension;

  const _DocIcon({this.extension = 'FILE'});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;

    switch (extension.toUpperCase()) {
      case 'PDF':
        bgColor = const Color(0xFFFFEBEE);
        icon = Icons.picture_as_pdf;
        break;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        bgColor = const Color(0xFFE3F2FD);
        icon = Icons.image;
        break;
      default:
        bgColor = const Color(0xFFF1F4FA);
        icon = Icons.description_outlined;
    }

    return Container(
      width: getHorizontalSize(36),
      height: getHorizontalSize(36),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.md,
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: const Color(0xFF4C5B7E),
        size: getHorizontalSize(20),
      ),
    );
  }
}

class _GhostPillButton extends StatelessWidget {
  const _GhostPillButton({
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.pill,
      onTap: onTap,
      child: Container(
        padding: getPadding(left: 10, right: 10, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FA),
          borderRadius: AppRadii.pill,
          border: Border.all(
            color: const Color(0xFFE1E6EF),
            width: getHorizontalSize(1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: getSize(14),
                color: const Color(0xFF4C5B7E),
              ),
              SizedBox(width: getHorizontalSize(4)),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF4C5B7E),
                fontWeight: FontWeight.w700,
                fontSize: getFontSize(11),
              ),
            ),
          ],
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
            Icon(
              Icons.attach_file,
              size: getHorizontalSize(28),
              color: const Color(0xFF1A2036),
            ),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black45,
              ),
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
        text: text,
        height: getVerticalSize(48),
        width: double.infinity,
        buttonStyle: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, getVerticalSize(48)),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          backgroundColor: appTheme.theme2,
          foregroundColor: Colors.white,
        ),
        buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

/// Document Type Button Widget
class _DocumentTypeButton extends StatelessWidget {
  const _DocumentTypeButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.lg,
      onTap: onTap,
      child: Container(
        padding: getPadding(top: 12, bottom: 12, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: appTheme.theme2?.withOpacity(0.3) ?? const Color(0xFF16A34A).withOpacity(0.3),
            width: getHorizontalSize(1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: getHorizontalSize(8),
              offset: Offset(0, getVerticalSize(2)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: getPadding(all: 8),
              decoration: BoxDecoration(
                color: appTheme.theme2?.withOpacity(0.1) ?? const Color(0xFF16A34A).withOpacity(0.1),
                borderRadius: AppRadii.md,
              ),
              child: Icon(
                icon,
                size: getSize(24),
                color: appTheme.theme2 ?? const Color(0xFF16A34A),
              ),
            ),
            SizedBox(height: getVerticalSize(8)),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF1A2036),
                fontWeight: FontWeight.w600,
                fontSize: getFontSize(11),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
