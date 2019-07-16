import UIKit
import AVFoundation
protocol CameraViewControllerDelegate: class {
  func cameraViewControllerDidSetupCaptureSession(_ controller: CameraViewController)
  func cameraViewControllerDidFailToSetupCaptureSession(_ controller: CameraViewController)
  func cameraViewController(_ controller: CameraViewController, didReceiveError error: Error)
  func cameraViewControllerDidTapSettingsButton(_ controller: CameraViewController)
  func cameraViewController(
    _ controller: CameraViewController,
    didOutput metadataObjects: [AVMetadataObject]
  )
}
public final class CameraViewController: UIViewController {
  weak var delegate: CameraViewControllerDelegate?
  public var barCodeFocusViewType: FocusViewType = .animated
  public var showsCameraButton: Bool = false {
    didSet {
      cameraButton.isHidden = showsCameraButton
    }
  }
  var metadata = [AVMetadataObject.ObjectType]()
  public private(set) lazy var focusView: UIView = self.makeFocusView()
  public private(set) lazy var flashButton: UIButton = .init(type: .custom)
  public private(set) lazy var settingsButton: UIButton = self.makeSettingsButton()
  public private(set) lazy var cameraButton: UIButton = self.makeCameraButton()
  private var regularFocusViewConstraints = [NSLayoutConstraint]()
  private var animatedFocusViewConstraints = [NSLayoutConstraint]()
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  private var captureDevice: AVCaptureDevice?
  private lazy var captureSession: AVCaptureSession = AVCaptureSession()
  private let permissionService = VideoPermissionService()
  private var torchMode: TorchMode = .off {
    didSet {
      guard let captureDevice = captureDevice, captureDevice.hasFlash else { return }
      guard captureDevice.isTorchModeSupported(torchMode.captureTorchMode) else { return }
      do {
        try captureDevice.lockForConfiguration()
        captureDevice.torchMode = torchMode.captureTorchMode
        captureDevice.unlockForConfiguration()
      } catch {}
      flashButton.setImage(torchMode.image, for: UIControl.State())
    }
  }
  private var frontCameraDevice: AVCaptureDevice? {
    return AVCaptureDevice.devices(for: .video).first(where: { $0.position == .front })
  }
  private var backCameraDevice: AVCaptureDevice? {
    return AVCaptureDevice.default(for: .video)
  }
  deinit {
    stopCapturing()
    NotificationCenter.default.removeObserver(self)
  }
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    flashButton.isHidden = true
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    videoPreviewLayer?.videoGravity = .resizeAspectFill
    guard let videoPreviewLayer = videoPreviewLayer else {
      return
    }
    view.layer.addSublayer(videoPreviewLayer)
    view.addSubviews(settingsButton, flashButton, focusView, cameraButton)
    torchMode = .off
    focusView.isHidden = true
    setupCamera()
    setupConstraints()
    setupActions()
  }
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupVideoPreviewLayerOrientation()
    animateFocusView()
  }
  public override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(
      alongsideTransition: { [weak self] _ in
        self?.setupVideoPreviewLayerOrientation()
      },
      completion: ({ [weak self] _ in
        self?.animateFocusView()
      }))
  }
  func startCapturing() {
    guard !isSimulatorRunning else {
      return
    }
    torchMode = .off
    captureSession.startRunning()
    focusView.isHidden = false
    flashButton.isHidden = true
    cameraButton.isHidden = !showsCameraButton
  }
  func stopCapturing() {
    guard !isSimulatorRunning else {
      return
    }
    torchMode = .off
    captureSession.stopRunning()
    focusView.isHidden = true
    flashButton.isHidden = true
    cameraButton.isHidden = true
  }
  private func setupActions() {
    flashButton.addTarget(
      self,
      action: #selector(handleFlashButtonTap),
      for: .touchUpInside
    )
    settingsButton.addTarget(
      self,
      action: #selector(handleSettingsButtonTap),
      for: .touchUpInside
    )
    cameraButton.addTarget(
      self,
      action: #selector(handleCameraButtonTap),
      for: .touchUpInside
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  @objc private func appWillEnterForeground() {
    torchMode = .off
    animateFocusView()
  }
  @objc private func handleSettingsButtonTap() {
    delegate?.cameraViewControllerDidTapSettingsButton(self)
  }
  @objc private func handleCameraButtonTap() {
    swapCamera()
  }
  @objc private func handleFlashButtonTap() {
    torchMode = torchMode.next
  }
  private func setupCamera() {
    permissionService.checkPersmission { [weak self] error in
      guard let strongSelf = self else {
        return
      }
      DispatchQueue.main.async { [weak self] in
        self?.settingsButton.isHidden = error == nil
      }
      if error == nil {
        strongSelf.setupSessionInput(for: .back)
        strongSelf.setupSessionOutput()
        strongSelf.delegate?.cameraViewControllerDidSetupCaptureSession(strongSelf)
      } else {
        strongSelf.delegate?.cameraViewControllerDidFailToSetupCaptureSession(strongSelf)
      }
    }
  }
  private func setupSessionInput(for position: AVCaptureDevice.Position) {
    guard !isSimulatorRunning else {
      return
    }
    guard let device = position == .front ? frontCameraDevice : backCameraDevice else {
      return
    }
    do {
      let newInput = try AVCaptureDeviceInput(device: device)
      captureDevice = device
      captureSession.beginConfiguration()
      if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
        captureSession.removeInput(currentInput)
      }
      captureSession.addInput(newInput)
      captureSession.commitConfiguration()
      flashButton.isHidden = position == .front
    } catch {
      delegate?.cameraViewController(self, didReceiveError: error)
      return
    }
  }
  private func setupSessionOutput() {
    guard !isSimulatorRunning else {
      return
    }
    let output = AVCaptureMetadataOutput()
    captureSession.addOutput(output)
    output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    output.metadataObjectTypes = metadata
    videoPreviewLayer?.session = captureSession
    view.setNeedsLayout()
  }
  private func swapCamera() {
    guard let input = captureSession.inputs.first as? AVCaptureDeviceInput else {
      return
    }
    setupSessionInput(for: input.device.position == .back ? .front : .back)
  }
  private func animateFocusView() {
    focusView.layer.removeAllAnimations()
    animatedFocusViewConstraints.deactivate()
    regularFocusViewConstraints.activate()
    view.layoutIfNeeded()
    guard barCodeFocusViewType == .animated else {
      return
    }
    regularFocusViewConstraints.deactivate()
    animatedFocusViewConstraints.activate()
    UIView.animate(
      withDuration: 1.0,
      delay: 0,
      options: [.repeat, .autoreverse, .beginFromCurrentState],
      animations: ({ [weak self] in
        self?.view.layoutIfNeeded()
      }),
      completion: nil
    )
  }
}
private extension CameraViewController {
  func setupConstraints() {
    if #available(iOS 11.0, *) {
      NSLayoutConstraint.activate(
        flashButton.topAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.topAnchor,
          constant: 30
        ),
        flashButton.trailingAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.trailingAnchor,
          constant: -13
        ),
        cameraButton.bottomAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.bottomAnchor,
          constant: -30
        )
      )
    } else {
      NSLayoutConstraint.activate(
        flashButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
        flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -13),
        cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
      )
    }
    let imageButtonSize: CGFloat = 37
    NSLayoutConstraint.activate(
      flashButton.widthAnchor.constraint(equalToConstant: imageButtonSize),
      flashButton.heightAnchor.constraint(equalToConstant: imageButtonSize),
      settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      settingsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      settingsButton.widthAnchor.constraint(equalToConstant: 150),
      settingsButton.heightAnchor.constraint(equalToConstant: 50),
      cameraButton.widthAnchor.constraint(equalToConstant: 48),
      cameraButton.heightAnchor.constraint(equalToConstant: 48),
      cameraButton.trailingAnchor.constraint(equalTo: flashButton.trailingAnchor)
    )
    setupFocusViewConstraints()
  }
  func setupFocusViewConstraints() {
    NSLayoutConstraint.activate(
      focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      focusView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    )
    let focusViewSize = barCodeFocusViewType == .oneDimension
      ? CGSize(width: 280, height: 80)
      : CGSize(width: 218, height: 150)
    regularFocusViewConstraints = [
      focusView.widthAnchor.constraint(equalToConstant: focusViewSize.width),
      focusView.heightAnchor.constraint(equalToConstant: focusViewSize.height)
    ]
    animatedFocusViewConstraints = [
      focusView.widthAnchor.constraint(equalToConstant: 280),
      focusView.heightAnchor.constraint(equalToConstant: 80)
    ]
    NSLayoutConstraint.activate(regularFocusViewConstraints)
  }
  func setupVideoPreviewLayerOrientation() {
    guard let videoPreviewLayer = videoPreviewLayer else {
      return
    }
    videoPreviewLayer.frame = view.layer.bounds
    if let connection = videoPreviewLayer.connection, connection.isVideoOrientationSupported {
      switch UIApplication.shared.statusBarOrientation {
      case .portrait:
        connection.videoOrientation = .portrait
      case .landscapeRight:
        connection.videoOrientation = .landscapeRight
      case .landscapeLeft:
        connection.videoOrientation = .landscapeLeft
      case .portraitUpsideDown:
        connection.videoOrientation = .portraitUpsideDown
      default:
        connection.videoOrientation = .portrait
      }
    }
  }
}
private extension CameraViewController {
  func makeFocusView() -> UIView {
    let view = UIView()
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = 2
    view.layer.cornerRadius = 5
    view.layer.shadowColor = UIColor.white.cgColor
    view.layer.shadowRadius = 10.0
    view.layer.shadowOpacity = 0.9
    view.layer.shadowOffset = CGSize.zero
    view.layer.masksToBounds = false
    return view
  }
  func makeSettingsButton() -> UIButton {
    let button = UIButton(type: .system)
    let title = NSAttributedString(
      string: localizedString("BUTTON_SETTINGS"),
      attributes: [.font: UIFont.boldSystemFont(ofSize: 17), .foregroundColor: UIColor.white]
    )
    button.setAttributedTitle(title, for: UIControl.State())
    button.sizeToFit()
    return button
  }
  func makeCameraButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(imageNamed("cameraRotate"), for: UIControl.State())
    button.isHidden = !showsCameraButton
    return button
  }
}
extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput,
                             didOutput metadataObjects: [AVMetadataObject],
                             from connection: AVCaptureConnection) {
    delegate?.cameraViewController(self, didOutput: metadataObjects)
  }
}
