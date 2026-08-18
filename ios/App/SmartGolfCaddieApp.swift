import SwiftUI
import WidgetKit

@main
struct SmartGolfCaddieApp: App {
    @StateObject private var model = CaddieModel()
    var body: some Scene { WindowGroup { ContentView(model: model) } }
}

final class CaddieModel: ObservableObject {
    @Published var holeYards = ""
    @Published var actualYards = ""
    @Published var learnedCarry = 0
    @Published var recommendedClub = ""

    private let defaults = UserDefaults(suiteName: "group.com.tylormcgill.smartgolfcaddie")!
    private let starting: [String: Int] = ["Driver":220,"3 Wood":200,"5 Wood":185,"4 Iron":175,"5 Iron":165,"6 Iron":155,"7 Iron":145,"8 Iron":135,"9 Iron":120,"PW":105,"GW":90,"SW":75,"LW":60]

    func recommend() {
        guard let yards = Int(holeYards), yards > 0 else { return }
        let clubs = starting.map { ($0.key, learned($0.key, start: $0.value)) }.sorted { $0.1 < $1.1 }
        let choice = clubs.first { $0.1 >= yards } ?? clubs.last!
        recommendedClub = choice.0
        learnedCarry = choice.1
        defaults.set(choice.0, forKey: "lastClub")
        defaults.set(choice.1, forKey: "lastCarry")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func recordShot() {
        guard let actual = Int(actualYards), actual > 0, !recommendedClub.isEmpty else { return }
        var values = defaults.array(forKey: "shots_\(recommendedClub)") as? [Int] ?? []
        values.append(actual)
        defaults.set(values, forKey: "shots_\(recommendedClub)")
        actualYards = ""
        recommend()
    }

    private func learned(_ name: String, start: Int) -> Int {
        let values = defaults.array(forKey: "shots_\(name)") as? [Int] ?? []
        guard !values.isEmpty else { return start }
        return Int((Double(values.reduce(0, +)) / Double(values.count)).rounded())
    }
}

struct ContentView: View {
    @ObservedObject var model: CaddieModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text("YARDS TO THE HOLE").font(.caption).fontWeight(.black).foregroundStyle(.secondary)
                TextField("227", text: $model.holeYards).keyboardType(.numberPad).font(.system(size: 64, weight: .black)).multilineTextAlignment(.center).foregroundStyle(Color.blue)
                Button("GET CLUB") { model.recommend() }.buttonStyle(.borderedProminent).controlSize(.large)
                if !model.recommendedClub.isEmpty {
                    VStack(spacing: 5) {
                        Text(model.recommendedClub).font(.system(size: 38, weight: .black)).foregroundStyle(Color.blue)
                        Text("Learned carry: \(model.learnedCarry) yards").foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity).padding().background(Color.blue.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 16))
                    TextField("Actual carry", text: $model.actualYards).keyboardType(.numberPad).textFieldStyle(.roundedBorder)
                    Button("SAVE SHOT") { model.recordShot() }.buttonStyle(.borderedProminent)
                }
                Spacer()
            }.padding().navigationTitle("⛳ Golf Caddie")
        }
    }
}
