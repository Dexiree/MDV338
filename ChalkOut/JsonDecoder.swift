//
//  JsonDecoder.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/24/22.
//

import UIKit
import FirebaseFirestore

// TODO: Check if I can decode this
struct User {
    var email: String
    var uid: String
    
    init(email: String = "", uid: String = "") {
        self.email = email
        self.uid = uid
    }
}

struct Projects: Codable {
    let name: String
    let image: String
    let collaborators: [String]
    let locked: Bool
    
    init(snapshot: [String: Any]) throws {
            self = try JSONDecoder().decode(Projects.self, from: JSONSerialization.data(withJSONObject: snapshot))
        }
}

struct ColorSchemes: Codable {
    let palette: [String]
    let sketches: [String]
    
    init(snapshot: [String : Any]) throws {
        self = try JSONDecoder().decode(ColorSchemes.self, from: JSONSerialization.data(withJSONObject: snapshot))
    }
}

struct SharedProjects: Codable {
    let sharedProjects: [String]
    
    init(snapshot: [String: Any]) throws {
        self = try JSONDecoder().decode(SharedProjects.self, from: JSONSerialization.data(withJSONObject: snapshot))
    }
}
