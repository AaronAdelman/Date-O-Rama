//
//  ASAAboutTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAAboutTab: View {
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
                    ASAAboutNavigationLink(fileName: "Thanks to", text: "Thanks to…")

                    ASAAboutNavigationLink(fileName: "What should I do if I have a", text: "What should I do if I have a problem with Date-O-Rama?")

                    ASAAboutNavigationLink(fileName: "What calendar systems are", text: "What calendar systems are currently supported?")


                    ASAAboutNavigationLink(fileName: "Personal information policy", text: "What is Adelsoft’s policy on your personal information?")
                }
            } // VStack
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAAboutTab


// MARK:  -

struct ASAAboutNavigationLink:  View {
    var fileName:  String
    var text:  String

    var body:  some View {
        NavigationLink(destination:                     ASALocalPDFView(fileName: fileName)) {
            Text(NSLocalizedString(text, comment: ""))
                .font(.headline)
        }
    } // var body
} // struct ASAAboutNavigationLink


// MARK:  -

struct ASAAboutView_Previews: PreviewProvider {
    static var previews: some View {
        ASAAboutTab()
    }
}
