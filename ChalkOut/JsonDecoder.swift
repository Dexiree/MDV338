//
//  JsonDecoder.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/24/22.
//

import UIKit
import FirebaseFirestore

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
