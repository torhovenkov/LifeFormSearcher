//
//  SearchModelsController.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import Foundation
import UIKit

struct SearchModelsController {
    
    static let shared = SearchModelsController()
    
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
    
    func fetchHierarchyItemInfo(for id: Int) async throws -> HierarchyResponse? {
        var urlComponents = URLComponents(string: "https://eol.org/api/hierarchy_entries/1.0/\(id).json")!
        urlComponents.queryItems = ["language" : "en"].map { URLQueryItem(name: $0.key, value: $0.value) }
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw SearchModelsControllerError.fetchingHierarchyFailed }
        let jsonDecoder = JSONDecoder()
        let hierarchy = try? jsonDecoder.decode(HierarchyResponse.self, from: data)
        
        return hierarchy
    }
    
    func fetchImage(_ url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw SearchModelsControllerError.fetchingImageFailed }
        guard let  image = UIImage(data: data) else { throw SearchModelsControllerError.fetchingImageFailed  }
        return image
    }
    
    
}

enum SearchModelsControllerError: Error, LocalizedError {
    case fetchingResultsFailed
    case fethingItemDetailFailed
    case fetchingHierarchyFailed
    case fetchingImageFailed
}
