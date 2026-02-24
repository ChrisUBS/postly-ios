//
//  PexelsService.swift
//  Postly
//
//  Created by Christian Bonilla on 23/02/26.
//

import Foundation

class PexelsService {
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "PEXELS_API_KEY") as? String
    private let baseURL = "https://api.pexels.com/v1/search"

    func searchImages(query: String) async throws -> [PexelsPhoto] {
        guard let apiKey else { return [] }
        guard let url = URL(string: "\(baseURL)?query=\(query)&per_page=6") else { return [] }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(PexelsResponse.self, from: data)
        return result.photos
    }
}

struct PexelsResponse: Codable {
    let photos: [PexelsPhoto]
}
