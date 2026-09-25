import Testing
import UIKit
@testable import BottomSheetKit

@Suite("Pan interaction")
@MainActor
struct PanInteractionTests {

  @Test
  func translationIsRelativeToGestureStart() {
    var interaction = BottomSheetPanInteraction()
    #expect(interaction.update(state: .began, translationY: 12, positionY: 500) == nil)
    #expect(interaction.update(state: .changed, translationY: 42, positionY: 500) == 530)
    // Rendering a previous sample must not compound the translation.
    #expect(interaction.update(state: .changed, translationY: 22, positionY: 530) == 510)
  }

  @Test
  func endingIncludesTheFinalTranslationAndClearsTheSession() {
    var interaction = BottomSheetPanInteraction()
    _ = interaction.update(state: .began, translationY: 0, positionY: 500)
    #expect(interaction.update(state: .changed, translationY: -40, positionY: 500) == 460)
    #expect(interaction.update(state: .ended, translationY: -55, positionY: 460) == 445)
    #expect(interaction.update(state: .changed, translationY: -80, positionY: 445) == nil)
    _ = interaction.update(state: .began, translationY: 10, positionY: 445)
    #expect(interaction.update(state: .changed, translationY: 30, positionY: 445) == 465)
  }

  @Test(arguments: [UIGestureRecognizer.State.cancelled, .failed])
  func interruptionKeepsTheLatestPosition(state: UIGestureRecognizer.State) {
    var interaction = BottomSheetPanInteraction()
    _ = interaction.update(state: .began, translationY: 0, positionY: 500)
    #expect(interaction.update(state: .changed, translationY: -40, positionY: 500) == 460)
    #expect(interaction.update(state: state, translationY: 0, positionY: 460) == nil)
    #expect(interaction.update(state: .ended, translationY: 0, positionY: 460) == nil)
  }

  @Test
  func hostSharesOneMultitouchRecognizerWithSurfaceAndAccessories() throws {
    let sheet = makeSheet()
    let bubble = UIView(frame: CGRect(x: 20, y: 400, width: 120, height: 50))
    sheet.interactionHost.addSubview(bubble)
    let pan = try #require(sheet.interactionHost.gestureRecognizers?.first as? UIPanGestureRecognizer)

    #expect(sheet.interactionHost.gestureRecognizers?.count == 1)
    #expect(sheet.view.gestureRecognizers?.isEmpty != false)
    #expect(pan.minimumNumberOfTouches == 1)
    #expect(pan.maximumNumberOfTouches > 1)
    #expect(sheet.view.superview === sheet.interactionHost)
    #expect(sheet.hitTest(CGPoint(x: 30, y: 410), with: nil) === bubble)
    #expect(sheet.hitTest(CGPoint(x: 30, y: 600), with: nil) === sheet.view)
    #expect(sheet.hitTest(CGPoint(x: 30, y: 475), with: nil) == nil)
    #expect(sheet.hitTest(CGPoint(x: 30, y: 200), with: nil) == nil)
    #expect(!sheet.interactionHost.clipsToBounds)
    #expect(sheet.view.clipsToBounds)
  }

  @Test
  func resizingTheContainerPreservesTheDraggedPosition() {
    let sheet = makeSheet()
    sheet.view.frame.origin.y = 310
    sheet.frame.size = CGSize(width: 844, height: 390)
    sheet.setNeedsLayout()
    sheet.layoutIfNeeded()

    #expect(sheet.interactionHost.frame == sheet.bounds)
    #expect(sheet.view.frame.minY == 310)
    #expect(sheet.view.bounds.size == sheet.bounds.size)
  }

  @Test
  func emptyLayoutDoesNotConsumeTheInitialPosition() {
    let sheet = BottomSheet()
    sheet.layoutSubviews()
    #expect(!sheet.didLayoutSubviews)
    sheet.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    sheet.layoutIfNeeded()
    #expect(sheet.didLayoutSubviews)
    #expect(sheet.view.frame.minY == 500)
  }

  private func makeSheet() -> BottomSheet {
    let sheet = BottomSheet()
    sheet.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    sheet.layoutIfNeeded()
    return sheet
  }

}
