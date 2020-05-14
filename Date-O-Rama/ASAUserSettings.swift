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

    @UserDefault("ASAEventsView_SHOULD_SHOW_SECONDARY_DATES", defaultValue: true)
    var eventsViewShouldShowSecondaryDates: Bool {
        willSet {
            objectWillChange.send()
        }
    }
}
