//
//  Dependencies.swift
//  APIRestDI
//
//  Created by Pablo Fuertes on 11/7/24.
//


import Foundation

/// A singleton class responsible for providing shared app dependencies.
public final class Dependencies {
    
    /// A shared instance of `Dependencies` to be accessed throughout the app.
    /// Marked as `@MainActor` to ensure thread-safe usage on the main thread.
    @MainActor public static var shared: Dependencies = .init()
    
    /// A configured `URLSession` instance with custom settings for timeouts, cache policy, and connectivity.
    public var session: URLSession {
        let configuration = URLSessionConfiguration.default
        
        // Set timeout for individual requests (in seconds)
        configuration.timeoutIntervalForRequest = 30
        
        // Set timeout for resources (e.g., downloads)
        configuration.timeoutIntervalForResource = 120
        
        // Wait for connectivity instead of failing immediately
        configuration.waitsForConnectivity = true
        
        // Limit max simultaneous connections to the same host
        configuration.httpMaximumConnectionsPerHost = 5
        
        // Ignore local cache and always fetch from network
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        
        // Use shared URL cache
        configuration.urlCache = .shared
        
        return URLSession(configuration: configuration)
    }
    
    /// External configurator provided by the app using the library
    private var configurator: ((Bool) -> Void)?

    /// Register external configuration logic
    public func registerConfigurator(_ block: @escaping (Bool) -> Void) {
        self.configurator = block
    }

    /// Called at app startup to register dependencies (real or mock)
    public func provideDependencies(testMode: Bool = false) {
        configurator?(testMode)
    }
}

