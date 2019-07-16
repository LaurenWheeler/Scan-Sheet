import AVFoundation
final class VideoPermissionService {
  enum Error: Swift.Error {
    case notAuthorizedToUseCamera
  }
  func checkPersmission(completion: @escaping (Error?) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion(nil)
    case .notDetermined:
      askForPermissions(completion)
    default:
      completion(Error.notAuthorizedToUseCamera)
    }
  }
  private func askForPermissions(_ completion: @escaping (Error?) -> Void) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        guard granted else {
          completion(Error.notAuthorizedToUseCamera)
          return
        }
        completion(nil)
      }
    }
  }
}
