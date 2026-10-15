import 'dart:typed_data';

/// Minimal JPEG structures for the format checks: markers with their lengths and some entropy-coded bytes.
abstract final class JpegTestBytes {
  static List<int> _segment(int marker, List<int> payload) =>
      [0xFF, marker, (payload.length + 2) >> 8, (payload.length + 2) & 0xFF, ...payload];

  /// A Huffman table of class [tableClass] with one symbol.
  static List<int> _table(int tableClass, int id) => [(tableClass << 4) | id, 1, ...List.filled(15, 0), 0];

  static const List<int> _soi = [0xFF, 0xD8];
  static const List<int> _eoi = [0xFF, 0xD9];

  /// Entropy-coded data with a stuffed 0xFF00 and a restart marker, as a real scan has.
  static const List<int> _scanData = [0x12, 0xFF, 0x00, 0x34, 0xFF, 0xD0, 0x56, 0x78];

  /// Baseline JPEG: APP0, DQT, SOF0, a DHT with two tables, one scan.
  static Uint8List baseline({List<int> tail = const []}) => Uint8List.fromList([
        ..._soi,
        ..._segment(0xE0, 'JFIF'.codeUnits + [0, 1, 1, 0, 0, 1, 0, 1, 0, 0]),
        ..._segment(0xDB, [0, ...List.filled(64, 1)]),
        ..._segment(0xC0, [8, 0, 16, 0, 16, 1, 1, 0x11, 0]),
        ..._segment(0xC4, [..._table(0, 0), ..._table(1, 0)]),
        ..._segment(0xDA, [1, 1, 0, 0, 63, 0]),
        ..._scanData,
        ..._eoi,
        ...tail,
      ]);

  /// Progressive JPEG whose second scan is preceded by a DHT segment without tables (WhatsApp and similar apps).
  static Uint8List progressiveWithEmptyDht() => Uint8List.fromList([
        ..._soi,
        ..._segment(0xDB, [0, ...List.filled(64, 1)]),
        ..._segment(0xC2, [8, 0, 16, 0, 16, 1, 1, 0x11, 0]),
        ..._segment(0xC4, _table(0, 0)),
        ..._segment(0xDA, [1, 1, 0, 0, 0, 0]),
        ..._scanData,
        ..._segment(0xC4, const []),
        ..._segment(0xDA, [1, 1, 0, 1, 63, 0]),
        ..._scanData,
        ..._eoi,
      ]);

  /// Progressive JPEG with a full DHT between scans.
  static Uint8List progressive() => Uint8List.fromList([
        ..._soi,
        ..._segment(0xDB, [0, ...List.filled(64, 1)]),
        ..._segment(0xC2, [8, 0, 16, 0, 16, 1, 1, 0x11, 0]),
        ..._segment(0xC4, _table(0, 0)),
        ..._segment(0xDA, [1, 1, 0, 0, 0, 0]),
        ..._scanData,
        ..._segment(0xC4, _table(1, 0)),
        ..._segment(0xDA, [1, 1, 0, 1, 63, 0]),
        ..._scanData,
        ..._eoi,
      ]);
}
