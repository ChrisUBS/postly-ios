//
//  APIClient.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session = URLSession.shared
    
    private init() {
        let configuredURL: URL = {
            if
                let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
                let url = URL(string: baseURLString)
            {
                return url
            } else {
                fatalError("BASE_URL not configured properly")
            }
        }()
        self.baseURL = configuredURL
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = AuthManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(
                statusCode: httpResponse.statusCode,
                message: errorMessage
            )
        }
        
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            // Create the formatter inside the closure to avoid capturing a non-Sendable instance.
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]
            
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format"
            )
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

enum APIError: Error {
    case serverError(statusCode: Int, message: String)
    case decodingError
}
