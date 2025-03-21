//
//  NotificationManager.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import Foundation
import UserNotifications
import SwiftUI
import UIKit  // For UINotificationFeedbackGenerator

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    // Singleton instance
    static let shared = NotificationManager()
    
    // Notification center
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Base value for notification identifier
    private let reminderIdentifierBase = "com.drinkwell.waterreminder"
    
    // User notification permissions
    @Published var isNotificationsAuthorized = false
    // To track notification permission statuses
    @Published var notificationPermissionStatus: NotificationPermissionStatus = .unknown

    // Enum representing permission statuses
    enum NotificationPermissionStatus {
        case unknown
        case granted
        case denied
        case notDetermined
    }

    // MARK: - Initializer
    
    private override init() {
        super.init() // Required call to super.init() because we inherit from NSObject
        // Set the delegate
        setupNotificationDelegate()
        // Set up notification categories
        setupNotificationCategories()
        // Check current notification authorization status
        checkAuthorizationStatus()
    }

    // MARK: - Delegate Setup
    
    /// Sets the delegate for the notification center
    func setupNotificationDelegate() {
        notificationCenter.delegate = self
    }

    // MARK: - Authorization Handling
    
    /// Checks the current notification authorization status
    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isNotificationsAuthorized = settings.authorizationStatus == .authorized
                
                // Also save the permission status using the enum
                switch settings.authorizationStatus {
                case .authorized:
                    self?.notificationPermissionStatus = .granted
                case .denied:
                    self?.notificationPermissionStatus = .denied
                case .notDetermined:
                    self?.notificationPermissionStatus = .notDetermined
                default:
                    self?.notificationPermissionStatus = .unknown
                }
            }
        }
    }
    
    /// Requests notification permissions from the user
    func requestAuthorization() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // Request permission for the first time
                    self?.requestNewPermission()
                } else if settings.authorizationStatus == .denied {
                    // Permission was previously denied
                    self?.notificationPermissionStatus = .denied
                } else if settings.authorizationStatus == .authorized {
                    self?.notificationPermissionStatus = .granted
                    self?.isNotificationsAuthorized = true
                }
            }
        }
    }

    // Request notification permission for the first time
    private func requestNewPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.isNotificationsAuthorized = true
                    self?.notificationPermissionStatus = .granted
                } else {
                    self?.isNotificationsAuthorized = false
                    self?.notificationPermissionStatus = .denied
                    
                    if let error = error {
                        print("Failed to get notification permission: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // Open the settings app
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    // Handle previously denied permissions (to be used in SettingsView)
    func handlePreviouslyDeniedPermission() {
        // Redirect to the settings app
        openAppSettings()
    }
    
    // MARK: - Notification Scheduling
    
    /// Schedules notifications based on user settings
    func scheduleReminders(frequency: Int, startHour: Int = 8, endHour: Int = 22) {
        // First, cancel all existing notifications
        cancelAllReminders()
        
        // Exit if no notification permission
        guard isNotificationsAuthorized else {
            #if DEBUG
            print("debug_no_permission".localized)
            #endif
            return
        }
        
        // Calculate notification hours
        var notificationHours: [Int] = []
        
        if frequency == 1 {
            // Every hour: Add all hours
            notificationHours = Array(startHour...endHour)
        } else {
            // Calculate hours based on the specified frequency
            var currentHour = startHour
            while currentHour <= endHour {
                notificationHours.append(currentHour)
                currentHour += frequency
            }
        }
        
        #if DEBUG
        print("\("debug_notification_hours".localized) \(notificationHours)")
        #endif
        
        // Schedule notifications for each hour
        for hour in notificationHours {
            scheduleReminderAt(hour: hour)
        }
    }
    
    /// Schedules a notification at a specific hour
    private func scheduleReminderAt(hour: Int) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "notification_title".localized
        let messages = [
            "notification_message_1".localized,
            "notification_message_2".localized,
            "notification_message_3".localized,
            "notification_message_4".localized
        ]
        content.body = messages.randomElement() ?? messages[0]
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        content.categoryIdentifier = "WATER_REMINDER"
        // Create the notification trigger (daily at a specific hour)
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the notification request
        let identifier = "\(reminderIdentifierBase)_\(hour)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                #if DEBUG
                print("\("debug_notification_failed".localized) \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                print("\("debug_notification_scheduled".localized) \(hour):00")
                #endif
            }
        }
    }

    // Set up notification categories and actions
    private func setupNotificationCategories() {
        // "Drank" action
        let drankAction = UNNotificationAction(
            identifier: "DRANK_ACTION",
            title: "drank_action".localized,
            options: .foreground
        )
        
        let waterCategory = UNNotificationCategory(
            identifier: "WATER_REMINDER",
            actions: [drankAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([waterCategory])
    }

    /// Schedules a custom notification with specific text and time
    func scheduleCustomReminder(title: String, body: String, hour: Int, minute: Int, identifier: String? = nil) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        // Create the notification trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the notification request
        let reminderID = identifier ?? "\(reminderIdentifierBase)_custom_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                #if DEBUG
                print("Failed to schedule notification: \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                print("Notification scheduled successfully for \(hour):00")
                #endif
            }
        }
    }
    
    // MARK: - Notification Cancellation
    
    /// Cancels all scheduled notifications
    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
        #if DEBUG
        print("debug_notifications_cancelled".localized)
        #endif
    }
    
    /// Cancels a specific notification by identifier
    func cancelReminder(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        #if DEBUG
        print("\("debug_notification_cancelled".localized) \(identifier)")
        #endif
    }
    
    // MARK: - Settings Updates
    
    /// Updates notification settings from SettingsView
    func updateFromSettings(isEnabled: Bool, frequency: Int) {
        if isEnabled {
            // Enable and schedule notifications
            if !isNotificationsAuthorized {
                requestAuthorization()
            }
            scheduleReminders(frequency: frequency)
        } else {
            // Cancel notifications
            cancelAllReminders()
        }
    }
    
    // MARK: - Testing and Debugging

    #if DEBUG
    /// Sends a test notification immediately
    func sendTestNotification() {
        // Extra simulation for the simulator
        #if targetEnvironment(simulator)
        simulateTestNotification()
        #endif
        
        guard isNotificationsAuthorized else {
            print("No notification permission, test notification failed")
            requestAuthorization()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "test_notification_title".localized
        content.body = "test_notification_message".localized
        content.sound = UNNotificationSound.default
        
        // Print content to console (for debugging)
        print("💧 NOTIFICATION CONTENT: \(content.title) - \(content.body)")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "\(reminderIdentifierBase)_test", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send test notification: \(error.localizedDescription)")
            } else {
                print("Test notification will be sent in 3 seconds")
            }
        }
    }

    /// Simulates a notification for testing in the simulator
    func simulateTestNotification() {
        let title = "test_notification_title".localized
        let body = "test_notification_message".localized
        
        // Print notification content to console
        print("\n🔔 NOTIFICATION SIMULATION 🔔")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 \(title)")
        print("📄 \(body)")
        print("⏰ \(Date().formatted(date: .numeric, time: .standard))")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
        
        // Provide haptic feedback to simulate the notification
        #if !targetEnvironment(simulator)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        #endif
    }
    #endif


}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager {

    // Display notifications while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notifications while the app is in the foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification actions and tapping on notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Reset the notification badge count when the notification is opened
        if #available(iOS 17.0, *) {
            center.setBadgeCount(0) { error in
                if let error = error {
                    #if DEBUG
                    print("Failed to reset badge: \(error.localizedDescription)")
                    #endif
                }
            }
        } else {
            // Use the old method for iOS versions before 17
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        // Handle notification actions
        let identifier = response.actionIdentifier
        
        if identifier == "DRANK_ACTION" {
            // User selected the "I Drank" action
            // Add a water intake record here
            #if DEBUG
            print("User selected 'I Drank' action")
            #endif

            // Send a notification to open the AddWater view
            NotificationCenter.default.post(
                name: Notification.Name("OpenAddWaterView"),
                object: nil
            )
        }
        
        completionHandler()
    }
    
    // Function to manually reset the notification badge count
    func resetBadgeCount() {
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    #if DEBUG
                    print("Failed to reset badge: \(error.localizedDescription)")
                    #endif
                }
            }
        } else {
            // Use the old method for iOS versions before 17
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
