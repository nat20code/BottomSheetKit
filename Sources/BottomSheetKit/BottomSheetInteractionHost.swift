import UIKit

/// A shared gesture container that passes hits on empty space to views behind it.
open class BottomSheetInteractionHost: UIView {

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    // Empty space between the sheet and its accessories passes through to the
    // underlying interface. Hits on descendants still reach our recognizer.
    return hitView === self ? nil : hitView
  }

}
