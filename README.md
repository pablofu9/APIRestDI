
# APIRestDI

A lightweight, protocol-oriented Swift library for clean, testable REST API calls with dependency injection.  
Designed to simplify networking with `async/await`, mock implementations, and flexible repository patterns.


## Features

- 🔗 Protocol-based `WebRepository` abstraction  
- 🧩 Dependency injection with `@Inject` and `@Provider` wrappers  
- 🧪 Easy to mock for testing and development  
- ⚙️ Configurable dependencies for test/production modes  
- 🚀 Async/await friendly, extensible, and lightweight  


## Installation

Add `APIRestDI` to your project via Swift Package Manager or manually include the source files.

Add package dependency: - https://github.com/pablofu9/APIRestDI.git
    
## Quick Start
### 1. Define your Repository Protocol & Implementations

```swift
import APIRestDI
import Foundation

protocol DummyWebRepo: WebRepository {
    func getUsers() async throws -> UserResponse
}

struct RealDummyWebRepo: DummyWebRepo {
    var session: URLSession
    @BaseURLSlashed private(set) var baseURL: String

    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }

    func getUsers() async throws -> UserResponse {
        try await call(endpoint: API.getUsers)
    }
}

struct MockDummyWebRepo: DummyWebRepo {
    var session: URLSession = .mockedResponsesOnly
    var baseURL: String = "https://mockapi.io/users"

    func getUsers() async throws -> UserResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        return UserResponse(users: [], total: 0, skip: 0, limit: 0)
    }
}

extension RealDummyWebRepo {
    enum API {
        case getUsers
    }
}

extension RealDummyWebRepo.API: APICall {
    var path: String { "" }
    var method: HTTPMethod { .get }
    var authenticated: Bool { false }
    func headers() async throws -> [String : String]? { [:] }
    func body() throws -> Data? { nil }
}
```

### 2. Register your dependencies in your @main app struct
```swift
   init() {
        Dependencies.shared.registerConfigurator { testMode in
            let session = Dependencies.shared.session
            let baseUrl = "https://dummyjson.com/users"

            if testMode {
                @Provider var dummyRepo = MockDummyWebRepo() as DummyWebRepo
            } else {
                @Provider var dummyRepo = RealDummyWebRepo(session: session, baseURL: baseUrl) as DummyWebRepo
            }
        }

        Dependencies.shared.provideDependencies(testMode: false) // Set true for mocks
    }
}
```
### 3. Inject your dependency and use it

````
class VM: ObservableObject {
    
    @Inject var dummyDataRepo: DummyDateRepo
    
    func getDummyData() async throws {
        do {
            let dummyData = try await categoriesRepo.getCategories()
            print("USER \(dummyData)")
        } catch {
            print(error)
        }
        
    }
}
