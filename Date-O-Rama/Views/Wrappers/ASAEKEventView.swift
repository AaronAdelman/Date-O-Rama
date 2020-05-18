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
    var event:  EKEvent
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        return eventViewController
    } // func makeUIViewController(context: Context) -> EKEventViewController
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {
        
    } // func updateUIViewController(_ uiViewController: EKEventViewController, context: Context)
} // struct ASAEKEventView
