//
//  SignInEmailView.swift
//  MenuInspector
//
//  Created by Kiss Roland on 19/03/2024.
//

import SwiftUI

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInViewModel()
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
                viewModel.signIn()
            }, label: {
                Text("Sign in")
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
        .navigationTitle("Sign in with email")
        .fullScreenCover(isPresented: $viewModel.showScannerView) {
            
            NavigationStack {
                CustomTabBar(selectedTab: .home, allCases: CustomTabBarItem.allCases)
                    .environmentObject(navigationCoordinator)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
            }
                  
                }
        .alert(isPresented: $viewModel.showAlert){
            Alert(title: Text("Error occured!"), message: Text(viewModel.alertText), dismissButton: .default(Text("OK!")))

        }
    }
}

#Preview {
    NavigationStack{
        SignInEmailView()
    }
}
