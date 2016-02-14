//
//  DetailsViewController.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 19/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit


class DetailsViewController: UIViewController {

//*********Variables
    
    var detalleTitulo:String?
    var detalleAuthor:String?
    var detallePortada: UIImage?
    
//**********Segues
    @IBOutlet weak var bookTitle: UILabel!
    
    @IBOutlet weak var bookAuthor: UILabel!
    
    @IBOutlet weak var portadaLibro: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTitle.text = detalleTitulo
        bookAuthor.text = detalleAuthor
        portadaLibro.image = detallePortada
    }
    

}
