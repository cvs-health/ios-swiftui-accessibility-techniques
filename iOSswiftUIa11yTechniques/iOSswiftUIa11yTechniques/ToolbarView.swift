//
//  ToolbarView.swift
//  iOSswiftUIa11yTechniques
//
//  Created by Paul Adam on 7/2/25.
//

import SwiftUI

struct ToolbarView: View {
    
    
    var body: some View {
        Text("Welcome to Liquid Glass UI")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.regularMaterial) // Liquid Glass effect
            .toolbarBackground(.ultraThinMaterial)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        print("Back tapped")
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    Button {
                        print("Folder tapped")
                    } label: {
                        Image(systemName: "folder")
                    }
                    Button {
                        print("Favorite tapped")
                    } label: {
                        Label("Favorite", systemImage: "heart")
                    }

                    Spacer()

                    Button {
                        print("Share tapped")
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Spacer()

                    Button {
                        print("Trash tapped")
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                }

                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            print("Edit tapped")
                        } label: {
                            Image(systemName: "square.and.pencil") //BAD EXAMPLE FOR LARGE TEXT VIEWER
                        }
                    }
                }
                .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
                .toolbarBackground(.visible, for: .bottomBar)
        
            .navigationTitle("Toolbars")
    }
}

#Preview {
    ToolbarView()
}
