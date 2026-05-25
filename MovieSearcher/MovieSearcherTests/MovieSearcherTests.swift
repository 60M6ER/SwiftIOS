//
//  MovieSearcherTests.swift
//  MovieSearcherTests
//
//  Created by Борис Ларионов on 23.05.2026.
//

import XCTest
@testable import MovieSearcher

final class MovieSearcherTests: XCTestCase {

    func testMakePosterURLReturnsCorrectURL() {
        let service = TMDBService.shared

        let url = service.makePosterURL(path: "/abc123.jpg", size: "w500")

        XCTAssertEqual(
            url?.absoluteString,
            "https://image.tmdb.org/t/p/w500/abc123.jpg"
        )
    }

    func testMakePosterURLReturnsNilForEmptyPath() {
        let service = TMDBService.shared

        let url = service.makePosterURL(path: "", size: "w500")

        XCTAssertNil(url)
    }

}
