//
//  DependencyInjector.swift
//  APIRestDI
//
//  Created by Pablo Fuertes on 11/7/24.
//

import Foundation


public actor DependencyInjector {
    private static var dependencyList: [String:Any] = [:]
    
    /// Attempts to retrieve the dependency. If it doesn't exist, it's an error in our logic, so we throw a fatal error.
    static func resolve<T>() -> T {
        guard let t = dependencyList[String(describing: T.self)] as? T else {
            fatalError("No provider registered for type \(T.self)")
        }
        return t
    }
    
    /// Creates a "key:value" in a dictionary with the description of T being the key, and T being the actual value.
    static func register<T>(dependency: T) {
        dependencyList[String(describing: T.self)] = dependency
    }
}

/// Property wrapper to simplify injection
@propertyWrapper
public struct Inject<T> {
    public var wrappedValue: T

    public init() {
        self.wrappedValue = DependencyInjector.resolve()
        print("Dependency injected <-", String(describing: type(of: self.wrappedValue)))
    }
}

/// Property wrapper to simplify providing
@propertyWrapper
public struct Provider<T> {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        DependencyInjector.register(dependency: wrappedValue)
        print("Dependency provided ->", String(describing: type(of: self.wrappedValue)))
    }
}

