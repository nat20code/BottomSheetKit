import UIKit

/// Tracks one continuous pan. UIKit keeps translation continuous when the
/// number of touches changes, so a new finger must not start a new session.
struct BottomSheetPanInteraction {

  private struct Session {
    let initialY: CGFloat
    let initialTranslationY: CGFloat
  }

  private var session: Session?

  mutating func update(
    state: UIGestureRecognizer.State,
    translationY: CGFloat,
    positionY: CGFloat
  ) -> CGFloat? {
    switch state {
    case .began:
      session = Session(initialY: positionY, initialTranslationY: translationY)
      return nil

    case .changed, .ended:
      guard let session else { return nil }
      let y = session.initialY + translationY - session.initialTranslationY
      if state == .ended {
        self.session = nil
      }
      return y

    case .cancelled, .failed:
      session = nil
      return nil

    default:
      return nil
    }
  }

}
