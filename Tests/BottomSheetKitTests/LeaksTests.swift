import Testing
@testable import BottomSheetKit
import UIKit

@Suite("Leaks Tests")
@MainActor
struct LeaksTests {

  @Test
  func memoryLeak() async throws {
    var bottomSheet: BottomSheet? = BottomSheet()
    weak let weakBottomSheet: BottomSheet? = bottomSheet

    let view = UIView()
    view.addSubview(bottomSheet!)

    bottomSheet = nil
    weakBottomSheet!.removeFromSuperview()
    try await Task.sleep(nanoseconds: 100_000_000)

    #expect(weakBottomSheet == nil)
  }
}

