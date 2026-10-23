import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_albums_remote_data_source.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

const _albumsBody = '{"albums":[{"localAlbumId":"747804901","name":"Vacaciones 2025","mode":"ALBUM",'
    '"folderId":null,"isNew":true}]}';

void main() {
  late List<http.Request> sent;

  LocalAlbumsRemoteDataSourceImpl dataSource(http.Response Function(http.Request) answer) {
    sent = [];
    return LocalAlbumsRemoteDataSourceImpl(
      client: MockClient((request) async {
        sent.add(request);
        return answer(request);
      }),
      baseUrl: 'https://api.test',
    );
  }

  group('LocalAlbumsRemoteDataSource', () {
    group('getAlbums', () {
      test('should read the albums of the device', () async {
        final albums = await dataSource((_) => http.Response(_albumsBody, 200)).getAlbums('uuid-1');

        expect(sent.single.method, 'GET');
        expect(sent.single.url.toString(), 'https://api.test/api/device/uuid-1/albums/');
        expect(albums.single.name, 'Vacaciones 2025');
        expect(albums.single.isNew, isTrue);
      });

      test('should throw the error of the server', () async {
        final source = dataSource((_) => http.Response(
            '{"code":"DEVICE_NOT_FOUND","message":"Device not found","timestamp":"2026-10-23T10:00:00"}', 400));

        await expectLater(source.getAlbums('uuid-1'),
            throwsA(isA<ApiException>().having((e) => e.code, 'code', 'DEVICE_NOT_FOUND')));
      });
    });

    group('register', () {
      test('should put the albums of the gallery', () async {
        final source = dataSource((_) => http.Response(_albumsBody, 200));

        await source.register('uuid-1', const [
          LocalAlbumRegistration(localAlbumId: '747804901', name: 'Vacaciones 2025', defaultMode: LocalAlbumMode.album),
        ]);

        expect(sent.single.method, 'PUT');
        expect(sent.single.url.toString(), 'https://api.test/api/device/uuid-1/albums/');
        expect(jsonDecode(sent.single.body), {
          'albums': [
            {'localAlbumId': '747804901', 'name': 'Vacaciones 2025', 'defaultMode': 'ALBUM'}
          ]
        });
      });

      test('should send the albums in requests of at most 1000', () async {
        final source = dataSource((_) => http.Response('{"albums":[]}', 200));
        final albums = [
          for (var i = 0; i < 1500; i++)
            LocalAlbumRegistration(localAlbumId: '$i', name: 'Album $i', defaultMode: LocalAlbumMode.album),
        ];

        await source.register('uuid-1', albums);

        expect(sent, hasLength(2));
        expect((jsonDecode(sent.first.body)['albums'] as List), hasLength(1000));
        expect((jsonDecode(sent.last.body)['albums'] as List), hasLength(500));
      });

      test('should register an empty gallery', () async {
        final albums = await dataSource((_) => http.Response('{"albums":[]}', 200)).register('uuid-1', const []);

        expect(albums, isEmpty);
        expect(jsonDecode(sent.single.body), {'albums': []});
      });
    });

    group('setModes', () {
      test('should put the options chosen by the user', () async {
        final source = dataSource((_) => http.Response(_albumsBody, 200));

        await source.setModes('uuid-1', {'702742726': LocalAlbumMode.excluded});

        expect(sent.single.method, 'PUT');
        expect(sent.single.url.toString(), 'https://api.test/api/device/uuid-1/albums/modes/');
        expect(jsonDecode(sent.single.body), {
          'modes': [
            {'localAlbumId': '702742726', 'mode': 'EXCLUDED'}
          ]
        });
      });
    });
  });
}
