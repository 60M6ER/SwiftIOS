//
//  ViewController.swift
//  MovieSearcher
//
//  Created by Kirill Timanovsky on 29.07.2021.
//

import UIKit

final class MainViewController: UIViewController {
    private enum Constants {
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 12
        static let interitemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 20
        static let paginationThreshold = 6
    }

    // Системный поиск живет прямо в navigation bar.
    private let searchController = UISearchController(searchResultsController: nil)

    // Коллекция показывает рабочий список фильмов.
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.interitemSpacing
        layout.minimumLineSpacing = Constants.lineSpacing
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Пустое состояние появляется, когда по текущему фильтру ничего не найдено.
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Ничего не найдено"
        label.isHidden = true
        return label
    }()

    // Общая модель держит рабочий массив главного списка.
    private let model = Model()

    // Флаг переключает обычный список и показ только лайкнутых фильмов.
    private var isShowingLikedOnly = false

    // Кнопка сердца управляет фильтром по избранному.
    private lazy var likedFilterButton = UIBarButtonItem(
        image: UIImage(systemName: "heart"),
        style: .plain,
        target: self,
        action: #selector(toggleLikedFilter)
    )

    // Кнопка сортировки переключает порядок списка.
    private lazy var sortButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.up.arrow.down"),
        style: .plain,
        target: self,
        action: #selector(toggleSorting)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        sortAscending = true
        model.prepareRealmData()
        model.printRealmFilePath()
        model.sortFilms()
        configureView()
        configureNavigationBar()
        configureSearchController()
        configureCollectionView()
        configureLayout()
        updateEmptyState()
        reloadCurrentMode()
    }

    // После возврата на главный экран список подтягивает актуальное состояние модели.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCurrentMode()
    }
}

private extension MainViewController {
    // Экран собирает только главные элементы списка.
    func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
    }

    // В navigation bar живут сортировка, сброс и фильтр по лайкам.
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationItem.rightBarButtonItems = [
            sortButton,
            UIBarButtonItem(
                barButtonSystemItem: .refresh,
                target: self,
                action: #selector(handleRefresh)
            ),
            likedFilterButton
        ]

        updateLikedFilterButtonAppearance()
        updateSortButtonVisibility()
        updateNavigationTitle()
    }

    // Поиск работает через системный search controller.
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Найди свой фильм"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // Коллекция регистрирует ячейку и готовится к вертикальному скроллу.
    func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.accessibilityIdentifier = "main.collection"
        collectionView.contentInset = UIEdgeInsets(
            top: Constants.topInset,
            left: Constants.horizontalInset,
            bottom: 24,
            right: Constants.horizontalInset
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            UINib(nibName: FilmCollectionViewCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: FilmCollectionViewCell.reuseIdentifier
        )
    }

    // Лейаут растягивает список на весь экран.
    func configureLayout() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    // Поиск обновляет рабочий массив модели и перерисовывает список.
    func applySearch(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let updateUI = { [weak self] in
            guard let self else {
                return
            }

            self.updateNavigationTitle()
            self.updateSortButtonVisibility()
            self.syncDisplayedData()
            self.scrollCollectionToTop()
        }

        model.search(with: trimmedText, inFavorites: isShowingLikedOnly, completion: updateUI)
    }

    // Синхронизация только перерисовывает уже готовые данные модели.
    func syncDisplayedData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        updateEmptyState()
    }

    // Текущий режим определяется фильтром избранного и текстом поиска.
    func reloadCurrentMode(scrollToTop: Bool = false) {
        let currentSearchText = searchController.searchBar.text ?? ""

        let updateUI = { [weak self] in
            guard let self else {
                return
            }

            self.updateNavigationTitle()
            self.updateSortButtonVisibility()
            self.syncDisplayedData()

            if scrollToTop {
                self.scrollCollectionToTop()
            }
        }

        if currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if isShowingLikedOnly {
                model.showFavorites(completion: updateUI)
            } else {
                model.showPopular(completion: updateUI)
            }
        } else {
            model.search(with: currentSearchText, inFavorites: isShowingLikedOnly, completion: updateUI)
        }
    }

    // Пустое состояние зависит от текущего источника данных.
    func updateEmptyState() {
        let hasFilms = !model.displayedFilms.isEmpty
        emptyStateLabel.isHidden = hasFilms
        collectionView.isHidden = !hasFilms
    }

    // Полный refresh должен одинаково возвращать список в начало.
    func scrollCollectionToTop() {
        let topOffset = CGPoint(
            x: -collectionView.adjustedContentInset.left,
            y: -collectionView.adjustedContentInset.top
        )
        collectionView.setContentOffset(topOffset, animated: false)
    }

    // Внешний вид сердца меняется вместе с состоянием фильтра.
    func updateLikedFilterButtonAppearance() {
        likedFilterButton.image = UIImage(systemName: isShowingLikedOnly ? "heart.fill" : "heart")
    }

    // Заголовок отражает текущий режим списка.
    func updateNavigationTitle() {
        if isShowingLikedOnly {
            title = "Моё"
        } else {
            title = "Популярное"
        }
    }

    // Сортировка показывается только в режиме избранного.
    func updateSortButtonVisibility() {
        var items = navigationItem.rightBarButtonItems ?? []

        if model.isSortingAvailable {
            if !items.contains(where: { $0 === sortButton }) {
                items.insert(sortButton, at: 0)
            }
        } else {
            items.removeAll { $0 === sortButton }
        }

        navigationItem.rightBarButtonItems = items
    }

    // Сброс возвращает поиск и сортировку к начальному состоянию.
    @objc func handleRefresh() {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        reloadCurrentMode(scrollToTop: true)
    }

    // Сердце включает и выключает показ только лайкнутых фильмов.
    @objc func toggleLikedFilter() {
        isShowingLikedOnly.toggle()
        updateLikedFilterButtonAppearance()
        reloadCurrentMode()
    }

    // Кнопка сортировки только меняет направление и пересобирает список.
    @objc func toggleSorting() {
        guard model.isSortingAvailable else {
            return
        }

        sortAscending.toggle()
        handleRefresh()
    }

    // Догрузка работает для любого текущего источника, если у него есть еще страницы.
    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        let triggerIndex = max(model.displayedFilms.count - Constants.paginationThreshold, 0)

        guard indexPath.item >= triggerIndex else {
            return
        }

        model.loadNextPage { [weak self] didLoadNewPage in
            guard let self, didLoadNewPage else {
                return
            }

            self.syncDisplayedData()
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    // Количество ячеек зависит от текущего фильтра.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.displayedFilms.count
    }

    // Ячейка получает объект фильма и обновляет сердце через модель.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilmCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? FilmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = model.displayedFilms[indexPath.item]
        cell.configure(with: item)
        cell.onLikeStateChanged = { [weak self] _, _ in
            guard let self else {
                return
            }

            self.syncDisplayedData()
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки держит текущую сетку в две колонки.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Баг с размером ячейки. Осталась старая логика по высоте. изначально исправил через констрейнт в XIB. Но позже обратил внимание на ворнинги. и понял что высотала осталась с неправильным соотношением из первых версий. получается конфилктовал Внешниц размер и размер на констрентах внутри XIB.
//        let totalHorizontalPadding = (Constants.horizontalInset * 2) + Constants.interitemSpacing
//        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
//        let cellWidth = floor(availableWidth / 2)
//        return CGSize(width: cellWidth, height: cellWidth * 1.82)
        let isLandscape = view.bounds.width > view.bounds.height
        let columns: CGFloat = isLandscape ? 4 : 2
        
        let horizontalInsets = collectionView.contentInset.left + collectionView.contentInset.right
        let totalSpacing = Constants.interitemSpacing * (columns - 1)
        let availableWidth = collectionView.bounds.width - horizontalInsets - totalSpacing
        let cellWidth = floor(availableWidth / columns)
        
        let posterHeight = cellWidth * 1.5 // Ориентир на уже заданные пропорции в XIB и нормально выглядищие на экране
        let infoHeight: CGFloat = 80 // Тоже уже так сложилось в XIB
        let cellHeight: CGFloat = posterHeight + infoHeight
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // Появление последних ячеек запускает догрузку следующей страницы.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadNextPageIfNeeded(for: indexPath)
    }

    // Переход на detail идет через передачу готового объекта фильма.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let film = model.displayedFilms[indexPath.item]
        let controller = DetailFilmViewController()
        controller.film = film
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MainViewController: UISearchResultsUpdating {
    // Автоматический запуск поиска отключен, чтобы поиск шел только по подтверждению ввода.
    func updateSearchResults(for searchController: UISearchController) {
        updateEmptyState()
    }
}

extension MainViewController: UISearchBarDelegate {
    // Ввод сам по себе ничего не запускает, пока пользователь не подтвердит поиск.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateEmptyState()
    }

    // Кнопка поиска закрывает клавиатуру и оставляет текущий результат.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        applySearch(text: searchBar.text ?? "")
    }

    // Cancel возвращает список к текущему рабочему состоянию модели.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        reloadCurrentMode()
    }
}
