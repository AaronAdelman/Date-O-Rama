//
//  ASAEKEventEditView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-19.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import EventKit
import EventKitUI
import Foundation
import SwiftUI

struct ASAEKEventEditView:  UIViewControllerRepresentable {
    @Binding var action:  EKEventEditViewAction?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    } // func makeCoordinator() -> Coordinator
    
    var event:  EKEvent?
    var eventStore:  EKEventStore
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore
        if let event = event {
            eventEditViewController.event = event
        }
        eventEditViewController.delegate = context.coordinator
        eventEditViewController.editViewDelegate = context.coordinator
        return eventEditViewController
    } // func makeUIViewController(context: Context) -> EKEventEditViewController
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {

    } // func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context)

    class Coordinator:  NSObject, EKEventEditViewDelegate, UINavigationControllerDelegate {
        var parent:  ASAEKEventEditView
        
        init(_ parent: ASAEKEventEditView) {
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
            } // switch action

            parent.action = action

            parent.presentationMode.wrappedValue.dismiss()
        } // func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)

//        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//            debugPrint(#file, #function, navigationController, viewController, animated)
//        }
//
//        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//            debugPrint(#file, #function, navigationController, viewController, animated)
//        }
//
//        func navigationController(_ navigationController: UINavigationController,
//                                  animationControllerFor operation: UINavigationController.Operation,
//                                  from fromVC: UIViewController,
//                                  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//            debugPrint(#file, #function, navigationController, operation, fromVC, toVC)
//
//            return nil
//        }
//
//        func navigationController(_ navigationController: UINavigationController,
//                                  interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//            debugPrint(#file, #function, navigationController, animationController)
//
//            return nil
//        }
//
//        func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
//            debugPrint(#file, #function, navigationController)
//            return .portrait
//        }
//
//        func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
//            debugPrint(#file, #function, navigationController)
//            return [.allButUpsideDown]
//        }
    } // class Coordinator

} // struct ASAEKEventEditView
