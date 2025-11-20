/*
   Copyright 2023 CVS Health and/or one of its affiliates

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
 
struct CarouselViewBad: View {
    
    @State private var isShowingSheetBad = false
    @State private var selectedPageBad: Int = 0

    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        ScrollView {
            VStack {
                Text("Carousels are used to swipe between content like images, videos, or text.")
                .padding([.bottom])
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                VStack {
                    Button(action: {
                        isShowingSheetBad = true
                    }) {
                        Text("Show Bad Carousel")
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .fullScreenCover(isPresented: $isShowingSheetBad) {
                    VStack {
                        HStack {
                            if selectedPageBad == 0 {
                                Rectangle().fill(Color.primary.opacity(0.8)).frame(maxWidth: .infinity, maxHeight: 10).clipShape(.capsule)
                            } else {
                                Rectangle().fill(Color.secondary.opacity(0.8)).frame(maxWidth: .infinity, maxHeight: 10).clipShape(.capsule)
                            }
                            if selectedPageBad == 1 {
                                Rectangle().fill(Color.primary.opacity(0.8)).frame(maxWidth: .infinity, maxHeight: 10).clipShape(.capsule)
                            } else {
                                Rectangle().fill(Color.secondary.opacity(0.8)).frame(maxWidth: .infinity, maxHeight: 10).clipShape(.capsule)
                            }
                            if selectedPageBad == 2 {
                                Rectangle().fill(Color.primary.opacity(0.8)).frame(maxWidth: .infinity, maxHeight: 10).clipShape(.capsule)
                            } else {
                                Rectangle().fill(Color.secondary.opacity(0.8)).frame(maxWidth: .infinity, maxHeight: 10).clipShape(.capsule)
                            }
                        }
                        TabView(selection: $selectedPageBad) {
                            VStack {
                                Image("mardi-gras")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                                    .overlay(
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 40))
                                            .frame(width: 70, height: 70)
                                            .position(x: UIScreen.main.bounds.width - (UIDevice.current.orientation.isLandscape ? 200 : 70), y: 30)
                                            .simultaneousGesture(TapGesture().onEnded {
                                                isShowingSheetBad = false
                                            })
                                    )
                                Text("Mardi Gras Parade, New Orleans, Louisiana. Digital photo by Carol M. Highsmith, 2011.")
                                    .padding(.top,4)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Mardi Gras")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(action: {
                                    print("Read More tapped")
                                }) {
                                    HStack {
                                        Text("Read More")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .bold()
                                        Image(systemName: "chevron.up")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 24)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                    )
                                }
                                .padding(.vertical, 16)
                                Spacer()
                            }
                            .tag(0)
                            VStack {
                                Image("stained-glass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                                    .overlay(
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 40))
                                            .frame(width: 70, height: 70)
                                            .position(x: UIScreen.main.bounds.width - (UIDevice.current.orientation.isLandscape ? 200 : 70), y: 30)
                                            .simultaneousGesture(TapGesture().onEnded {
                                                isShowingSheetBad = false
                                            })
                                    )
                                Text("Stained glass ceiling, Old State Capitol, Baton Rouge, Louisiana. Digital photo by Carol M. Highsmith, 2021.")
                                    .padding(.top,4)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Stained Glass")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(action: {
                                    print("Read More tapped")
                                }) {
                                    HStack {
                                        Text("Read More")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .bold()
                                        Image(systemName: "chevron.up")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 24)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                    )
                                }
                                .padding(.vertical, 16)
                                Spacer()
                            }
                            .tag(1)
                            VStack {
                                Image("carousel")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                                    .overlay(
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 40))
                                            .frame(width: 70, height: 70)
                                            .position(x: UIScreen.main.bounds.width - (UIDevice.current.orientation.isLandscape ? 200 : 70), y: 30)
                                            .simultaneousGesture(TapGesture().onEnded {
                                                isShowingSheetBad = false
                                            })
                                    )
                                Text("Carousel, Asbury Park, New Jersey. Color slide photo by John Margolies, 1978.")
                                    .padding(.top,4)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Carousel")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(action: {
                                    print("Read More tapped")
                                }) {
                                    HStack {
                                        Text("Read More")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .bold()
                                        Image(systemName: "chevron.up")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 24)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                    )
                                }
                                .padding(.vertical, 16)
                                Spacer()
                            }
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onReceive(timer, perform: { _ in
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedPageBad = (selectedPageBad + 1) % 3
                                    }
                                })
                        Spacer()
                    }
                    .padding([.leading,.trailing])
                }

                DisclosureGroup("Details") {
                    Text("The second bad tabs example uses `.tabViewStyle(.page)` which has white page indicator dots that are only visible in dark mode but are invisible in light mode. There is also no `.accessibilityLabel`.")
                }.padding(.bottom)
            }
            .padding()
            .navigationTitle("Carousels")

        }
 
    }
}
 
#Preview {
    NavigationStack {
        CarouselViewBad()
    }
}
