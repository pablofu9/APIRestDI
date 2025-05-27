//
//  WebRepository.swift
//  APIRestDI
//
//  Created by Pablo Fuertes on 11/7/24.
//

import Foundation

/// A protocol defining the requirements for a web repository.
public protocol WebRepository {
    /// The URLSession used for network requests.
    var session: URLSession { get }
    
    /// The base URL of the web repository.
    var baseURL: String { get }
    
    /// The JSON decoder used for decoding responses.
    var decoder: JSONDecoder { get }
}

public extension WebRepository {
    /// Default JSON decoder used when not provided explicitly.
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
}

public extension WebRepository {
    /// Performs an asynchronous API call and decodes the response.
    /// - Parameters:
    ///   - endpoint: The endpoint to call.
    ///   - httpCodes: The expected range of HTTP status codes for success.
    /// - Returns: A decoded response of type `T`.
    func callResult<T: Codable>(
        endpoint: APICall,
        httpCodes: HTTPCodes = .success
    ) async -> Result<T, APIError> {
        do {
            let request = try await endpoint.urlRequest(baseURL: baseURL)
            let (data, response) = try await session.data(for: request)

            guard let code = (response as? HTTPURLResponse)?.statusCode else {
                return .failure(.unexpectedResponse)
            }

            guard httpCodes.contains(code) else {
                return .failure(.httpCode(code))
            }

            do {
                let decoded = try decoder.decode(T.self, from: data)
                return .success(decoded)
            } catch {
                return .failure(.decoding(error))
            }
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(.unexpectedResponse)
        }
    }
}

public extension URLSession {
    /// Provides a URLSession instance for mocked responses only.
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

/// A property wrapper for ensuring the base URL ends with a slash.
@propertyWrapper public struct BaseURLSlashed {
    public var wrappedValue: String
    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}
