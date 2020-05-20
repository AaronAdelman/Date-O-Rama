//
//  ASAEKEventEditView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-19.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI
import SwiftUI

struct ASAEKEventEditView:  UIViewControllerRepresentable {
    @Binding var action:  EKEventEditViewAction?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
//        debugPrint(#file, #function)
        
        return Coordinator(self)
    } // func makeCoordinator() -> Coordinator
    
    var event:  EKEvent?
    var eventStore:  EKEventStore
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
//        debugPrint(#file, #function, context)

        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = event
        eventEditViewController.eventStore = eventStore
        eventEditViewController.delegate = context.coordinator
        eventEditViewController.editViewDelegate = context.coordinator
        return eventEditViewController
    } // func makeUIViewController(context: Context) -> EKEventEditViewController
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
//        debugPrint(#file, #function, uiViewController, context)
        
    } // func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context)

    class Coordinator:  NSObject, EKEventEditViewDelegate, UINavigationControllerDelegate {
        var parent:  ASAEKEventEditView
        
        init(_ parent: ASAEKEventEditView) {
//            debugPrint(#file, #function, parent)

            self.parent = parent
        } // init(_ parent: ASAEKEventEditView)
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .canceled:
                debugPrint(#file, #function, "Canceled")
                
            case .saved:
                debugPrint(#file, #function, "Saved")
                
            case .deleted:
                debugPrint(#file, #function, "Deleted")
                
            @unknown default:
                debugPrint(#file, #function, "Unknown default")
                
            } // switch
            
            parent.action = action
            
            parent.presentationMode.wrappedValue.dismiss()
        } // func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
    } // class Coordinator

} // struct ASAEKEventEditView
