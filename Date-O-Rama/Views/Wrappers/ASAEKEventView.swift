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
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    var event:  EKEvent
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        eventViewController.delegate = context.coordinator
        return eventViewController
    } // func makeUIViewController(context: Context) -> EKEventViewController
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {
        
    } // func updateUIViewController(_ uiViewController: EKEventViewController, context: Context)
    
    class Coordinator:  NSObject, EKEventViewDelegate {
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
                
            }
        }
        
        
    }
} // struct ASAEKEventView
