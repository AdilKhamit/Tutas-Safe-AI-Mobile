import 'dart:io';
import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/backup_service.dart';

/// Mock BackupService for testing
class MockBackupService extends Mock implements BackupService {
  MockBackupService() {
    // Setup default behaviors
  }

  /// Setup successful export data
  void setupExportDataSuccess(String jsonData) {
    when(() => exportData()).thenAnswer((_) async => jsonData);
  }

  /// Setup export data failure
  void setupExportDataError(Exception error) {
    when(() => exportData()).thenThrow(error);
  }

  /// Setup successful save to file
  void setupSaveToFileSuccess(File file) {
    when(() => saveToFile(any())).thenAnswer((_) async => file);
  }

  /// Setup successful import data
  void setupImportDataSuccess() {
    when(() => importData(any())).thenAnswer((_) async => {});
  }

  /// Setup import data failure
  void setupImportDataError(Exception error) {
    when(() => importData(any())).thenThrow(error);
  }

  /// Setup successful import from file
  void setupImportFromFileSuccess() {
    when(() => importFromFile(any())).thenAnswer((_) async => {});
  }

  /// Setup validate backup file
  void setupValidateBackupFile(bool isValid) {
    when(() => validateBackupFile(any())).thenReturn(isValid);
  }
}
