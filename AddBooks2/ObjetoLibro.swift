//
//  ObjetoLibro.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 19/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit


struct ObjetoLibro {
        
        var titulo: [String] = [String]()
        var autores: [String]?
        var porada: [UIImage]?

        
        init(_titulo: [String]){
            
            self.titulo = _titulo
            
        }
        
    }

