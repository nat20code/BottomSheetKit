import UIKit

open class BottomSheet: UIView, UIGestureRecognizerDelegate {

  open private(set) lazy var view = loadView()

  open private(set) lazy var backgroundView = loadBackgroundView()

  /// The common parent of the sheet surface and any external drag handles.
  /// Add accessories here so they share the sheet's pan recognizer.
  /// Customize its creation by overriding `loadInteractionHost()`.
  public private(set) lazy var interactionHost: UIView = loadInteractionHost()

  open private(set) var didLayoutSubviews = false

  private let panRecognizer = UIPanGestureRecognizer()
  private var panInteraction = BottomSheetPanInteraction()

  // MARK: - Init

  public init(configuration: Configuration? = nil) {
    super.init(frame: .zero)
    setupUI()
    view.backgroundColor = .red
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    backgroundView.frame = bounds
    interactionHost.frame = bounds

    guard !interactionHost.bounds.isEmpty else { return }

    if !didLayoutSubviews {
      setInitialLayout()
      didLayoutSubviews = true
    } else {
      // Dragging only changes the origin. Resize the surface when its host resizes.
      view.frame.size = interactionHost.bounds.size
    }
  }

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    return hitView === self ? nil : hitView
  }

  open override func didMoveToWindow() {
    super.didMoveToWindow()

    if window == nil {
      panInteraction = BottomSheetPanInteraction()
    }
  }

  open func loadView() -> UIView {
    return UIView()
  }

  open func loadBackgroundView() -> UIView {
    return UIView()
  }

  /// Creates the host once during setup. BottomSheet manages its frame and pan
  /// recognizer. Subclass `BottomSheetInteractionHost` to retain the default
  /// behavior that passes touches through empty space.
  open func loadInteractionHost() -> UIView {
    return BottomSheetInteractionHost()
  }

  open func setupUI() {
    // The viewport clips the full-height surface; the interaction host does not
    // clip accessories to the surface's frame or mask.
    clipsToBounds = true
    view.backgroundColor = .systemBackground
    view.clipsToBounds = true
    backgroundView.isUserInteractionEnabled = false

    addSubview(backgroundView)
    addSubview(interactionHost)
    interactionHost.addSubview(view)

    interactionHost.addGestureRecognizer(panRecognizer)
    panRecognizer.addTarget(self, action: #selector(handlePanRecognizer))
    panRecognizer.delegate = self
    panRecognizer.minimumNumberOfTouches = 1
    panRecognizer.maximumNumberOfTouches = Int.max
  }

  private func setInitialLayout() {
    let initialY: CGFloat = 500 // TODO: Resolve the initial detent.
    view.frame = CGRect(
      origin: CGPoint(x: interactionHost.bounds.minX, y: initialY),
      size: interactionHost.bounds.size
    )
  }

  @objc
  open func handlePanRecognizer(_ sender: UIPanGestureRecognizer) {
    guard sender === panRecognizer else { return }
    layoutIfNeeded()
    guard didLayoutSubviews else { return }

    // Use the stationary host's coordinates, not the moving surface's.
    let translationY = sender.translation(in: interactionHost).y
    guard let y = panInteraction.update(
      state: sender.state,
      translationY: translationY,
      positionY: view.frame.minY
    ) else { return }

    UIView.performWithoutAnimation {
      view.frame.origin.y = y
    }
  }

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
