//
//  DetailsViewController.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 19/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit




class DetailsViewController: UIViewController {
    

//*********Variables globales
    
    var detalleTitulo:String!
    var detalleAuthor:String!
    var detallePortada: UIImage!
    
//**********Outlets
    @IBOutlet weak var bookTitle: UILabel!
    
    @IBOutlet weak var bookAuthor: UILabel!
    
    @IBOutlet weak var portadaLibro: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTitle.text = detalleTitulo
        bookAuthor.text = detalleAuthor
        portadaLibro.image = detallePortada
    }
    
    
/*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
*/

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
