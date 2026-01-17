import 'dart:io';

/// JSON Reader Utility
///
/// This utility helps read JSON fixture files from the test/fixtures/json/ directory.
/// It's useful for loading complex JSON responses for testing API data sources.
///
/// Usage Example:
/// ```dart
/// test('should parse user from JSON', () {
///   final jsonString = readJson('user_response.json');
///   final json = jsonDecode(jsonString);
///   final user = UserModel.fromJson(json);
///   expect(user.email, 'test@example.com');
/// });
/// ```

/// Reads a JSON file from the test/fixtures/json directory.
///
/// Parameters:
/// - [filename]: The name of the JSON file (e.g., 'user_response.json')
///
/// Returns:
/// - The contents of the file as a String
///
/// Throws:
/// - FileSystemException if the file doesn't exist
String readJson(String filename) {
  final file = File('test/fixtures/json/$filename');
  return file.readAsStringSync();
}

/// Checks if a JSON fixture file exists.
///
/// Parameters:
/// - [filename]: The name of the JSON file
///
/// Returns:
/// - true if the file exists, false otherwise
bool jsonFixtureExists(String filename) {
  final file = File('test/fixtures/json/$filename');
  return file.existsSync();
}