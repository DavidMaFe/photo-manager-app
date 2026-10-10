import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:photo_manager_app/core/crypto/domain/bip39/bip39_english.dart';
import 'package:photo_manager_app/core/crypto/domain/bip39/bip39_spanish.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

enum RecoveryPhraseLanguage {
  english(bip39English),
  spanish(bip39Spanish);

  final List<String> words;

  const RecoveryPhraseLanguage(this.words);
}

/// The recovery key shown to the user as 24 BIP39 words (docs/e2ee-spec.md, section 4).
///
/// 32 bytes of key + 8 bits of SHA-256 checksum = 264 bits = 24 words of 11 bits. The checksum detects typos and tells
/// the language when a word exists in both lists. Spanish words are accepted with or without accents, composed or
/// decomposed.
class RecoveryPhrase {
  static const int keyLength = 32;
  static const int wordCount = 24;

  const RecoveryPhrase._();

  static List<String> encode(Uint8List key, RecoveryPhraseLanguage language) {
    if (key.length != keyLength) {
      throw ArgumentError.value(key.length, 'key', 'The recovery key must have $keyLength bytes');
    }
    final checksum = sha256.convert(key).bytes.first;
    final bits = StringBuffer();
    for (final byte in [...key, checksum]) {
      bits.write(byte.toRadixString(2).padLeft(8, '0'));
    }
    final binary = bits.toString();
    return List.generate(wordCount, (i) {
      final index = int.parse(binary.substring(i * 11, i * 11 + 11), radix: 2);
      // The official Spanish list stores accents decomposed; NFC shows and copies them as single characters
      return unorm.nfc(language.words[index]);
    });
  }

  /// Returns the 32-byte key, or throws [FormatException] if a word is unknown, the count is wrong or the checksum
  /// does not match (a typo).
  static Uint8List decode(List<String> words) {
    final normalized = words.map(_normalize).where((word) => word.isNotEmpty).toList();
    if (normalized.length != wordCount) {
      throw FormatException('The recovery phrase must have $wordCount words', normalized.length);
    }

    for (final language in RecoveryPhraseLanguage.values) {
      final indexes = _indexes(normalized, language);
      if (indexes == null) {
        continue;
      }
      final key = _keyWithValidChecksum(indexes);
      if (key != null) {
        return key;
      }
    }
    throw const FormatException('The recovery phrase is not valid');
  }

  static List<int>? _indexes(List<String> words, RecoveryPhraseLanguage language) {
    final lookup = _lookups[language] ??= {
      for (var i = 0; i < language.words.length; i++) _normalize(language.words[i]): i,
    };
    final indexes = <int>[];
    for (final word in words) {
      final index = lookup[word];
      if (index == null) {
        return null;
      }
      indexes.add(index);
    }
    return indexes;
  }

  static Uint8List? _keyWithValidChecksum(List<int> indexes) {
    final binary = indexes.map((index) => index.toRadixString(2).padLeft(11, '0')).join();
    final bytes = Uint8List(keyLength + 1);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(binary.substring(i * 8, i * 8 + 8), radix: 2);
    }
    final key = Uint8List.sublistView(bytes, 0, keyLength);
    if (sha256.convert(key).bytes.first != bytes[keyLength]) {
      return null;
    }
    return Uint8List.fromList(key);
  }

  static final Map<RecoveryPhraseLanguage, Map<String, int>> _lookups = {};

  /// Lowercase, trimmed and without accents ("Ábaco " -> "abaco"). Two words are the same word if their normalized
  /// forms are equal.
  static String normalizeWord(String word) => _normalize(word);

  static String _normalize(String word) {
    final decomposed = unorm.nfkd(word.trim().toLowerCase());
    return decomposed.replaceAll(RegExp(r'[̀-ͯ]'), '');
  }
}
