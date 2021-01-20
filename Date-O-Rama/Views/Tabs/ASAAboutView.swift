//
//  ASAAboutView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAAboutView: View {
    var body: some View {
        NavigationView {
            VStack {
                let SCALE = 2.0
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .cornerRadius(2.0)
                    .scaleEffect(CGSize(width: SCALE, height: SCALE))

                Spacer()
                    .frame(height:  8.0)

                let mainBundle: Bundle = Bundle.main
                let appName = (mainBundle.infoDictionary?["CFBundleName"] as? String) ?? ""
                let version: String = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                let build:  String = mainBundle.infoDictionary?["CFBundleVersion"] as? String ?? ""
                Text("\(appName) \(version) (\(build))")
                    .font(.largeTitle)

                Text("by Aaron Solomon Adelman")
                Link("✉️ Aaron.Solomon.Adelman@gmail.com", destination:  URL(string: "mailto:Aaron.Solomon.Adelman@gmail.com?subject=Date-O-Rama")!)

                List {
                    NavigationLink(destination:                     ASALocalPDFView(fileName: "Thanks to")) {
                        Text("Thanks to…")
                    }
                }
            } // VStack
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAAboutView

struct ASAAboutView_Previews: PreviewProvider {
    static var previews: some View {
        ASAAboutView()
    }
}
