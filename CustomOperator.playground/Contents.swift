import Combine

extension Publisher {
    func sampleOperator<T>(source: T) -> AnyPublisher<Self.Output, Self.Failure>
        where T: Publisher, T.Output: Equatable, T.Failure == Self.Failure {
        combineLatest(source)
            .removeDuplicates(by: {
                (first, second) -> Bool in
                first.1 == second.1
            })
            .map { first in
                first.0
        }
        .eraseToAnyPublisher()
    }
}

