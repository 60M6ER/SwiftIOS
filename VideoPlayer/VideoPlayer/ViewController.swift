//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit
import AVKit

// Контроллер показывает список видео и открывает встроенный плеер по нажатию на ячейку.
class ViewController: UIViewController {
    // Заголовок показывает название экрана над таблицей.
    private let titleLabel = UILabel()

    // Таблица отображает все доступные видео из массива.
    private let tableView = UITableView(frame: .zero, style: .plain)

    // Массив хранит все подготовленные ролики для таблицы.
    let videoContent: [Video] = Video.fetchVideos()

    // Загрузка контроллера настраивает таблицу и базовые элементы интерфейса.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupTableView()
    }

    // Метод добавляет основные элементы на экран.
    private func setupView() {
        view.backgroundColor = .systemBackground
        titleLabel.text = "Video Player"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }

    // Констрейнты.
    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Метод подключает таблицу к dataSource и delegate и регистрирует кодовую ячейку.
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 128
        tableView.register(VideoContentCell.self, forCellReuseIdentifier: VideoContentCell.reuseIdentifier)
    }
}

extension ViewController: UITableViewDataSource {
    // Метод возвращает количество видео в массиве.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoContent.count
    }

    // Метод создает и настраивает ячейку для текущего видео.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoContentCell.reuseIdentifier, for: indexPath) as? VideoContentCell else {
            return UITableViewCell()
        }

        let currentVideo = videoContent[indexPath.row]
        cell.video = currentVideo
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    // Метод запускает встроенный плеер для выбранного видео.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentVideo = videoContent[indexPath.row]
        let player = AVPlayer(url: currentVideo.videoUrl)
        let playerControll = AVPlayerViewController()
        playerControll.player = player
        playerControll.allowsPictureInPicturePlayback = true
        playerControll.player?.play()

        present(playerControll, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
