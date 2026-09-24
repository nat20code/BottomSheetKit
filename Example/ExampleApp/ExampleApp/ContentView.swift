import SwiftUI
import BottomSheetKit

struct ContentView: View {
  @State private var bottomSheetPadding: CGFloat = 0
  @State private var addsTopSafeArea = false
  @State private var addsBottomSafeArea = false

  private let paddingOptions: [CGFloat] = [0, 16, 32, 64]

  var body: some View {
    ZStack {
      BottomSheetViewControllerRepresentable()
        .safeAreaPadding(.top, addsTopSafeArea ? 100 : 0)
        .safeAreaPadding(.bottom, addsBottomSafeArea ? 100 : 0)
        .ignoresSafeArea()
        .padding(bottomSheetPadding)
    }
    .overlay(alignment: .topTrailing) {
      Menu {
        Section("Padding") {
          ForEach(paddingOptions, id: \.self) { padding in
            Button {
              bottomSheetPadding = padding
            } label: {
              if padding == bottomSheetPadding {
                Label(paddingTitle(for: padding), systemImage: "checkmark")
              } else {
                Text(paddingTitle(for: padding))
              }
            }
          }
        }

        Section("Safe Area") {
          Toggle("Сверху +100 pt", isOn: $addsTopSafeArea)
          Toggle("Снизу +100 pt", isOn: $addsBottomSafeArea)
        }
      } label: {
        Label(
          "Layout",
          systemImage: "arrow.down.right.and.arrow.up.left"
        )
      }
      .buttonStyle(.borderedProminent)
      .padding()
    }
    .navigationTitle("Main")
  }

  private func paddingTitle(for padding: CGFloat) -> String {
    padding == 0 ? "Без отступа" : "\(Int(padding)) pt"
  }
}

#Preview {
  ContentView()
}
