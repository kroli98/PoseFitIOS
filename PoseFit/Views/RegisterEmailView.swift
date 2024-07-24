//
//  RegisterEmailView.swift
//  MenuInspector
//
//  Created by Kiss Roland on 20/03/2024.
//

import SwiftUI

struct RegisterEmailView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    let persistenceController = PersistenceController.shared


    var body: some View {
        VStack{
           
            TextField("Email...", text: $viewModel.email )
                .padding()
                .background(.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
            
            SecureField("Password...", text: $viewModel.password )
                .padding()
                .background(.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
            
            Button(action: {
                viewModel.register()
            }, label: {
                Text("Sign up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 40)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                
            })
               
            
            Spacer()
            
        }
        .padding()
        .navigationTitle("Sign up with email")
        .fullScreenCover(isPresented: $viewModel.showScannerView) {
                    NavigationStack {
                        FirstLaunchView()
                            .environmentObject(navigationCoordinator)
                    }
                  
                }
    }
}

#Preview {
    NavigationStack{
        RegisterEmailView()
    }
}
