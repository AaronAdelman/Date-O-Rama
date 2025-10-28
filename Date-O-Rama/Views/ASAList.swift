import SwiftUI

public struct ASAList<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        #if os(iOS)
        Group {
            if hSizeClass == .regular {
                Form { content() }
            } else {
                List { content() }
            }
        }
        #else
        // Non-iOS platforms: default to Form for grouped appearance
        Form { content() }
        #endif
    }
}
