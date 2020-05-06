import Combine
import SwiftUI
import PlaygroundSupport

// Class Person
final class Person: ObservableObject {
    
    // Variables that will be notified every time they changes
    @Published var name: String = ""
    @Published var surname: String = ""
    // A set to store subscriptions
    var subscriptions = Set<AnyCancellable>()
    
    init(_ name: String, _ surname: String) {
        self.name = name
        self.surname = surname
        
        // Subscriptions to published variables
        $name
            .removeDuplicates()
            .sink(receiveValue: {
                print("New name: \($0)")
            })
            .store(in: &subscriptions)
        
        $surname
            .removeDuplicates()
            .sink {
                print("New surname: \($0)")
            }
            .store(in: &subscriptions)
    }
}

struct ContentView: View {
    
    // Variables
    @ObservedObject var person: Person
    @State var name: String = ""
    @State var surname: String = ""
    
    
    // View body
    var body: some View {
        VStack(alignment: .center, spacing: 25){
            Text("Hello, \(person.name) \(person.surname)")
                .padding(.bottom, 50)
            HStack(alignment: .center, spacing: 2){
                VStack{
                    Text("New name: ")
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 30)
                VStack{
                    TextField("Name", text: $name)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
            }
            HStack(alignment: .center, spacing: 2){
                VStack{
                    Text("New surname: ")
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 30)
                VStack{
                    TextField("Surname", text: $surname)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            // Triggers the publisher
            Button(action: {
                self.person.name = self.name
                self.person.surname = self.surname
            }) {
                Text("Update")
            }
            // Once this button is pressed, publisher won't work anymore
            Button(action: {
                self.person.subscriptions.removeAll()
            }) {
                Text("Cancel subscriptions")
            }
        }
    }
}

// To display the view in playground
PlaygroundPage.current.setLiveView(ContentView(person: Person("Mario", "Rossi")))
