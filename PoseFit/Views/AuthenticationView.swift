//
//  AuthenticationView.swift
//  MenuInspector
//
//  Created by Kiss Roland on 18/03/2024.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack{
            Text("Welcome to PoseFit")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)
            Text("We give you the tool to build a better version of yourself")
                .multilineTextAlignment(.center)
                .padding()
                .font(.headline)
            Spacer()
            NavigationLink{
                
                RegisterEmailView()}
            label: {
                Text("Get started")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 40)
                    .background(Color(UIColor.systemBrown))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                
            }
            NavigationLink{
                SignInEmailView()}
            label: {
                Text("I already have an account")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 40)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                
            }
          
            
        }
        .padding()
        
    }
}

#Preview {
    NavigationStack{
        AuthenticationView()
    }
}
