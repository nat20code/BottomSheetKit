import Testing
@testable import BottomSheetKit
import UIKit

@Suite("Leaks Tests")
@MainActor
struct LeaksTests {

  @Test
  func memoryLeak() async throws {
    var bottomSheet: BottomSheetView? = BottomSheetView()
    weak let weakBottomSheet: BottomSheetView? = bottomSheet

    let view = UIView()
    view.addSubview(bottomSheet!)

    bottomSheet = nil
    weakBottomSheet!.removeFromSuperview()
    try await Task.sleep(nanoseconds: 100_000_000)

    #expect(weakBottomSheet == nil)
  }
}


