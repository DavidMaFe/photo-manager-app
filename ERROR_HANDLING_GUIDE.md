# Error Handling Implementation Guide

## 📋 Overview

This project implements a **comprehensive, unified error handling system** that provides:
- ✅ Consistent error handling across all layers (Data, Domain, Presentation)
- ✅ Beautiful, modern error UI with animations
- ✅ Backend integration with structured error responses
- ✅ Hybrid localization (backend messages + Flutter fallback)
- ✅ Field-level validation error support
- ✅ Comprehensive error logging for debugging

---

## 🏗️ Architecture

### Error Flow

```
Backend API Error
    ↓
ErrorResponseModel (parsed JSON)
    ↓
ApiException (thrown by DataSource)
    ↓
ErrorHandler.handleError() (converts to Failure)
    ↓
BLoC State (emits error state with Failure)
    ↓
UI Widget (displays error using error widgets)
```

---

## 📁 Key Files & Components

### 1. **Error Models**

**`lib/core/errors/models/error_response_model.dart`**
- Parses backend JSON error responses
- Fields: `code`, `message`, `timestamp`, `path`, `details` (field errors)

**`lib/core/errors/exceptions/api_exception.dart`**
- Wraps `ErrorResponseModel`
- Thrown by all remote data sources

### 2. **Failure Classes**

**`lib/core/errors/base/failures.dart`**
- 17 specific failure types (NetworkFailure, ValidationFailure, etc.)
- Each has: `messageKey`, `code`, `data`, `errorResponse`

**`lib/core/errors/base/generic_failure.dart`**
- Handles unknown backend error codes
- Preserves backend code and message

**`lib/core/errors/base/failure_codes.dart`**
- Constants for all backend error codes (24+)
- Organized by domain (User, File, Folder, etc.)

### 3. **Error Handler**

**`lib/core/errors/handler/error_handler.dart`**
- Centralized error processing
- Converts exceptions to Failures
- Uses code-based mapping (no regex)
- Integrated logging

**Usage:**
```dart
try {
  await someOperation();
} catch (e) {
  final failure = ErrorHandler.handleError(e, context: 'MyBloc.myMethod');
  emit(MyErrorState(failure));
}
```

### 4. **Error UI Widgets**

**`lib/core/errors/widget/error_display.dart`**
- Full-page error display
- Animated (fade + slide)
- Shows: icon, title, message, field errors, retry button

**`lib/core/errors/widgets/error_dialog.dart`**
- Modal error dialog
- Scale + fade animation
- Expandable field errors section
- Dismiss + retry buttons

**`lib/core/errors/widgets/error_snack_bar.dart`**
- Non-intrusive bottom notification
- Auto-dismissible
- Compact field errors display
- Optional retry button

**`lib/core/errors/widgets/error_banner.dart`**
- Inline error banner for forms
- Slide-in animation
- Field errors with bullet points
- Dismissible + retry option

**`lib/core/errors/widgets/field_error_display.dart`**
- Standalone widget for form validation
- Single or multiple field errors
- Compact design

### 5. **Error Notification Service**

**`lib/core/errors/service/error_notification_service.dart`**
- Unified API for showing errors
- Three display modes: SnackBar, Dialog, Banner
- Haptic feedback for critical errors

**Usage:**
```dart
ErrorNotificationService.showError(
  context,
  failure,
  config: ErrorDisplayConfig.snackBar,
  onRetry: () => _retryOperation(),
);
```

### 6. **Error Logging**

**`lib/core/errors/utils/error_logger.dart`**
- Structured logging with visual formatting
- Methods: `logFailure()`, `logException()`, `logApiError()`, `logNetworkError()`
- Captures: context, stack traces, field errors, backend responses

### 7. **Localization**

**`lib/core/errors/helper/failure_message_helper.dart`**
- Hybrid localization strategy:
  1. Primary: Backend message (from errorResponse)
  2. Fallback: Flutter ARB localization

**`lib/core/utils/http_headers_util.dart`**
- Generates HTTP headers with Accept-Language
- Three methods: `getJsonHeaders()`, `getAuthJsonHeaders()`, `getAuthHeaders()`
- Automatically includes device locale

---

## 🎯 Implementation Checklist

### ✅ Data Layer (All 6 Data Sources)
- [x] AuthRemoteDataSource
- [x] ProfileRemoteDataSource
- [x] GalleryRemoteDataSource
- [x] FileManagementRemoteDataSource
- [x] FolderRemoteDataSource
- [x] SyncSessionRemoteDataSource

**Pattern:**
```dart
try {
  final response = await client.post(
    url,
    headers: HttpHeadersUtil.getAuthJsonHeaders(token),
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return parseResponse(response);
  } else {
    final errorResponse = ErrorResponseModel.fromJson(jsonDecode(response.body));
    throw ApiException(errorResponse);
  }
} on SocketException {
  rethrow;
} on HttpException {
  rethrow;
} on ApiException {
  rethrow;
} catch (e) {
  throw Exception('Connection error: $e');
}
```

### ✅ Domain Layer (All 10 BLoCs)
- [x] AuthBloc
- [x] ProfileBloc
- [x] GalleryBloc
- [x] FileManagementBloc
- [x] ManageFolderBloc
- [x] FolderBloc
- [x] FolderContentBloc
- [x] SyncSessionBloc
- [x] EditUserBloc
- [x] ChangePasswordBloc

**Pattern:**
```dart
try {
  final result = await useCase();
  emit(SuccessState(result));
} catch (e) {
  final failure = ErrorHandler.handleError(e, context: 'MyBloc.myEvent');
  emit(ErrorState(failure));
}
```

### ✅ Presentation Layer (All Features)
- [x] Auth feature widgets
- [x] Profile feature widgets
- [x] Gallery feature widgets
- [x] File Management widgets
- [x] Folder feature widgets
- [x] Sync Session widgets

**Pattern:**
```dart
BlocConsumer<MyBloc, MyState>(
  listener: (context, state) {
    if (state is MyError) {
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
        onRetry: () => _retry(),
      );
    }
  },
  builder: (context, state) {
    if (state is MyError) {
      return ErrorDisplay(
        failure: state.failure,
        onRetry: () => _retry(),
      );
    }
    // ... other states
  },
)
```

---

## 🔧 Backend Error Codes

### User Domain
- `EMAIL_ALREADY_USED` → EmailAlreadyExistsFailure
- `USER_NOT_FOUND` → NotFoundFailure
- `INCORRECT_PASSWORD` → InvalidCredentialsFailure
- `INVALID_CREDENTIALS` → InvalidCredentialsFailure

### File Domain
- `FILE_NOT_FOUND` → NotFoundFailure
- `FILE_SIZE_NOT_ACCEPTED` → ValidationFailure
- `INVALID_FILE_MIME_TYPE` → ValidationFailure
- `DELETE_FILE_ERROR` → ServerFailure

### Folder Domain
- `FOLDER_NOT_FOUND` → NotFoundFailure
- `FOLDER_ALREADY_EXISTS` → AlreadyExistsFailure
- `FOLDER_NAME_ALREADY_USED` → AlreadyExistsFailure
- `FOLDER_NOT_EMPTY` → ValidationFailure
- `DELETE_FOLDER_ERROR` → ServerFailure

### Storage Domain
- `STORAGE_QUOTA_EXCEEDED` → StorageSpaceExceededFailure
- `INSUFFICIENT_STORAGE` → StorageSpaceExceededFailure

### Device Domain
- `DEVICE_NOT_FOUND` → NotFoundFailure
- `DEVICE_ALREADY_EXISTS` → AlreadyExistsFailure

### Sync Domain
- `DUPLICATE_FOUND` → AlreadyExistsFailure

### Generic
- `VALIDATION_ERROR` → ValidationFailure (with field errors in `details`)
- `UNAUTHORIZED` → UnauthorizedFailure
- `FORBIDDEN` → PermissionDeniedFailure
- Unknown codes → GenericFailure

---

## 📊 Error Display Configuration

### SnackBar (Default, Non-intrusive)
```dart
ErrorDisplayConfig.snackBar
```
- Auto-dismisses after 4 seconds
- Shows at bottom of screen
- Compact field errors
- Optional retry button

### Dialog (Requires User Interaction)
```dart
ErrorDisplayConfig.dialog
```
- Modal overlay
- Blocks interaction until dismissed
- Expandable field errors
- Dismiss + Retry buttons

### Critical Dialog (With Haptic Feedback)
```dart
ErrorDisplayConfig.critical
```
- Like dialog but with vibration
- For critical errors only

### Banner (Inline, For Forms)
```dart
ErrorDisplayConfig.banner
```
- Inline display
- Slide-in animation
- Use with ErrorBanner widget directly

---

## 🎨 Error UI Features

### Failure-Type Specific Styling

**Network/Connectivity (Blue)**
- NetworkFailure, TimeoutFailure

**Validation/Warning (Orange)**
- ValidationFailure, StorageSpaceExceededFailure

**Auth/Permission (Amber)**
- UnauthorizedFailure, PermissionDeniedFailure

**Critical Errors (Red)**
- ServerFailure, NotFoundFailure, etc.

### Field Error Display

When backend returns validation errors with field details:
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Validation failed",
  "details": {
    "email": "Email is required",
    "password": "Password must be at least 8 characters"
  }
}
```

All error widgets automatically display field errors in a beautiful format.

---

## 🧪 Testing

### Manual Testing Checklist

**Network Errors:**
- [ ] Turn off WiFi/data → Network error shown
- [ ] Slow connection → Timeout error shown
- [ ] Server down → Server error shown

**Validation Errors:**
- [ ] Submit empty form → Field errors shown
- [ ] Invalid email → Email validation error
- [ ] Weak password → Password validation error

**Auth Errors:**
- [ ] Wrong password → Invalid credentials error
- [ ] Expired token → Token expired error
- [ ] No permission → Permission denied error

**Resource Errors:**
- [ ] File not found → Not found error
- [ ] Storage full → Storage exceeded error
- [ ] Duplicate action → Already exists error

**Error UI:**
- [ ] SnackBar displays correctly
- [ ] Dialog displays correctly
- [ ] ErrorDisplay full-page shows correctly
- [ ] Field errors display properly
- [ ] Retry button works
- [ ] Animations work smoothly

**Localization:**
- [ ] Switch device language → Error messages change
- [ ] Backend messages displayed when available
- [ ] Flutter fallback messages work

---

## 📝 Adding New Error Types

### 1. Add Backend Code Constant

In `lib/core/errors/base/failure_codes.dart`:
```dart
static const String myNewError = "MY_NEW_ERROR";
```

### 2. Create Failure Class (Optional)

In `lib/core/errors/base/failures.dart`:
```dart
class MyNewFailure extends Failure {
  const MyNewFailure({
    super.messageKey = 'errorMyNew',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}
```

### 3. Add Mapping in ErrorHandler

In `lib/core/errors/handler/error_handler.dart`:
```dart
case FailureCodes.myNewError:
  return MyNewFailure(
    code: code,
    errorResponse: errorResponse,
  );
```

### 4. Add Localization

In `lib/l10n/app_es.arb` and `app_en.arb`:
```json
{
  "errorMyNew": "My error message",
  "errorMyNewTitle": "Error Title"
}
```

### 5. Update FailureMessageHelper (Optional)

If you need custom title logic in `lib/core/errors/helper/failure_message_helper.dart`:
```dart
if (failure is MyNewFailure) return l10n.errorMyNewTitle;
```

---

## 🚀 Best Practices

### DO:
✅ Always use `ErrorHandler.handleError()` in BLoCs
✅ Always throw `ApiException` in data sources
✅ Use `ErrorNotificationService` for displaying errors
✅ Include context when logging: `context: 'MyBloc.myMethod'`
✅ Use field errors for validation failures
✅ Test error scenarios manually

### DON'T:
❌ Don't create custom error widgets (use existing ones)
❌ Don't show raw exception messages to users
❌ Don't use `print()` for error logging (use ErrorLogger)
❌ Don't skip error handling in BLoCs
❌ Don't ignore network/connectivity errors
❌ Don't hardcode error messages (use localization)

---

## 📚 Additional Resources

### Related Files
- `/lib/l10n/` - Localization files
- `/lib/config/data_constants.dart` - Backend URL configuration
- `/lib/core/injection_container.dart` - Dependency injection setup

### Backend API
- Base URL: `http://10.0.2.2:8080` (Android emulator)
- All endpoints return structured error responses

---

## ✨ Summary

This error handling system provides:
1. **Consistency** - Same pattern across entire app
2. **User Experience** - Beautiful, informative error displays
3. **Developer Experience** - Easy to use, comprehensive logging
4. **Maintainability** - Centralized, well-documented
5. **Localization** - Hybrid approach with fallback
6. **Flexibility** - Multiple display modes, customizable

**Result:** Professional, production-ready error handling that enhances both user and developer experience.
