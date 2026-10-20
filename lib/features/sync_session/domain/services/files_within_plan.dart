import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

/// The [files] the [plan] allows to upload: videos over its limit are left out, because the server would reject them
/// after receiving them whole. Without a plan (it could not be read) every file goes, and the server decides.
List<SyncFile> filesWithinPlan(Iterable<SyncFile> files, UserPlan? plan) => [
      for (final file in files)
        if (plan == null || !file.isVideo || plan.allowsVideo(file.sizeBytes)) file,
    ];
