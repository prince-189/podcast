import SwiftUI

struct registerView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var navigateToHome = false
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.top, 50)
                    
                    Text("Register")
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    VStack(spacing: 16) {
                        // Input fields with better visibility
                        CustomInputField(placeholder: "Username", text: $username)
                        CustomInputField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        CustomInputField(placeholder: "Password", text: $password, isSecure: true)
                        CustomInputField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }
                    .padding(.horizontal)

                    // Register button
                    Button(action: {
                        registerUser()
                    }) {
                        Text(isLoading ? "Registering..." : "Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.title2)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isLoading)

                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(errorMessage.contains("✅") ? .green : .red)
                            .padding(.top, 8)
                    }

                    Spacer(minLength: 40)
                    
                    // Hidden navigation link
                    NavigationLink(destination: SignInView(), isActive: $navigateToHome) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func registerUser() {
        errorMessage = ""

        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true

        SupabaseAuthService.shared.signUp(email: email, password: password, username: username) { result in
            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    print("Registration response: \(response)")

                    if let user = response["user"] as? [String: Any],
                       let userId = user["id"] as? String {
                        print("User registered with ID: \(userId)")

                        UserDefaults.standard.set(userId, forKey: "user_id")
                    }

                    self.errorMessage = "Registered successfully! ✅"

                    // ✅ Navigate to SignInView instead of home
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.navigateToHome = true
                    }

                case .failure(let error):
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }

}

// Your existing CustomInputField remains the same
struct CustomInputField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .textInputAutocapitalization(placeholder=="email" ? .none : .never)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}



struct registerView_Previews: PreviewProvider {
    static var previews: some View {
        registerView()
    }
}
