//
//  SearchModels.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import Foundation

//MARK: - Model for search API request

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

//MARK: - Model for 'pages' API request

/// Uses ID from 1st request SearchItem.id, returns data for image, copyright info, id for detail lookup. Use detail.first.id of [DetailId] to get an ID for futrher request.
/// #warning Agent url may contain NULL or empty string. Must be converted to URL type if contains data
struct RawDetailResponse: Codable {
    let itemDetailResponse: ItemDetailResponse
    
    enum CodingKeys: String, CodingKey {
        case itemDetailResponse = "taxonConcept"
    }
}

struct ItemDetailResponse: Codable {
    let detailData: [DetailData]? //may be empty or even missing
    let detailIDs: [DetailId]
    let title: String
    
    struct DetailData: Codable {
        let mimeType: String?
        let imageURL: URL?
        let agents: [Agent]?
        let rightsHolder: String?
        let license: URL?
        
        struct Agent: Codable {
            let fullName: String?
            let urlString: String?
            
            enum CodingKeys: String, CodingKey {
                case fullName = "full_name"
                case urlString = "homepage"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case mimeType
            case imageURL = "eolMediaURL"
            case agents
            case rightsHolder
            case license
        }
        
    }
    
    struct DetailId: Codable {
        let id: Int
        
        enum CodingKeys: String, CodingKey {
            case id = "identifier"
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case detailData = "dataObjects"
        case detailIDs = "taxonConcepts"
        case title = "scientificName"
    }
}


