import WidgetKit
import SwiftUI
import AppIntents

struct CaddieEntry: TimelineEntry {
    let date: Date
    let club: String
    let carry: Int
}

struct CaddieProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.tylormcgill.smartgolfcaddie")!
    func placeholder(in context: Context) -> CaddieEntry { CaddieEntry(date: .now, club: "3 Wood", carry: 190) }
    func getSnapshot(in context: Context, completion: @escaping (CaddieEntry) -> Void) { completion(current()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<CaddieEntry>) -> Void) {
        completion(Timeline(entries: [current()], policy: .after(Date().addingTimeInterval(3600))))
    }
    private func current() -> CaddieEntry {
        CaddieEntry(date: .now, club: defaults.string(forKey: "lastClub") ?? "3 Wood", carry: defaults.integer(forKey: "lastCarry") == 0 ? 190 : defaults.integer(forKey: "lastCarry"))
    }
}

struct CaddieWidgetView: View {
    let entry: CaddieEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("⛳ GOLF CADDIE").font(.caption).fontWeight(.bold)
            Spacer()
            Text(entry.club).font(.title2).fontWeight(.black).foregroundStyle(.blue)
            Text("\(entry.carry) yd learned").font(.caption).foregroundStyle(.secondary)
        }.padding()
        .containerBackground(for: .widget) { Color(red: 0.94, green: 0.98, blue: 1.0) }
    }
}

struct GolfCaddieWidget: Widget {
    let kind = "GolfCaddieWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaddieProvider()) { entry in
            CaddieWidgetView(entry: entry)
        }
        .configurationDisplayName("Golf Caddie")
        .description("See your learned club recommendation at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct GolfCaddieWidgetBundle: WidgetBundle {
    var body: some Widget { GolfCaddieWidget() }
}
