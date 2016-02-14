//
//  objetoLibro.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 19/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit

struct Model {
    
    var titulo: [String] = [String]()
    var author:[String]
    var portada: [UIImage]
    var isbn: [String]
    
    init(titulo : [String], autor: [String], portada: [UIImage], isbn: [String]) {
        
        self.titulo = titulo
        self.author = autor
        self.portada = portada
        self.isbn = isbn
        
    }
    
}

