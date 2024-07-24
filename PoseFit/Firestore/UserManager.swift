//
//  UserManager.swift
//  MenuInspector
//
//  Created by Kiss Roland on 12/04/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum UserManagerError: Error{
    case updateError
}

class UserManager {
    
    static let shared = UserManager()
    
    private init(){}
    
    func createNewUser(auth: AuthdataResultModel) async throws{
        var userData: [String:Any] = [
            "user_id" : auth.uid,
            "date_created" : Timestamp()
            
        ]
        
        if let email = auth.email{
            userData["email"] = email
        }
        if let photoUrl = auth.photoUrl{
            userData["photo_url"] = photoUrl
        }
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    func getUser(userId: String) async throws -> DBUser{
        let user =  try await Firestore.firestore().collection("users").document( userId).getDocument(as: DBUser.self)
        
        return user
       
    }
    func getCurrentUser() async throws -> DBUser{
        let user =  try await Firestore.firestore().collection("users").document( AuthenticationManager.shared.getAuthenticatedUser().uid).getDocument(as: DBUser.self)
        
        return user

    }
    func updateCurrentUser(userData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(UserManagerError.updateError))
            return
        }
        
        Firestore.firestore().collection("users").document(currentUserId).updateData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error)")
                completion(.failure(UserManagerError.updateError))
            } else {
                completion(.success(()))
            }
        }
    }

}
