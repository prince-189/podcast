import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        // Load login state from UserDefaults
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "is_logged_in")
    }

    func logIn(email: String, displayName: String) {
        self.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "is_logged_in")
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(displayName, forKey: "user_display_name")
    }

    func logOut() {
        self.isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "is_logged_in")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_display_name")
        UserDefaults.standard.removeObject(forKey: "user_id")
    }
}
