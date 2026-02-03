import 'package:drift/drift.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/data/local/database.dart';

/// Mock AppDatabase for testing
/// Note: This is a simplified mock. For more complex testing, consider using
/// an in-memory database or drift_test package
class MockAppDatabase extends Mock implements AppDatabase {
  final List<LocalPipe> _pipes = [];
  final List<LocalDefect> _defects = [];

  MockAppDatabase() {
    // Setup default behaviors for common queries
    when(() => getAllPipes()).thenAnswer((_) async => _pipes);
    when(() => getAllDefects()).thenAnswer((_) async => _defects);
    when(() => getPendingDefects()).thenAnswer((_) async => 
      _defects.where((d) => d.syncStatus == SyncStatus.pending).toList()
    );
    
    // Setup localDefects table getter - return a mock that can be used with into()
    // Note: This is a workaround - Drift's into() is complex to mock
    // For saveDefect test, we'll need to mock the insert operation differently
  }

  /// Add a pipe to mock database
  void addPipe(LocalPipe pipe) {
    _pipes.add(pipe);
  }

  /// Add a defect to mock database
  void addDefect(LocalDefect defect) {
    _defects.add(defect);
  }

  /// Clear all mock data
  void clear() {
    _pipes.clear();
    _defects.clear();
  }

  /// Setup getPipeById
  void setupGetPipeById(String id, LocalPipe? pipe) {
    when(() => getPipeById(id)).thenAnswer((_) async => pipe);
  }

  /// Setup getPipeByQrCode
  void setupGetPipeByQrCode(String qrCode, LocalPipe? pipe) {
    when(() => getPipeByQrCode(qrCode)).thenAnswer((_) async => pipe);
  }

  /// Setup getDefectById
  void setupGetDefectById(String id, LocalDefect? defect) {
    when(() => getDefectById(id)).thenAnswer((_) async => defect);
  }

  /// Setup savePipe
  void setupSavePipe() {
    when(() => savePipe(any())).thenAnswer((_) async => {});
  }

  /// Setup updateDefectSyncStatus
  void setupUpdateDefectSyncStatus() {
    when(() => updateDefectSyncStatus(any(), any(), serverVersionJson: any(named: 'serverVersionJson')))
        .thenAnswer((_) async => {});
  }

  /// Setup insert operation
  /// Note: Drift's into() method is complex to mock, 
  /// so this is a simplified version
  void setupInsert() {
    // In real tests, you might want to use an in-memory database
    // or test the actual database operations
  }
}
