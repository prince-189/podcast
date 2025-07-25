
import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @EnvironmentObject var auth: AuthManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.top, 50)

                    Text("Login")
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    VStack(spacing: 16) {
                        CustomInputField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        CustomInputField(placeholder: "Password", text: $password, isSecure: true)
                    }
                    .padding(.horizontal)

                    // Login button
                    Button(action: {
                        signInUser()
                    }) {
                        Text(isLoading ? "Logging in..." : "Login")
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
                            .multilineTextAlignment(.center)
                    }

                    // Forgot password button
                    Button("Forgot Password?") {
                        // Add forgot password logic here if needed
                    }
                    .foregroundColor(.purple)
                    .padding(.top, 8)

                    // Sign up navigation
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)

                        NavigationLink("Sign Up") {
                            registerView().environmentObject(auth)
                        }
                        .foregroundColor(.purple)
                        
                    }
                    .padding(.top, 16)

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func signInUser() {
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTrimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !emailTrimmed.isEmpty, !passwordTrimmed.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }

        isLoading = true
        errorMessage = ""

        SupabaseAuthService.shared.signIn(email: emailTrimmed, password: passwordTrimmed) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let userData):
                    print("✅ Login successful!")
                    print("User data: \(userData)")

                    if let user = userData["user"] as? [String: Any],
                       let metadata = user["user_metadata"] as? [String: Any],
                       let displayName = metadata["display_name"] as? String {
                        auth.logIn(email: emailTrimmed, displayName: displayName)
                    } else {
                        auth.logIn(email: emailTrimmed, displayName: "User")
                    }

                    alertTitle = "Success"
                    alertMessage = "You have successfully logged in!"
                    showingAlert = true

                case .failure(let err):
                    print("❌ Login failed: \(err)")
                    switch err {
                    case .custom(let msg):
                        errorMessage = "Login failed: \(msg)"
                    case .decodingError(let err):
                        errorMessage = "Failed to read response: \(err.localizedDescription)"
                    case .invalidResponse:
                        errorMessage = "Unexpected response from server. Please try again."
                    }
                }
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthManager()) // For preview
    }
}
