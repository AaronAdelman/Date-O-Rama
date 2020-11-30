//
//  ASAEKCalendarChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//  Based on https://nemecek.be/blog/39/how-to-use-ekcalendarchooser-with-swiftui
//

import EventKitUI
import SwiftUI

struct ASAEKCalendarChooserView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    @Environment(\.presentationMode) var presentationMode
    var externalEventManager =  ASAExternalEventManager.shared()

    var calendars: Set<EKCalendar>? = ASAExternalEventManager.shared().calendarSet

    func makeUIViewController(context: UIViewControllerRepresentableContext<ASAEKCalendarChooserView>) -> UINavigationController {
        let chooser = EKCalendarChooser(selectionStyle: .multiple, displayStyle: .allCalendars, entityType: .event, eventStore: externalEventManager.eventStore)
        chooser.selectedCalendars = calendars ?? []
        chooser.delegate = context.coordinator
        chooser.showsDoneButton = true
        chooser.showsCancelButton = true
        return UINavigationController(rootViewController: chooser)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<ASAEKCalendarChooserView>) {
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, EKCalendarChooserDelegate {
        let parent: ASAEKCalendarChooserView

        init(_ parent: ASAEKCalendarChooserView) {
            self.parent = parent
        }

        func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
            debugPrint(#file, #function, calendarChooser)

            let calendars = calendarChooser.selectedCalendars
            parent.externalEventManager.calendars = Array(calendars)
            ASAUserData.shared().savePreferences(code: .events)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
            debugPrint(#file, #function, calendarChooser)

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ASAEKCalendarChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEKCalendarChooserView()
    }
}
