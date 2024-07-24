import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FirstLaunchView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    let persistenceController = PersistenceController.shared
    @State private var name: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var birthDate = Date()
    @State private var gender = "Férfi"
    @State private var shouldNavigateToCustomTabBar = false
    var isFormComplete: Bool {
        return !name.isEmpty && !height.isEmpty && !weight.isEmpty && gender != ""
    }

    private let genders = ["Férfi", "Nő", "Egyéb"]

    var body: some View {
        List {
            Section {
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
        .onAppear {
            navigationCoordinator.isNavigating = true
        }
        NavigationLink(destination:  CustomTabBar(selectedTab: .home, allCases: CustomTabBarItem.allCases)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(navigationCoordinator)
                       
            , isActive: $shouldNavigateToCustomTabBar) {
            EmptyView()
        }
    }

    func saveUserData() {
        guard isFormComplete else { return }

        let userData: [String: Any] = [
            "name": name,
            "height": height,
            "weight": weight,
            "birthDate": Timestamp(date: birthDate),
            "gender": gender
        ]


        UserManager.shared.updateCurrentUser(userData: userData) { result in
                switch result {
                case .success():
                    print("User data updated successfully")
                    shouldNavigateToCustomTabBar = true
                case .failure(let error):
                    print("Failed to update user data: \(error.localizedDescription)")
                    
                }
            }    }
}

struct FirstLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLaunchView()
            
    }
}
