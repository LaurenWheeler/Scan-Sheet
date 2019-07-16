import UIKit
import AVFoundation
public enum TorchMode {
  case on
  case off
  var next: TorchMode {
    switch self {
    case .on:
      return .off
    case .off:
      return .on
    }
  }
  var image: UIImage {
    switch self {
    case .on:
      return imageNamed("flashOn")
    case .off:
      return imageNamed("flashOff")
    }
  }
  var captureTorchMode: AVCaptureDevice.TorchMode {
    switch self {
    case .on:
      return .on
    case .off:
      return .off
    }
  }
}
