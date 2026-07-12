import Foundation

enum FlowMode: String, CaseIterable, Identifiable, Codable {
    case everyday, privateMode, travel
    var id: String { rawValue }
    var title: String { self == .privateMode ? "Private" : rawValue.capitalized }
    var symbol: String { switch self { case .everyday: "sparkles"; case .privateMode: "shield.lefthalf.filled"; case .travel: "airplane" } }
    var subtitle: String { switch self {
        case .everyday: "Fastest healthy server · speed & battery"
        case .privateMode: "Two encrypted hops · stronger privacy"
        case .travel: "Automatic recovery across Wi‑Fi, 4G, and 5G"
    }}
}

enum TunnelState: Equatable { case idle, connecting, protected, disconnecting, failed(String) }

struct Region: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let countryCode: String
    let endpoint: String
    let publicKey: String
    let load: Int
}

