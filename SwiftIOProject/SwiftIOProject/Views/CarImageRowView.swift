//
//  CarImageRowView.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import SwiftUI
import Kingfisher

// Строка показывает маленькую картинку и короткий заголовок автомобиля.
struct CarImageRowView: View {
    // Модель картинки передается из списка.
    let image: CarImage

    var body: some View {
        HStack(spacing: 12) {
            KFImage(image.previewImageURL)
                .placeholder {
                    ProgressView()
                        .frame(width: 90, height: 70)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(image.titleText)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
