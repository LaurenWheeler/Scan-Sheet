import UIKit
import AVFoundation
func imageNamed(_ name: String) -> UIImage {
  let cls = BarcodeScannerViewController.self
  var bundle = Bundle(for: cls)
  let traitCollection = UITraitCollection(displayScale: 3)
  if let resourceBundle = bundle.resourcePath.flatMap({ Bundle(path: $0 + "/BarcodeScanner.bundle") }) {
    bundle = resourceBundle
  }
  guard let image = UIImage(named: name, in: bundle, compatibleWith: traitCollection) else {
    return UIImage()
  }
  return image
}
func localizedString(_ key: String) -> String {
  if let path = Bundle(for: BarcodeScannerViewController.self).resourcePath,
    let resourceBundle = Bundle(path: path + "/Localization.bundle") {
    return resourceBundle.localizedString(forKey: key, value: nil, table: "Localizable")
  }
  return key
}
var isSimulatorRunning: Bool = {
  #if swift(>=4.1)
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  #else
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      return true
    #else
      return false
    #endif
  #endif
}()
