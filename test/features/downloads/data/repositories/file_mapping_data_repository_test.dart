import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/downloads/data/repositories/file_mapping_data_repository.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase database;
  late FileMappingDataRepository repository;

  setUp(() {
    database = MockAppDatabase();
    repository = FileMappingDataRepository(database: database);
  });

  group('FileMappingDataRepository', () {
    test('should give every mapping', () async {
      when(() => database.getAllMappings()).thenAnswer((_) async => {'1': '100'});

      expect(await repository.all(), {'1': '100'});
    });

    test('should save a downloaded file without content hash', () async {
      when(() => database.saveFileMapping(serverId: any(named: 'serverId'), localId: any(named: 'localId'),
          localPath: any(named: 'localPath'), hash: any(named: 'hash'))).thenAnswer((_) async {});

      await repository.save(serverId: '1', localId: '100', localPath: 'Pictures/PhotoManager/IMG.jpg');

      verify(() => database.saveFileMapping(
          serverId: '1', localId: '100', localPath: 'Pictures/PhotoManager/IMG.jpg', hash: '')).called(1);
    });
  });
}
