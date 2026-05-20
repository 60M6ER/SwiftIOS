//
//  FullPicViewController.swift
//  MovieSearcher
//
//  Created by Kirill Timanovsky on 29.07.2021.
//

import UIKit

final class FullPicViewController: UIViewController {
    // Одна картинка используется для открытия постера без коллекции.
    var image: UIImage?

    // Коллекция картинок нужна для сценария со скроллингом кадров.
    var images: [UIImage] = []

    // Стартовый индекс позволяет открыть fullscreen сразу на выбранном кадре.
    var initialIndex = 0

    // Коллекция выступает основой полноэкранной карусели.
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Нижняя полупрозрачная панель показывает номер текущей картинки.
    private let bottomOverlayView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))

    // Счетчик нужен только когда fullscreen открыт не на одиночном постере, а на коллекции.
    private let counterLabel = UILabel()

    // Флаг запоминает, скрыты ли сейчас служебные панели.
    private var areChromeViewsHidden = false

    // Общий массив нужен, чтобы одинаково работать и с одной картинкой, и с коллекцией.
    private var displayImages: [UIImage] {
        if images.isEmpty {
            return image.map { [$0] } ?? []
        }

        return images
    }

    // Нижний счетчик нужен только в сценарии со списком картинок.
    private var shouldShowCounter: Bool {
        !images.isEmpty && displayImages.count > 1
    }

    // При загрузке экран собирает интерфейс и готовит стартовое состояние.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar()
        configureLayout()
        updateCounter(for: initialIndex)
    }

    // Перед показом экран переводит навбар в прозрачный overlay-режим.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyOverlayNavigationBarAppearance()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // После расчета размеров коллекции экран обновляет размер fullscreen-страниц.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
        }
    }

    // После появления экран прокручивается к стартовой картинке, если открыта коллекция.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToInitialImageIfNeeded()
    }
}

private extension FullPicViewController {
    // Метод настраивает fullscreen-коллекцию, нижний счетчик и базовый фон экрана.
    func configureView() {
        view.backgroundColor = .black

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomOverlayView.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.translatesAutoresizingMaskIntoConstraints = false

        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ZoomableImageCollectionViewCell.self, forCellWithReuseIdentifier: ZoomableImageCollectionViewCell.reuseIdentifier)

        counterLabel.font = .systemFont(ofSize: 15, weight: .medium)
        counterLabel.textColor = .white
        counterLabel.textAlignment = .center

        bottomOverlayView.alpha = shouldShowCounter ? 1 : 0

        view.addSubview(collectionView)
        view.addSubview(bottomOverlayView)
        bottomOverlayView.contentView.addSubview(counterLabel)
    }

    // Navigation bar здесь нужен только как верхняя системная панель без заголовка.
    func configureNavigationBar() {
        title = nil
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeScreen)
        )
    }

    // Прозрачный nav bar висит поверх картинки и не должен сдвигать контент.
    func applyOverlayNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
    }

    // Констрейнты растягивают карусель на весь экран и прижимают счетчик вниз.
    func configureLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bottomOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            counterLabel.topAnchor.constraint(equalTo: bottomOverlayView.contentView.topAnchor, constant: 10),
            counterLabel.leadingAnchor.constraint(equalTo: bottomOverlayView.contentView.leadingAnchor, constant: 16),
            counterLabel.trailingAnchor.constraint(equalTo: bottomOverlayView.contentView.trailingAnchor, constant: -16),
            counterLabel.bottomAnchor.constraint(equalTo: bottomOverlayView.contentView.bottomAnchor, constant: -10)
        ])
    }

    // Метод один раз прокручивает карусель к картинке, по которой пришли на экран.
    func scrollToInitialImageIfNeeded() {
        guard shouldShowCounter, displayImages.indices.contains(initialIndex) else {
            return
        }

        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: initialIndex, section: 0), at: .centeredHorizontally, animated: false)
        updateCounter(for: initialIndex)
    }

    // Метод обновляет подпись вида "2 из 5" на нижней панели.
    func updateCounter(for index: Int) {
        guard shouldShowCounter else {
            counterLabel.text = nil
            return
        }

        counterLabel.text = "\(index + 1) из \(displayImages.count)"
    }

    // Одинарный тап скрывает и возвращает панели в классическом fullscreen-сценарии.
    func toggleChromeViews() {
        areChromeViewsHidden.toggle()
        navigationController?.setNavigationBarHidden(areChromeViewsHidden, animated: true)

        guard shouldShowCounter else {
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.bottomOverlayView.alpha = self.areChromeViewsHidden ? 0 : 1
        }
    }

    // Кнопка закрытия завершает модальный просмотр и возвращает на экран деталей.
    @objc func closeScreen() {
        dismiss(animated: true)
    }
}

extension FullPicViewController: UICollectionViewDataSource {
    // Коллекция показывает либо один постер, либо всю переданную галерею.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayImages.count
    }

    // Каждая страница получает свою картинку и обратные события от жестов.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ZoomableImageCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ZoomableImageCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: displayImages[indexPath.item])
        cell.onSingleTap = { [weak self] in
            self?.toggleChromeViews()
        }
        cell.onZoomStateChange = { [weak self] isZoomed in
            self?.collectionView.isScrollEnabled = !isZoomed
        }
        return cell
    }
}

extension FullPicViewController: UICollectionViewDelegateFlowLayout {
    // После ручного листания обновляется счетчик текущей картинки.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = max(scrollView.bounds.width, 1)
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        updateCounter(for: page)
    }

    // После программной прокрутки тоже обновляется счетчик.
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth = max(scrollView.bounds.width, 1)
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        updateCounter(for: page)
    }
}

private final class ZoomableImageCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    // Идентификатор нужен только для внутренней fullscreen-коллекции.
    static let reuseIdentifier = "ZoomableImageCollectionViewCell"

    // Одинарный тап пробрасывается наружу, чтобы fullscreen мог скрыть панели.
    var onSingleTap: (() -> Void)?

    // Изменение состояния зума нужно родителю, чтобы решать, можно ли листать коллекцию.
    var onZoomStateChange: ((Bool) -> Void)?

    // Внутренний scroll view отвечает за zoom и pan у конкретной картинки.
    private let scrollView = UIScrollView()

    // Image view показывает текущее изображение на странице fullscreen-режима.
    private let imageView = UIImageView()

    // Пан-жест нужен для привычного закрытия свайпом сверху вниз.
    private lazy var dismissPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configureLayout()
    }

    // Перед повторным использованием ячейка сбрасывает zoom и временные обработчики.
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.setZoomScale(1, animated: false)
        scrollView.contentOffset = .zero
        scrollView.isScrollEnabled = false
        imageView.image = nil
        onSingleTap = nil
        onZoomStateChange = nil
    }

    // Метод кладет новое изображение на fullscreen-страницу.
    func configure(with image: UIImage) {
        imageView.image = image
        onZoomStateChange?(false)
    }

    // Общая настройка собирает scroll view, image view и жесты для картинки.
    private func configureView() {
        contentView.backgroundColor = .black

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)

        dismissPanGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(dismissPanGestureRecognizer)

        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }

    // Констрейнты растягивают zoomable-контент на весь размер страницы.
    private func configureLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    // Одинарный тап переключает видимость системных панелей.
    @objc private func handleSingleTap() {
        onSingleTap?()
    }

    // Двойной тап циклично меняет масштаб между 1x, 2x и 4x.
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let currentScale = scrollView.zoomScale
        let nextScale: CGFloat

        if currentScale < 2 {
            nextScale = 2
        } else if currentScale < 4 {
            nextScale = 4
        } else {
            nextScale = 1
        }

        if nextScale == 1 {
            scrollView.setZoomScale(1, animated: true)
            return
        }

        let tapPoint = gesture.location(in: imageView)
        let zoomRect = zoomRect(for: nextScale, centeredAt: tapPoint)
        scrollView.zoom(to: zoomRect, animated: true)
    }

    // Свайп вниз закрывает fullscreen, если картинка сейчас не увеличена.
    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == scrollView.minimumZoomScale else {
            return
        }

        let translation = gesture.translation(in: contentView)
        let velocity = gesture.velocity(in: contentView)

        if gesture.state == .ended,
           translation.y > 120,
           abs(translation.y) > abs(translation.x),
           velocity.y > 300 {
            parentViewController?.dismiss(animated: true)
        }
    }

    // Метод считает область, которую надо приблизить вокруг точки двойного тапа.
    private func zoomRect(for scale: CGFloat, centeredAt point: CGPoint) -> CGRect {
        let width = scrollView.bounds.width / scale
        let height = scrollView.bounds.height / scale
        let originX = point.x - (width / 2)
        let originY = point.y - (height / 2)
        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    // После zoom страница решает, можно ли скроллить коллекцию и саму картинку.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let isZoomed = scrollView.zoomScale > scrollView.minimumZoomScale
        scrollView.isScrollEnabled = isZoomed
        onZoomStateChange?(isZoomed)
    }
}

extension ZoomableImageCollectionViewCell: UIGestureRecognizerDelegate {
    // Пан для закрытия не должен мешать обычному горизонтальному листанию коллекции.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        let velocity = panGestureRecognizer.velocity(in: contentView)
        return abs(velocity.y) > abs(velocity.x) && velocity.y > 0
    }
}

private extension UIView {
    // Хелпер помогает дочерней view добраться до своего контроллера без лишних связей.
    var parentViewController: UIViewController? {
        sequence(first: next, next: { $0?.next }).first { $0 is UIViewController } as? UIViewController
    }
}
