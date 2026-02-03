import 'package:mocktail/mocktail.dart';
import '../../lib/repositories/defect_repository.dart';
import '../../lib/repositories/pipe_repository.dart';
import '../../lib/data/local/database.dart';
import '../../lib/data/models/defect_dto.dart';
import '../../lib/data/models/pipe_dto.dart';

/// Mock DefectRepository for testing
class MockDefectRepository extends Mock implements DefectRepository {
  MockDefectRepository() {
    // Setup default behaviors
    when(() => getPendingDefects()).thenAnswer((_) async => []);
    when(() => getAllDefects()).thenAnswer((_) async => []);
    when(() => getConflictedDefects()).thenAnswer((_) async => []);
  }

  /// Setup successful save defect
  void setupSaveDefectSuccess() {
    when(() => saveDefect(any())).thenAnswer((_) async => {});
  }

  /// Setup save defect failure
  void setupSaveDefectError(Exception error) {
    when(() => saveDefect(any())).thenThrow(error);
  }

  /// Setup successful sync
  void setupSyncPendingDefectsSuccess({
    int synced = 0,
    int failed = 0,
    int conflicts = 0,
  }) {
    when(() => syncPendingDefects(batchSize: any(named: 'batchSize')))
        .thenAnswer((_) async => SyncResult(
          synced: synced,
          failed: failed,
          conflicts: conflicts,
        ));
  }

  /// Setup get defect by ID
  void setupGetDefectById(LocalDefect? defect) {
    when(() => getDefectById(any())).thenAnswer((_) async => defect);
  }

  /// Setup accept server version
  void setupAcceptServerVersionSuccess() {
    when(() => acceptServerVersion(any())).thenAnswer((_) async => {});
  }

  /// Setup keep local version
  void setupKeepLocalVersionSuccess() {
    when(() => keepLocalVersion(any())).thenAnswer((_) async => {});
  }
}

/// Mock PipeRepository for testing
class MockPipeRepository extends Mock implements PipeRepository {
  MockPipeRepository() {
    // Setup default behaviors
    when(() => getAllPipes()).thenAnswer((_) async => []);
    when(() => getPipesPaginated(any(), any())).thenAnswer((_) async => []);
  }

  /// Setup successful get pipe by ID
  void setupGetPipeById(LocalPipe? pipe) {
    when(() => getPipeById(any())).thenAnswer((_) async => pipe);
  }

  /// Setup successful get pipe by QR code
  void setupGetPipeByQrCode(LocalPipe? pipe) {
    when(() => getPipeByQrCode(any())).thenAnswer((_) async => pipe);
  }

  /// Setup successful save pipe
  void setupSavePipeSuccess() {
    when(() => savePipe(any())).thenAnswer((_) async => {});
  }

  /// Setup successful load pipe from API
  void setupLoadPipeFromApiSuccess(LocalPipe? pipe) {
    when(() => loadPipeFromApi(any())).thenAnswer((_) async => pipe);
  }

  /// Setup successful sync pipes from API
  void setupSyncPipesFromApiSuccess() {
    when(() => syncPipesFromApi()).thenAnswer((_) async => {});
  }
}
