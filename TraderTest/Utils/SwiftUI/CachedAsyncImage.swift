//
//  CachedAsyncImage.swift
//  TraderTest
//
//  Created by Asan Ametov on 10.03.2026.
//

import SwiftUI

private enum LogoLoadingError: Error {
    case invalidImage
}

struct LogoAsyncImage<Content: View, Placeholder: View>: View {
    let placeholder: () -> Placeholder
    let urlString: String?
    var minSide: CGFloat = 5
    let content: (Image) -> Content

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        ZStack {
            switch phase {
            case .success(let image):
                content(image)
            case .failure, .empty:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
        .task(id: urlString) {
            await load()
        }
    }

    private func load() async {
        guard let urlString, let url = URL(string: urlString) else {
            phase = .empty
            return
        }

        let request = URLRequest(url: url)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let uiImage = UIImage(data: data) else {
                phase = .failure(LogoLoadingError.invalidImage)
                return
            }

            // фильтр по размеру
            if uiImage.size.width < minSide || uiImage.size.height < minSide {
                phase = .empty         // считаем, что логотипа нет
                return
            }

            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }
}
