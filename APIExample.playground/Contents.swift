import UIKit
import PlaygroundSupport
import Combine

struct API {
    
    /// API Errors
    /// List all errors that can be retrieved by URLSession
    enum Error: LocalizedError {
        case addressUnreachable(URL)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from the server"
            case .addressUnreachable(let url):
                return "Unreachable URL: \(url.absoluteString)"
            }
        }
    }
    
    /// API Endpoints
    /// Define all endpoints for the API
    enum EndPoint {
        static let baseURL = URL(string: "https://api.chucknorris.io/jokes/")!
        
        case random
        case category(String)
        case categories
        case query(String)
        
        var url: URL {
            switch self {
            case .random:
                return EndPoint.baseURL.appendingPathComponent("random")
            case .category(let category):
                var baseQueryURL = URLComponents(url: EndPoint.baseURL.appendingPathComponent("random"), resolvingAgainstBaseURL: false)!
                baseQueryURL.queryItems = [
                    URLQueryItem(name: "category", value: category)
                ]
                return baseQueryURL.url!
            case .categories:
                return EndPoint.baseURL.appendingPathComponent("categories")
            case .query(let query):
                var baseQueryURL = URLComponents(url: EndPoint.baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)!
                baseQueryURL.queryItems = [
                    URLQueryItem(name: "query", value: query)
                ]
                return baseQueryURL.url!
            }
        }
    }
    
    /// Private decoder for JSON decoding
    private let decoder = JSONDecoder()
    
    /// Specify the scheduler that manages the responses
    private let apiQueue = DispatchQueue(label: "ChuckNorrisAPI",
                                         qos: .default,
                                         attributes: .concurrent)
    
    //MARK: - API Methods
    
    /// Retrieve the publisher for a random quote
    func randomQuote() -> AnyPublisher<ChuckQuote, Error> {
        URLSession.shared
            .dataTaskPublisher(for: EndPoint.random.url)
            .receive(on: apiQueue)
            .map(\.data)
            .decode(type: ChuckQuote.self, decoder: decoder)
            .catch { _ in Empty<ChuckQuote, Error>() }
            .eraseToAnyPublisher()
    }
    
    func randomQuoteFrom(_ category: String) -> AnyPublisher<ChuckQuote, Error> {
        URLSession.shared
            .dataTaskPublisher(for: EndPoint.category(category).url)
            .map(\.data)
            .decode(type: ChuckQuote.self, decoder: decoder)
            .mapError { (error) -> Error in
                switch error {
                case is URLError:
                    return Error.addressUnreachable(EndPoint.category(category).url)
                default:
                    return Error.invalidResponse
                }
        }
        .eraseToAnyPublisher()
    }
    
    // Now it's your time
    // Explore the other endpoints from the API documentation at https://api.chucknorris.io/
    // and construct the other methods.
    // Feel free to try multiple operators and manipulate the output from the API in any way you like!
}

//MARK: - API Testing
let api = API()
var subscriptions = [AnyCancellable]()

api.randomQuote()
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

api.randomQuoteFrom("animal")
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

// Simulating error response
api.randomQuoteFrom("notExistingCategory")
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)


PlaygroundPage.current.needsIndefiniteExecution = true
