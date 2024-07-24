//
//  SettingsViewModel.swift
//  MenuInspector
//
//  Created by Kiss Roland on 08/04/2024.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    @Published var showAuthenticationView = false
    
    func signOut()
    {
        Task{
            AuthenticationManager.shared.signOutUser()
            
            DispatchQueue.main.async{
                self.showAuthenticationView = true
            }
            
        }
    }
}
