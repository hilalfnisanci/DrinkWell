//
//  DrinkWellWidgetControl.swift
//  DrinkWellWidget
//
//  Created by Hilal on 19.03.2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct DrinkWellWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "hilalNisanci.DrinkWell.DrinkWellWidget",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "widget_start_timer".localized,
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(
                    isRunning ? "widget_timer_on".localized : "widget_timer_off".localized, 
                    systemImage: "timer"
                )
            }
        }
        .displayName(LocalizedStringResource("widget_timer"))
        .description(LocalizedStringResource("widget_timer_description"))
    }
}

extension DrinkWellWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
