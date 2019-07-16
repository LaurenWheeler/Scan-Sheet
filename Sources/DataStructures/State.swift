import UIKit
enum State {
  case scanning
  case processing
  case unauthorized
  case notFound
}
public struct StateMessageProvider {
  public var scanningText = localizedString("INFO_DESCRIPTION_TEXT")
  public var processingText = localizedString("INFO_LOADING_TITLE")
  public var unathorizedText = localizedString("ASK_FOR_PERMISSION_TEXT")
  public var notFoundText = localizedString("NO_PRODUCT_ERROR_TITLE")
  func makeText(for state: State) -> String {
    switch state {
    case .scanning:
      return scanningText
    case .processing:
      return processingText
    case .unauthorized:
      return unathorizedText
    case .notFound:
      return notFoundText
    }
  }
}
struct Status {
  let state: State
  let animated: Bool
  let text: String?
  init(state: State, animated: Bool = true, text: String? = nil) {
    self.state = state
    self.animated = animated
    self.text = text
  }
}
