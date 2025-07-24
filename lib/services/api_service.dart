import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/file_model.dart';
import '../models/insight_model.dart';
import '../utils/constants.dart';

class ApiService {
  final String _baseUrl = AppConstants.baseUrl;
  
  Future<FileUploadResponse> uploadFile(html.File file) async {
    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      
      await reader.onLoad.first;
      final bytes = reader.result as Uint8List;
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FileUploadResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  Future<Map<String, dynamic>> processFile(String fileId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'file_id': fileId}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Processing failed');
      }
    } catch (e) {
      throw Exception('Failed to process file: $e');
    }
  }
  
  Future<dynamic> getInsights(String fileId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/insights?file_id=$fileId'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Check if it's a status response or insights response
        if (jsonData.containsKey('insights')) {
          return InsightResponse.fromJson(jsonData);
        } else {
          return jsonData; // Status response
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get insights');
      }
    } catch (e) {
      throw Exception('Failed to get insights: $e');
    }
  }
  
  Future<FileStatus> getFileStatus(String fileId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status?file_id=$fileId'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FileStatus.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get status');
      }
    } catch (e) {
      throw Exception('Failed to get file status: $e');
    }
  }
}