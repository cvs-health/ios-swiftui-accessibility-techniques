import SwiftUI

struct Techniques: Identifiable {
    let id = UUID()
    let name: String
}

let techniques: [Techniques] = [
    Techniques(name: "Decorative Images"),
    Techniques(name: "Headings"),
    Techniques(name: "Informative Images"),
    Techniques(name: "Functional Images")
]
