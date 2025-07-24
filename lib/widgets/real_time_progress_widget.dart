import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../utils/constants.dart';

class RealTimeProgressWidget extends StatefulWidget {
  final String fileId;
  final VoidCallback? onComplete;

  const RealTimeProgressWidget({
    super.key,
    required this.fileId,
    this.onComplete,
  });

  @override
  State<RealTimeProgressWidget> createState() => _RealTimeProgressWidgetState();
}

class _RealTimeProgressWidgetState extends State<RealTimeProgressWidget>
    with TickerProviderStateMixin {
  late WebSocketService _wsService;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  String _currentStatus = 'Connecting...';
  double _currentProgress = 0.0;
  String _currentStep = '';
  int _insightsFound = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _setupWebSocket();
  }

  void _setupWebSocket() {
    _wsService = Provider.of<WebSocketService>(context, listen: false);
    
    // Connect to WebSocket
    _wsService.connect(widget.fileId);
    
    // Listen to status updates
    _wsService.statusUpdates.listen((message) {
      if (mounted) {
        setState(() {
          _currentStatus = message.message ?? message.status ?? 'Processing...';
        });
      }
    });
    
    // Listen to progress updates
    _wsService.progressUpdates.listen((progress) {
      if (mounted) {
        setState(() {
          _currentStep = progress.currentStep;
          _currentProgress = progress.progress / 100.0;
          _insightsFound = progress.insightsFound;
          _currentStatus = progress.message;
        });
        
        // Animate progress bar
        _progressController.animateTo(_currentProgress);
      }
    });
    
    // Listen to completion
    _wsService.completionUpdates.listen((message) {
      if (mounted) {
        setState(() {
          _isComplete = true;
          _currentProgress = 1.0;
          _currentStatus = message.message ?? 'Analysis complete!';
        });
        
        _progressController.animateTo(1.0);
        
        // Call completion callback after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketService>(
      builder: (context, wsService, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildProgressIndicator(),
                const SizedBox(height: 16),
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildStatusText(),
                if (_insightsFound > 0) ...[
                  const SizedBox(height: 12),
                  _buildInsightsCounter(),
                ],
                const SizedBox(height: 16),
                _buildConnectionStatus(wsService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isComplete ? 1.0 : _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isComplete 
                      ? AppConstants.successColor.withOpacity(0.1)
                      : AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isComplete ? Icons.check_circle : Icons.analytics,
                  color: _isComplete 
                      ? AppConstants.successColor
                      : AppConstants.primaryColor,
                  size: 32,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isComplete ? 'Analysis Complete!' : 'Analyzing Your Data',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time AI insights generation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    if (_isComplete) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppConstants.successColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: AppConstants.successColor,
          size: 40,
        ),
      );
    }
    
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: _currentProgress,
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          ),
          SpinKitPulse(
            color: AppConstants.primaryColor.withOpacity(0.3),
            size: 60,
          ),
          Text(
            '${(_currentProgress * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_currentProgress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isComplete 
                    ? AppConstants.successColor
                    : AppConstants.primaryColor,
              ),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        Text(
          _currentStatus,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (_currentStep.isNotEmpty && !_isComplete) ...[
          const SizedBox(height: 8),
          Text(
            'Current step: $_currentStep',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildInsightsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppConstants.successColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$_insightsFound insights found',
            style: TextStyle(
              color: AppConstants.successColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(WebSocketService wsService) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (wsService.connectionStatus) {
      case 'connected':
        statusColor = AppConstants.successColor;
        statusIcon = Icons.wifi;
        statusText = 'Connected';
        break;
      case 'connecting':
        statusColor = AppConstants.warningColor;
        statusIcon = Icons.wifi_tethering;
        statusText = 'Connecting...';
        break;
      case 'error':
        statusColor = AppConstants.errorColor;
        statusIcon = Icons.wifi_off;
        statusText = 'Connection Error';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.wifi_off;
        statusText = 'Disconnected';
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(statusIcon, color: statusColor, size: 16),
        const SizedBox(width: 6),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}