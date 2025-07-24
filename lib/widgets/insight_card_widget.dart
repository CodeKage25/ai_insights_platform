import 'package:flutter/material.dart';
import '../models/insight_model.dart';
import '../utils/constants.dart';

class InsightCardWidget extends StatelessWidget {
  final Insight insight;
  final int index;

  const InsightCardWidget({
    super.key,
    required this.insight,
    required this.index,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'statistical':
        return Colors.blue;
      case 'pattern':
        return Colors.green;
      case 'anomaly':
        return Colors.orange;
      case 'data_quality':
        return Colors.red;
      case 'overview':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'statistical':
        return Icons.analytics_outlined;
      case 'pattern':
        return Icons.trending_up_outlined;
      case 'anomaly':
        return Icons.warning_outlined;
      case 'data_quality':
        return Icons.verified_outlined;
      case 'overview':
        return Icons.info_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(insight.category);
    final categoryIcon = _getCategoryIcon(insight.category);
    
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          onTap: () => _showInsightDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  insight.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: categoryColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _buildConfidenceIndicator(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                if (insight.affectedColumns.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: insight.affectedColumns.map((column) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          column,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidencePercent = (insight.confidence * 100).round();
    Color confidenceColor;
    
    if (insight.confidence >= 0.8) {
      confidenceColor = AppConstants.successColor;
    } else if (insight.confidence >= 0.6) {
      confidenceColor = AppConstants.warningColor;
    } else {
      confidenceColor = AppConstants.errorColor;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.analytics,
          size: 14,
          color: confidenceColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$confidencePercent%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: confidenceColor,
          ),
        ),
      ],
    );
  }

  void _showInsightDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getCategoryIcon(insight.category),
              color: _getCategoryColor(insight.category),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(insight.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(insight.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Confidence: ',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildConfidenceIndicator(),
                ],
              ),
              if (insight.affectedColumns.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Affected Columns',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: insight.affectedColumns.map((column) {
                    return Chip(
                      label: Text(column),
                      backgroundColor: Colors.grey.shade100,
                    );
                  }).toList(),
                ),
              ],
              if (insight.affectedRows.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Affected Rows',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Rows: ${insight.affectedRows.take(10).join(', ')}${insight.affectedRows.length > 10 ? '...' : ''}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}