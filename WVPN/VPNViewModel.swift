import Foundation
import NetworkExtension

@MainActor
final class VPNViewModel: ObservableObject {
    @Published var state: TunnelState = .idle
    @Published var mode: FlowMode = .everyday
    @Published var regions: [Region] = []
    @Published var selectedRegion: Region?
    @Published var proof = ProtectionProof.empty
    private let api = APIClient()
    private let tunnel = AppleTunnelManager()

    func load() async {
        do { regions = try await api.regions(); selectedRegion = regions.first(where: { $0.countryCode == "DE" }) ?? regions.first }
        catch { state = .failed("Could not load W VPN regions") }
    }

    func toggle() async {
        switch state {
        case .idle, .failed:
            guard let region = selectedRegion else { state = .failed("Choose a region"); return }
            state = .connecting
            do {
                try await tunnel.connect(region: region, mode: mode)
                state = .protected
                proof = await ProtectionProof.verify()
            } catch { state = .failed(error.localizedDescription) }
        case .protected:
            state = .disconnecting
            tunnel.disconnect(); proof = .empty; state = .idle
        default: break
        }
    }
}

struct ProtectionProof: Equatable {
    var handshake, ipChanged, secureDNS, ipv6Protected: Bool
    static let empty = ProtectionProof(handshake: false, ipChanged: false, secureDNS: false, ipv6Protected: false)
    static func verify() async -> ProtectionProof {
        // Never display a successful proof without independent checks.
        // Implement signed /v1/proof response plus local route inspection.
        .empty
    }
}
