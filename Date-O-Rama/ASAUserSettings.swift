//
//  ASAUserSettings.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-14.
//  Copyright © 2020 Adelsoft. All rights reserved.
//  Based on https://stackoverflow.com/questions/56822195/how-do-i-use-userdefaults-with-swiftui
//

import Foundation
import Combine

let PRIMARY_ROW_UUID_KEY:  String   = "ASAEventsView_ROW_1_UUID"
let SECONDARY_ROW_UUID_KEY:  String = "ASAEventsView_ROW_2_UUID"
let SHOULD_SHOW_SECONDARY_DATES_KEY:  String = "ASAEventsView_SHOULD_SHOW_SECONDARY_DATES"


@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class ASAUserSettings: ObservableObject {

    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault(SHOULD_SHOW_SECONDARY_DATES_KEY, defaultValue: true)
    var eventsViewShouldShowSecondaryDates: Bool {
        willSet {
            objectWillChange.send()
        }
    } // var eventsViewShouldShowSecondaryDates
    
    @UserDefault(PRIMARY_ROW_UUID_KEY, defaultValue: UUID().uuidString)
    var primaryRowUUIDString: String {
        willSet {
            objectWillChange.send()
        }
    } // var primaryRowUUID

    @UserDefault(SECONDARY_ROW_UUID_KEY, defaultValue: UUID().uuidString)
    var secondaryRowUUIDString: String {
        willSet {
            objectWillChange.send()
        }
    } //
}
