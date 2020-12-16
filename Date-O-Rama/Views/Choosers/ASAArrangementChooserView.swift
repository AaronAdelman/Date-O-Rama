//
//  ASAArrangementChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAArrangementChooserView: View {
    @Binding var groupingOption:  ASAClocksViewGroupingOption
    @State var tempGroupingOption:  ASAClocksViewGroupingOption

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    var body: some View {
        List {
            ForEach(ASAClocksViewGroupingOption.allOptions, id: \.self) {
                groupingOption
                in
                ASAArrangementCell(groupingOption: groupingOption, selectedGroupingOption: self.$tempGroupingOption)
                    .onTapGesture {
                        self.tempGroupingOption = groupingOption
                    }
            }
        }
        .navigationBarItems(trailing:
                                Button("Cancel", action: {
                                    self.didCancel = true
                                    self.presentationMode.wrappedValue.dismiss()
                                })
        )
        .onAppear() {
            self.tempGroupingOption = self.groupingOption
        }
        .onDisappear() {
            if !self.didCancel {
                self.groupingOption = self.tempGroupingOption
            }
        }
    }
}

struct ASAArrangementCell: View {
    var groupingOption: ASAClocksViewGroupingOption

    @Binding var selectedGroupingOption: ASAClocksViewGroupingOption

    var body: some View {
        HStack {
            Text(verbatim: groupingOption.text())
            Spacer()
            if self.groupingOption == self.selectedGroupingOption {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    } // var body
} // struct ASAArrangementCell

struct ASAArrangementChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASAArrangementChooserView(groupingOption: .constant(ASAClocksViewGroupingOption.byPlaceName), tempGroupingOption: ASAClocksViewGroupingOption.byPlaceName)
    }
}
