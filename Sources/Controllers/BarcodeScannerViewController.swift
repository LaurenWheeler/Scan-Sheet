import UIKit
import AVFoundation
public protocol BarcodeScannerCodeDelegate: class {
  func scanner(
    _ controller: BarcodeScannerViewController,
    didCaptureCode code: String,
    type: String
  )
}
public protocol BarcodeScannerErrorDelegate: class {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error)
}
public protocol BarcodeScannerDismissalDelegate: class {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController)
}
open class BarcodeScannerViewController: UIViewController {
  private static let footerHeight: CGFloat = 0
  public weak var codeDelegate: BarcodeScannerCodeDelegate?
  public weak var errorDelegate: BarcodeScannerErrorDelegate?
  public weak var dismissalDelegate: BarcodeScannerDismissalDelegate?
  public var isOneTimeSearch = true
  public var metadata = AVMetadataObject.ObjectType.barcodeScannerMetadata {
    didSet {
      cameraViewController.metadata = metadata
    }
  }
  private var locked = false
  private var constraintsActivated = false
  private var isVisible = false
  public private(set) lazy var cameraViewController: CameraViewController = .init()
  private var status: Status = Status(state: .scanning) {
    didSet {
      changeStatus(from: oldValue, to: status)
    }
  }
  open override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black
    cameraViewController.metadata = metadata
    cameraViewController.delegate = self
    add(childViewController: cameraViewController)
  }
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupCameraConstraints()
    isVisible = true
  }
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    isVisible = false
  }
  public func resetWithError(message: String? = nil) {
    status = Status(state: .notFound, text: message)
  }
  public func reset(animated: Bool = true) {
    status = Status(state: .scanning, animated: animated)
  }
  private func changeStatus(from oldValue: Status, to newValue: Status) {
    guard newValue.state != .notFound else {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
        self.status = Status(state: .scanning)
      }
      return
    }
    let animatedTransition = newValue.state == .processing
      || oldValue.state == .processing
      || oldValue.state == .notFound
    let duration = newValue.animated && animatedTransition ? 0.5 : 0.0
    let delayReset = oldValue.state == .processing || oldValue.state == .notFound
    if !delayReset {
      resetState()
    }
    UIView.animate(
      withDuration: duration,
      animations: ({
        self.view.layoutIfNeeded()
      }),
      completion: ({ [weak self] _ in
        if delayReset {
          self?.resetState()
        }
      }))
  }
  private func resetState() {
    locked = status.state == .processing && isOneTimeSearch
    if status.state == .scanning {
      cameraViewController.startCapturing()
    } else {
      cameraViewController.stopCapturing()
    }
  }
  private func animateFlash(whenProcessing: Bool = false) {
    let flashView = UIView(frame: view.bounds)
    flashView.backgroundColor = UIColor.white
    flashView.alpha = 1
    view.addSubview(flashView)
    view.bringSubviewToFront(flashView)
    UIView.animate(
      withDuration: 0.2,
      animations: ({
        flashView.alpha = 0.0
      }),
      completion: ({ [weak self] _ in
        flashView.removeFromSuperview()
        if whenProcessing {
          self?.status = Status(state: .processing)
        }
      }))
  }
}
private extension BarcodeScannerViewController {
  private func setupCameraConstraints() {
    guard !constraintsActivated else {
      return
    }
    constraintsActivated = true
    let cameraView = cameraViewController.view!
    NSLayoutConstraint.activate(
      cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      cameraView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor,
        constant: -BarcodeScannerViewController.footerHeight
      )
    )
    cameraView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
  }
}
extension BarcodeScannerViewController: CameraViewControllerDelegate {
  func cameraViewControllerDidSetupCaptureSession(_ controller: CameraViewController) {
    status = Status(state: .scanning)
  }
  func cameraViewControllerDidFailToSetupCaptureSession(_ controller: CameraViewController) {
    status = Status(state: .unauthorized)
  }
  func cameraViewController(_ controller: CameraViewController, didReceiveError error: Error) {
    errorDelegate?.scanner(self, didReceiveError: error)
  }
  func cameraViewControllerDidTapSettingsButton(_ controller: CameraViewController) {
    DispatchQueue.main.async {
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.openURL(settingsURL)
      }
    }
  }
  func cameraViewController(_ controller: CameraViewController,
                            didOutput metadataObjects: [AVMetadataObject]) {
    guard !locked && isVisible else { return }
    guard !metadataObjects.isEmpty else { return }
    guard
      let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
      var code = metadataObj.stringValue,
      metadata.contains(metadataObj.type)
      else { return }
    if isOneTimeSearch {
      locked = true
    }
    var rawType = metadataObj.type.rawValue
    if metadataObj.type == AVMetadataObject.ObjectType.ean13 && code.hasPrefix("0") {
      code = String(code.dropFirst())
      rawType = AVMetadataObject.ObjectType.upca.rawValue
    }
    codeDelegate?.scanner(self, didCaptureCode: code, type: rawType)
    animateFlash(whenProcessing: isOneTimeSearch)
  }
}
