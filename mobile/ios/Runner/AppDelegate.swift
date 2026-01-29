import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // КРИТИЧЕСКИ ВАЖНО: Упрощенная регистрация плагинов
    GeneratedPluginRegistrant.register(with: self)
    
    // Вызываем super - это критически важно для правильной инициализации
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
