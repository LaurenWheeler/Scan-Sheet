import UIKit
public final class MessageViewController: UIViewController {
  public var regularTintColor: UIColor = .black
  public var errorTintColor: UIColor = .red
  public var messages = StateMessageProvider()
  public private(set) lazy var textLabel: UILabel = self.makeTextLabel()
  public private(set) lazy var imageView: UIImageView = self.makeImageView()
  public private(set) lazy var borderView: UIView = self.makeBorderView()
  private lazy var blurView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .extraLight))
  private lazy var collapsedConstraints: [NSLayoutConstraint] = self.makeCollapsedConstraints()
  private lazy var expandedConstraints: [NSLayoutConstraint] = self.makeExpandedConstraints()
  var status = Status(state: .scanning) {
    didSet {
      handleStatusUpdate()
    }
  }
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(blurView)
    blurView.contentView.addSubviews(textLabel, imageView, borderView)
    handleStatusUpdate()
  }
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    blurView.frame = view.bounds
  }
  func animateLoading() {
    animate(blurStyle: .light)
    animate(borderViewAngle: CGFloat(Double.pi/2))
  }
   private func animate(blurStyle: UIBlurEffect.Style) {
    guard status.state == .processing else { return }
    UIView.animate(
      withDuration: 2.0,
      delay: 0.5,
      options: [.beginFromCurrentState],
      animations: ({ [weak self] in
        self?.blurView.effect = UIBlurEffect(style: blurStyle)
      }),
      completion: ({ [weak self] _ in
        self?.animate(blurStyle: blurStyle == .light ? .extraLight : .light)
      }))
  }
  private func animate(borderViewAngle: CGFloat) {
    guard status.state == .processing else {
      borderView.transform = .identity
      return
    }
    UIView.animate(
      withDuration: 0.8,
      delay: 0.5,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 1.0,
      options: [.beginFromCurrentState],
      animations: ({ [weak self] in
        self?.borderView.transform = CGAffineTransform(rotationAngle: borderViewAngle)
      }),
      completion: ({ [weak self] _ in
        self?.animate(borderViewAngle: borderViewAngle + CGFloat(Double.pi / 2))
      }))
  }
  private func handleStatusUpdate() {
    borderView.isHidden = true
    borderView.layer.removeAllAnimations()
    textLabel.text = status.text ?? messages.makeText(for: status.state)
    switch status.state {
    case .scanning, .unauthorized:
      textLabel.numberOfLines = 3
      textLabel.textAlignment = .left
      imageView.tintColor = regularTintColor
    case .processing:
      textLabel.numberOfLines = 10
      textLabel.textAlignment = .center
      borderView.isHidden = false
      imageView.tintColor = regularTintColor
    case .notFound:
      textLabel.font = UIFont.boldSystemFont(ofSize: 16)
      textLabel.numberOfLines = 10
      textLabel.textAlignment = .center
      imageView.tintColor = errorTintColor
    }
    if status.state == .scanning || status.state == .unauthorized {
      expandedConstraints.deactivate()
      collapsedConstraints.activate()
    } else {
      collapsedConstraints.deactivate()
      expandedConstraints.activate()
    }
  }
}
private extension MessageViewController {
  func makeTextLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.numberOfLines = 3
    label.font = UIFont.boldSystemFont(ofSize: 14)
    return label
  }
  func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = imageNamed("info").withRenderingMode(.alwaysTemplate)
    imageView.tintColor = .black
    return imageView
  }
  func makeBorderView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.layer.borderWidth = 2
    view.layer.cornerRadius = 10
    view.layer.borderColor = UIColor.black.cgColor
    return view
  }
}
extension MessageViewController {
  private func makeExpandedConstraints() -> [NSLayoutConstraint] {
    let padding: CGFloat = 10
    let borderSize: CGFloat = 51
    return [
      imageView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor, constant: -60),
      imageView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 30),
      imageView.heightAnchor.constraint(equalToConstant: 27),
      textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 18),
      textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      borderView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -12),
      borderView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
      borderView.widthAnchor.constraint(equalToConstant: borderSize),
      borderView.heightAnchor.constraint(equalToConstant: borderSize)
    ]
  }
  private func makeCollapsedConstraints() -> [NSLayoutConstraint] {
    let padding: CGFloat = 10
    var constraints = [
      imageView.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 18),
      imageView.widthAnchor.constraint(equalToConstant: 30),
      imageView.heightAnchor.constraint(equalToConstant: 27),
      textLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -3),
      textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10)
    ]
    if #available(iOS 11.0, *) {
      constraints += [
        imageView.leadingAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.leadingAnchor,
          constant: padding
        ),
        textLabel.trailingAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.trailingAnchor,
          constant: -padding
        )
      ]
    } else {
      constraints += [
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
        textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
      ]
    }
    return constraints
  }
}
