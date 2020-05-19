//
//  ASAEKEventView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-18.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit
import EventKitUI

struct ASAEKEventView: UIViewControllerRepresentable {
    @Binding var action:  EKEventViewAction?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    var event:  EKEvent
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        eventViewController.allowsEditing = true
        eventViewController.allowsCalendarPreview = true
        eventViewController.delegate = context.coordinator
        return eventViewController
    } // func makeUIViewController(context: Context) -> EKEventViewController
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {
        
    } // func updateUIViewController(_ uiViewController: EKEventViewController, context: Context)
    
    class Coordinator:  NSObject, EKEventViewDelegate {
        var parent:  ASAEKEventView

        init(_ parent: ASAEKEventView) {
            self.parent = parent
        } // init(_ parent: ASAEKEventView)
        
        func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
            switch action {
            case .done:
                debugPrint(#file, #function, "Done")
                
            case .responded:
                debugPrint(#file, #function, "Responded")
                
            case .deleted:
                debugPrint(#file, #function, "Deleted")
                
            @unknown default:
                debugPrint(#file, #function, "Unknown default")
                
            } // switch action
            
            parent.action = action
            
            parent.presentationMode.wrappedValue.dismiss()
        } // func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction)
    } // class Coordinator
} // struct ASAEKEventView
