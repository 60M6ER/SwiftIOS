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

    // Сервис пока нужен для проверки TMDB-запросов в консоли.
    private let tmdbService = TMDBService.shared

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

    // Источник данных для коллекции зависит от активного фильтра.
    private var displayedItems: [FilmObject] {
        isShowingLikedOnly ? likedTestArray : newTestArray
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sortAscending = true
        model.prepareRealmData()
        model.printRealmFilePath()
        tmdbService.debugRunAllRequests()
        model.sortFilms()
        likedTestArray = model.showLikedFilms()
        title = "Фильмы"
        configureView()
        configureNavigationBar()
        configureSearchController()
        configureCollectionView()
        configureLayout()
        updateEmptyState()
    }

    // После возврата на главный экран список подтягивает актуальное состояние модели.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncDisplayedData()
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
        model.search(with: text)
        likedTestArray = model.showLikedFilms()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        updateEmptyState()
    }

    // Синхронизация возвращает список к актуальным данным модели.
    func syncDisplayedData() {
        let currentSearchText = searchController.searchBar.text ?? ""

        if currentSearchText.isEmpty {
            model.sortFilms()
        } else {
            model.search(with: currentSearchText)
        }

        likedTestArray = model.showLikedFilms()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        updateEmptyState()
    }

    // Пустое состояние зависит от текущего источника данных.
    func updateEmptyState() {
        let hasFilms = !displayedItems.isEmpty
        emptyStateLabel.isHidden = hasFilms
        collectionView.isHidden = !hasFilms
    }

    // Внешний вид сердца меняется вместе с состоянием фильтра.
    func updateLikedFilterButtonAppearance() {
        likedFilterButton.image = UIImage(systemName: isShowingLikedOnly ? "heart.fill" : "heart")
    }

    // Сброс возвращает поиск и сортировку к начальному состоянию.
    @objc func handleRefresh() {
        searchController.searchBar.text = nil
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        sortAscending = true
        syncDisplayedData()
    }

    // Сердце включает и выключает показ только лайкнутых фильмов.
    @objc func toggleLikedFilter() {
        isShowingLikedOnly.toggle()
        likedTestArray = model.showLikedFilms()
        updateLikedFilterButtonAppearance()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        updateEmptyState()
    }

    // Кнопка сортировки только меняет направление и пересобирает список.
    @objc func toggleSorting() {
        sortAscending.toggle()
        syncDisplayedData()
    }
}

extension MainViewController: UICollectionViewDataSource {
    // Количество ячеек зависит от текущего фильтра.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedItems.count
    }

    // Ячейка получает объект фильма и обновляет сердце через модель.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilmCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? FilmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = displayedItems[indexPath.item]
        cell.configure(with: item)
        cell.onLikeStateChanged = { [weak self] _, _ in
            guard let self else {
                return
            }

            likedTestArray = self.model.showLikedFilms()
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки держит текущую сетку в две колонки.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalPadding = (Constants.horizontalInset * 2) + Constants.interitemSpacing
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: cellWidth * 1.82)
    }

    // Переход на detail идет через передачу готового объекта фильма.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let film = displayedItems[indexPath.item]
        let controller = DetailFilmViewController()
        controller.film = film
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MainViewController: UISearchResultsUpdating {
    // Системный поиск обновляет список по мере ввода.
    func updateSearchResults(for searchController: UISearchController) {
        applySearch(text: searchController.searchBar.text ?? "")
    }
}

extension MainViewController: UISearchBarDelegate {
    // Ввод в строке поиска сразу обновляет список.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch(text: searchText)
    }

    // Кнопка поиска закрывает клавиатуру и оставляет текущий результат.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        applySearch(text: searchBar.text ?? "")
    }

    // Cancel возвращает список к текущему рабочему состоянию модели.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        syncDisplayedData()
    }
}
