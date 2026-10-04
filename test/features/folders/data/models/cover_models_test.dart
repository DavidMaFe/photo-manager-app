import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/folders/data/models/album_cover_model.dart';
import 'package:photo_manager_app/features/folders/data/models/cover_change_model.dart';
import 'package:photo_manager_app/features/folders/data/models/cover_target_model.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_content_model.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_covers_model.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_change.dart';

import '../../../../fixtures/json_reader.dart';

void main() {
  group('CoverTargetModel', () {
    test('should parse the cover-targets fixture from the root down', () {
      // Act
      final targets = (jsonDecode(readJson('cover_targets.json')) as List<dynamic>)
          .map((json) => CoverTargetModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Assert
      expect(targets.map((t) => t.name), ['Vacaciones 2024', 'Playa', 'Atardeceres']);
      expect(targets.map((t) => t.depth), [0, 1, 2]);
      expect(targets.last.containsDirectly, isTrue);
      expect(targets[1].isFull, isTrue);
      expect(targets[0].isFull, isFalse);
      expect(targets[1].hasCover('102'), isTrue);
    });

    test('should sort the covers by position', () {
      // Act
      final target = CoverTargetModel.fromJson((jsonDecode(readJson('cover_targets.json')) as List).first);

      // Assert
      expect(target.covers.map((c) => c.fileId), ['100', '101']);
    });

    test('should default missing fields', () {
      // Act
      final target = CoverTargetModel.fromJson(const {'folderId': 9});

      // Assert
      expect(target.folderId, '9');
      expect(target.name, '');
      expect(target.depth, 0);
      expect(target.containsDirectly, isFalse);
      expect(target.covers, isEmpty);
    });
  });

  group('AlbumCoverModel', () {
    test('should parse the source path and tell covers of the album itself', () {
      // Act
      final fromSub = AlbumCoverModel.fromJson(const {
        'fileId': 102,
        'position': 1,
        'sourceFolderId': 3,
        'sourceFolderName': 'Atardeceres',
        'sourceFolderPath': ['Playa', 'Atardeceres'],
      });
      final own = AlbumCoverModel.fromJson(const {
        'fileId': 100,
        'position': 0,
        'sourceFolderId': 1,
        'sourceFolderName': 'Vacaciones',
      });

      // Assert
      expect(fromSub.fileId, '102');
      expect(fromSub.sourceFolderId, '3');
      expect(fromSub.sourceFolderPath, ['Playa', 'Atardeceres']);
      expect(fromSub.isFromThisAlbum, isFalse);
      expect(own.sourceFolderPath, isEmpty);
      expect(own.isFromThisAlbum, isTrue);
    });

    test('should round-trip through toJson', () {
      // Arrange
      const cover = AlbumCoverModel(
        fileId: '1',
        position: 2,
        sourceFolderId: '3',
        sourceFolderName: 'Playa',
        sourceFolderPath: ['Playa'],
      );

      // Act & Assert
      expect(AlbumCoverModel.fromJson(cover.toJson()), cover);
    });
  });

  group('FolderCoversModel', () {
    test('should parse the folder and its covers', () {
      // Act
      final model = FolderCoversModel.fromJson(const {
        'folderId': 2,
        'covers': [
          {'fileId': 5, 'position': 0, 'sourceFolderId': 2, 'sourceFolderName': 'Playa', 'sourceFolderPath': []},
        ],
      });

      // Assert
      expect(model.folderId, '2');
      expect(model.covers.single.fileId, '5');
    });
  });

  group('CoverChangeModel', () {
    test('should serialize each action', () {
      expect(CoverChangeModel.toJson(const CoverChange.add('1')), {'folderId': '1', 'action': 'add'});
      expect(CoverChangeModel.toJson(const CoverChange.remove('1')), {'folderId': '1', 'action': 'remove'});
      expect(
        CoverChangeModel.toJson(const CoverChange.replace('1', '9')),
        {'folderId': '1', 'action': 'replace', 'replaceFileId': '9'},
      );
    });
  });

  group('FolderContentModel with covers', () {
    test('should parse covers of the album and favorites and coverOf of its files', () {
      // Act
      final content = FolderContentModel.fromJson(
        jsonDecode(readJson('folder_detail_with_covers.json')) as Map<String, dynamic>,
        currentPage: 0,
      );

      // Assert
      expect(content.folder.coverFileIds, ['100', '102']);
      expect(content.subfolders.single.mosaicFileIds, ['102']);
      expect(content.files.first.isFavorite, isTrue);
      expect(content.files.first.coverOf, ['1', '2']);
      expect(content.files.first.isCoverOf('2'), isTrue);
      expect(content.files.last.isFavorite, isFalse);
      expect(content.files.last.coverOf, isEmpty);
    });
  });
}
