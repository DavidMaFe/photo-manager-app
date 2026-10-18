import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/get_device_storage_use_case.dart';

class MockDeviceGalleryRepository extends Mock implements DeviceGalleryRepository {}

void main() {
  late MockDeviceGalleryRepository gallery;
  late GetDeviceStorageUseCase useCase;

  setUp(() {
    gallery = MockDeviceGalleryRepository();
    useCase = GetDeviceStorageUseCase(gallery);
  });

  group('GetDeviceStorageUseCase', () {
    test('should give the free and total space of the device', () async {
      const storage = DeviceStorage(freeBytes: 100, totalBytes: 200);
      when(() => gallery.isSupported()).thenAnswer((_) async => true);
      when(() => gallery.storage()).thenAnswer((_) async => storage);

      expect(await useCase(), storage);
    });

    test('should give nothing where the app cannot save into the gallery', () async {
      when(() => gallery.isSupported()).thenAnswer((_) async => false);

      expect(await useCase(), isNull);
      verifyNever(() => gallery.storage());
    });
  });
}
