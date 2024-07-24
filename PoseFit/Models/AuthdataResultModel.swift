//
//  AuthdataResultModel.swift
//  MenuInspector
//
//  Created by Kiss Roland on 19/03/2024.
//

import Foundation
import FirebaseAuth

struct AuthdataResultModel{
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}
