import UIKit

extension BottomSheet {

  /// A named resting position, resolved against the sheet's current environment.
  ///
  /// IDs must be unique within a sheet. Keep an ID when its geometry changes so
  /// selection and an in-flight animation can continue targeting the same detent.
  /// Detents deliberately aren't `Equatable`: equal IDs don't imply equal resolvers.
  public struct Detent: Identifiable, Sendable {

    public let id: ID
    public let reference: Reference

    /// Overrides the environment's policy. `nil` inherits it.
    public let keyboardAvoidance: KeyboardAvoidance?

    private let resolver: @Sendable (ResolutionContext) -> Position?

    public init(
      id: ID,
      position: Position,
      reference: Reference = .safeArea,
      keyboardAvoidance: KeyboardAvoidance? = nil
    ) {
      self.id = id
      self.reference = reference
      self.keyboardAvoidance = keyboardAvoidance
      self.resolver = { _ in position }
    }

    /// Creates an adaptive detent. Return `nil` to make it inactive.
    ///
    /// The resolver returns a relative position, not a height or an absolute Y.
    /// Use the supplied snapshot; don't measure or mutate views from the resolver.
    public static func custom(
      id: ID,
      reference: Reference = .safeArea,
      keyboardAvoidance: KeyboardAvoidance? = nil,
      resolver: @escaping @Sendable (ResolutionContext) -> Position?
    ) -> Self {
      Self(
        id: id,
        reference: reference,
        keyboardAvoidance: keyboardAvoidance,
        resolver: resolver
      )
    }

    /// Returns the top-edge coordinate in the container's bounds coordinate space.
    ///
    /// Returns `nil` for inactive detents, invalid geometry or positions, missing
    /// content measurements, or an empty reference area. Finite offsets may place
    /// the top edge outside the reference area; they aren't silently clamped.
    /// Resolving doesn't move a view, change selection, or cancel an interaction.
    public func resolve(in environment: Environment) -> Resolved? {
      guard let bounds = environment.referenceBounds(
        for: reference,
        keyboardAvoidance: keyboardAvoidance
      ) else { return nil }

      let context = ResolutionContext(environment: environment, referenceBounds: bounds)
      guard let position = resolver(context) else { return nil }

      let y: CGFloat
      switch position {
      case .fromTop(let offset):
        y = bounds.minY + offset
      case .middle(let offset):
        y = bounds.midY + offset
      case .fromBottom(let offset):
        y = bounds.maxY - offset
      case .proportion(let fraction, let offset):
        guard fraction.isFinite, (0...1).contains(fraction) else { return nil }
        y = bounds.minY + bounds.height * fraction + offset
      case .contentHeight(let additionalHeight):
        guard let height = environment.contentHeight,
              height.isFinite, height >= 0,
              additionalHeight.isFinite,
              (height + additionalHeight).isFinite,
              height + additionalHeight >= 0
        else { return nil }
        y = bounds.maxY - (height + additionalHeight)
      }

      guard y.isFinite else { return nil }
      return Resolved(id: id, y: y, referenceBounds: bounds)
    }

    private init(
      id: ID,
      reference: Reference,
      keyboardAvoidance: KeyboardAvoidance?,
      resolver: @escaping @Sendable (ResolutionContext) -> Position?
    ) {
      self.id = id
      self.reference = reference
      self.keyboardAvoidance = keyboardAvoidance
      self.resolver = resolver
    }
  }
}

extension BottomSheet.Detent {

  /// Semantic identity, independent of the detent's current position.
  public struct ID: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
      self.rawValue = value
    }
  }

  /// Positions the sheet's top edge. All distances are in points, not pixels.
  public enum Position: Equatable, Sendable {
    /// Positive offsets move down from the reference area's top edge.
    case fromTop(CGFloat)

    /// Positive offsets move down from the reference area's midpoint.
    case middle(offset: CGFloat = 0)

    /// Positive offsets move up from the reference area's bottom edge.
    /// This distance doesn't implicitly add safe-area insets or view chrome.
    case fromBottom(CGFloat)

    /// A top-edge position: 0 is the top and 1 is the bottom of the reference area.
    /// This is not a fraction of the sheet's visible height. Offset is positive down.
    case proportion(CGFloat, offset: CGFloat = 0)

    /// Uses the externally measured content height plus optional chrome or padding.
    /// Returns no resolved detent until a measurement is available. Doesn't clamp
    /// tall content; use a custom resolver to apply an explicit maximum height.
    case contentHeight(additionalHeight: CGFloat = 0)

    public static func top() -> Self { .fromTop(0) }
    public static func bottom() -> Self { .fromBottom(0) }
  }

  public enum Reference: Equatable, Sendable {
    case container
    case safeArea
  }

  /// Geometry policy only. Keyboard observation, scrolling the focused field into
  /// view, and the timing of transitions belong to the sheet's coordinator.
  public enum KeyboardAvoidance: Equatable, Sendable {
    case ignore

    /// Moves the reference bottom to the keyboard's top only when the keyboard
    /// covers the container's entire bottom edge. Ignores floating/partial overlap.
    /// This describes intersection geometry, not the keyboard's system docking state.
    case avoidBottomOverlap

    /// Moves the reference bottom above any intersecting keyboard rectangle,
    /// including a floating keyboard. Conservatively reserves the full width.
    case avoidOverlap
  }

  /// Immutable inputs shared by all detents during one resolution pass.
  ///
  /// Rectangles use the same container-local coordinate space, including a nonzero
  /// bounds origin. Convert keyboard frames into that space before creating this
  /// value. Supply the keyboard's current or target frame according to the transition
  /// being coordinated; this type doesn't select an animation strategy.
  public struct Environment: Equatable, Sendable {
    public let containerBounds: CGRect
    public let safeAreaInsets: UIEdgeInsets

    /// `nil` means no keyboard. Off-container frames don't affect resolution.
    /// A bounding rectangle can't describe gaps inside a split keyboard.
    public let keyboardFrame: CGRect?

    /// Measured externally at the intended content width, excluding any padding
    /// subsequently requested via `Position.contentHeight(additionalHeight:)`.
    public let contentHeight: CGFloat?

    /// Default policy for detents without an explicit override.
    public let keyboardAvoidance: KeyboardAvoidance

    public init(
      containerBounds: CGRect,
      safeAreaInsets: UIEdgeInsets = .zero,
      keyboardFrame: CGRect? = nil,
      contentHeight: CGFloat? = nil,
      keyboardAvoidance: KeyboardAvoidance = .ignore
    ) {
      self.containerBounds = containerBounds
      self.safeAreaInsets = safeAreaInsets
      self.keyboardFrame = keyboardFrame
      self.contentHeight = contentHeight
      self.keyboardAvoidance = keyboardAvoidance
    }

    /// Applies safe-area insets, then keyboard avoidance. Uses the keyboard's top
    /// coordinate rather than subtracting its height, avoiding double-counting the
    /// bottom safe area. Returns `nil` when no positive reference area remains.
    public func referenceBounds(
      for reference: Reference,
      keyboardAvoidance override: KeyboardAvoidance? = nil
    ) -> CGRect? {
      guard containerBounds.hasFinitePositiveSize else { return nil }

      var bounds = containerBounds
      if reference == .safeArea {
        let insets = safeAreaInsets
        guard [insets.top, insets.left, insets.bottom, insets.right]
          .allSatisfy({ $0.isFinite && $0 >= 0 })
        else { return nil }

        let width = bounds.width - insets.left - insets.right
        let height = bounds.height - insets.top - insets.bottom
        guard width > 0, height > 0 else { return nil }
        bounds = CGRect(
          x: bounds.minX + insets.left,
          y: bounds.minY + insets.top,
          width: width,
          height: height
        )
      }

      let policy = override ?? keyboardAvoidance
      if policy != .ignore, let keyboardFrame {
        guard keyboardFrame.hasFiniteNonnegativeSize else { return nil }
        let overlap = bounds.intersection(keyboardFrame)
        if !overlap.isNull, !overlap.isEmpty {
          let coversBottom = keyboardFrame.minX <= containerBounds.minX
            && keyboardFrame.maxX >= containerBounds.maxX
            && keyboardFrame.maxY >= containerBounds.maxY
          if policy == .avoidOverlap || coversBottom {
            let bottom = max(bounds.minY, min(bounds.maxY, keyboardFrame.minY))
            bounds.size.height = bottom - bounds.minY
          }
        }
      }

      return bounds.hasFinitePositiveSize ? bounds : nil
    }
  }

  public struct ResolutionContext: Equatable, Sendable {
    public let environment: Environment

    /// The chosen reference area after applying this detent's keyboard policy.
    public let referenceBounds: CGRect
  }

  /// A computed anchor. Re-resolve after environment changes; keep the ID as the
  /// target identity. Equal coordinates may belong to different semantic IDs.
  public struct Resolved: Identifiable, Equatable, Sendable {
    public let id: ID
    public let y: CGFloat
    public let referenceBounds: CGRect
  }
}

private extension CGRect {
  var hasFiniteNonnegativeSize: Bool {
    !isNull && !isInfinite
      && origin.x.isFinite && origin.y.isFinite
      && size.width.isFinite && size.height.isFinite
      && size.width >= 0 && size.height >= 0
      && maxX.isFinite && maxY.isFinite
  }

  var hasFinitePositiveSize: Bool {
    hasFiniteNonnegativeSize && size.width > 0 && size.height > 0
  }
}
