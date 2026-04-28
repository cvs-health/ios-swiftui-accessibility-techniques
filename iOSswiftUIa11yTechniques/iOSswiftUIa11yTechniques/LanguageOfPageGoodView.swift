/*
   Copyright 2026 CVS Health and/or one of its affiliates

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import SwiftUI

private let headingWelcome = "Bienvenido a nuestra aplicación."
private let introParagraph = "Estamos encantados de tenerte aquí. Esta página demuestra cómo configurar el idioma de una página completa para que VoiceOver utilice el sintetizador de voz correcto."
private let sectionHeading = "Funciones de accesibilidad"
private let featuresIntro = "Nuestra aplicación incluye las siguientes funciones de accesibilidad:"
private let feature1 = "• Compatibilidad con VoiceOver"
private let feature2 = "• Texto dinámico"
private let feature3 = "• Alto contraste"
private let feature4 = "• Reducir movimiento"
private let pageTitle = "Bienvenido"

struct LanguageOfPageGoodView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(headingWelcome)
                    .font(.title)
                    .padding(.bottom, 4)
                    .accessibilityAddTraits(.isHeader)
                Text(introParagraph)
                    .padding(.bottom)
                Text(sectionHeading)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                    .padding(.bottom, 4)
                Text(featuresIntro)
                    .padding(.bottom, 4)
                Text(feature1)
                Text(feature2)
                Text(feature3)
                Text(feature4)
            }
            .padding()
        }
        .navigationTitle(pageTitle)
        .environment(\.locale, Locale(identifier: "es"))
    }
}

struct LanguageOfPageGoodView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LanguageOfPageGoodView()
        }
    }
}
