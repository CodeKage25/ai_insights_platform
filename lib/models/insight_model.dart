class Insight {
  final String title;
  final String description;
  final double confidence;
  final String category;
  final List<String> affectedColumns;
  final List<int> affectedRows;

  Insight({
    required this.title,
    required this.description,
    required this.confidence,
    required this.category,
    this.affectedColumns = const [],
    this.affectedRows = const [],
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      category: json['category'] as String,
      affectedColumns: (json['affected_columns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      affectedRows: (json['affected_rows'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
    );
  }
}

class InsightResponse {
  final String fileId;
  final List<Insight> insights;
  final double processingTime;
  final int totalInsights;

  InsightResponse({
    required this.fileId,
    required this.insights,
    required this.processingTime,
    required this.totalInsights,
  });

  factory InsightResponse.fromJson(Map<String, dynamic> json) {
    return InsightResponse(
      fileId: json['file_id'] as String,
      insights: (json['insights'] as List<dynamic>)
          .map((insight) => Insight.fromJson(insight as Map<String, dynamic>))
          .toList(),
      processingTime: (json['processing_time'] as num).toDouble(),
      totalInsights: json['total_insights'] as int,
    );
  }
}