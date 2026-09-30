import SwiftUI

/// The explanation at the top of each settings pane.
struct PaneIntro: View {
    let intro: Help.Intro

    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: intro.symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(.orange)
                    .frame(width: 24)
                    .accessibilityHidden(true)
                Text(intro.text)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 2)
        }
    }
}

/// An ⓘ that explains the setting next to it: a tooltip on hover, a popover on click.
struct InfoButton: View {
    let text: String
    @State private var isShowing = false

    var body: some View {
        Button {
            isShowing.toggle()
        } label: {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        .help(text)
        .accessibilityLabel("More information")
        .accessibilityHint(text)
        .popover(isPresented: $isShowing, arrowEdge: .bottom) {
            Text(text)
                .font(.callout)
                .frame(width: 280, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14)
        }
    }
}

/// A setting's label followed by its ⓘ.
struct InfoLabel: View {
    let title: String
    let info: String

    init(_ title: String, info: String) {
        self.title = title
        self.info = info
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
            InfoButton(text: info)
        }
    }
}
