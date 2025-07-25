import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var profileImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var displayName: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.purple)
                            }
                        }
                        .onChange(of: photoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    self.profileImage = uiImage
                                }
                            }
                        }

                        Text(displayName)
                            .font(.title2)
                            .bold()
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // App Settings Section
                    VStack(spacing: 12) {
                        Toggle("Dark Mode", isOn: $isDarkMode)

                        NavigationLink(destination: EditProfileView()) {
                            ProfileRow(icon: "pencil", title: "Edit Profile")
                        }

                        NavigationLink(destination: FAQView()) {
                            ProfileRow(icon: "questionmark.circle", title: "FAQ")
                        }

                        NavigationLink(destination: PrivacyPolicyView()) {
                            ProfileRow(icon: "lock.shield", title: "Privacy Policy")
                        }

                        NavigationLink(destination: TermsView()) {
                            ProfileRow(icon: "doc.text", title: "Terms of Service")
                        }

                        Button {
                            // App Store / Review redirect
                        } label: {
                            ProfileRow(icon: "star.fill", title: "Rate Us")
                        }

                        Button(role: .destructive) {
                            auth.logOut()
                        } label: {
                            ProfileRow(icon: "arrowshape.turn.up.left.fill", title: "Log Out", color: .red)
                        }
                    }
                }
                .padding()
                .onAppear {
                    loadProfileData()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    func loadProfileData() {
        displayName = UserDefaults.standard.string(forKey: "user_display_name") ?? "Unknown User"
        email = UserDefaults.standard.string(forKey: "user_email") ?? "no-email@example.com"

        if let imageData = UserDefaults.standard.data(forKey: "user_profile_image_data"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }

}

struct ProfileRow: View {
    let icon: String
    let title: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(color)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Placeholder Views


struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var username: String = ""
    @State private var selectedAvatar: String = "avatar_adult_male"
    @State private var isSaving = false
    @State private var saveSuccess = false

    let avatars = [
        "avtar_adult_male", "avtar_adult_female",
        "avatar_teen_male", "avatar_teen_female",
        "avatar_senior_male", "avatar_senior_female"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Edit Profile")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Display name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name").font(.subheadline)
                    TextField("Enter name", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Avatar Selection Grid
                Text("Choose an Avatar").font(.subheadline)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(avatars, id: \.self) { avatar in
                        Image(avatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding(6)
                            .background(avatar == selectedAvatar ? Color.purple.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedAvatar = avatar
                            }
                    }
                }

                // Save Button
                Button(action: saveProfile) {
                    if isSaving {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.purple)
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .alert(isPresented: $saveSuccess) {
                Alert(title: Text("Success"), message: Text("Profile updated"), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            loadProfile()
        }
    }

    // Load from UserDefaults or Supabase if needed
    func loadProfile() {
        self.username = UserDefaults.standard.string(forKey: "user_display_name") ?? ""
        self.selectedAvatar = UserDefaults.standard.string(forKey: "user_avatar_name") ?? avatars.first!
    }

    func saveProfile() {
        guard !username.isEmpty else { return }
        isSaving = true

        // Get UIImage from selected avatar
        let selectedImage = UIImage(named: selectedAvatar)

        // Save to Supabase (mocked here)
        updateProfileInSupabase(name: username, avatar: selectedAvatar) { success in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    saveSuccess = true
                    UserDefaults.standard.set(username, forKey: "user_display_name")
                    UserDefaults.standard.set(selectedAvatar, forKey: "user_avatar_name")

                    if let imageData = selectedImage?.pngData() {
                        UserDefaults.standard.set(imageData, forKey: "user_profile_image_data")
                    }

                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    func updateProfileInSupabase(name: String, avatar: String, completion: @escaping (Bool) -> Void) {
        // Replace this with your real API call
        completion(true)
    }
}


struct FAQView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Frequently Asked Questions")
                    .font(.title2.bold())

                Text("Q: How to upload a podcast?\nA: Use the '+' button in the Explore tab.")

                Text("Q: How to delete my account?\nA: Contact support for account removal.")

                Text("Q: Why can’t I play a video?\nA: Check your internet connection or update the app.")
            }
            .padding()
        }
        .navigationTitle("FAQ")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Your privacy is important to us. This app collects minimal user data and does not share it with third parties...")
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            Text("By using this app, you agree to the following terms and conditions...")
                .padding()
        }
        .navigationTitle("Terms of Service")
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
