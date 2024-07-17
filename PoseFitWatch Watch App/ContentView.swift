//
//  ContentView.swift
//  PoseFitWatch Watch App
//
//  Created by Kiss Roland on 09/02/2024.
//

import SwiftUI


struct ContentView: View {
    
    @State var isPaused = false
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        VStack {
         
                
            Text("Fekvőtámasz")
                .font(.title3)
                .foregroundStyle(.green)
                .padding()
            SetsView(organizedExercisesGroups: connectivityManager.organizedExercisesGroups, currentGroup: connectivityManager.currentGroup, currentExercise: connectivityManager.currentExercise)
                .frame(height: 8)
         
            HStack{
                HStack{
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("68")
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
                Spacer()
                Text("2/15")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                Spacer()
                Text("00:30")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
            .font(.title3)
            
            Spacer()
            
            
            VStack{
                
                Button(action: {
                    withAnimation{
                        isPaused.toggle()
                    }
                }, label: {
                    if(!isPaused)
                    {
                        Image(systemName: "pause")
                            .font(.title2)
                            .padding(.horizontal,15)
                           
                            
                    }else{
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .padding(.horizontal,10)
                    }
                })
               
                
               
            }
            .fixedSize()
            
           
          
            Spacer()
          
            
       
            HStack{
                Button("Befejezés")
                {
                    WatchConnectivityManager.shared.send("Hello World!\n\(Date().ISO8601Format())")
                }
                .foregroundStyle(.red)
                .overlay(
                                   RoundedRectangle(cornerRadius: 25)
                                       .stroke(Color.red, lineWidth: 2)
                               )
                
                
                
                
                
                Button("Következő")
                {}
            }
            .font(.system(size: 12))
            
         
            
         
            
        }
       
        .ignoresSafeArea(.all )
    }
        
}

#Preview {
    ContentView()
}
