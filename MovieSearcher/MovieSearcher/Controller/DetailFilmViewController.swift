//
//  DetailFilmViewController.swift
//  MovieSearcher
//
//  Created by Kirill Timanovsky on 29.07.2021.
//

import UIKit

final class DetailFilmViewController: UIViewController {
    // Модель нужна для изменения liked-состояния.
    private let model = Model()

    // Фильм приходит с предыдущего экрана готовым объектом.
    var film: FilmObject?

    // Scroll view держит длинный экран целиком и дает спокойно прокручивать его.
    private let scrollView = UIScrollView()

    // Внутренний контейнер нужен для удобной раскладки всех блоков экрана.
    private let contentView = UIView()

    // Постер фильма стоит в левом верхнем блоке и открывается в fullscreen по тапу.
    private let posterImageView = UIImageView()

    // Заголовок показывает название фильма.
    private let titleLabel = UILabel()

    // Сердце в detail показывает лайкнут фильм или нет.
    private let likeButton = UIButton(type: .system)

    // Год выпуска идет отдельной строкой под названием.
    private let yearLabel = UILabel()

    // Переиспользуемый блок рейтинга используется и здесь, и в плитке.
    private let ratingView = RatingView(rating: 0, fontSize: 20)

    // Заголовок секции кадров подписывает карусель превью.
    private let stillsTitleLabel = UILabel()

    // Горизонтальный scroll view держит ленту тестовых кадров.
    private let stillsScrollView = UIScrollView()

    // Внутренний stack view раскладывает превью-картинки по горизонтали.
    private let stillsStackView = UIStackView()

    // Заголовок секции описания отделяет текст от остальных блоков.
    private let overviewTitleLabel = UILabel()

    // Само описание фильма занимает нижнюю часть detail-экрана.
    private let overviewLabel = UILabel()

    // Отдельный аниматор отвечает за красивое открытие fullscreen из картинки.
    private let transition = RoundingTransition()

    // Источник нужен, чтобы анимация стартовала именно из нажатого элемента.
    private weak var transitionSourceView: UIView?

    // Загрузка контроллера собирает экран и сразу наполняет его данными фильма.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar()
        configurePosterBlock()
        configureLikeButton()
        configureStillsBlock()
        configureOverviewBlock()
        configureLayout()
        DispatchQueue.main.async {
            self.applyFilm()
        }
    }
}

private extension DetailFilmViewController {
    // Метод добавляет основные контейнеры экрана и настраивает прокрутку.
    func configureView() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stillsScrollView.translatesAutoresizingMaskIntoConstraints = false
        stillsStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        stillsScrollView.showsHorizontalScrollIndicator = false
        stillsScrollView.alwaysBounceHorizontal = true

        stillsStackView.axis = .horizontal
        stillsStackView.spacing = 12
        stillsStackView.alignment = .fill
        stillsStackView.distribution = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    // Navigation bar на detail-экране работает без large title.
    func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = "О фильме"
    }

    // Верхний блок собирает постер и три главных параметра фильма.
    func configurePosterBlock() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 18
        posterImageView.isUserInteractionEnabled = true
        posterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPosterFullScreen)))

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 6

        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        yearLabel.textColor = .secondaryLabel
        yearLabel.numberOfLines = 1

        ratingView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(ratingView)
    }

    // Сердце в верхнем блоке меняет liked-состояние фильма.
    func configureLikeButton() {
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.tintColor = .systemRed
        likeButton.addTarget(self, action: #selector(toggleLikeState), for: .touchUpInside)
        contentView.addSubview(likeButton)
    }

    // Блок кадров готовит горизонтальную карусель превью.
    func configureStillsBlock() {
        stillsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        stillsTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        stillsTitleLabel.text = "Кадры и съемки"

        contentView.addSubview(stillsTitleLabel)
        contentView.addSubview(stillsScrollView)
        stillsScrollView.addSubview(stillsStackView)
    }

    // Блок описания показывает длинный текст под каруселью кадров.
    func configureOverviewBlock() {
        overviewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        overviewTitleLabel.text = "Описание"

        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.font = .systemFont(ofSize: 17, weight: .regular)
        overviewLabel.textColor = .label
        overviewLabel.numberOfLines = 0

        contentView.addSubview(overviewTitleLabel)
        contentView.addSubview(overviewLabel)
    }

    // Констрейнты собирают все смысловые блоки на экране деталей.
    func configureLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            posterImageView.widthAnchor.constraint(equalToConstant: 180),
            posterImageView.heightAnchor.constraint(equalToConstant: 290),

            likeButton.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            likeButton.widthAnchor.constraint(equalToConstant: 28),
            likeButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            ratingView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingView.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),
            ratingView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            ratingView.heightAnchor.constraint(equalToConstant: 28),

            yearLabel.bottomAnchor.constraint(equalTo: ratingView.topAnchor, constant: -15),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            yearLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: yearLabel.topAnchor, constant: -15),

            stillsTitleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 28),
            stillsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stillsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            stillsScrollView.topAnchor.constraint(equalTo: stillsTitleLabel.bottomAnchor, constant: 14),
            stillsScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stillsScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stillsScrollView.heightAnchor.constraint(equalToConstant: 112),

            stillsStackView.topAnchor.constraint(equalTo: stillsScrollView.contentLayoutGuide.topAnchor),
            stillsStackView.leadingAnchor.constraint(equalTo: stillsScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stillsStackView.trailingAnchor.constraint(equalTo: stillsScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stillsStackView.bottomAnchor.constraint(equalTo: stillsScrollView.contentLayoutGuide.bottomAnchor),
            stillsStackView.heightAnchor.constraint(equalTo: stillsScrollView.frameLayoutGuide.heightAnchor),

            overviewTitleLabel.topAnchor.constraint(equalTo: stillsScrollView.bottomAnchor, constant: 28),
            overviewTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
    }

    // Метод переносит данные выбранного фильма в верхний блок, карусель и описание.
    func applyFilm() {
        guard let film else {
            titleLabel.text = "Фильм недоступен"
            overviewLabel.text = "Не удалось получить данные для подробного экрана."
            stillsTitleLabel.isHidden = true
            stillsScrollView.isHidden = true
            return
        }

        title = film.title
        titleLabel.text = film.title
        updateLikeButtonAppearance(isLiked: film.isLiked)
        yearLabel.text = String(film.year)
        ratingView.configure(rating: film.rating, fontSize: 20)
        overviewLabel.text = film.overview
        posterImageView.image = film.posterImage
        applyGalleryImages(film.galleryImages)
    }

    // Метод собирает тестовые превью-картинки в горизонтальную ленту.
    func applyGalleryImages(_ images: [UIImage]) {
        stillsStackView.arrangedSubviews.forEach { view in
            stillsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        images.forEach { image in
            let previewImageView = UIImageView()
            previewImageView.translatesAutoresizingMaskIntoConstraints = false
            previewImageView.image = image
            previewImageView.contentMode = .scaleAspectFill
            previewImageView.clipsToBounds = true
            previewImageView.layer.cornerRadius = 16
            previewImageView.isUserInteractionEnabled = true
            previewImageView.widthAnchor.constraint(equalToConstant: 168).isActive = true
            previewImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openGalleryImage(_:))))
            previewImageView.tag = stillsStackView.arrangedSubviews.count
            stillsStackView.addArrangedSubview(previewImageView)
        }
    }

    // Тап по постеру открывает одиночный fullscreen без нижнего счетчика.
    @objc func openPosterFullScreen() {
        guard let film else {
            return
        }

        let controller = FullPicViewController()
        controller.film = film
        controller.showsGallery = false
        presentFullScreen(controller, from: posterImageView)
    }

    // Тап по кадру открывает fullscreen уже со всей коллекцией изображений.
    @objc func openGalleryImage(_ gesture: UITapGestureRecognizer) {
        guard
            let tappedImageView = gesture.view as? UIImageView,
            let film
        else {
            return
        }

        let controller = FullPicViewController()
        controller.film = film
        controller.showsGallery = true
        controller.initialIndex = tappedImageView.tag
        presentFullScreen(controller, from: tappedImageView)
    }

    // Сердце меняет liked-состояние текущего фильма.
    @objc func toggleLikeState() {
        guard let film else {
            return
        }

        let isLiked = model.toggleLikedState(forID: film.id)
        self.film = model.item(withID: film.id)
        updateLikeButtonAppearance(isLiked: isLiked)
    }

    // Полноразмерный экран открывается модально с кастомной анимацией от tapped view.
    func presentFullScreen(_ controller: FullPicViewController, from sourceView: UIView) {
        transitionSourceView = sourceView
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        present(navigationController, animated: true)
    }

    // Сердце показывает обычное или залитое состояние.
    func updateLikeButtonAppearance(isLiked: Bool) {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

extension DetailFilmViewController: UIViewControllerTransitioningDelegate {
    // Открытие fullscreen берет фрейм из нажатого элемента.
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let transitionSourceView else {
            return nil
        }

        transition.transitionProfile = .show
        transition.sourceFrame = transitionSourceView.superview?.convert(transitionSourceView.frame, to: nil) ?? transitionSourceView.frame
        return transition
    }

    // Закрытие fullscreen уходит вниз и не спорит с нашим swipe to dismiss.
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionProfile = .dismiss
        return transition
    }
}
