//
//  SearchModels.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import Foundation

struct SearchResponse: Codable {
    let results: [SearchItem]
}

struct SearchItem: Codable, CustomStringConvertible {
    let id: Int
    let title: String
    let commonName: String
    let url: URL
    var description: String {
        return "\nCommonName: \(commonName), Title: \(title), ID: \(id), URL: \(url)\n"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case commonName = "content"
        case url = "link"
    }
}
