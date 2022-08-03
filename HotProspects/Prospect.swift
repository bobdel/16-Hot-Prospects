//
//  Prospect.swift
//  HotProspects
//
//  Created by Paul Hudson on 03/01/2022.
//

import SwiftUI

/// Data Model for this class
class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false // restrict toggle to the func below
}

/// Data container for this app. This is injected into the Environment (specifically the TabView.)
@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData" // avoids 

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }

        // no saved data!
        people = []
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }

    /// Mutate and save isContacted property
    /// - Parameter prospect: prospect to mutate
    /// - This function is required because SwiftUI doesn't re-render when a value
    ///   inside a Prospect changes. It can only monitor the collection itself for changes.
    ///   Therefore, the data is mutated and saved here after signaling SwiftUI.
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
