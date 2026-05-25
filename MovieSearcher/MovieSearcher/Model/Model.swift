//
//  Model.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import Foundation
import RealmSwift

// Флаг управляет направлением сортировки на главном экране.
var sortAscending = true

final class Model {
    private enum DataSource {
        case popular
        case favorites
        case searchPopular
        case searchFavorites
    }

    // Сервис загружает страницы TMDB и передает модели уже декодированные ответы.
    private let tmdbService = TMDBService.shared

    // Realm-результат нужен как источник локальной пагинации избранного.
    private var favoriteResults: Results<FilmObject>?

    // Текущий источник определяет, откуда брать следующую страницу.
    private var currentSource: DataSource = .popular

    // Единственный рабочий массив уже готов для collection view.
    private(set) var displayedFilms: [FilmObject] = []

    // Последний поисковый текст нужен, чтобы не терять фильтр после обновления массива.
    private var currentSearchText = ""

    // Номер последней загруженной страницы нужен для догрузки следующих результатов.
    private(set) var currentPage = 0

    // Общее число страниц приходит из TMDB и ограничивает пагинацию.
    private(set) var totalPages = 0

    // Общее количество результатов полезно для отладки и будущего UI.
    private(set) var totalResults = 0

    // Флаг защищает от параллельной догрузки одной и той же страницы.
    private(set) var isLoadingPage = false

    // Признак позволяет экрану понять, можно ли просить следующую страницу.
    var canLoadNextPage: Bool {
        !isLoadingPage && currentPage < totalPages
    }

    // Сортировка доступна только для локального списка избранного.
    var isSortingAvailable: Bool {
        currentSource == .favorites || currentSource == .searchFavorites
    }

    // Размер страницы для локального избранного держим фиксированным и простым.
    private let favoritesPageSize = 20

    // Адрес realm-файла удобно смотреть в консоли при отладке.
    func printRealmFilePath() {
        let realm = makeRealm()

        guard let fileURL = realm.configuration.fileURL else {
            return
        }

        print(fileURL.path)
    }

    // Метод оставлен как точка входа для инициализации локального состояния.
    func prepareRealmData() {
        applyFilters()
    }

    // Главный экран возвращается к popular и сбрасывает его пагинацию на первую страницу.
    func showPopular(completion: @escaping () -> Void) {
        currentSource = .popular
        currentSearchText = ""
        loadPopularMovies(page: 1, completion: completion)
    }

    // Фильтр избранного переключает источник на локальную базу и грузит первую страницу.
    func showFavorites(completion: @escaping () -> Void) {
        currentSource = .favorites
        currentSearchText = ""
        refreshFavorites()
        completion()
    }

    // Поиск становится отдельным источником и выбирает TMDB или Realm по активному режиму.
    func search(with text: String, inFavorites: Bool, completion: @escaping () -> Void) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentSearchText = trimmedText

        guard !trimmedText.isEmpty else {
            if inFavorites {
                showFavorites(completion: completion)
            } else {
                showPopular(completion: completion)
            }
            return
        }

        if inFavorites {
            currentSource = .searchFavorites
            refreshFavorites()
            completion()
        } else {
            currentSource = .searchPopular
            loadSearchPopularMovies(query: trimmedText, page: 1, completion: completion)
        }
    }

    // Главный экран берет популярные фильмы из модели, а не из Realm.
    func loadPopularMovies(page: Int = 1, completion: @escaping () -> Void) {
        guard !isLoadingPage else {
            completion()
            return
        }

        if page > 1 {
            guard canLoadNextPage else {
                completion()
                return
            }
        }

        isLoadingPage = true

        tmdbService.fetchPopularMovieList(page: page) { [weak self] result in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                switch result {
                case let .success(moviePage):
                    self.currentPage = moviePage.page
                    self.totalPages = moviePage.totalPages
                    self.totalResults = moviePage.totalResults

                    self.mergeLoadedFilms(moviePage.films, replacingCurrentPage: page == 1)

                    self.applyLikedStateFromRealm()
                    self.applyFilters()
                    self.isLoadingPage = false
                    completion()
                case let .failure(error):
                    print("TMDB popular loading error: \(error.localizedDescription)")
                    self.isLoadingPage = false
                    completion()
                }
            }
        }
    }

    // Следующая страница догружается только если TMDB еще не исчерпан.
    func loadNextPage(completion: @escaping (_ didLoadNewPage: Bool) -> Void) {
        switch currentSource {
        case .popular:
            guard canLoadNextPage else {
                completion(false)
                return
            }

            loadPopularMovies(page: currentPage + 1) {
                completion(true)
            }
        case .searchPopular:
            guard canLoadNextPage, !currentSearchText.isEmpty else {
                completion(false)
                return
            }

            loadSearchPopularMovies(query: currentSearchText, page: currentPage + 1) {
                completion(true)
            }
        case .favorites:
            guard canLoadNextPage else {
                completion(false)
                return
            }

            loadNextFavoritesPage()
            completion(true)
        case .searchFavorites:
            guard canLoadNextPage else {
                completion(false)
                return
            }

            loadNextFavoritesPage()
            completion(true)
        }
    }

    // Переключение лайка меняет объект в памяти и синхронизирует локальную базу.
    @discardableResult
    func toggleLikedState(for film: FilmObject) -> Bool {
        let newState = !film.isLiked
        film.isLiked = newState
        updateStoredLike(for: film, isLiked: newState)

        if (currentSource == .favorites || currentSource == .searchFavorites) && !newState {
            refreshFavorites()
        }

        applyFilters()
        return newState
    }

    // Сортировка просто пересобирает уже загруженный in-memory список.
    func sortFilms() {
        applyFilters()
    }
}

private extension Model {
    // Realm создается на том потоке, на котором он используется.
    func makeRealm() -> Realm {
        try! Realm()
    }

    // Следующие страницы дописываются по id без дублирования уже загруженных фильмов.
    func mergeLoadedFilms(_ newFilms: [FilmObject], replacingCurrentPage: Bool) {
        if replacingCurrentPage {
            displayedFilms = newFilms
            return
        }

        let existingIDs = Set(displayedFilms.map(\.id))
        let uniqueFilms = newFilms.filter { !existingIDs.contains($0.id) }
        displayedFilms.append(contentsOf: uniqueFilms)
    }

    // Поиск в TMDB повторяет логику popular, но использует отдельный источник и query.
    func loadSearchPopularMovies(query: String, page: Int = 1, completion: @escaping () -> Void) {
        guard !isLoadingPage else {
            completion()
            return
        }

        if page > 1 {
            guard canLoadNextPage else {
                completion()
                return
            }
        }

        isLoadingPage = true

        tmdbService.fetchSearchMovieList(query: query, page: page) { [weak self] result in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                switch result {
                case let .success(moviePage):
                    self.currentPage = moviePage.page
                    self.totalPages = moviePage.totalPages
                    self.totalResults = moviePage.totalResults

                    self.mergeLoadedFilms(moviePage.films, replacingCurrentPage: page == 1)

                    self.applyLikedStateFromRealm()
                    self.applyFilters()
                    self.isLoadingPage = false
                    completion()
                case let .failure(error):
                    print("TMDB search loading error: \(error.localizedDescription)")
                    self.isLoadingPage = false
                    completion()
                }
            }
        }
    }

    // Realm подготавливает запрос liked-фильмов как источник локальной пагинации.
    func prepareFavoritePagination() {
        let realm = makeRealm()
        let likedFilms = realm.objects(FilmObject.self)
            .where { $0.isLiked == true }
        var results = likedFilms

        if !currentSearchText.isEmpty {
            let searchText = currentSearchText.lowercased()
            results = results.where {
                $0.searchTitle.contains(searchText)
            }
        }

        results = results.sorted(byKeyPath: "rating", ascending: sortAscending)

        favoriteResults = results
        totalResults = results.count
        totalPages = totalResults == 0 ? 0 : Int(ceil(Double(totalResults) / Double(favoritesPageSize)))
        currentPage = 0

        displayedFilms.removeAll()
    }

    // Следующая локальная страница берется из Realm по границам индексов.
    func loadNextFavoritesPage() {
        guard let favoriteResults, currentPage < totalPages else {
            return
        }

        let startIndex = currentPage * favoritesPageSize
        let endIndex = min(startIndex + favoritesPageSize, totalResults)
        let pageFilms = favoriteResults[startIndex..<endIndex].map(cloneFilm)

        displayedFilms.append(contentsOf: pageFilms)
        currentPage += 1
        applyFilters()
    }

    // Избранное можно заново открыть с первой страницы без восстановления прошлой отрисовки.
    func refreshFavorites() {
        prepareFavoritePagination()

        guard totalPages > 0 else {
            applyFilters()
            return
        }

        loadNextFavoritesPage()
    }

    // Realm хранит локальный кэш фильмов, поэтому лайк читается из сохраненного объекта.
    func applyLikedStateFromRealm() {
        let realm = makeRealm()
        let storedFilms = realm.objects(FilmObject.self)
        let storedFilmsByID = Dictionary(uniqueKeysWithValues: storedFilms.map { ($0.id, $0) })

        displayedFilms.forEach { film in
            film.isLiked = storedFilmsByID[film.id]?.isLiked ?? false
        }
    }

    // Локальная база хранит фильм для офлайна и обновляет его текущее liked-состояние.
    func updateStoredLike(for film: FilmObject, isLiked: Bool) {
        let realm = makeRealm()

        do {
            try realm.write {
                let storedFilm = FilmObject(
                    id: film.id,
                    title: film.title,
                    originalTitle: film.originalTitle,
                    year: film.year,
                    rating: film.rating,
                    posterImageName: film.posterImageName,
                    overview: film.overview,
                    galleryImageNames: Array(film.galleryImageNames),
                    isLiked: isLiked
                )
                realm.add(storedFilm, update: .modified)
            }
        } catch {
            print("Realm write error: \(error.localizedDescription)")
        }
    }

    // Копия нужна, чтобы список избранного не держал managed Realm-объекты напрямую.
    func cloneFilm(_ film: FilmObject) -> FilmObject {
        FilmObject(
            id: film.id,
            title: film.title,
            originalTitle: film.originalTitle,
            year: film.year,
            rating: film.rating,
            posterImageName: film.posterImageName,
            overview: film.overview,
            galleryImageNames: Array(film.galleryImageNames),
            isLiked: film.isLiked
        )
    }

    // Для избранного сортировка работает поверх уже загруженной локальной страницы.
    func applyFilters() {
        if isSortingAvailable {
            displayedFilms = displayedFilms.sorted { leftFilm, rightFilm in
                if sortAscending {
                    return leftFilm.rating < rightFilm.rating
                }

                return leftFilm.rating > rightFilm.rating
            }
        }
    }
}
