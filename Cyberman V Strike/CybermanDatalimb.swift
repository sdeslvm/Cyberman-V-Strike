import Foundation
import SwiftUI

struct CybermanEntryScreen: View {
    @StateObject private var loader: CybermanWebLoader

    init(loader: CybermanWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            CybermanWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                CybermanProgressIndicator(value: percent)
            case .failure(let err):
                CybermanErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                CybermanOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct CybermanProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            CybermanLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct CybermanErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct CybermanOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
