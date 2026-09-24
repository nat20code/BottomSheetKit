import SwiftUI

public struct BottomSheetViewControllerRepresentable: UIViewControllerRepresentable {
  public init() {}

  public func makeUIViewController(context: Context) -> BottomSheetViewController {
    BottomSheetViewController()
  }

  public func updateUIViewController(
    _ uiViewController: BottomSheetViewController,
    context: Context
  ) {}
}
