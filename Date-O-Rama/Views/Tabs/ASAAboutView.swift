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
        VStack {
            let appName = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
            let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
            let build:  String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
            Text("\(appName) \(version) (\(build))")
                .font(.largeTitle)

            Text("by Aaron Solomon Adelman")
            Link("✉️ Aaron.Solomon.Adelman@gmail.com", destination:  URL(string: "mailto:Aaron.Solomon.Adelman@gmail.com?subject=Date-O-Rama")!)
        } // VStack

    } // var body
} // struct ASAAboutView

struct ASAAboutView_Previews: PreviewProvider {
    static var previews: some View {
        ASAAboutView()
    }
}
