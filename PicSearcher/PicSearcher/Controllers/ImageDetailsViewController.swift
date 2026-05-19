//
//  ImageDetailsViewController.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit
import Kingfisher

// Контроллер показывает выбранную картинку на весь экран, позволяет скрыть панели, увеличить изображение и сохранить его.
final class ImageDetailsViewController: UIViewController {
    // Модель картинки передается с предыдущего экрана перед переходом.
    var picture: Picture?

    // Scroll view дает стандартное увеличение картинки жестом и позволяет двигать ее после zoom.
    private let scrollView = UIScrollView()

    // Image view показывает большую картинку и выступает объектом для масштабирования.
    private let imageView = UIImageView()

    // Нижняя панель показывает подпись с тегами выбранной картинки.
    private let bottomOverlayView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))

    // Подпись показывает название изображения внизу экрана.
    private let titleLabel = UILabel()

    // Верхняя строка нижней плашки показывает разрешение изображения.
    private let resolutionLabel = UILabel()

    // Индикатор показывает ожидание, пока большая картинка еще не загрузилась.
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // Флаг хранит текущее состояние видимости верхней и нижней панели.
    private var areOverlayViewsHidden = false

    // Загрузка контроллера настраивает экран и запускает загрузку большого изображения.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupNavigationBar()
        putPictureToImageView()
    }

    // Настраивает и добавляет основные элементы на экран.
    private func setupView() {
        view.backgroundColor = .systemBackground

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.bouncesZoom = true
        scrollView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.text = picture?.titleText

        resolutionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        resolutionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        resolutionLabel.numberOfLines = 1
        resolutionLabel.textAlignment = .left
        resolutionLabel.text = picture?.resolutionText

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleOverlayViews))
        view.addGestureRecognizer(tapGestureRecognizer)

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(bottomOverlayView)
        view.addSubview(activityIndicator)
        bottomOverlayView.contentView.addSubview(resolutionLabel)
        bottomOverlayView.contentView.addSubview(titleLabel)
    }

    // Navigation bar получает стандартную кнопку сохранения на правой стороне.
    private func setupNavigationBar() {
        title = nil
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(saveImage)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    // Экран снова показывает системный navigation bar при открытии.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // Констрейнты.
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        bottomOverlayView.translatesAutoresizingMaskIntoConstraints = false
        resolutionLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),

            bottomOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            resolutionLabel.topAnchor.constraint(equalTo: bottomOverlayView.contentView.topAnchor, constant: 16),
            resolutionLabel.leadingAnchor.constraint(equalTo: bottomOverlayView.contentView.leadingAnchor, constant: 16),
            resolutionLabel.trailingAnchor.constraint(equalTo: bottomOverlayView.contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: resolutionLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: bottomOverlayView.contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: bottomOverlayView.contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomOverlayView.contentView.bottomAnchor, constant: -16),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Метод загружает большую картинку и прячет индикатор после завершения.
    private func putPictureToImageView() {
        guard let detailImageURL = picture?.detailImageURL else {
            titleLabel.text = "Изображение недоступно."
            return
        }

        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false

        imageView.kf.indicatorType = .none
        imageView.kf.setImage(with: detailImageURL) { [weak self] result in
            guard let self = self else {
                return
            }

            self.activityIndicator.stopAnimating()

            switch result {
            case .success:
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            case .failure:
                self.titleLabel.text = "Не удалось загрузить изображение."
            }
        }
    }

    // Метод сохраняет текущую картинку в системную галерею.
    @objc private func saveImage() {
        guard let image = imageView.image else {
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    // Метод показывает или скрывает нижнюю панель по тапу на экран.
    @objc private func toggleOverlayViews() {
        areOverlayViewsHidden.toggle()

        UIView.animate(withDuration: 0.25) {
            let alpha: CGFloat = self.areOverlayViewsHidden ? 0 : 1
            self.bottomOverlayView.alpha = alpha
        }

        navigationController?.setNavigationBarHidden(areOverlayViewsHidden, animated: true)
    }

    // Метод получает результат сохранения и показывает пользователю короткое системное сообщение.
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        let message = error == nil ? "Изображение сохранено." : "Не удалось сохранить изображение."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alertController, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak alertController] in
            alertController?.dismiss(animated: true)
        }
    }
}

extension ImageDetailsViewController: UIScrollViewDelegate {
    // Метод возвращает image view как объект, который должен масштабироваться внутри scroll view.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    // Метод включает прокрутку только после увеличения изображения.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
    }
}
