//
//  ASAMarkdownView.swift
//  Googlinator
//
//  Created by אהרן שלמה אדלמן on 03/06/2026.
//

import SwiftUI
import Textual

struct ASAMarkdownView: View {
    @State var fileName: String
    @State private var text: String = ""

    var body: some View {
        ScrollView {
            StructuredText(markdown: text)
        }
        .onAppear(perform: loadDescription)
        .padding()
    }

    private func loadDescription() {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: "md"
        ),
              let data = try? Data(contentsOf: url),
              let raw = String(data: data, encoding: .utf8) else {
            text = ""
            return
        }
        text = raw
    }
}

#Preview {
    ASAMarkdownView(fileName: "Thanks to")
}
