import UIKit
import Combine

public func example(of: String, execute: () -> Void) {
    print("------ \(of) ------")
    execute()
}

example(of: "URLSession+Publisher") {
    guard let url = URL(string: "https://www.fakeurl.com/fakeData.json") else { return }
    
    let _ = URLSession.shared
    .dataTaskPublisher(for: url)
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            print("Failed with error \(error)")
        }
    }, receiveValue: { data, response in
        print("Data retrieved with size \(data.count), response = \(response)")
    })
}

example(of: "URLSession+Publisher+Codable") {
    struct Article: Codable {
        let title: String
        let headline: String
        let description: String
    }
    
    let url = URL(string: "http://combineExample.com/exampleEndpoint")!
    _ = URLSession.shared
        .dataTaskPublisher(for: url)
        .tryMap{ element -> Data in
            guard let httpResponse = element.response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
            }
            return element.data
    }
    .decode(type: Article.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { print("Received completion: \($0)")},
          receiveValue: { article in print("Received article: \(article)")})
}

example(of: "Multicast") {
    let url = URL(string: "https://www.google.com")!
    
    // Create the ConnectablePublisher using a PassthroughSubject
    let publisher = URLSession.shared
    .dataTaskPublisher(for: url)
        .map(\.data)
        .multicast { PassthroughSubject<Data, URLError>() }
    
    // Create subscriptions
    let subscription1 = publisher
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            print("First sink has reported an error: \(error)")
        }
    }, receiveValue: { obj in
        print("First sink retrieved object \(obj)")
    })
    
    let subscription2 = publisher
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            print("Second sink has reported an error: \(error)")
        }
    }, receiveValue: { obj in
        print("Second sink retrieved object \(obj)")
    })
    
    // Connect the publisher
    let subscription = publisher.connect()
}
