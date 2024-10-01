import SwiftUI

struct Person: Identifiable {
    let givenName: String
    let familyName: String
    let emailAddress: String
    let id = UUID()

    var fullName: String { givenName + " " + familyName }
}

struct PeopleView: View {
    @State private var people = [
        Person(givenName: "Juan", familyName: "Chavez", emailAddress: "juanchavez@icloud.com"),
        Person(givenName: "Mei", familyName: "Chen", emailAddress: "meichen@icloud.com"),
        Person(givenName: "Tom", familyName: "Clark", emailAddress: "tomclark@icloud.com"),
        Person(givenName: "Gita", familyName: "Kumar", emailAddress: "gitakumar@icloud.com")
    ]

    var body: some View {
        PeopleTable(people: $people)
    }
}

struct PeopleTable: View {
    var people: Binding<[Person]>

    init(people: Binding<[Person]>) {
        self.people = people
    }

    var body: some View {
        Table(self.people.wrappedValue) {
            TableColumn("Given Name", value: \.givenName)
            TableColumn("Family Name", value: \.familyName)
            TableColumn("E-Mail Address", value: \.emailAddress)
        }
    }
}

struct TableView: View {
    var body: some View {
        PeopleView()
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
    }
}
