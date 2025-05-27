//
//  DependencyInjector.swift
//  APIRestDI
//
//  Created by Pablo Fuertes on 11/7/24.
//

import Foundation

/// A thread-safe singleton actor responsible for managing dependencies.
/// It stores and resolves instances by type to enable dependency injection.
public actor DependencyInjector {
    /// Internal storage mapping type names to their dependency instances.
    private static var dependencyList: [String: Any] = [:]
    
    /// Resolves and returns a registered dependency of type `T`.
    /// If no dependency has been registered for the requested type,
    /// it triggers a runtime fatal error to catch incorrect usage early.
    ///
    /// - Returns: The resolved dependency instance of type `T`.
    static func resolve<T>() -> T {
        guard let t = dependencyList[String(describing: T.self)] as? T else {
            fatalError("No provider registered for type \(T.self)")
        }
        return t
    }
    
    /// Registers a dependency instance of type `T` into the internal storage.
    /// The key is the string description of the type.
    ///
    /// - Parameter dependency: The instance to register as a dependency.
    static func register<T>(dependency: T) {
        dependencyList[String(describing: T.self)] = dependency
    }
}

/// A property wrapper to simplify injecting dependencies.
///
/// Usage:
/// ```swift
/// @Inject var service: SomeServiceProtocol
/// ```
/// This will automatically resolve and assign the registered instance for `SomeServiceProtocol`.
@propertyWrapper
public struct Inject<T> {
    /// The injected dependency instance.
    public var wrappedValue: T

    /// Initializes the property wrapper by resolving the dependency from `DependencyInjector`.
    public init() {
        self.wrappedValue = DependencyInjector.resolve()
        print("Dependency injected <-", String(describing: type(of: self.wrappedValue)))
    }
}

/// A property wrapper to simplify providing dependencies.
///
/// Usage:
/// ```swift
/// @Provider var service = RealServiceImplementation() as SomeServiceProtocol
/// ```
/// This registers the provided instance with the `DependencyInjector`.
@propertyWrapper
public struct Provider<T> {
    /// The provided dependency instance.
    public var wrappedValue: T

    /// Initializes the property wrapper with the given dependency instance
    /// and registers it immediately with the `DependencyInjector`.
    ///
    /// - Parameter wrappedValue: The dependency instance to register.
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        DependencyInjector.register(dependency: wrappedValue)
        print("Dependency provided ->", String(describing: type(of: self.wrappedValue)))
    }
}
