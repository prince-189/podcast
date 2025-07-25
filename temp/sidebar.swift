////
////  Sidebar.swift
////  locallog
////
////  Created by APPLE SERVER on 30/11/24.
////
//import SwiftUI
//var secondaryColor: Color = Color(.init(
//    red: 100 / 255,
//    green: 174 / 255,
//    blue: 255 / 255,
//    alpha: 1))
//
//struct MenuItem: Identifiable {
//    var id: Int
//    var icon: String
//    var text: String
//    
//}
//
//var userActions: [MenuItem] = [
//    MenuItem(id: 4001, icon: "person.circle.fill", text: "My Account"),
//    MenuItem(id: 4002, icon: "bag.fill", text: "My Orders"),
//    MenuItem(id: 4003, icon: "gift.fill", text: "Wishlist"),
//]
//
//var profileActions: [MenuItem] = [
//    MenuItem(id: 4004, icon: "wrench.and.screwdriver.fill", text: "Settings"),
//    MenuItem(id: 4005, icon: "iphone.and.arrow.forward", text: "Logout"),
//]
//
//struct SideMenu: View {
//    @Binding var isSidebarVisible: Bool
//    var sideBarWidth = UIScreen.main.bounds.size.width * 0.7
//    var bgColor: Color = Color(.init(
//            red: 52 / 255,
//            green: 70 / 255,
//            blue: 182 / 255,
//            alpha: 1))
//
//    var body: some View {
//        ZStack {
//            
//            GeometryReader { _ in
//                EmptyView()
//            }
//            .background(.black.opacity(0.6))
//            .opacity(isSidebarVisible ? 1 : 0)
//            .animation(.easeInOut.delay(0.2), value: isSidebarVisible)
//            .onTapGesture {
//                isSidebarVisible.toggle()
//            }
//
//            
//            content
//                .zIndex(1) // Make sure the side menu appears on top
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//
//    var content: some View {
//        HStack(alignment: .top) {
//            ZStack(alignment: .top) {
//                bgColor
//                MenuChevron
//
//                VStack(alignment: .leading, spacing: 20) {
//                    userProfile
//                    Divider()
//                    MenuLinks(items: userActions)
//                    Divider()
//                    MenuLinks(items: profileActions)
//                }
//                .padding(.top, 80)
//                .padding(.horizontal, 40)
//            }
//            .frame(width: sideBarWidth)
//            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
//            .animation(.default, value: isSidebarVisible)
//
//            Spacer()
//        }
//    }
//
//    var MenuChevron: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 18)
//                .fill(bgColor)
//                .frame(width: 60, height: 60)
//                .rotationEffect(Angle(degrees: 45))
//                .offset(x: isSidebarVisible ? -18 : -10)
//                .onTapGesture {
//                    isSidebarVisible.toggle()
//                }
//
//            Image(systemName: "chevron.right")
//                .foregroundColor(secondaryColor)
//                .rotationEffect(isSidebarVisible ?
//                    Angle(degrees: 180) : Angle(degrees: 0))
//                .offset(x: isSidebarVisible ? -4 : 8)
//        }
//        .offset(x: sideBarWidth / 2, y: 80)
//        .animation(.default, value: isSidebarVisible)
//    }
//
//    var userProfile: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Image("naruto2")
//                    .resizable()
//                    .frame(width: 50, height: 50, alignment: .center)
//                    .clipShape(Circle())
//                    .overlay {
//                        Circle().stroke(.blue, lineWidth: 2)
//                    }
//                    .shadow(radius: 4)
//                    .padding(.trailing, 18)
//
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("prince")
//                        .foregroundColor(.white)
//                        .bold()
//                        .font(.title3)
//                    Text(verbatim: "Apple.dev@gmail.com")
//                        .foregroundColor(secondaryColor)
//                        .font(.caption)
//                }
//            }
//            .padding(.bottom, 20)
//        }
//    }
//}
//
//struct MenuLinks: View {
//    var items: [MenuItem]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 30) {
//            ForEach(items) { item in
//                NavigationLink(destination: destinationView(for: item)) {
//                    menuLink(icon: item.icon, text: item.text)
//                }
//            }
//        }
//        .padding(.vertical, 14)
//        .padding(.leading, 8)
//    }
//
//    @ViewBuilder
//    private func destinationView(for item: MenuItem) -> some View {
//        switch item.id {
//        case 4001: myaccount()
//        case 4002: myorder()
//        case 4003: info()
//        case 4004: mysetting()
//        case 4005: ContentView()
//        default: Text("Page not found")
//        }
//    }
//   
//}
//
//struct menuLink: View {
//    var icon: String
//    var text: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .resizable()
//                .frame(width: 20, height: 20)
//                .foregroundColor(secondaryColor)
//                .padding(.trailing, 18)
//            Text(text)
//                .foregroundColor(.white)
//                .font(.body)
//        }
//    }
//}
//
//
//
//
//struct SideMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenu(isSidebarVisible: .constant(true))
//    }
//}
//
