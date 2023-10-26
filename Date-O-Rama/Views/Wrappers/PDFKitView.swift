//
//  PDFKitView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//  From https://stackoverflow.com/questions/61478290/how-can-i-open-a-local-pdf-file-using-a-swiftui-button


import Foundation
import SwiftUI
import PDFKit

struct PDFKitView: View {
    var url: URL
    var body: some View {
        PDFKitRepresentedView(url)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    init(_ url: URL) {
        self.url = url
    }

    func makeUIView(context: UIViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.UIViewType {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFKitRepresentedView>) {
        // Update the view.
    }
}


// MARK:  -

struct ASALocalPDFView:  View {
    var fileName:  String

    var body: some View {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: "pdf")

        if fileURL == nil {
            EmptyView()
        } else {
            PDFKitView(url: fileURL!)
        }
    }
}
