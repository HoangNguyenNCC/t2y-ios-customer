//
//  DataHandler.swift
//  Trailer2You
//
//  Created by Aritro Paul on 28/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

class DataHandler {
    static let shared = DataHandler()
    
    func saveData<T: Codable>(data: T, key: String) {
        let encodedData = try? JSONEncoder().encode(data)
        UserDefaults.standard.set(encodedData, forKey: key)
    }
    
    func getData<T: Codable>(withKey key: String, completion: @escaping(Bool, T)->()){
        if let data = UserDefaults.standard.data(forKey: key) {
            if let decodedData = try? JSONDecoder().decode(T.self, from: data) {
                completion(true, decodedData)
            }
        }
    }
    
}
