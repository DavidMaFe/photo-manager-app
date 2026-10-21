import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/injection_container.dart' as di;
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_code_step.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_details_step.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_email_step.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Registration in three steps: the email, the code emailed to it and the rest of the data. Nobody can register an
/// email they do not own.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RegistrationEmailCubit>(),
      child: const RegisterSteps(),
    );
  }
}

/// The step of the registration, under a [RegistrationEmailCubit] provided above.
class RegisterSteps extends StatelessWidget {
  const RegisterSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationEmailCubit, RegistrationEmailState>(
      listenWhen: (previous, current) =>
          (current.failure != null && previous.failure != current.failure) ||
          (current.codeResent && !previous.codeResent),
      listener: _showNotice,
      child: BlocBuilder<RegistrationEmailCubit, RegistrationEmailState>(
        buildWhen: (previous, current) => previous.step != current.step,
        builder: (context, state) => switch (state.step) {
          RegistrationStep.email => const RegisterEmailStep(),
          RegistrationStep.code => const RegisterCodeStep(),
          RegistrationStep.details => RegisterDetailsStep(email: state.email, emailCode: state.code),
        },
      ),
    );
  }

  void _showNotice(BuildContext context, RegistrationEmailState state) {
    if (state.failure != null) {
      // Kept until the next request: the code field shows the error meanwhile
      ErrorNotificationService.showError(context, state.failure!, config: ErrorDisplayConfig.snackBar);
    } else if (state.codeResent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.codeResent)));
      context.read<RegistrationEmailCubit>().codeResentShown();
    }
  }
}
