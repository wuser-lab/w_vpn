import Foundation
import NetworkExtension

final class AppleTunnelManager {
    private var manager: NETunnelProviderManager?

    func connect(region: Region, mode: FlowMode) async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        let manager = managers.first ?? NETunnelProviderManager()
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "com.wvpn.app.tunnel"
        proto.serverAddress = region.endpoint
        proto.providerConfiguration = ["regionID": region.id, "mode": mode.rawValue]
        manager.protocolConfiguration = proto
        manager.localizedDescription = "W VPN"
        manager.isEnabled = true
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
        try manager.connection.startVPNTunnel()
        self.manager = manager
    }

    func disconnect() { manager?.connection.stopVPNTunnel() }
}

