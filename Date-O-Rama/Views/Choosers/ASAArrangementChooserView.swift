//
//  ASAArrangementChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAArrangementChooserView: View {
    @Binding var selectedGroupingOption:  ASAClocksViewGroupingOption
    var groupingOptions:  Array<ASAClocksViewGroupingOption>
    @Binding var otherGroupingOption:  ASAClocksViewGroupingOption
    var otherGroupingOptionIsSecondary:  Bool

    @State var tempGroupingOption:  ASAClocksViewGroupingOption = .byPlaceName

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    var body: some View {
        List {
            ForEach(groupingOptions, id: \.self) {
                groupingOption
                in
                ASAArrangementCell(groupingOption: groupingOption, selectedGroupingOption: self.$tempGroupingOption)
                    .onTapGesture {
                        self.tempGroupingOption = groupingOption
                    }
            }
        }
//        .navigationBarItems(trailing:
//                                Button("Cancel", action: {
//                                    self.didCancel = true
//                                    self.presentationMode.wrappedValue.dismiss()
//                                })
//        )
        .onAppear() {
            self.tempGroupingOption = self.selectedGroupingOption
        }
        .onDisappear() {
            if !self.didCancel {
                self.selectedGroupingOption = self.tempGroupingOption
                if otherGroupingOptionIsSecondary {
                    if !self.selectedGroupingOption.compatibleOptions.contains(self.otherGroupingOption) {
                        self.otherGroupingOption = self.selectedGroupingOption.defaultCompatibleOption
                    }
                }
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
                ASACheckmarkSymbol()
            }
        }
    } // var body
} // struct ASAArrangementCell

struct ASAArrangementChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASAArrangementChooserView(selectedGroupingOption: .constant(ASAClocksViewGroupingOption.byPlaceName), groupingOptions: ASAClocksViewGroupingOption.byPlaceName.compatibleOptions, otherGroupingOption: .constant(.byFormattedDate), otherGroupingOptionIsSecondary: true)
    }
}
