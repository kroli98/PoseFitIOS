//
//  RegisterViewModel.swift
//  MenuInspector
//
//  Created by Kiss Roland on 20/03/2024.
//

import Foundation


@MainActor
final class RegisterViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var showScannerView = false
    
    func register(){
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password is found.")
            return
        }
        
        Task{
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                DispatchQueue.main.async{
                    self.showScannerView = true
                }
               
                
            }catch{
                print("Error: \(error)")
            }
        }
    }
}
