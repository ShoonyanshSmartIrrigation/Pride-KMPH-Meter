import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pride_kmph_meter/core/constants/app_colors.dart';
import 'package:pride_kmph_meter/core/theme/app_theme.dart';
import 'package:pride_kmph_meter/core/utils/csv_exporter.dart';
import 'package:pride_kmph_meter/core/utils/date_formatter.dart';
import 'package:pride_kmph_meter/core/utils/speed_formatter.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_model.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/controllers/measurement_controller.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/widgets/kpi_card_widget.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/widgets/speed_chart_widget.dart';
import 'package:pride_kmph_meter/features/settings/presentation/controllers/settings_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(measurementControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final history = liveState.history;

    // Filter by search query or selected date
    final filteredHistory = history.where((m) {
      final matchesQuery = _searchQuery.isEmpty ||
          m.testNumber.toString().contains(_searchQuery) ||
          m.currentSpeedKmph.toString().contains(_searchQuery);

      final matchesDate = _selectedDate == null ||
          (m.measuredAt.year == _selectedDate!.year &&
              m.measuredAt.month == _selectedDate!.month &&
              m.measuredAt.day == _selectedDate!.day);

      return matchesQuery && matchesDate;
    }).toList();

    // Compute KPIs
    double maxSpeed = 0.0;
    double minSpeed = history.isEmpty ? 0.0 : double.infinity;
    double totalSpeed = 0.0;

    for (final m in history) {
      final s = m.currentSpeedKmph;
      if (s > maxSpeed) maxSpeed = s;
      if (s < minSpeed) minSpeed = s;
      totalSpeed += s;
    }

    if (minSpeed == double.infinity) minSpeed = 0.0;
    final avgSpeed = history.isEmpty ? 0.0 : totalSpeed / history.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement History'),
        actions: [
          // CSV Export Button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export CSV',
            onPressed: history.isEmpty
                ? null
                : () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Generating CSV export...')),
                      );
                      await CsvExporter.exportAndShare(history);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
          ),
          // Clear History Button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear History',
            onPressed: history.isEmpty
                ? null
                : () => _confirmClearDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. KPI SUMMARY CARDS GRID
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                KpiCardWidget(
                  label: 'MAX SPEED',
                  value: SpeedFormatter.formatSpeed5Decimals(maxSpeed),
                  unit: settings.speedUnit,
                  icon: Icons.trending_up,
                  accentColor: Colors.purple.shade700,
                ),
                KpiCardWidget(
                  label: 'MIN SPEED',
                  value: SpeedFormatter.formatSpeed5Decimals(minSpeed),
                  unit: settings.speedUnit,
                  icon: Icons.trending_down,
                  accentColor: Colors.teal.shade700,
                ),
                KpiCardWidget(
                  label: 'AVERAGE SPEED',
                  value: SpeedFormatter.formatSpeed5Decimals(avgSpeed),
                  unit: settings.speedUnit,
                  icon: Icons.functions,
                  accentColor: AppColors.primary,
                ),
                KpiCardWidget(
                  label: 'TOTAL TESTS',
                  value: '${history.length}',
                  icon: Icons.tag,
                  accentColor: Colors.indigo.shade700,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. SPEED TREND CHART
            SpeedChartWidget(
              measurements: history,
              speedUnit: settings.speedUnit,
            ),

            const SizedBox(height: 20),

            // 3. SEARCH & DATE FILTER BAR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search test # or speed...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (_selectedDate != null) {
                      setState(() => _selectedDate = null);
                      return;
                    }
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: Icon(
                    _selectedDate != null ? Icons.close : Icons.calendar_today,
                    size: 16,
                  ),
                  label: Text(_selectedDate != null
                      ? DateFormatter.formatDate(_selectedDate!)
                      : 'Date'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. DETAILED MEASUREMENTS LIST
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'RECORDED TESTS (${filteredHistory.length})',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Offline Cached & Firestore Ready',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (filteredHistory.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'No measurements found.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredHistory.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = filteredHistory[index];
                  return _buildMeasurementTile(context, item, settings.speedUnit);
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementTile(
      BuildContext context, MeasurementModel item, String unit) {
    return Card(
      child: InkWell(
        onTap: () => _showDetailDialog(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Test number badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${item.testNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Measurement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          SpeedFormatter.formatSpeed5Decimals(
                              item.currentSpeedKmph),
                          style: AppTheme.digitalStyle(
                            fontSize: 18,
                            color: AppColors.currentSpeed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'T: ${SpeedFormatter.formatTimeUs(item.elapsedTimeUs)}  •  D: ${SpeedFormatter.formatDistanceMm(item.distanceMm)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatDateTime(item.measuredAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Firestore sync pill
              Icon(
                item.syncedToFirestore ? Icons.cloud_done : Icons.cloud_off,
                size: 18,
                color: item.syncedToFirestore
                    ? AppColors.connected
                    : Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, MeasurementModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.speed, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Test #${item.testNumber} Details',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalRow(
                  'Current Speed',
                  '${SpeedFormatter.formatSpeed5Decimals(item.currentSpeedKmph)} KM/H',
                  color: AppColors.currentSpeed),
              _buildModalRow(
                  'Previous Speed',
                  '${SpeedFormatter.formatSpeed5Decimals(item.previousSpeedKmph)} KM/H',
                  color: AppColors.previousSpeed),
              _buildModalRow(
                  'Sensor Distance',
                  SpeedFormatter.formatDistanceMm(item.distanceMm)),
              _buildModalRow(
                  'Elapsed Time',
                  SpeedFormatter.formatTimeUs(item.elapsedTimeUs),
                  color: AppColors.timerText),
              _buildModalRow('Hardware Device', item.deviceName),
              _buildModalRow('Measurement Status', item.status),
              _buildModalRow('Timestamp',
                  DateFormatter.formatDateTime(item.measuredAt)),
              _buildModalRow('Firestore Cloud Sync',
                  item.syncedToFirestore ? 'Synchronized' : 'Stored Locally'),
              _buildModalRow('Record ID', item.id, isMono: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value,
      {Color? color, bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.deepNavy,
                fontFamily: isMono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Clear Measurement History?'),
          content: const Text(
            'This action will permanently delete all recorded measurements stored on this device. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(measurementControllerProvider.notifier)
                    .clearHistory();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared successfully.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
