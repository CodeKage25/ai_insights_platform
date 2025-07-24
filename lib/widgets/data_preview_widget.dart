import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DataPreviewWidget extends StatelessWidget {
  final List<List<dynamic>> previewData;
  final String filename;

  const DataPreviewWidget({
    super.key,
    required this.previewData,
    required this.filename,
  });

  @override
Widget build(BuildContext context) {
  if (previewData.isEmpty) return const SizedBox.shrink();

  final headers = previewData[0];
  final rows = previewData.skip(1).toList();

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the header
            children: [
              Icon(
                Icons.table_chart_outlined,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Flexible( 
                child: Text(
                  'Data Preview - $filename',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints( // Add constraints for responsiveness
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  AppConstants.primaryColor.withOpacity(0.1),
                ),
                columns: headers
                    .map<DataColumn>((header) => DataColumn(
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              header.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                rows: rows
                    .map<DataRow>((row) => DataRow(
                          cells: row
                              .map<DataCell>((cell) => DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 150),
                                      child: Text(
                                        cell?.toString() ?? 'N/A',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Showing first ${rows.length} rows of data',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ),
  );
}
}
