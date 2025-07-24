import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../utils/constants.dart';

class FileUploadWidget extends StatefulWidget {
  final Function(html.File) onFileSelected;
  final bool isLoading;

  const FileUploadWidget({
    super.key,
    required this.onFileSelected,
    this.isLoading = false,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget>
    with SingleTickerProviderStateMixin {
  bool _isDragOver = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectFile() {
    final input = html.FileUploadInputElement()
      ..accept = '.csv,.xls,.xlsx'
      ..click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        if (_validateFile(file)) {
          widget.onFileSelected(file);
        }
      }
    });
  }

  bool _validateFile(html.File file) {
    final extension = file.name.split('.').last.toLowerCase();
    if (!AppConstants.allowedExtensions.contains(extension)) {
      _showError('Invalid file type. Please select a CSV, XLS, or XLSX file.');
      return false;
    }

    if (file.size > AppConstants.maxFileSizeBytes) {
      _showError('File too large. Maximum size is 10MB.');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _scaleAnimation,
    builder: (context, child) {
      return Center( 
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 200,
            constraints: const BoxConstraints(maxWidth: 500), 
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDragOver
                    ? AppConstants.primaryColor
                    : Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
              color: _isDragOver
                  ? AppConstants.primaryColor.withOpacity(0.05)
                  : Colors.grey.shade50,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : _selectFile,
                borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: _isDragOver
                            ? AppConstants.primaryColor
                            : Colors.grey.shade400,
                      ),
                    const SizedBox(height: 16),
                    Padding( // Add padding for text
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.isLoading
                            ? 'Uploading...'
                            : 'Click to upload or drag and drop',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _isDragOver
                              ? AppConstants.primaryColor
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supports CSV, XLS, XLSX files (max 10MB)',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}
