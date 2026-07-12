import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // WireGuardKit adapter is connected here after the Xcode target imports
        // the audited WireGuardKit package and receives a signed config from API.
        completionHandler(NSError(domain: "WVPN", code: 1, userInfo: [NSLocalizedDescriptionKey: "WireGuardKit is not linked"]));
    }
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) { completionHandler() }
}

