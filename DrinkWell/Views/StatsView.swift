import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var viewModel: WaterViewModel
    @EnvironmentObject private var preferences: UserPreferences
    
    // MARK: - Computed Properties
    
    // Last 7 days data
    private var lastSevenDays: [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        _ = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        return (0...6).compactMap { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let intakes = viewModel.waterIntakes.filter {
                $0.timestamp >= dayStart && $0.timestamp < dayEnd
            }
            let total = intakes.reduce(0) { $0 + $1.amount }
            
            return (date: date, amount: total)
        }.reversed()
    }
    
    // Number of days reached the goal
    private var daysReachedGoal: Int {
        let groupedIntakes = Dictionary(grouping: viewModel.waterIntakes) { intake in
            Calendar.current.startOfDay(for: intake.timestamp)
        }
        
        return groupedIntakes.filter { _, intakes in
            let total = intakes.reduce(0) { $0 + $1.amount }
            return total >= viewModel.dailyGoal
        }.count
    }
    
    // Days with highest and lowest water intake
    private var extremeDays: (max: (date: Date, amount: Double)?, min: (date: Date, amount: Double)?) {
        let groupedIntakes = Dictionary(grouping: viewModel.waterIntakes) { intake in
            Calendar.current.startOfDay(for: intake.timestamp)
        }
        
        let dailyTotals = groupedIntakes.map { (date, intakes) in
            (date: date, amount: intakes.reduce(0) { $0 + $1.amount })
        }
        
        return (
            max: dailyTotals.max(by: { $0.amount < $1.amount }),
            min: dailyTotals.min(by: { $0.amount < $1.amount })
        )
    }

    // MARK: - New computed property for monthly data
    private var monthlyData: [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        var result: [(Date, Double)] = []
        var currentDate = startOfMonth
        
        while currentDate <= endOfMonth {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let intakes = viewModel.waterIntakes.filter {
                $0.timestamp >= dayStart && $0.timestamp < dayEnd
            }
            let total = intakes.reduce(0) { $0 + $1.amount }
            
            result.append((currentDate, total))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    // MARK: - Monthly average
    private var monthlyAverage: Double {
        let totalAmount = monthlyData.reduce(0) { $0 + $1.amount }
        return totalAmount / Double(monthlyData.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Last 7 days chart
                    ChartSection(
                        title: "last_seven_days".localized,
                        subtitle: "daily_water_intake".localized
                    ) {
                        Chart(lastSevenDays, id: \.date) { day in
                            BarMark(
                                x: .value("day_label".localized, day.date, unit: .day),
                                y: .value("amount_label".localized, preferences.useMetricSystem ? day.amount : day.amount * 0.033814)
                            )
                            .foregroundStyle(Color.blue.gradient)
                            
                            RuleMark(
                                y: .value("target_label".localized, preferences.useMetricSystem ? viewModel.dailyGoal : viewModel.dailyGoal * 0.033814)
                            )
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisValueLabel(format: .dateTime.weekday())
                            }
                        }
                        .frame(height: 200)
                    }

                    ChartSection(
                        title: "monthly_view".localized,
                        subtitle: "daily_water_intake_and_average".localized
                    ) {
                        Chart {
                            ForEach(monthlyData, id: \.date) { day in
                                LineMark(
                                    x: .value("Gün", day.date, unit: .day),
                                    y: .value("Miktar", preferences.useMetricSystem ? 
                                        day.amount : day.amount * 0.033814)
                                )
                                .foregroundStyle(Color.blue.gradient)
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                            }
                            
                            // Average line
                            RuleMark(
                                y: .value("Ortalama", preferences.useMetricSystem ? 
                                    monthlyAverage : monthlyAverage * 0.033814)
                            )
                            .foregroundStyle(.green)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            
                            // Target line
                            RuleMark(
                                y: .value("Hedef", preferences.useMetricSystem ? 
                                    viewModel.dailyGoal : viewModel.dailyGoal * 0.033814)
                            )
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                if let date = value.as(Date.self) {
                                    let day = Calendar.current.component(.day, from: date)
                                    if day == 1 || day % 5 == 0 {
                                        AxisValueLabel {
                                            Text("\(day)")
                                                .font(.caption2)
                                        }
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 200)
                        
                        // Legend
                        HStack(spacing: 16) {
                            LegendItem(color: .blue, label: "legend_daily_intake".localized)
                            LegendItem(color: .green, label: "legend_monthly_average".localized)
                            LegendItem(color: .red, label: "legend_target".localized)
                        }
                        .font(.caption)
                        .padding(.top, 8)
                    }
                    
                    // Monthly statistics card
                    StatCard(
                        title: "monthly_average_title".localized,
                        value: preferences.useMetricSystem ?
                            "\(Int(monthlyAverage)) ml" :
                            String(format: "%.1f oz", monthlyAverage * 0.033814),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                    .padding(.horizontal)

                    // Statistics cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        if let maxDay = extremeDays.max {
                            StatCard(
                                title: "highest_intake".localized,
                                value: preferences.useMetricSystem ?
                                    "\(Int(maxDay.amount)) ml" :
                                    String(format: "%.1f oz", maxDay.amount * 0.033814),
                                subtitle: maxDay.date.formatted(date: .abbreviated, time: .omitted),
                                icon: "arrow.up.circle.fill",
                                color: .blue
                            )
                        }
                        
                        if let minDay = extremeDays.min {
                            StatCard(
                                title: "lowest_intake".localized,
                                value: preferences.useMetricSystem ?
                                    "\(Int(minDay.amount)) ml" :
                                    String(format: "%.1f oz", minDay.amount * 0.033814),
                                subtitle: minDay.date.formatted(date: .abbreviated, time: .omitted),
                                icon: "arrow.down.circle.fill",
                                color: .orange
                            )
                        }
                        
                        StatCard(
                            title: "target_reached".localized,
                            value: String(format: "days_count".localized, daysReachedGoal),
                            icon: "target",
                            color: .green
                        )
                        

                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("stats_title".localized)
        }
    }
}

// MARK: - Helper Views

struct ChartSection<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            content
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2.bold())
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - New Helper View
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(WaterViewModel())
        .environmentObject(UserPreferences.shared)
}
