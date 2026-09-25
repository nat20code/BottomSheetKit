import Testing
import UIKit
import BottomSheetKit

@Suite("Detent contracts")
struct DetentTests {
  typealias Detent = BottomSheet.Detent

  private let bounds = CGRect(x: 10, y: 100, width: 400, height: 800)
  private let insets = UIEdgeInsets(top: 50, left: 10, bottom: 30, right: 20)

  @Test("Relative positions include the reference area's origin", arguments: [
    (Detent.Position.top(), CGFloat(150)),
    (.fromTop(20), 170),
    (.middle(), 510),
    (.middle(offset: -10), 500),
    (.fromBottom(120), 750),
    (.bottom(), 870),
    (.proportion(0), 150),
    (.proportion(0.25, offset: 10), 340),
    (.proportion(1), 870),
  ])
  func relativePositions(position: Detent.Position, expectedY: CGFloat) throws {
    let environment = Detent.Environment(containerBounds: bounds, safeAreaInsets: insets)
    let result = try #require(Detent(id: "test", position: position).resolve(in: environment))
    #expect(result.y == expectedY)
    #expect(result.referenceBounds == CGRect(x: 20, y: 150, width: 370, height: 720))
  }

  @Test("Identity survives size changes and a replacement definition")
  func stableIdentity() throws {
    let detent = Detent(id: "details", position: .middle())
    let before = try #require(detent.resolve(in: .init(containerBounds: bounds)))
    let after = try #require(detent.resolve(in: .init(
      containerBounds: CGRect(x: 10, y: 100, width: 800, height: 400)
    )))
    let replacement = Detent(id: "details", position: .fromBottom(100))
    #expect(before.id == after.id)
    #expect(after.id == replacement.id)
    #expect(before.y == 500)
    #expect(after.y == 300)
  }

  @Test("Container reference and signed offsets remain explicit")
  func containerReference() throws {
    let environment = Detent.Environment(containerBounds: bounds, safeAreaInsets: insets)
    let detent = Detent(id: "edge", position: .fromTop(-20), reference: .container)
    let result = try #require(detent.resolve(in: environment))
    #expect(result.y == 80)
    #expect(result.referenceBounds == bounds)
  }

  @Test("Keyboard avoidance doesn't subtract the bottom safe area twice")
  func keyboardAndSafeArea() throws {
    let detent = Detent(id: "editor", position: .fromBottom(120))
    let shown = Detent.Environment(
      containerBounds: bounds,
      safeAreaInsets: insets,
      keyboardFrame: CGRect(x: 0, y: 600, width: 500, height: 400),
      keyboardAvoidance: .avoidBottomOverlap
    )
    let hidden = Detent.Environment(
      containerBounds: bounds,
      safeAreaInsets: insets,
      keyboardAvoidance: .avoidBottomOverlap
    )
    let shownResult = try #require(detent.resolve(in: shown))
    let hiddenResult = try #require(detent.resolve(in: hidden))
    #expect(shownResult.referenceBounds.maxY == 600)
    #expect(shownResult.y == 480)
    #expect(hiddenResult.y == 750)
    #expect(shownResult.id == hiddenResult.id)
  }

  @Test("Floating keyboard avoidance is opt-in")
  func floatingKeyboard() throws {
    let environment = Detent.Environment(
      containerBounds: bounds,
      safeAreaInsets: insets,
      keyboardFrame: CGRect(x: 100, y: 550, width: 200, height: 200),
      keyboardAvoidance: .avoidBottomOverlap
    )
    let inherited = Detent(id: "floating", position: .fromBottom(100))
    let avoiding = Detent(
      id: "floating", position: .fromBottom(100), keyboardAvoidance: .avoidOverlap
    )
    #expect(try #require(inherited.resolve(in: environment)).y == 770)
    #expect(try #require(avoiding.resolve(in: environment)).y == 450)
  }

  @Test("Partial bottom overlap isn't treated as full-width overlap")
  func partialBottomOverlap() throws {
    let environment = Detent.Environment(
      containerBounds: bounds,
      keyboardFrame: CGRect(x: 100, y: 600, width: 200, height: 400),
      keyboardAvoidance: .avoidBottomOverlap
    )
    let detent = Detent(id: "partial", position: .bottom())
    #expect(try #require(detent.resolve(in: environment)).y == 900)
  }

  @Test("A detent can ignore the environment's keyboard policy")
  func keyboardOverride() throws {
    let environment = Detent.Environment(
      containerBounds: bounds,
      keyboardFrame: CGRect(x: 0, y: 600, width: 500, height: 400),
      keyboardAvoidance: .avoidBottomOverlap
    )
    let detent = Detent(
      id: "persistent", position: .fromBottom(120), keyboardAvoidance: .ignore
    )
    #expect(try #require(detent.resolve(in: environment)).y == 780)
  }

  @Test("An off-container keyboard doesn't move anchors", arguments: [
    CGRect(x: 0, y: 900, width: 500, height: 300),
    CGRect(x: 500, y: 600, width: 300, height: 300),
  ])
  func offContainerKeyboard(frame: CGRect) throws {
    let environment = Detent.Environment(
      containerBounds: bounds, keyboardFrame: frame, keyboardAvoidance: .avoidOverlap
    )
    #expect(try #require(Detent(id: "test", position: .bottom()).resolve(in: environment)).y == 900)
  }

  @Test("Content measurement is required and chrome is added exactly once")
  func contentMeasurement() throws {
    let detent = Detent(id: "content", position: .contentHeight(additionalHeight: 24))
    #expect(detent.resolve(in: .init(containerBounds: bounds)) == nil)
    let environment = Detent.Environment(
      containerBounds: bounds, safeAreaInsets: insets, contentHeight: 200
    )
    #expect(try #require(detent.resolve(in: environment)).y == 646)
  }

  @Test("A custom resolver sees adjusted bounds and can deactivate a detent")
  func customResolution() throws {
    let detent = Detent.custom(id: "adaptive") { context in
      guard context.referenceBounds.height >= 300 else { return nil }
      return .fromBottom(min(context.environment.contentHeight ?? 200, context.referenceBounds.height))
    }
    let environment = Detent.Environment(
      containerBounds: bounds,
      safeAreaInsets: insets,
      keyboardFrame: CGRect(x: 0, y: 600, width: 500, height: 400),
      contentHeight: 700,
      keyboardAvoidance: .avoidBottomOverlap
    )
    #expect(try #require(detent.resolve(in: environment)).y == 150)
    #expect(detent.resolve(in: .init(containerBounds: CGRect(x: 0, y: 0, width: 400, height: 200))) == nil)
  }

  @Test("Invalid or empty geometry doesn't produce a usable anchor")
  func invalidGeometry() {
    let detent = Detent(id: "test", position: .middle())
    #expect(detent.resolve(in: .init(containerBounds: .zero)) == nil)
    #expect(detent.resolve(in: .init(containerBounds: .null)) == nil)
    #expect(detent.resolve(in: .init(containerBounds: .infinite)) == nil)
    #expect(detent.resolve(in: .init(
      containerBounds: bounds, safeAreaInsets: UIEdgeInsets(top: 900, left: 0, bottom: 0, right: 0)
    )) == nil)
    #expect(detent.resolve(in: .init(
      containerBounds: bounds, keyboardFrame: bounds, keyboardAvoidance: .avoidOverlap
    )) == nil)
  }

  @Test("Invalid positions don't leak NaN or infinity into layout", arguments: [
    Detent.Position.fromTop(.nan),
    .fromBottom(.infinity),
    .proportion(-0.1),
    .proportion(1.1),
    .proportion(.nan),
    .contentHeight(additionalHeight: .infinity),
  ])
  func invalidPosition(position: Detent.Position) {
    let environment = Detent.Environment(containerBounds: bounds, contentHeight: 200)
    #expect(Detent(id: "test", position: position).resolve(in: environment) == nil)
  }
}
