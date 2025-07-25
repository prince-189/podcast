//import SwiftUI
//
//struct HomeView: View {
//    @State private var isSidebarVisible = false
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//            NavigationView {
//                List {
//                    ForEach(0..<8) { _ in
//                        AsyncImage(url: URL(string: "https://picsum.photos/600")) { image in
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(height: 240)
//                        } placeholder: {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 12)
//                                    .fill(.gray.opacity(0.6))
//                                    .frame(height: 240)
//                                ProgressView()
//                            }
//                        }
//                        .cornerRadius(12)
//                        .padding(.vertical)
//                        .shadow(radius: 4)
//                    }
//                }
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {
//                            withAnimation {
//                                isSidebarVisible.toggle()
//                            }
//                        } label: {
//                            Image(systemName: "line.3.horizontal.circle.fill")
//                                .imageScale(.large)
//                        }
//                    }
//                }
//                .navigationTitle("Home")
//                .navigationBarTitleDisplayMode(.inline)
//            }
//
//            // Sidebar
//            SideMenu(isSidebarVisible: $isSidebarVisible)
//                .navigationBarBackButtonHidden(true)
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//// MARK: - Dummy Views for Navigation
//
//struct myaccount: View {
//    var body: some View {
//        VStack {
//            Text("My Account")
//                .font(.largeTitle)
//                .padding()
//            Spacer()
//        }
//        .navigationTitle("My Account")
//        .background(Color.white)
//    }
//}
//
//struct myorder: View {
//    var body: some View {
//        VStack {
//            Text("My Orders")
//                .font(.largeTitle)
//                .padding()
//            Spacer()
//        }
//        .navigationTitle("My Orders")
//        .background(Color.white)
//    }
//}
//
//struct info: View {
//    var body: some View {
//        VStack {
//            Text("Wishlist / Info")
//                .font(.largeTitle)
//                .padding()
//            Spacer()
//        }
//        .navigationTitle("Wishlist")
//        .background(Color.white)
//    }
//}
//
//struct mysetting: View {
//    var body: some View {
//        VStack {
//            Text("Settings")
//                .font(.largeTitle)
//                .padding()
//            Spacer()
//        }
//        .navigationTitle("Settings")
//        .background(Color.white)
//    }
//}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
