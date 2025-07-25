import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let ImgName: String
    let category: String
    let price: Double
    let rating: Int
}

struct TempHome: View {
    let bgcolor = Color(red: 245/255, green: 245/255, blue: 236/255)
    let headingColor = Color(red: 184/255, green: 146/255, blue: 95/255)

    @State private var selectedCategory = "Chair"
    @State private var searchText = ""
    @State private var selectedTab = 0

    let categories = ["All", "Chair", "Sofa", "Lamp", "Kitchen", "Table"]

    let allProducts: [Product] = [
        Product(name: "Luxury Swedian chair", ImgName: "chair1", category: "Chair", price: 1299, rating: 5),
        Product(name: "Luxury Wooden Stool", ImgName: "chair2", category: "Chair", price: 799, rating: 4),
        Product(name: "Elegant Sofa", ImgName: "sofa1", category: "Sofa", price: 2399, rating: 5),
        Product(name: "Modern Lamp", ImgName: "lamp1", category: "Lamp", price: 399, rating: 3)
    ]

    var filteredProducts: [Product] {
        allProducts.filter { product in
            (selectedCategory == "All" || product.category == selectedCategory)
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: HOME TAB
            VStack(alignment: .leading, spacing: 16) {

                // Header
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(headingColor)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)

                    Spacer()

                    Image("tanjiro") // Replace with your asset
                        .resizable()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }
                .padding(.horizontal)
                .padding(.top, 75)

                // Title
                Text("Find the\nBest Furniture!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(headingColor)
                    .padding(.horizontal)

                // Search bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search Furniture", text: $searchText)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)

                    Rectangle()
                        .fill(headingColor)
                        .frame(width: 40, height: 40)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Category Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(categories, id: \.self) { cat in
                            VStack {
                                Text(cat)
                                    .foregroundColor(selectedCategory == cat ? headingColor : .gray)
                                    .fontWeight(selectedCategory == cat ? .bold : .regular)
                                if selectedCategory == cat {
                                    Capsule()
                                        .fill(headingColor)
                                        .frame(height: 3)
                                } else {
                                    Capsule()
                                        .fill(Color.clear)
                                        .frame(height: 3)
                                }
                            }
                            .onTapGesture {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Section: Popular
                Text("Popular")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product, headingColor: headingColor)
                        }
                    }
                    .padding(.horizontal)
                }

                // Section: Best (reuse Popular)
                Text("Best")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(filteredProducts.reversed()) { product in
                            ProductCard(product: product, headingColor: headingColor)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 60)

            }
            .background(bgcolor)
            .ignoresSafeArea()
            .tag(0)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            // MARK: PROFILE TAB
            Text("Profile Page")
                .tag(1)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

// MARK: - Product Card View
struct ProductCard: View {
    let product: Product
    let headingColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(product.ImgName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(12)

            Text(product.name)
                .font(.footnote)
                .foregroundColor(.black)
                .lineLimit(2)

            HStack(spacing: 4) {
                ForEach(0..<5) { i in
                    Image(systemName: i < product.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(i < product.rating ? .yellow : .gray.opacity(0.4))
                }

                Spacer()

                Text("$\(Int(product.price))")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(headingColor)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: 180)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct TempHome_Previews: PreviewProvider {
    static var previews: some View {
        TempHome()
    }
}
