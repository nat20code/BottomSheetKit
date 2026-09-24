import UIKit

extension BottomSheet {

  @MainActor
  public static var globalConfiguration: Configuration = .default

  public struct Configuration {
    public var bounces: Bool
    public var bouncesFactor: CGFloat
    public var viewIgnoresTopSafeArea: Bool
    public var viewIgnoresBottomBarHeight: Bool
    public var viewIgnoresBottomSafeArea: Bool
    public var prefersGrabberVisible: Bool
    public var cornerRadius: CGFloat
    public var shadowColor: CGColor?
    public var shadowOpacity: Float
    public var shadowOffset: CGSize
    public var shadowRadius: CGFloat
    public var shadowPath: CGPath?
    public var bottomBarIsHidden: Bool
    public var bottomBarHeight: CGFloat

    @MainActor
    public init(
      bounces: Bool = Configuration.default.bounces,
      bouncesFactor: CGFloat = Configuration.default.bouncesFactor,
      viewIgnoresTopSafeArea: Bool = Configuration.default.viewIgnoresTopSafeArea,
      viewIgnoresBottomBarHeight: Bool = Configuration.default.viewIgnoresBottomBarHeight,
      viewIgnoresBottomSafeArea: Bool = Configuration.default.viewIgnoresBottomSafeArea,
      prefersGrabberVisible: Bool = Configuration.default.prefersGrabberVisible,
      cornerRadius: CGFloat = Configuration.default.cornerRadius,
      shadowColor: CGColor? = Configuration.default.shadowColor,
      shadowOpacity: Float = Configuration.default.shadowOpacity,
      shadowOffset: CGSize = Configuration.default.shadowOffset,
      shadowRadius: CGFloat = Configuration.default.shadowRadius,
      shadowPath: CGPath? = Configuration.default.shadowPath,
      bottomBarIsHidden: Bool = Configuration.default.bottomBarIsHidden,
      bottomBarHeight: CGFloat = Configuration.default.bottomBarHeight
    ) {
      self.bounces = bounces
      self.bouncesFactor = bouncesFactor
      self.viewIgnoresTopSafeArea = viewIgnoresTopSafeArea
      self.viewIgnoresBottomBarHeight = viewIgnoresBottomBarHeight
      self.viewIgnoresBottomSafeArea = viewIgnoresBottomSafeArea
      self.prefersGrabberVisible = prefersGrabberVisible
      self.cornerRadius = cornerRadius
      self.shadowColor = shadowColor
      self.shadowOpacity = shadowOpacity
      self.shadowOffset = shadowOffset
      self.shadowRadius = shadowRadius
      self.shadowPath = shadowPath
      self.bottomBarIsHidden = bottomBarIsHidden
      self.bottomBarHeight = bottomBarHeight
    }

    @MainActor
    public static let `default` = Configuration(
      bounces: true,
      bouncesFactor: 0.1,
      viewIgnoresTopSafeArea: true,
      viewIgnoresBottomBarHeight: false,
      viewIgnoresBottomSafeArea: false,
      prefersGrabberVisible: true,
      cornerRadius: 10.0,
      shadowColor: UIColor.black.withAlphaComponent(0.5).cgColor,
      shadowOpacity: 0.5,
      shadowOffset: CGSize(width: 1.5, height: 1.5),
      shadowRadius: 3.0,
      shadowPath: nil,
      bottomBarIsHidden: true,
      bottomBarHeight: 64.0
    )
  }
}

