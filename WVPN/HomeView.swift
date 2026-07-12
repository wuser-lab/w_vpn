import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var model: VPNViewModel
    private let background = Color(red: 0.035, green: 0.039, blue: 0.043)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    connectButton
                    modePicker
                    modeDescription
                    regionPicker
                    proofCard
                    Text("No activity logs · WireGuard · 5 devices").font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }
            .background(background.ignoresSafeArea())
            .navigationTitle("W VPN")
            .task { await model.load() }
        }
    }

    private var connectButton: some View {
        VStack(spacing: 14) {
            Button { Task { await model.toggle() } } label: {
                Text("W").font(.system(size: 64, weight: .medium, design: .rounded))
                    .frame(width: 176, height: 176)
                    .background(model.state == .protected ? Color.white : Color.white.opacity(0.07))
                    .foregroundStyle(model.state == .protected ? Color.black : Color.white)
                    .clipShape(Circle()).overlay(Circle().stroke(Color.white.opacity(0.14)))
            }.buttonStyle(.plain).accessibilityLabel(model.state == .protected ? "Disconnect W VPN" : "Connect W VPN")
            Text(stateTitle).font(.headline).tracking(2)
            Text(stateSubtitle).foregroundStyle(.secondary)
        }
    }

    private var modePicker: some View {
        Picker("Protection mode", selection: $model.mode) {
            ForEach(FlowMode.allCases) { Text($0.title).tag($0) }
        }.pickerStyle(.segmented)
    }

    private var modeDescription: some View {
        HStack(spacing: 12) { Image(systemName: model.mode.symbol); Text(model.mode.subtitle); Spacer() }
            .padding(16).background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
    }

    private var regionPicker: some View {
        Picker("W Route", selection: $model.selectedRegion) {
            ForEach(model.regions) { region in Text("\(region.name) · \(region.load)% load").tag(Optional(region)) }
        }.pickerStyle(.menu).frame(maxWidth: .infinity, alignment: .leading)
    }

    private var proofCard: some View {
        VStack(spacing: 12) {
            HStack { Text("W Proof").font(.headline); Spacer(); Text(model.state == .protected ? "Protected" : "Not checked").font(.caption) }
            proofRow("Tunnel handshake", model.proof.handshake)
            proofRow("Public IP changed", model.proof.ipChanged)
            proofRow("Secure DNS", model.proof.secureDNS)
            proofRow("IPv6 protected", model.proof.ipv6Protected)
        }.padding(18).background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
    }
    private func proofRow(_ label: String, _ value: Bool) -> some View { HStack { Text(label); Spacer(); Image(systemName: value ? "checkmark.circle.fill" : "minus.circle").foregroundStyle(value ? .primary : .secondary) } }
    private var stateTitle: String { switch model.state { case .idle: "READY"; case .connecting: "CONNECTING"; case .protected: "PROTECTED"; case .disconnecting: "DISCONNECTING"; case .failed: "ATTENTION" } }
    private var stateSubtitle: String { if case .failed(let message) = model.state { return message }; return model.state == .protected ? "\(model.mode.title) · \(model.selectedRegion?.name ?? "W Route")" : "Tap W to protect this device" }
}

struct SettingsView: View { @EnvironmentObject var model: VPNViewModel; var body: some View { Form { Section("Privacy") { Text("W VPN never stores browsing, DNS, or destination history.") } } } }

