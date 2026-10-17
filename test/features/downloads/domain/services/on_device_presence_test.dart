import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/missing_on_device.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockComputeMissingOnDeviceUseCase computeMissing;
  late OnDevicePresence presence;

  setUp(() {
    computeMissing = MockComputeMissingOnDeviceUseCase();
    presence = OnDevicePresence(computeMissing);
    when(() => computeMissing()).thenAnswer((_) async =>
        const MissingOnDevice(missing: [DownloadsTestData.video], onDevice: [DownloadsTestData.photo]));
  });

  group('OnDevicePresence', () {
    test('should not know anything before the first refresh', () {
      expect(presence.isKnown, isFalse);
      expect(presence.isOnDevice('1'), isNull);
      expect(presence.missing, isEmpty);
    });

    test('should know which files are missing after a refresh and notify the change', () async {
      final changes = <void>[];
      presence.changes.listen(changes.add);

      await presence.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(presence.isKnown, isTrue);
      expect(presence.isOnDevice('1'), isTrue);
      expect(presence.isOnDevice('2'), isFalse);
      expect(presence.isOnDevice('99'), isTrue);
      expect(presence.missing, [DownloadsTestData.video]);
      expect(changes, hasLength(1));
    });

    test('should share one computation between refreshes made at the same time', () async {
      final completer = Completer<MissingOnDevice>();
      when(() => computeMissing()).thenAnswer((_) => completer.future);

      final first = presence.refresh();
      final second = presence.refresh();
      completer.complete(const MissingOnDevice(missing: [], onDevice: []));
      await Future.wait([first, second]);

      verify(() => computeMissing()).called(1);
    });

    test('should mark files as on the device once downloaded', () async {
      await presence.refresh();

      presence.markOnDevice(['2']);

      expect(presence.isOnDevice('2'), isTrue);
      expect(presence.missing, isEmpty);
    });

    test('should mark freed up files as missing only once it is known', () async {
      presence.markMissing([DownloadsTestData.photo]);
      expect(presence.isOnDevice('1'), isNull);

      await presence.refresh();
      presence.markMissing([DownloadsTestData.photo]);

      expect(presence.isOnDevice('1'), isFalse);
    });

    test('should keep the last state when a refresh fails and allow the next one', () async {
      await presence.refresh();
      when(() => computeMissing()).thenThrow(Exception('offline'));

      await expectLater(presence.refresh(), throwsA(isA<Exception>()));
      expect(presence.isOnDevice('2'), isFalse);

      when(() => computeMissing()).thenAnswer((_) async => const MissingOnDevice(missing: [], onDevice: []));
      await presence.refresh();
      expect(presence.isOnDevice('2'), isTrue);
    });

    test('should forget everything on clear', () async {
      await presence.refresh();

      presence.clear();

      expect(presence.isKnown, isFalse);
      expect(presence.missing, isEmpty);
    });
  });
}
