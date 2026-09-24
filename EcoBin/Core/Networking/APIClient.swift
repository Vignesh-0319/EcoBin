//
//  APIClient.swift
//  EcoBin
//
//  Created by SUPER CHARGE on 24/09/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The requested URL was invalid."
        case .serverError(let code): return "Server returned error code \(code)."
        case .decodingError(let error): return "Failed to parse data: \(error.localizedDescription)"
        case .unauthorized: return "Session expired. Please log in again."
        case .unknown(let error): return error.localizedDescription
        }
    }
}

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
    func uploadMultipart<T: Decodable>(endpoint: Endpoint, fields: [String: String], fileData: Data, mimeType: String) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method
        urlRequest.allHTTPHeaderFields = endpoint.headers

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(statusCode: -1)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 { throw NetworkError.unauthorized }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func uploadMultipart<T: Decodable>(
        endpoint: Endpoint,
        fields: [String: String],
        fileData: Data,
        mimeType: String
    ) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let (data, response) = try await session.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct Endpoint {
    let path: String
    var method: String = "GET"
    var headers: [String: String] = ["Content-Type": "application/json"]
    var queryItems: [URLQueryItem]?

    var url: URL? {
        var components = URLComponents(string: "https://api.ecobin-city.internal/v1" + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
