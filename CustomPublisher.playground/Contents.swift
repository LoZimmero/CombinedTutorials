import Combine
import Foundation

extension Publishers {
    
    class DataSubscription<S: Subscriber>: Subscription where S.Input == Data, S.Failure == Error {
        private let urlSession = URLSession.shared
        private let urlRequest: URLRequest
        private var subscriber: S?
        
        init(request: URLRequest, subscriber: S) {
            self.urlRequest = request
            self.subscriber = subscriber
            sendRequest()
        }
        
        func request(_ demand: Subscribers.Demand) {
            // Adjust the demand in case you need to
        }
        
        func cancel() {
            subscriber = nil
        }
        
        private func sendRequest() {
            guard let subscriber = subscriber else { return }
            urlSession.dataTask(with: urlRequest) { (data, _, error) in
                _ = data.map(subscriber.receive)
                _ = error.map { subscriber.receive(completion: Subscribers.Completion.failure($0)) }
            }.resume()
        }
    }
    
    struct DataPublisher: Publisher {
        typealias Output = Data
        typealias Failure = Error
        
        private let urlRequest: URLRequest
        
        init(urlRequest: URLRequest) {
            self.urlRequest = urlRequest
        }
        
        func receive<S: Subscriber>(subscriber: S) where
            DataPublisher.Failure == S.Failure, DataPublisher.Output == S.Input {
                let subscription = DataSubscription(request: urlRequest,
                                                    subscriber: subscriber)
                subscriber.receive(subscription: subscription)
        }
    }
}

extension URLSession {
    func dataResponse(for request: URLRequest) -> Publishers.DataPublisher {
        return Publishers.DataPublisher(urlRequest: request)
    }
}


let request = URLRequest(url: URL(string: "https://www.google.it")!)
let subscription = URLSession.shared.dataResponse(for: request)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
