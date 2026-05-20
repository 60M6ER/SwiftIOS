//
//  CarImageDetailView.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import SwiftUI
import Kingfisher

// Детальный экран показывает большую картинку и описание под ней.
struct CarImageDetailView: View {
    // Модель картинки передается с главного экрана.
    let image: CarImage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(image.titleText)
                    .font(.system(size: 34, weight: .regular))
                    .multilineTextAlignment(.leading)

                KFImage(image.detailImageURL)
                    .placeholder {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(image.descriptionText)
                    .font(.system(size: 20, weight: .regular))
                    .multilineTextAlignment(.leading)

                Text("Автор: \(image.user)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
