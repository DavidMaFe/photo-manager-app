import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_state.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';

class MockOnDevicePresenceCubit extends MockCubit<OnDevicePresenceState> implements OnDevicePresenceCubit {}

class MockDownloadProgressBloc extends MockBloc<DownloadProgressEvent, DownloadProgressState>
    implements DownloadProgressBloc {}

class MockShareCubit extends MockCubit<ShareState> implements ShareCubit {}

class FakeDownloadProgressEvent extends Fake implements DownloadProgressEvent {}

/// The blocs of the downloads that the pages read from above (provided by main.dart in the app), as mocks.
class DownloadsTestProviders {
  final MockOnDevicePresenceCubit presence = MockOnDevicePresenceCubit();
  final MockDownloadProgressBloc progress = MockDownloadProgressBloc();
  final MockShareCubit share = MockShareCubit();

  DownloadsTestProviders({
    OnDevicePresenceState presenceState = const OnDevicePresenceState(),
    DownloadProgressState progressState = const DownloadProgressState(),
  }) {
    registerFallbackValue(FakeDownloadProgressEvent());
    when(() => presence.state).thenReturn(presenceState);
    when(() => progress.state).thenReturn(progressState);
    when(() => share.state).thenReturn(const ShareIdle());
    when(() => share.share(any())).thenAnswer((_) async {});
  }

  List<BlocProvider> get providers => [
        BlocProvider<OnDevicePresenceCubit>.value(value: presence),
        BlocProvider<DownloadProgressBloc>.value(value: progress),
        BlocProvider<ShareCubit>.value(value: share),
      ];
}

/// Shortcut for the pages that do not check the downloads.
List<BlocProvider> downloadsTestProviders() => DownloadsTestProviders().providers;
