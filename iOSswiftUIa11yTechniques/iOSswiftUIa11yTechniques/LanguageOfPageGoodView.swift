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

struct LanguageOfPageGoodView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Bienvenido a nuestra aplicación.")
                    .font(.title)
                    .padding(.bottom, 4)
                Text("Estamos encantados de tenerte aquí. Esta página demuestra cómo configurar el idioma de una página completa para que VoiceOver utilice el sintetizador de voz correcto.")
                    .padding(.bottom)
                Text("Funciones de accesibilidad")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.bottom, 4)
                Text("Nuestra aplicación incluye las siguientes funciones de accesibilidad:")
                    .padding(.bottom, 4)
                Text("• Compatibilidad con VoiceOver")
                Text("• Texto dinámico")
                Text("• Alto contraste")
                Text("• Reducir movimiento")
            }
            .padding()
        }
        .environment(\.locale, Locale(identifier: "es"))
        .navigationTitle("Bienvenido")
    }
}

struct LanguageOfPageGoodView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LanguageOfPageGoodView()
        }
    }
}
