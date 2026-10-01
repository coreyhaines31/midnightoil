import AppKit
import MidnightOilTeams
import SwiftUI

/// The Teams section at the bottom of Settings › General: the license and what it includes.
struct TeamsSection: View {
    let license: TeamsLicense
    @State private var isEntering = false

    var body: some View {
        if let key = license.key {
            licensed(key)
        } else {
            Section {
                LabeledContent {
                    HStack {
                        Button("Learn More…") { NSWorkspace.shared.open(TeamsHelp.pricingURL) }
                            .help(TeamsHelp.getTeams)
                        Button("Enter License Key…") { isEntering = true }
                            .help(TeamsHelp.keyInfo)
                    }
                } label: {
                    InfoLabel("Midnight Oil for Teams", info: TeamsHelp.intro)
                }
                if let problem = license.problem {
                    Label(TeamsHelp.problemText(problem), systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
            .sheet(isPresented: $isEntering) { TeamsKeySheet(license: license) }
        }
    }

    @ViewBuilder
    private func licensed(_ key: LicenseKey) -> some View {
        Section {
            LabeledContent("Licensed to", value: key.payload.name)
            LabeledContent("Seats", value: "\(key.payload.seats) Macs")
            LabeledContent {
                Text(TeamsHelp.statusText(key))
                    .foregroundStyle(key.status() == .valid ? Color.secondary : Color.orange)
            } label: {
                InfoLabel("Key valid until", info: TeamsHelp.expiry)
            }
            LabeledContent("Includes", value: key.payload.features.map(TeamsHelp.featureName).joined(separator: ", "))
            if !license.isManaged {
                HStack {
                    Button("Manage Subscription…") { NSWorkspace.shared.open(TeamsHelp.dashboardURL) }
                        .help(TeamsHelp.manage)
                    Spacer()
                    Button("Remove Key", role: .destructive) { license.remove() }
                        .help(TeamsHelp.removeKey)
                }
            }
        } header: {
            InfoLabel("Midnight Oil for Teams", info: TeamsHelp.intro)
        } footer: {
            if license.isManaged {
                Text(TeamsHelp.deployedByOrganization).foregroundStyle(.secondary)
            }
        }
    }
}

/// Paste a license key.
private struct TeamsKeySheet: View {
    let license: TeamsLicense
    @State private var draft = ""
    @State private var problem: LicenseKey.Problem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter License Key").font(.headline)
            Text(TeamsHelp.keyInfo).font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            TextField("License key", text: $draft, prompt: Text("MO1-…"), axis: .vertical)
                .lineLimit(3...5)
                .font(.system(.body, design: .monospaced))
                .labelsHidden()
            if let problem {
                Label(TeamsHelp.problemText(problem), systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Activate") {
                    problem = license.activate(draft)
                    if problem == nil { dismiss() }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 460)
    }
}

/// Copy for the Teams section. Lives with the commercial code rather than in Help.swift.
enum TeamsHelp {
    static let pricingURL = URL(string: "https://midnightoil.app/teams")!
    static let dashboardURL = URL(string: "https://app.midnightoil.app/dashboard")!

    static let intro = """
        For organizations: deploy settings to every Mac, lock policies like a battery floor, send session \
        events to your own systems, and see your fleet in one dashboard. Everything else in Midnight Oil \
        stays free.
        """
    static let keyInfo = """
        Your organization's admin finds the key in the Teams dashboard. It's checked on this Mac against \
        Midnight Oil's signature, without contacting any server.
        """
    static let expiry = """
        Keys renew with the subscription. A renewed key is in the Teams dashboard and is usually deployed \
        for you by your organization.
        """
    static let deployedByOrganization = "Your organization deployed this license, so it can't be changed here."
    static let manage = "Open the Teams dashboard to change seats, billing, or deployment."
    static let removeKey = "Remove the license from this Mac. Teams features turn off; everything else keeps working."
    static let getTeams = "Pricing and details for Midnight Oil for Teams."

    static func featureName(_ feature: TeamsFeature) -> String {
        switch feature {
        case .policies: "Policies"
        case .webhook: "Session webhook"
        case .fleet: "Fleet dashboard"
        }
    }

    static func statusText(_ key: LicenseKey) -> String {
        let date = key.payload.exp.formatted(date: .abbreviated, time: .omitted)
        switch key.status() {
        case .valid: return date
        case .expiringSoon: return "\(date) · renew soon"
        case .expired: return "Expired \(date)"
        }
    }

    static func problemText(_ problem: LicenseKey.Problem) -> String {
        switch problem {
        case .malformed: "That doesn't look like a license key. Keys start with MO1-."
        case .badSignature: "This key wasn't issued by Midnight Oil for Teams. Check that it was copied in full."
        case .unsupportedVersion: "This key needs a newer version of Midnight Oil. Check for updates."
        }
    }
}
