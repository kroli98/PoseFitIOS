//
//  SignInViewModel.swift
//  MenuInspector
//
//  Created by Kiss Roland on 19/03/2024.
//

import Foundation


final class SignInViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var showScannerView = false
    @Published var showAlert = false
    @Published var alertText = ""
    
    func signIn(){
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password is found.")
            return
        }
        
      
        Task {
             let result = await AuthenticationManager.shared.signInUser(email: email, password: password)
             var tempAlertText = ""
             switch result {
             case .success:
                 showScannerView = true
             case .failure(let error):
                 switch error {
                 case .operationNotAllowed:
                     tempAlertText = "Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console."
                 case .userDisabled:
                     tempAlertText = "The user account has been disabled by an administrator."
                 case .wrongPassword:
                     tempAlertText = "The password is invalid or the user does not have a password."
                 case .invalidEmail:
                     tempAlertText = "Indicates the email address is malformed."
                 case .unknown(let underlyingError):
                     tempAlertText = underlyingError.localizedDescription
                 }
                 DispatchQueue.main.async{
                     self.alertText = tempAlertText
                     self.showAlert = true
                 }
                
             }
         }
                
            
        
    }
}
