import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var preferences: UserPreferences
    @Binding var isFirstLaunch: Bool
    
    @State private var username = ""
    @State private var height: Double? = nil
    @State private var weight: Double? = nil
    @State private var currentPage = 0
    @State private var selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    @State private var refreshView = false
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case username, height, weight
    }
    
    // Function to change the language
    private func changeLanguage(to languageCode: String) {
        selectedLanguage = languageCode
        
        // Set user defaults
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        if let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: bundlePath) {
                LocalizationManager.shared.currentBundle = bundle
        }

        withAnimation {
            refreshView.toggle()
        }
    }

    private var isFormValid: Bool {
        // Validation for the second page (personal information)
        if currentPage == 1 {
            // Username must be at least 2 characters
            let isUsernameValid = !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && username.count >= 2
            
            // Height and weight must be within reasonable values
            let isHeightValid = height != nil && height! >= 120 && height! <= 220
            let isWeightValid = weight != nil && weight! >= 40 && weight! <= 200
            
            return isUsernameValid && isHeightValid && isWeightValid
        }
        
        // Always valid for other pages
        return true
    }

    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(currentPage >= index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.top)
            
            Spacer()
            
            // Content
            TabView(selection: $currentPage) {
                // Welcome screen
                VStack(spacing: 20) {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("welcome_title".localized)
                        .font(.title.bold())
                        .accessibilityIdentifier("welcome_title")
                    
                    Text("welcome_description".localized)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer().frame(height: 20)
                    
                    // Language selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("language_section".localized)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("", selection: $selectedLanguage) {
                            Text("English").tag("en")
                            Text("Türkçe").tag("tr")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .onChange(of: selectedLanguage) { _, newValue in
                            changeLanguage(to: newValue)
                        }
                    }
                }
                .tag(0)
                
                // Personal information screen
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("personal_info_title".localized)
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                        
                        Text("personal_info_description".localized)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Group {
                            Text("name_label".localized)
                                .font(.headline)
                            
                            TextField("name_placeholder".localized, text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.next)
                                .focused($focusedField, equals: .username)
                                .onSubmit {
                                    focusedField = .height
                                }
                                .padding(.bottom)
                            
                            Text("height_label".localized)
                                .font(.headline)
                            HStack {
                                TextField("height_placeholder".localized, value: $height, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .height)
                                Text("cm_unit".localized)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom)
                            
                            Text("weight_label".localized)
                                .font(.headline)
                            HStack {
                                TextField("weight_placeholder".localized, value: $weight, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .weight)
                                Text("kg_unit".localized)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
                .tag(1)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button("done_button".localized) {
                            hideKeyboard()
                        }
                    }
                }
                
                // Completion screen
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("great_title".localized)
                        .font(.title.bold())
                    
                    Text("info_saved_message".localized)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("daily_recommendation".localized)
                        .fontWeight(.medium)
                        .padding(.top)
                    
                    Text("\(Int((weight ?? 70) * 35)) ml")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            // Buttons
            HStack {
                if currentPage > 0 {
                    Button("back_button".localized) {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                if currentPage < 2 {
                    Button("next_button".localized) {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentPage == 1 && !isFormValid)
                    .opacity(currentPage == 1 && !isFormValid ? 0.5 : 1)
                } else {
                    Button("start_button".localized) {
                        // Save information
                        preferences.username = username
                        preferences.userHeight = height
                        preferences.userWeight = weight
                        if let userWeight = weight {
                            preferences.dailyGoal = userWeight * 35 // Weight x 35 ml
                        } else {
                            preferences.dailyGoal = 2500
                        }
                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                        UserDefaults.standard.synchronize()

                        // Complete first launch
                        isFirstLaunch = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .padding()
        .id(refreshView) // Refresh the entire view when the language changes
        .onAppear {
            // Load the current language
            if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
                selectedLanguage = savedLanguage
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            // Extra listener to catch language changes instantly
            DispatchQueue.main.async {
                self.refreshView.toggle()
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    OnboardingView(isFirstLaunch: .constant(true))
        .environmentObject(UserPreferences.shared)
}