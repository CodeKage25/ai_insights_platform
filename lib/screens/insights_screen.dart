import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/insight_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../widgets/insight_card_widget.dart';
import '../widgets/real_time_progress_widget.dart';
import '../utils/constants.dart';

class InsightsScreen extends StatefulWidget {
  final String fileId;
  final String filename;

  const InsightsScreen({
    super.key,
    required this.fileId,
    required this.filename,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late ApiService _apiService;
  bool _isProcessing = false;
  bool _hasStartedProcessing = false;
  InsightResponse? _insightResponse;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    setState(() {
      _isProcessing = true;
      _hasStartedProcessing = true;
    });

    try {
      final response = await _apiService.processFile(widget.fileId);
      
      _showSuccessSnackBar('Processing started with real-time updates!');
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Failed to start processing: $e');
    }
  }

  void _onProcessingComplete() async {
    try {
      final result = await _apiService.getInsights(widget.fileId);
      
      if (result is InsightResponse) {
        setState(() {
          _insightResponse = result;
          _isProcessing = false;
        });
        
        _fadeController.forward();
        _showSuccessSnackBar('Analysis complete! Found ${result.insights.length} insights.');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching insights: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Insights - ${widget.filename}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_hasStartedProcessing) _buildStartButton(),
              if (_isProcessing) _buildRealTimeProgress(),
              if (_insightResponse != null) _buildInsightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to Generate Insights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Click the button below to start analyzing your data with real-time progress updates.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startProcessing,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Real-time Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeProgress() {
    return RealTimeProgressWidget(
      fileId: widget.fileId,
      onComplete: _onProcessingComplete,
    );
  }

  Widget _buildInsightsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Generated Insights',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_insightResponse!.totalInsights} insights found',
                  style: TextStyle(
                    color: AppConstants.successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_insightResponse!.insights.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No insights found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The analysis completed but no significant insights were discovered in your data.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              _insightResponse!.insights.length,
              (index) => InsightCardWidget(
                insight: _insightResponse!.insights[index],
                index: index,
              ),
            ),
        ],
      ),
    );
  }
}