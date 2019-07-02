//
//  User.swift
//  yard
//
//  Created by Dara Ladjevardian on 5/5/19.
//  Copyright © 2019 Dara Ladjevardian. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let name: String
    let email: String
    let grad: Int
    let number: String
    
    init(authData: Firebase.User) {
        name = authData.name
        email = authData.email!
        grad = authData.grad
        number = authData.number
    }
    
    init(name: String, email: String, grad: Int, number: String) {
        self.name = name
        self.email = email
        self.grad = grad
        self.number = number
    }
}
