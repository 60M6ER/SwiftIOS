//
//  ViewController.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import UIKit
import SafariServices

// Контроллер управляет таблицей новостей, получает данные от сервиса и открывает статью в Safari.
final class ViewController: UIViewController {
    // Сервис выполняет сетевой запрос к News API и возвращает массив статей.
    private let newsService = NewsService()

    // Таблица показывает список новостей
    private let tableView = UITableView(frame: .zero, style: .plain)

    // Массив хранит полученные из API новости и служит источником данных для таблицы.
    private var articles: [NewsArticle] = []

    // Лейбл пустого состояния показывает сообщение, если список новостей не удалось получить.
    private let emptyStateLabel = UILabel()

    // Текущая страница нужна сервису для последовательной загрузки новостей.
    private var currentPage = 1

    // Флаг показывает, загружается ли самая первая страница новостей.
    private var isInitialLoading = true

    // Флаг показывает, идет ли сейчас догрузка следующей страницы.
    private var isLoadingNextPage = false

    // Флаг показывает, есть ли еще страницы, которые можно запросить у API.
    private var hasMorePages = true

    // Размер страницы хранится отдельно, чтобы было проще сравнивать его с полученным ответом.
    private let pageSize = 20

    // Загрузка контроллера настраивает таблицу и запускает первый сетевой запрос.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        setupView()
        setupLayout()
        setupTableView()
        setupEmptyState()
        loadNews()
    }

    // Настраивает и добавляет основные элементы на экран.
    private func setupView() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
    }

    // Констрейнты
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // Таблица получает delegate, dataSource и регистрацию кастомной ячейки.
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 190
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.reuseIdentifier)
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
    }

    // Лейбл пустого состояния сначала скрыт и становится видимым только при ошибке или пустом ответе.
    private func setupEmptyState() {
        emptyStateLabel.text = "Новости не найдены."
        emptyStateLabel.font = .systemFont(ofSize: 17, weight: .medium)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
    }

    // Метод запрашивает новости у сервиса и обновляет таблицу после ответа.
    private func loadNews() {
        newsService.fetchNews(page: currentPage) { [weak self] result in
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
    private func applyLoadedPage(_ response: NewsResponse) {
        let loadedArticles = response.articles

        if currentPage == 1 {
            articles = loadedArticles
        } else {
            articles.append(contentsOf: loadedArticles)
        }

        let loadedCount = currentPage * pageSize
        hasMorePages = !loadedArticles.isEmpty && loadedCount < response.totalResults
        isInitialLoading = false
        isLoadingNextPage = false
        emptyStateLabel.isHidden = !articles.isEmpty
        emptyStateLabel.text = "Новости не найдены."
        tableView.reloadData()
    }

    // Метод переводит экран в состояние ошибки загрузки
    private func applyLoadingFailure() {
        if currentPage == 1 {
            articles = []
            isInitialLoading = false
            hasMorePages = false
            emptyStateLabel.text = "Не удалось загрузить новости."
            emptyStateLabel.isHidden = false
        } else {
            hasMorePages = false
        }

        isLoadingNextPage = false
        tableView.reloadData()
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

        isLoadingNextPage = true
        currentPage += 1
        tableView.reloadData()
        loadNews()
    }

    // Метод открывает оригинальную статью в SFSafariViewController внутри приложения.
    private func openArticle(at indexPath: IndexPath) {
        let article = articles[indexPath.row]

        guard let url = article.articleURL else {
            emptyStateLabel.text = "Ссылка на статью недоступна."
            emptyStateLabel.isHidden = false
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    // Возвращает количество строк с учетом служебной loading-ячейки.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isInitialLoading {
            return 1
        }

        return articles.count + (hasMorePages || isLoadingNextPage ? 1 : 0)
    }

    // Создает loading-ячейку или обычную новостную ячейку в зависимости от индекса и состояния.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowLoadingCell(at: indexPath) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.reuseIdentifier, for: indexPath) as? LoadingTableViewCell else {
                return UITableViewCell()
            }

            let loadingText = isInitialLoading ? "Загрузка новостей..." : "Загрузка следующей страницы..."
            cell.configure(text: loadingText)
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: articles[indexPath.row])
        return cell
    }

    // Метод определяет, должна ли текущая строка быть служебной loading-ячейкой.
    private func shouldShowLoadingCell(at indexPath: IndexPath) -> Bool {
        if isInitialLoading {
            return true
        }

        return indexPath.row >= articles.count
    }
}

extension ViewController: UITableViewDelegate {
    // Обрабатывает нажатие на строку и открывает источник новости во встроенном браузере.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row < articles.count else {
            return
        }

        openArticle(at: indexPath)
    }

    // Метод запускает догрузку только после того, как loading-ячейка реально появилась на экране.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard shouldShowLoadingCell(at: indexPath) else {
            return
        }

        guard !isInitialLoading else {
            return
        }

        loadNextPageIfNeeded()
    }
}
