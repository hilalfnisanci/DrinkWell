//
//  DrinkWellWidgetLiveActivity.swift
//  DrinkWellWidget
//
//  Created by Hilal on 19.03.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DrinkWellWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DrinkWellWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DrinkWellWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DrinkWellWidgetAttributes {
    fileprivate static var preview: DrinkWellWidgetAttributes {
        DrinkWellWidgetAttributes(name: "World")
    }
}

extension DrinkWellWidgetAttributes.ContentState {
    fileprivate static var smiley: DrinkWellWidgetAttributes.ContentState {
        DrinkWellWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DrinkWellWidgetAttributes.ContentState {
         DrinkWellWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DrinkWellWidgetAttributes.preview) {
   DrinkWellWidgetLiveActivity()
} contentStates: {
    DrinkWellWidgetAttributes.ContentState.smiley
    DrinkWellWidgetAttributes.ContentState.starEyes
}
