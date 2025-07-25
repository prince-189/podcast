//
//  tabsView.swift
//  SOS
//
//  Created by Apple 12 on 07/07/25.
//

import SwiftUI

struct AudioverseMainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(.purple) // Optional: customize active tab color
    }
}

// Placeholder views





struct tabsView_Previews: PreviewProvider {
    static var previews: some View {
        AudioverseMainView()
    }
}
