# Test Documentation

> Comprehensive testing guide for Photo Manager App

## Table of Contents
- [Overview](#overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [Test Helpers](#test-helpers)
- [Mock Factories](#mock-factories)
- [Test Fixtures](#test-fixtures)
- [Best Practices](#best-practices)
- [Common Pitfalls](#common-pitfalls)

---

## Overview

This project follows **Clean Architecture** with comprehensive test coverage across all layers:
- **Domain Layer**: Pure business logic (entities, use cases, repository interfaces)
- **Data Layer**: Data sources, repositories, and models
- **Presentation Layer**: BLoCs, pages, and widgets

### Testing Philosophy
- Follow the **AAA pattern** (Arrange, Act, Assert)
- Tests should be **independent** and **deterministic**
- Mock external dependencies, not internal logic
- Test behavior, not implementation details

### Test Coverage Goals
- ✅ Overall coverage: ≥ 80%
- ✅ Critical paths: 100%
- ✅ All features tested at all three layers
- ✅ Integration tests for key user flows

---

## Test Structure

```
test/
├── helpers/                          # Shared test utilities
│   ├── widget_test_helper.dart      # Widget testing helpers
│   └── mock_factories.dart          # Mock object factories
├── fixtures/                         # Test data
│   ├── test_data.dart               # Sample entities and constants
│   ├── json_reader.dart             # JSON file reader utility
│   └── json/                        # JSON response fixtures
│       ├── auth_response.json
│       ├── user_profile_response.json
│       └── error_*.json
├── features/                         # Feature tests (mirrors lib/features/)
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/            # Entity tests
│   │   │   └── use_cases/           # Use case tests
│   │   ├── data/
│   │   │   ├── models/              # Model tests
│   │   │   ├── data_sources/        # Data source tests
│   │   │   └── repositories/        # Repository tests
│   │   └── presentation/
│   │       ├── bloc/                # BLoC tests
│   │       ├── pages/               # Page tests
│   │       └── widgets/             # Widget tests
│   └── [other features...]
└── integration_test/                 # End-to-end integration tests

```

---

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth/domain/use_cases/login_use_case_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Generate HTML Coverage Report
```bash
# Generate coverage
flutter test --coverage

# Convert to HTML (requires genhtml from lcov package)
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS)
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Run Tests in Watch Mode
Using `entr` (install via `brew install entr` on macOS):
```bash
find test -name "*.dart" | entr -c flutter test /_
```

---

## Writing Tests

### 1. Domain Layer Tests

#### Entity Tests
Test entity creation, equality, and any business logic.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('should create user with all fields', () {
      // Arrange & Act
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test',
        surname: 'User',
      );

      // Assert
      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test');
      expect(user.surname, 'User');
    });

    test('should be valid when all required fields are present', () {
      // Arrange
      final user = User(id: '1', email: 'test@example.com', name: 'Test');

      // Act & Assert
      expect(user.isValid, true);
    });
  });
}
```

#### Use Case Tests
Test business logic and validation. Mock repository dependencies.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('should call repository with correct parameters', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password123';
      when(() => mockRepository.login(email, password))
          .thenAnswer((_) async => User(id: '1', email: email, name: 'Test'));

      // Act
      await useCase(email, password);

      // Assert
      verify(() => mockRepository.login(email, password)).called(1);
    });

    test('should throw exception when email is empty', () async {
      // Arrange, Act & Assert
      expect(
        () => useCase('', 'password'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### 2. Data Layer Tests

#### Model Tests
Test JSON serialization/deserialization and model-entity relationship.

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should be a subclass of User entity', () {
      // Arrange
      final model = UserModel(id: '1', email: 'test@example.com', name: 'Test');

      // Assert
      expect(model, isA<User>());
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final jsonString = '{"id":"1","email":"test@example.com","name":"Test"}';
      final json = jsonDecode(jsonString);

      // Act
      final model = UserModel.fromJson(json);

      // Assert
      expect(model.id, '1');
      expect(model.email, 'test@example.com');
      expect(model.name, 'Test');
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final model = UserModel(id: '1', email: 'test@example.com', name: 'Test');

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test');
    });
  });
}
```

#### Data Source Tests
Test API calls and local storage operations.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../../../helpers/mock_factories.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late AuthRemoteDataSource dataSource;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(mockClient);
  });

  group('AuthRemoteDataSource', () {
    test('should perform POST request to login endpoint', () async {
      // Arrange
      final response = createHttpResponse(200, '{"token":"abc","user":{...}}');
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => response);

      // Act
      await dataSource.login('test@example.com', 'password');

      // Assert
      verify(() => mockClient.post(
        Uri.parse('http://10.0.2.2:8080/auth/login'),
        headers: {'content-type': 'application/json'},
        body: any(named: 'body'),
      )).called(1);
    });

    test('should throw exception on 401 response', () async {
      // Arrange
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => HttpErrorResponses.unauthorized());

      // Act & Assert
      expect(
        () => dataSource.login('test@example.com', 'wrong'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
```

#### Repository Tests
Test repository logic, caching strategies, and error handling.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthDataRepository repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthDataRepository(mockRemoteDataSource, mockLocalDataSource);
  });

  group('AuthDataRepository', () {
    test('should return user from remote data source', () async {
      // Arrange
      final userModel = UserModel(id: '1', email: 'test@example.com', name: 'Test');
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => userModel);
      when(() => mockLocalDataSource.cacheToken(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.login('test@example.com', 'password');

      // Assert
      expect(result, userModel);
      verify(() => mockLocalDataSource.cacheToken(any())).called(1);
    });
  });
}
```

### 3. Presentation Layer Tests

#### BLoC Tests
Test state transitions and event handling using `bloc_test`.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    bloc = AuthBloc(loginUseCase: mockLoginUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be NotAuthenticated', () {
      expect(bloc.state, isA<NotAuthenticated>());
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [Loading, Authenticated] when login succeeds',
      build: () {
        when(() => mockLoginUseCase(any(), any()))
            .thenAnswer((_) async => TestUsers.johnDoe);
        return bloc;
      },
      act: (bloc) => bloc.add(LoginRequested('test@example.com', 'password')),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockLoginUseCase('test@example.com', 'password')).called(1);
      },
    );
  });
}
```

#### Widget Tests
Test UI components and user interactions.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_inputs.dart';
import '../../../helpers/widget_test_helper.dart';

void main() {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
  });

  tearDown(() {
    emailController.dispose();
    passwordController.dispose();
  });

  group('LoginInputs', () {
    testWidgets('should render email and password fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
        ),
      ));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should validate empty email', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final validationResult = emailField.validator!('');

      // Assert
      expect(validationResult, 'Please enter an email address');
    });
  });
}
```

---

## Test Helpers

### Widget Test Helper (`test/helpers/widget_test_helper.dart`)

Provides reusable functions for widget testing:

#### `makeTestableWidget(Widget child)`
Wraps widget with MaterialApp and localization support.

```dart
await tester.pumpWidget(makeTestableWidget(MyWidget()));
```

#### `makeTestableWidgetWithBloc<B>()`
Wraps widget with BLoC provider.

```dart
await tester.pumpWidget(makeTestableWidgetWithBloc<AuthBloc>(
  bloc: mockAuthBloc,
  child: LoginPage(),
));
```

#### `makeTestableWidgetWithBlocs()`
Wraps widget with multiple BLoC providers.

```dart
await tester.pumpWidget(makeTestableWidgetWithBlocs(
  providers: [
    BlocProvider<AuthBloc>.value(value: mockAuthBloc),
    BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
  ],
  child: HomePage(),
));
```

#### `setUpScreenSize(WidgetTester tester)`
Sets standard screen size for consistent widget tests.

```dart
testWidgets('should render correctly', (tester) async {
  setUpScreenSize(tester);
  // ... test code
});
```

---

## Mock Factories

### HTTP Response Helpers (`test/helpers/mock_factories.dart`)

#### `createHttpResponse(int statusCode, String body)`
Creates fake HTTP responses.

```dart
final response = createHttpResponse(200, '{"success": true}');
```

#### `HttpErrorResponses`
Common HTTP error responses.

```dart
final unauthorized = HttpErrorResponses.unauthorized();
final notFound = HttpErrorResponses.notFound();
final serverError = HttpErrorResponses.internalServerError();
```

#### `setupMockSharedPreferences(Map<String, Object> initialValues)`
Sets up SharedPreferences with initial data.

```dart
setUp(() async {
  await setupMockSharedPreferences({
    'auth_token': 'test_token',
    'user_id': '123',
  });
});
```

---

## Test Fixtures

### Test Data (`test/fixtures/test_data.dart`)

Predefined test entities and constants:

```dart
// Users
final user = TestUsers.johnDoe;
final emptyUser = TestUsers.empty;

// Profiles
final profile = TestProfiles.johnDoeProfile;
final fullStorage = TestProfiles.fullStorageProfile;

// Auth
const validEmail = TestAuth.validEmail;
const validPassword = TestAuth.validPassword;
const token = TestAuth.validToken;

// File IDs
const fileId = TestFileIds.file1;
const folderIds = TestFileIds.bulkFileIds;

// Devices
const deviceId = TestDevices.deviceId1;
const androidDevice = TestDevices.androidDevice;
```

### JSON Fixtures (`test/fixtures/json/`)

Sample JSON responses for API testing:

```dart
import '../fixtures/json_reader.dart';

final jsonString = readJson('auth_response.json');
final json = jsonDecode(jsonString);
```

Available JSON files:
- `auth_response.json` - Login response
- `user_profile_response.json` - User profile data
- `error_unauthorized.json` - 401 error
- `error_validation.json` - Validation error

---

## Best Practices

### 1. Follow AAA Pattern
```dart
test('should do something', () {
  // Arrange - Set up test data and mocks
  final user = TestUsers.johnDoe;

  // Act - Execute the code under test
  final result = user.isValid;

  // Assert - Verify the result
  expect(result, true);
});
```

### 2. Use Descriptive Test Names
✅ Good:
```dart
test('should throw ValidationException when email is empty', () { ... });
```

❌ Bad:
```dart
test('email test', () { ... });
```

### 3. Test One Thing Per Test
Each test should verify a single behavior.

### 4. Use Test Data from Fixtures
Instead of creating new data in each test:
```dart
final user = TestUsers.johnDoe; // ✅ Good
final user = User(id: '1', ...); // ❌ Avoid
```

### 5. Mock External Dependencies Only
- ✅ Mock: HTTP clients, repositories, use cases
- ❌ Don't mock: Entities, value objects, internal utilities

### 6. Use `setUp` and `tearDown`
```dart
setUp(() {
  mockRepository = MockAuthRepository();
  useCase = LoginUseCase(mockRepository);
});

tearDown(() {
  // Clean up if needed
});
```

### 7. Register Fallback Values for Mocktail
```dart
setUpAll(() {
  registerFallbackValue(FakeAuthEvent());
});
```

### 8. Verify Mock Interactions
```dart
verify(() => mockRepository.login(email, password)).called(1);
verifyNever(() => mockRepository.logout());
```

### 9. Test Error Scenarios
Always test both success and failure cases.

### 10. Keep Tests Fast
- Avoid real network calls
- Minimize async operations
- Use mocks instead of real implementations

---

## Common Pitfalls

### ❌ Don't Test Implementation Details
```dart
// Bad - testing private methods or internal state
expect(bloc.internalCounter, 5);

// Good - testing public behavior
expect(bloc.state, isA<LoadedState>());
```

### ❌ Don't Share State Between Tests
```dart
// Bad
final sharedUser = TestUsers.johnDoe;

test('test 1', () {
  sharedUser.name = 'Modified'; // Affects other tests!
});

// Good
test('test 1', () {
  final user = TestUsers.johnDoe; // Fresh instance
});
```

### ❌ Don't Forget to Close BLoCs
```dart
tearDown(() {
  bloc.close(); // Always close BLoCs
});
```

### ❌ Don't Mock What You Don't Own
```dart
// Bad
class MockDateTime extends Mock implements DateTime {}

// Good - Create a wrapper
class DateTimeProvider {
  DateTime now() => DateTime.now();
}
class MockDateTimeProvider extends Mock implements DateTimeProvider {}
```

### ❌ Don't Use Real Async Delays
```dart
// Bad
await Future.delayed(Duration(seconds: 2));

// Good - Use fake async or mock time
await tester.pumpAndSettle();
```

---

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [bloc_test Package](https://pub.dev/packages/bloc_test)
- [mocktail Package](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)

---

**Happy Testing! 🧪**