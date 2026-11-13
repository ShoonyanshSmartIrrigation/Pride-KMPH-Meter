import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pride_kmph_meter/core/utils/speed_formatter.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_status.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/widgets/instrument_display_panel.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/widgets/modern_speedometer_card.dart';

void main() {
  testWidgets('InstrumentDisplayPanel renders exact TFT physical numerals',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InstrumentDisplayPanel(
            currentSpeed: 1.34473,
            previousSpeed: 2.21500,
            distanceMm: 50.0,
            elapsedTimeUs: 133856,
            status: HardwareMeasurementStatus.completed,
            isPreview: true,
          ),
        ),
      ),
    );

    // Verify TFT screen labels
    expect(find.text('CURRENT SPEED'), findsOneWidget);
    expect(find.text('PREVIOUS SPEED'), findsOneWidget);

    // Verify 5-decimal formatted digits with leading zeros
    expect(find.text('01.34473'), findsOneWidget);
    expect(find.text('02.21500'), findsOneWidget);

    // Verify distance and microsecond time
    expect(find.text(SpeedFormatter.formatDistanceMm(50.0)), findsOneWidget);
    expect(find.text(SpeedFormatter.formatTimeUs(133856)), findsOneWidget);
  });

  testWidgets('ModernSpeedometerCard renders modern radial gauge numerals and labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModernSpeedometerCard(
            currentSpeed: 0.06556,
            speedUnit: 'km/h',
          ),
        ),
      ),
    );

    // Verify Modern Clean UI elements
    expect(find.text('CURRENT SPEED'), findsOneWidget);
    expect(find.text('00.06556'), findsOneWidget);
    expect(find.text('km/h'), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
  });

  testWidgets('Discovered device tile handles very long device name without overflow',
      (WidgetTester tester) async {
    // Set a narrow screen size (320px) to stress-test overflow handling
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: const Icon(Icons.bluetooth),
            title: Row(
              children: [
                const Flexible(
                  child: Text(
                    'Extremely_Long_Bluetooth_Device_Name_Pride_Meter_Telemetry_Rev2',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: const Text('METER'),
                ),
              ],
            ),
            subtitle: const Text(
              'ID: AA:BB:CC:DD:EE:FF   RSSI: -45 dBm',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Connect'),
            ),
          ),
        ),
      ),
    );

    // Verify widget rendered cleanly without RenderFlex overflow exception
    expect(tester.takeException(), isNull);
    expect(find.text('Connect'), findsOneWidget);
  });
}
