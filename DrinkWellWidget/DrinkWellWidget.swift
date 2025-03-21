import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = WaterEntry

    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: Date(), intake: 1500, goal: 2500)
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> ()) {
        let entry = WaterEntry(date: Date(), intake: 1500, goal: 2500)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.hilalNisanci.DrinkWell")

        let intake = userDefaults?.double(forKey: "todaysIntake") ?? 0
        let goal = userDefaults?.double(forKey: "dailyGoal") ?? 2500

        print("Widget Timeline - Intake: \(intake), Goal: \(goal)")
        
        let entry = WaterEntry(date: Date(), intake: intake, goal: goal)
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct WaterEntry: TimelineEntry {
    let date: Date
    let intake: Double
    let goal: Double
    
    var progress: Double {
        if goal <= 0 { return 0 }  // If goal is 0 or negative, progress should be 0
        return min(intake / goal, 1.0)
    }
    
    var remaining: Double {
        max(0, goal - intake)
    }
}

struct DrinkWellWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 4) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(Int(entry.intake))")
                        .font(.system(size: 16, weight: .bold))
                    Text("ml")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
            
            Text("\(max(0, min(100, Int(entry.progress * 100))))%")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(8)
        .containerBackground(.background, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        HStack {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 24, weight: .bold))
                }
            }
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "drop.fill",
                    title: "widget_consumed".localized,
                    value: "\(Int(entry.intake)) ml",
                    color: .blue
                )
                
                InfoRow(
                    icon: "target",
                    title: "widget_goal".localized,
                    value: "\(Int(entry.goal)) ml",
                    color: .green
                )
                
                InfoRow(
                    icon: "arrow.down.circle.fill",
                    title: "widget_remaining".localized,
                    value: "\(Int(entry.remaining)) ml",
                    color: .orange
                )
            }
            .padding(.leading)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

struct LargeWidgetView: View {
    let entry: Provider.Entry

    var body: some View {
        VStack {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 15)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(entry.intake))")
                        .font(.system(size: 36, weight: .bold))
                    Text("ml")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("\(Int(entry.progress * 100))%")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            HStack(spacing: 20) {
                StatView(
                    title: "widget_goal".localized,
                    value: "\(Int(entry.goal)) ml",
                    icon: "target",
                    color: .green
                )
                
                StatView(
                    title: "widget_remaining".localized,
                    value: "\(Int(entry.remaining)) ml",
                    icon: "arrow.down.circle.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.caption)
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.callout)
                .bold()
        }
    }
}

struct DrinkWellWidget: Widget {
    let kind: String = "DrinkWellWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DrinkWellWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .widgetURL(URL(string: "drinkwell://widget")) 
            } else {
                DrinkWellWidgetEntryView(entry: entry)
                    .padding()
                    .background()
                    .widgetURL(URL(string: "drinkwell://widget")) 
            }
        }
        .configurationDisplayName("widget_display_name".localized)
        .description("widget_description".localized)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews
// Widget previews
#Preview(as: .systemSmall) {
    DrinkWellWidget()
} timeline: {
    WaterEntry(date: .now, intake: 1500, goal: 2500)
    WaterEntry(date: .now, intake: 2000, goal: 2500)
}

#Preview(as: .systemMedium) {
    DrinkWellWidget()
} timeline: {
    WaterEntry(date: .now, intake: 1500, goal: 2500)
    WaterEntry(date: .now, intake: 2000, goal: 2500)
}

#Preview(as: .systemLarge) {
    DrinkWellWidget()
} timeline: {
    WaterEntry(date: .now, intake: 1500, goal: 2500)
    WaterEntry(date: .now, intake: 2000, goal: 2500)
}

// Previews for different scenarios
#Preview("Goal Exceeded", as: .systemSmall) {
    DrinkWellWidget()
} timeline: {
    WaterEntry(date: .now, intake: 3000, goal: 2500)
}

#Preview("Low Progress", as: .systemSmall) {
    DrinkWellWidget()
} timeline: {
    WaterEntry(date: .now, intake: 500, goal: 2500)
}
