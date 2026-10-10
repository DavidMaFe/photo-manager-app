import 'package:photo_manager_app/features/legal/data/data_sources/legal_remote_data_source.dart';
import 'package:photo_manager_app/features/legal/domain/repositories/legal_acceptance_repository.dart';

class LegalAcceptanceDataRepository implements LegalAcceptanceRepository {
  final LegalRemoteDataSource remoteDataSource;

  LegalAcceptanceDataRepository({required this.remoteDataSource});

  @override
  Future<void> accept({required String termsVersion, required String privacyVersion}) =>
      remoteDataSource.acceptLegalTerms(termsVersion: termsVersion, privacyVersion: privacyVersion);
}
