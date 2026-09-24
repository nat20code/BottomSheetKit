import UIKit

open class BottomSheet: UIView, UIGestureRecognizerDelegate {

  open private(set) lazy var view = loadView()

  open private(set) lazy var backgroundView = loadBackgroundView()

  open private(set) var didLayoutSubviews = false

  private let panRecognizer = UIPanGestureRecognizer()

  // MARK: - Init

  public init(configuration: Configuration? = nil) {
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    if !didLayoutSubviews {
      didLayoutSubviews = true
    }

  }

  open func loadView() -> UIView {
    return UIView()
  }

  open func loadBackgroundView() -> UIView {
    return UIView()
  }

  open func setupUI() {
    view.backgroundColor = .systemBackground

    view.addGestureRecognizer(panRecognizer)
    panRecognizer.addTarget(self, action: #selector(handlePanRecognizer))
    panRecognizer.delegate = self
  }

  @objc
  open func handlePanRecognizer(_ sender: UIPanGestureRecognizer) {}

}

public struct BottomSheetLayoutSnapshot: Equatable {
  public let frame: CGRect

  public let frameInSuperview: CGRect
  public let frameInWindow: CGRect?

  public let safeAreaInsets: UIEdgeInsets
  public let safeAreaFrame: CGRect

  public let windowBounds: CGRect?
  public let windowSafeAreaInsets: UIEdgeInsets?
  public let isAttachedToWindow: Bool
}
