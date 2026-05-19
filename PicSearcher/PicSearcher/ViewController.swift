//
//  ViewController.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit

// Контроллер управляет галереей изображений, запускает поиск и открывает выбранную картинку на отдельном экране.
final class ViewController: UIViewController {
    // Сервис выполняет сетевой запрос к Pixabay и возвращает массив найденных изображений.
    private let pictureService = PictureService()

    // Коллекция показывает сетку картинок и служебную loading-ячейку.
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Системный refresh control перезапускает текущий поисковый запрос по жесту вниз.
    private let refreshControl = UIRefreshControl()

    // Системный поиск встроен в navigation bar и скрывается при прокрутке вниз.
    private let searchController = UISearchController(searchResultsController: nil)

    // Массив хранит найденные изображения и служит источником данных для коллекции.
    private var pictures: [Picture] = []

    // Лейбл пустого состояния показывает стартовую подсказку, ошибку или сообщение об отсутствии результатов.
    private let emptyStateLabel = UILabel()

    // Текст последнего успешного запроса нужен для повторной загрузки и пагинации.
    private var currentQuery = ""

    // Текущая страница нужна сервису для последовательной загрузки результатов поиска.
    private var currentPage = 1

    // Флаг показывает, загружается ли сейчас первая страница результатов.
    private var isInitialLoading = false

    // Флаг показывает, идет ли сейчас догрузка следующей страницы.
    private var isLoadingNextPage = false

    // Флаг показывает, что первая страница сейчас обновляется через pull-to-refresh.
    private var isRefreshing = false

    // Флаг показывает, есть ли еще страницы, которые можно запросить у API.
    private var hasMorePages = false

    // Размер страницы хранится отдельно, чтобы было проще сравнивать его с полученным ответом.
    private let pageSize = 20

    // Выбранная картинка временно хранится до перехода через storyboard segue.
    private var selectedPicture: Picture?

    // Идентификатор перехода нужен для открытия экрана деталей через storyboard.
    private let showImageDetailsSegueIdentifier = "ShowImageDetails"

    // Загрузка контроллера настраивает navigation bar, коллекцию и стартовое состояние экрана.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pic Searcher"
        setupView()
        setupLayout()
        setupNavigationBar()
        setupCollectionView()
        setupEmptyState()
        loadPopularPictures()
    }

    // Метод подготавливает переход и передает выбранную картинку на детальный экран.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showImageDetailsSegueIdentifier,
           let imageDetailsViewController = segue.destination as? ImageDetailsViewController {
            imageDetailsViewController.picture = selectedPicture
        }
    }

    // Настраивает и добавляет основные элементы на экран.
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
    }

    // Констрейнты.
    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // Navigation bar получает встроенный поиск со стандартным поведением очистки.
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск изображений"
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }

    // Коллекция получает delegate, dataSource и регистрацию кастомных ячеек.
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: LoadingCollectionViewCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    // Лейбл пустого состояния сначала показывает подсказку до первого поиска.
    private func setupEmptyState() {
        emptyStateLabel.text = "Загрузка изображений..."
        emptyStateLabel.font = .systemFont(ofSize: 17, weight: .medium)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = false
    }

    // Метод загружает первую страницу популярных изображений при открытии приложения.
    private func loadPopularPictures() {
        currentQuery = ""
        currentPage = 1
        isInitialLoading = true
        isLoadingNextPage = false
        isRefreshing = false
        hasMorePages = true
        pictures = []
        selectedPicture = nil
        emptyStateLabel.isHidden = false
        collectionView.reloadData()
        loadPictures()
    }

    // Метод запускает первую страницу для нового текста поиска.
    private func performSearch(with text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            eraseSearch()
            return
        }

        currentQuery = trimmedText
        currentPage = 1
        isInitialLoading = true
        isLoadingNextPage = false
        isRefreshing = false
        hasMorePages = true
        pictures = []
        selectedPicture = nil
        emptyStateLabel.isHidden = true
        collectionView.reloadData()
        loadPictures()
    }

    // Метод запрашивает изображения у сервиса и обновляет коллекцию после ответа.
    private func loadPictures() {
        pictureService.fetchPictures(query: currentQuery, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                switch result {
                case .success(let response):
                    self.applyLoadedPage(response)
                case .failure:
                    self.applyLoadingFailure()
                }
            }
        }
    }

    // Метод применяет успешный ответ API к текущему состоянию контроллера.
    private func applyLoadedPage(_ response: PictureResponse) {
        let loadedPictures = response.pictures

        if currentPage == 1 {
            pictures = loadedPictures
        } else {
            pictures.append(contentsOf: loadedPictures)
        }

        let loadedCount = currentPage * pageSize
        hasMorePages = !loadedPictures.isEmpty && loadedCount < response.totalHits
        isInitialLoading = false
        isLoadingNextPage = false
        isRefreshing = false
        refreshControl.endRefreshing()

        emptyStateLabel.text = pictures.isEmpty ? "Ничего не найдено." : emptyStateLabel.text
        emptyStateLabel.isHidden = !pictures.isEmpty
        collectionView.reloadData()
    }

    // Метод переводит экран в состояние ошибки загрузки.
    private func applyLoadingFailure() {
        if currentPage == 1 {
            pictures = []
            isInitialLoading = false
            hasMorePages = false
            emptyStateLabel.text = "Не удалось загрузить изображения."
            emptyStateLabel.isHidden = false
        } else {
            hasMorePages = false
        }

        isLoadingNextPage = false
        isRefreshing = false
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }

    // Метод запускает следующую страницу только один раз и только если API еще может вернуть данные.
    private func loadNextPageIfNeeded() {
        guard hasMorePages else {
            return
        }

        guard !isInitialLoading else {
            return
        }

        guard !isLoadingNextPage else {
            return
        }

        guard !isRefreshing else {
            return
        }

        isLoadingNextPage = true
        currentPage += 1
        collectionView.reloadData()
        loadPictures()
    }

    // Метод определяет, должна ли текущая ячейка быть служебной loading-ячейкой.
    private func shouldShowLoadingCell(at indexPath: IndexPath) -> Bool {
        if isInitialLoading {
            return true
        }

        return indexPath.item == pictures.count && (hasMorePages || isLoadingNextPage)
    }

    // Размер плитки считает ширину так, чтобы на экране помещалось три изображения в ряд.
    private func pictureItemSize() -> CGSize {
        let horizontalInsets = collectionView.contentInset.left + collectionView.contentInset.right
        let totalSpacing = 16.0
        let availableWidth = collectionView.bounds.width - horizontalInsets - totalSpacing
        let side = floor(availableWidth / 3)
        return CGSize(width: side, height: side)
    }

    // Метод очищает текущий запрос, скрывает результаты и возвращает экран в стартовое состояние.
    private func eraseSearch() {
        currentQuery = ""
        currentPage = 1
        isInitialLoading = false
        isLoadingNextPage = false
        isRefreshing = false
        hasMorePages = false
        pictures = []
        selectedPicture = nil
        searchController.searchBar.text = nil
        searchController.isActive = false
        emptyStateLabel.text = "Загрузка изображений..."
        refreshControl.endRefreshing()
        loadPopularPictures()
    }

    // Метод повторно загружает первую страницу текущего поискового запроса по жесту pull-to-refresh.
    @objc private func handleRefreshControl() {
        guard !currentQuery.isEmpty else {
            refreshControl.endRefreshing()
            return
        }

        pictures = []
        currentPage = 1
        hasMorePages = true
        isInitialLoading = true
        isLoadingNextPage = false
        isRefreshing = true
        emptyStateLabel.isHidden = true
        collectionView.reloadData()
        loadPictures()
    }
}

extension ViewController: UICollectionViewDataSource {
    // Возвращает количество элементов с учетом служебной loading-ячейки.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInitialLoading {
            return 1
        }

        return pictures.count + (hasMorePages || isLoadingNextPage ? 1 : 0)
    }

    // Создает loading-ячейку или обычную ячейку изображения в зависимости от индекса и состояния.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowLoadingCell(at: indexPath) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionViewCell.reuseIdentifier, for: indexPath) as? LoadingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let loadingText = isInitialLoading ? "Загрузка изображений..." : "Загрузка следующей страницы..."
            cell.configure(text: loadingText)
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: pictures[indexPath.item])
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    // Метод сохраняет выбранную модель и запускает переход на экран деталей через storyboard segue.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < pictures.count else {
            return
        }

        selectedPicture = pictures[indexPath.item]
        performSegue(withIdentifier: showImageDetailsSegueIdentifier, sender: self)
    }

    // Метод запускает догрузку только когда loading-ячейка реально появилась на экране.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if shouldShowLoadingCell(at: indexPath) {
            loadNextPageIfNeeded()
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    // Размер элемента зависит от того, обычная ли это плитка изображения или служебная loading-ячейка.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if shouldShowLoadingCell(at: indexPath) {
            let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
            return CGSize(width: width, height: 64)
        }

        return pictureItemSize()
    }
}

extension ViewController: UISearchBarDelegate {
    // Кнопка Search на клавиатуре запускает поиск и закрывает клавиатуру.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(with: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    // Метод сбрасывает результаты, когда пользователь очищает поле поиска штатным способом.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            eraseSearch()
        }
    }

    // Кнопка Cancel возвращает экран в стартовое состояние.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        eraseSearch()
    }
}
