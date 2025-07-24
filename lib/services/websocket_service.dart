import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; 
import '../utils/constants.dart';

class WebSocketMessage {
  final String type;
  final String fileId;
  final String? status;
  final String? message;
  final double? progress;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.fileId,
    this.status,
    this.message,
    this.progress,
    this.details,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      fileId: json['file_id'] as String,
      status: json['status'] as String?,
      message: json['message'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      details: json['details'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ProcessingProgress {
  final String currentStep;
  final int totalSteps;
  final int currentStepNum;
  final double progress;
  final int insightsFound;
  final String message;

  ProcessingProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.currentStepNum,
    required this.progress,
    required this.insightsFound,
    required this.message,
  });

  factory ProcessingProgress.fromJson(Map<String, dynamic> json) {
    return ProcessingProgress(
      currentStep: json['current_step'] as String,
      totalSteps: json['total_steps'] as int,
      currentStepNum: json['current_step_num'] as int,
      progress: (json['progress'] as num).toDouble(),
      insightsFound: json['insights_found'] as int? ?? 0,
      message: json['message'] as String,
    );
  }
}

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool _isConnected = false;
  String? _currentFileId;
  String _connectionStatus = 'disconnected';

  ProcessingProgress? _currentProgress;
  WebSocketMessage? _lastMessage;

  final _statusUpdateController = StreamController<WebSocketMessage>.broadcast();
  final _progressController = StreamController<ProcessingProgress>.broadcast();
  final _completionController = StreamController<WebSocketMessage>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  ProcessingProgress? get currentProgress => _currentProgress;
  WebSocketMessage? get lastMessage => _lastMessage;

  // Streams
  Stream<WebSocketMessage> get statusUpdates => _statusUpdateController.stream;
  Stream<ProcessingProgress> get progressUpdates => _progressController.stream;
  Stream<WebSocketMessage> get completionUpdates => _completionController.stream;

  Future<void> connect(String fileId) async {
    if (_isConnected && _currentFileId == fileId) {
      return;
    }

    await disconnect();

    try {
      _currentFileId = fileId;
      _connectionStatus = 'connecting';
      notifyListeners();

      final wsUrl = '${AppConstants.baseUrl.replaceFirst('http', 'ws')}/ws/$fileId';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _sendPing();

      Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isConnected) {
          _sendPing();
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      _connectionStatus = 'error';
      _handleError(e);
    }
  }

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    await _subscription?.cancel();
    _subscription = null;

    _isConnected = false;
    _currentFileId = null;
    _connectionStatus = 'disconnected';
    _currentProgress = null;

    notifyListeners();
  }

  void _sendPing() {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(json.encode({
        'type': 'ping',
        'file_id': _currentFileId,
      }));
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> messageData = json.decode(data as String);
      final message = WebSocketMessage.fromJson(messageData);

      _lastMessage = message;

      switch (message.type) {
        case 'connection_established':
          _isConnected = true;
          _connectionStatus = 'connected';
          debugPrint('WebSocket connected for file: ${message.fileId}');
          break;

        case 'status_update':
          _statusUpdateController.add(message);
          debugPrint('Status update: ${message.status} - ${message.message}');
          break;

        case 'insight_progress':
          final progress = ProcessingProgress.fromJson(messageData);
          _currentProgress = progress;
          _progressController.add(progress);
          debugPrint('Progress: ${progress.progress}% - ${progress.message}');
          break;

        case 'insights_complete':
          _completionController.add(message);
          debugPrint('Insights complete: ${message.message}');
          break;

        case 'pong':
          debugPrint('Received pong from server');
          break;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }

  void _handleError(error) {
    debugPrint('WebSocket error: $error');
    _connectionStatus = 'error';
    _isConnected = false;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  void _handleDisconnection() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _connectionStatus = 'disconnected';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    disconnect();
    _statusUpdateController.close();
    _progressController.close();
    _completionController.close();
    super.dispose();
  }
}