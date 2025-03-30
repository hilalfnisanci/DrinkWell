//
//  DrinkWellApp.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import SwiftUI
import SwiftData
import UserNotifications
import GoogleMobileAds 

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}

@main
struct DrinkWellApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var preferences = UserPreferences.shared
    @State private var isLaunchScreenShowing = true
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @State private var selectedTab = 0
    
    init() {

        if let languageCode = UserDefaults.standard.string(forKey: "selectedLanguage") {
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }

        // Check and configure notifications
        if UserPreferences.shared.notificationsEnabled {
            NotificationManager.shared.checkAuthorizationStatus()
            
            let enabled = UserPreferences.shared.notificationsEnabled
            let frequency = UserPreferences.shared.notificationFrequency
            // Schedule notifications (if permission is granted)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if NotificationManager.shared.isNotificationsAuthorized {
                    NotificationManager.shared.updateFromSettings(
                        isEnabled: enabled, 
                        frequency: frequency
                    )
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunchScreenShowing {
                    LaunchScreen()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            // Remove Launch Screen after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isLaunchScreenShowing = false
                                }
                            }
                        }
                } else {
                    if isFirstLaunch {
                        OnboardingView(isFirstLaunch: $isFirstLaunch)
                            .environmentObject(preferences)
                            .preferredColorScheme(.light)
                    } else {
                        ContentView(selectedTab: $selectedTab)
                            .preferredColorScheme(preferences.isDarkMode ? .dark : .light)
                            .environmentObject(preferences)
                    }
                }
            }
            .onAppear {
                // Reset notifications
                NotificationManager.shared.resetBadgeCount()
            }
            .onOpenURL { url in
                if url.scheme == "drinkwell" {
                    selectedTab = 0
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                // Restart the app when the language changes
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let window = windowScene.windows.first
                else { return }
                
                window.rootViewController = UIHostingController(rootView: ContentView(selectedTab: $selectedTab))
            }
        }
    }
}