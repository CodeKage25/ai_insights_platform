class FileUploadResponse {
  final String fileId;
  final String filename;
  final List<List<dynamic>> preview;
  final String message;

  FileUploadResponse({
    required this.fileId,
    required this.filename,
    required this.preview,
    required this.message,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      fileId: json['file_id'] as String,
      filename: json['filename'] as String,
      preview: (json['preview'] as List<dynamic>)
          .map((row) => (row as List<dynamic>))
          .toList(),
      message: json['message'] as String,
    );
  }
}

class FileStatus {
  final String fileId;
  final String status;
  final DateTime uploadTime;
  final String filename;

  FileStatus({
    required this.fileId,
    required this.status,
    required this.uploadTime,
    required this.filename,
  });

  factory FileStatus.fromJson(Map<String, dynamic> json) {
    return FileStatus(
      fileId: json['file_id'] as String,
      status: json['status'] as String,
      uploadTime: DateTime.parse(json['upload_time'] as String),
      filename: json['filename'] as String,
    );
  }
}
