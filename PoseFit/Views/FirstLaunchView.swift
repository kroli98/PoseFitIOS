
import SwiftUI

struct FirstLaunchView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var name: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var birthDate = Date()
    @State private var gender = "Férfi"
    var isFormComplete: Bool {
        return !name.isEmpty && !height.isEmpty && !weight.isEmpty && gender != ""
    }

    
    private let genders = ["Férfi", "Nő", "Egyéb"]
    

    var body: some View {
      
            
            List {
                Section{
                    Text("Üdvözöljük!")
                        .font(.largeTitle)
                    Text("Kérem töltse ki a következő mezőket!")
                        .font(.title2)
                }
                    .listRowBackground(Color.clear)
                       
                Section(header: Text("Személyes adatok")) {
                    SettingsRow(title: "Név", text: $name)
                    SettingsRow(title: "Magasság (cm)", text: $height, isNumberInput: true)
                    SettingsRow(title: "Súly (kg)", text: $weight, isNumberInput: true)
                    DatePickerRow(title: "Születési idő", date: $birthDate)
                    Picker("Nem", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                   
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button(action: saveUserData) {
                            Text("Mentés")
                                .padding()
                                .foregroundColor(Color(UIColor.label))
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray)
                                )
                                .shadow(radius: 15)
                        }
                        .disabled(!isFormComplete)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.automatic)
            .navigationBarBackButtonHidden(true)
            .onAppear{
                navigationCoordinator.isNavigating = true
            }
        
    }
    func saveUserData() {
        
        guard isFormComplete else { return }
        UserDefaults.standard.setValue(name, forKey: "UserName")
        UserDefaults.standard.setValue(height, forKey: "UserHeight")
        UserDefaults.standard.setValue(weight, forKey: "UserWeight")
        UserDefaults.standard.setValue(birthDate, forKey: "UserBirthDate")
        UserDefaults.standard.setValue(gender, forKey: "UserGender")
        
        let persistenceController = PersistenceController.shared
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: CustomTabBar(selectedTab: .home, allCases: CustomTabBarItem.allCases)
                .environmentObject(navigationCoordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext))
           
                window.makeKeyAndVisible()
        }
    }
}

struct FirstLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLaunchView()
    }
}

