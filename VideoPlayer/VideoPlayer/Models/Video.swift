//
//  Video.swift
//  VideoPlayer
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit

// Структура хранит изображение, заголовок и ссылку на конкретное видео.
struct Video {
    // Картинка используется как заставка видео в таблице.
    let videoImage: UIImage

    // Заголовок показывает название ролика рядом с картинкой.
    let videoTitle: String

    // Ссылка нужна для запуска AVPlayer с выбранным роликом.
    let videoUrl: URL

    // Перечисление хранит все заголовки видео в одном месте.
    private enum VideoTitle: String {
        case videoTitleOne = "Mutt and Jeff On Strike"
        case videoTitleTwo = "Avez Vous"
        case videoTitleThree = "The Kings Trumpet"
        case videoTitleFour = "Popeye the Sailor Meets Aladdin and His Wonderful Lamp"
    }

    // Перечисление хранит все ссылки на видео из задания.
    private enum VideoUrl: String {
        case videoOne = "https://ia800602.us.archive.org/19/items/mutt-and-jeff-on-strike-1920/mutt-and-jeff-on-strike-1920.mp4"
        case videoTwo = "https://ia800604.us.archive.org/19/items/Avez-vousDjVu...LePlusPetitZooDuMonde/104_Le_Plus_Petit_Zoo_du_Monde.mp4"
        case videoThree = "https://ia800705.us.archive.org/28/items/TheSpiritOf43_56/The_Spirit_of__43_512kb.mp4"
        case videoFour = "https://ia800703.us.archive.org/30/items/Popeye_the_Sailor_Meets_Aladdin_and_His_Wonderful_Lamp/Popeye_-_Aladdin_and_His_Wonderful_Lamp_512kb.mp4"
    }

    // Метод создает готовый массив видео для таблицы.
    static func fetchVideos() -> [Video] {
        let v1 = Video(videoImage: UIImage(named: "v1") ?? UIImage(), videoTitle: VideoTitle.videoTitleOne.rawValue, videoUrl: URL(string: VideoUrl.videoOne.rawValue)!)
        let v2 = Video(videoImage: UIImage(named: "v2") ?? UIImage(), videoTitle: VideoTitle.videoTitleTwo.rawValue, videoUrl: URL(string: VideoUrl.videoTwo.rawValue)!)
        let v3 = Video(videoImage: UIImage(named: "v3") ?? UIImage(), videoTitle: VideoTitle.videoTitleThree.rawValue, videoUrl: URL(string: VideoUrl.videoThree.rawValue)!)
        let v4 = Video(videoImage: UIImage(named: "v4") ?? UIImage(), videoTitle: VideoTitle.videoTitleFour.rawValue, videoUrl: URL(string: VideoUrl.videoFour.rawValue)!)

        return [v1, v2, v3, v4]
    }
}
