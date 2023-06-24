//
//  SearchModelsController.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import Foundation

struct SearchModelsController {
    
    let baseURL = URL(string: "https://eol.org/api/search/1.0.json")!
    
    func fetchResults(with query: String) async throws -> [SearchItem] {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            "q" : query,
            "page" : "1"
        ].map { URLQueryItem(name: $0.key, value: $0.value) }
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw SearchModelsControllerError.fetchingResultsFailed }
        let jsonDecoder = JSONDecoder()
        let searchResponse = try? jsonDecoder.decode(SearchResponse.self, from: data)
        guard let searchItems = searchResponse?.results else { throw SearchModelsControllerError.fetchingResultsFailed }
        return searchItems
    }
    
    enum SearchModelsControllerError: Error, LocalizedError {
        case fetchingResultsFailed
        case fethingItemDetailFailed
    }
    
    func fetchItemDetail(for id: Int) async throws -> ItemDetailResponse? {
        var urlComponents = URLComponents(string: "https://eol.org/api/pages/1.0/\(id).json")!
        urlComponents.queryItems = [
            "taxonomy" : "true",
            "images_per_page" : "1",
            "language" : "en"
        ].map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw SearchModelsControllerError.fethingItemDetailFailed }
        let jsonDecoder = JSONDecoder()
        let detailResponse = try? jsonDecoder.decode(RawDetailResponse.self, from: data)
        
        
        return detailResponse?.itemDetailResponse
    }
}
