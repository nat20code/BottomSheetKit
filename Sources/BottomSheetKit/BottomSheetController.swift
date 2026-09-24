import UIKit

public final class BottomSheetViewController: UIViewController {

  public let bottomSheetView: BottomSheet

  public init(bottomSheetView: BottomSheet = BottomSheet()) {
    self.bottomSheetView = bottomSheetView
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(bottomSheetView)
    bottomSheetView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      bottomSheetView.topAnchor.constraint(equalTo: view.topAnchor),
      bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.present(NativeBottomSheetViewController(), animated: true)
    }
  }
}
