
import SwiftUI
import CoreData

enum ActiveAlert: Identifiable {
    case deleteConfirmation, missingData

    var id: Int {
        hashValue
    }
}


struct SettingsView: View {
    @State private var name = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var birthday = Date()
    @State private var selectedGender = Gender.male
    @State private var showAlert = false
    @State private var buttonScale: CGFloat = 1.0
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteConfirmation = false
    @State private var deleteAction: (() -> Void)?
    @State private var shouldNavigateToFirstLaunch = false
    @State private var activeAlert: ActiveAlert?





    var body: some View {
        
     
            VStack{
                List {
                    Section(header: Text("Személyes adatok")) {
                        SettingsRow(title: "Név", text: $name)
                        SettingsRow(title: "Magasság (cm)", text: $height, isNumberInput: true)
                        SettingsRow(title: "Súly (kg)", text: $weight, isNumberInput: true)
                        DatePickerRow(title: "Születési idő", date: $birthday)
                        
                        PickerRow(title: "Nem", selectedGender: $selectedGender)
                        
                    }
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    Section(header: Text("Adatok törlése")) {
                        
                        Button(action: {
                            showingDeleteConfirmation = true
                            deleteAction = deleteAllExercises
                            activeAlert = .deleteConfirmation
                            print("Első gomb lenyomva")
                        }) {
                            Text("Gyakorlati napló törlése")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showingDeleteConfirmation = true
                            deleteAction = deleteAllData
                            activeAlert = .deleteConfirmation
                            print("Adatok törlése")
                        }) {
                            Text("Összes adat törlése")
                                .foregroundColor(.red)
                        }
                       
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                buttonScale = 0.95
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    buttonScale = 1.0
                                }
                            }
                            
                            if name.isEmpty || height.isEmpty || weight.isEmpty {
                                showAlert = true
                                activeAlert = .missingData
                                return
                            }
                            saveUserSettings()
                        }) {
                            Text("Mentés")
                                .padding()
                                .foregroundColor(Color(UIColor.label))
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray)
                                )
                            
                        }
                        .scaleEffect(buttonScale)
                        .shadow(radius: 10)
                        
                        
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    
                    
                    
                    
                    
                    
                }
                
               
                
                .listStyle(.automatic)
                
                .onAppear {
                    loadUserSettings()
                }
                .scrollContentBackground(.hidden)
                
                NavigationLink(destination: FirstLaunchView(), isActive: $shouldNavigateToFirstLaunch) {
                    EmptyView()
                }
             
                
                
                
                
                
            }
            .alert(item: $activeAlert) { currentAlert in
                switch currentAlert {
                case .deleteConfirmation:
                    return Alert(
                        title: Text("Megerősítés"),
                        message: Text("Biztosan törölni szeretné az adatokat?"),
                        primaryButton: .destructive(Text("Törlés")) {
                            deleteAction?()
                        },
                        secondaryButton: .cancel(Text("Mégsem"))
                    )
                case .missingData:
                    return Alert(title: Text("Hiányzó adatok"), message: Text("Kérjük, töltse ki az összes mezőt."), dismissButton: .default(Text("OK")))
                }
            }

       
     

      

            
            
            .ignoresSafeArea(.all, edges: .bottom)
            
        
        
        
        
    }
        
    
    func deleteAllExercises() {
        let fetchRequestExercises: NSFetchRequest<NSFetchRequestResult> = CompletedExercise.fetchRequest()
        let batchDeleteRequestExercises = NSBatchDeleteRequest(fetchRequest: fetchRequestExercises)

        let fetchRequestWorkouts: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let batchDeleteRequestWorkouts = NSBatchDeleteRequest(fetchRequest: fetchRequestWorkouts)

        do {
            try viewContext.execute(batchDeleteRequestExercises)
            try viewContext.execute(batchDeleteRequestWorkouts)
        } catch {
            print("Error deleting exercises: \(error)")
        }
       }
    
    func deleteAllData() {
        let fetchRequestExercises: NSFetchRequest<NSFetchRequestResult> = CompletedExercise.fetchRequest()
        let batchDeleteRequestExercises = NSBatchDeleteRequest(fetchRequest: fetchRequestExercises)

        let fetchRequestWorkouts: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let batchDeleteRequestWorkouts = NSBatchDeleteRequest(fetchRequest: fetchRequestWorkouts)

        do {
            try viewContext.execute(batchDeleteRequestExercises)
            try viewContext.execute(batchDeleteRequestWorkouts)
        } catch {
            print("Error deleting data: \(error)")
        }

        UserDefaults.standard.removeObject(forKey: "UserName")
        UserDefaults.standard.removeObject(forKey: "UserHeight")
        UserDefaults.standard.removeObject(forKey: "UserWeight")
        UserDefaults.standard.removeObject(forKey: "UserBirthDate")
        UserDefaults.standard.removeObject(forKey: "UserGender")

        name = ""
        height = ""
        weight = ""
        birthday = Date()
        selectedGender = .male

        shouldNavigateToFirstLaunch = true
    }



    func loadUserSettings() {
            if let savedName = UserDefaults.standard.string(forKey: "UserName") {
                name = savedName
            }

            if let savedHeight = UserDefaults.standard.string(forKey: "UserHeight") {
                height = savedHeight
            }

            if let savedWeight = UserDefaults.standard.string(forKey: "UserWeight") {
                weight = savedWeight
            }

            if let savedBirthday = UserDefaults.standard.object(forKey: "UserBirthDate") as? Date {
                birthday = savedBirthday
            }

            if let savedGender = UserDefaults.standard.string(forKey: "UserGender"), let gender = Gender(rawValue: savedGender) {
                selectedGender = gender
            }
        }

        func saveUserSettings() {
            if name.isEmpty || height.isEmpty || weight.isEmpty {
                        showAlert = true
                        return
                    }
            UserDefaults.standard.setValue(name, forKey: "UserName")
            UserDefaults.standard.setValue(height, forKey: "UserHeight")
            UserDefaults.standard.setValue(weight, forKey: "UserWeight")
            UserDefaults.standard.setValue(birthday, forKey: "UserBirthDate")
            UserDefaults.standard.setValue(selectedGender.rawValue, forKey: "UserGender")
        }
}

struct SettingsRow: View {
    let title: String
    @Binding var text: String
    var isNumberInput: Bool = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField(title, text: $text)
                .multilineTextAlignment(.trailing)
                .keyboardType(isNumberInput ? .numberPad : .default)
        }
    }
}


struct DatePickerRow: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
        }
    }
}

struct PickerRow: View {
    let title: String
    @Binding var selectedGender: Gender

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: $selectedGender) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue)
                }
            }
            .pickerStyle(DefaultPickerStyle())
        }
    }
}

enum Gender: String, CaseIterable {
    case male = "Férfi"
    case female = "Nő"
    case other = "Egyéb"
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
