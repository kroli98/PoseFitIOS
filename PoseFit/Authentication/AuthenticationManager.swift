//
//  AuthenticationManager.swift
//  MenuInspector
//
//  Created by Kiss Roland on 19/03/2024.
//

import Foundation
import FirebaseAuth

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    private init() {
        
    }
    
    func createUser(email: String, password: String) async throws -> AuthdataResultModel  {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
      
        try await UserManager.shared.createNewUser(auth: AuthdataResultModel(user: authDataResult.user))
        
        return  AuthdataResultModel(user: authDataResult.user)
    }
    func getAuthenticatedUser() throws -> AuthdataResultModel{
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthdataResultModel(user: user)
    }
    func signInUser(email: String, password: String) async -> Result<AuthDataResult, AuthError> {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            print("User signs in successfully")
            return .success(authResult)
        } catch {
            if let errorCode = AuthErrorCode.Code(rawValue: error._code) {
                switch errorCode {
                case .operationNotAllowed:
                    print("Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.")
                    return .failure(.operationNotAllowed)
                case .userDisabled:
                    print("Error: The user account has been disabled by an administrator.")
                    return .failure(.userDisabled)
                case .wrongPassword:
                    print("Error: The password is invalid or the user does not have a password.")
                    return .failure(.wrongPassword)
                case .invalidEmail:
                    print("Error: Indicates the email address is malformed.")
                    return .failure(.invalidEmail)
                default:
                    print("Error: \(error.localizedDescription)")
                    return .failure(.unknown(error))
                }
            } else {
                print("Error: \(error.localizedDescription)")
                return .failure(.unknown(error))
            }
        }
    }
    
    
    func signOutUser()
    {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}

enum AuthError: Error {
    case operationNotAllowed
    case userDisabled
    case wrongPassword
    case invalidEmail
    case unknown(Error)
}
