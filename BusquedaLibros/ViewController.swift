//
//  ViewController.swift
//  BusquedaLibros
//
//  Created by Gandhi Mena Salas on 13/12/15.
//  Copyright © 2015 Trenx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchISBN: UISearchBar!
    
    @IBOutlet weak var tituloLibro: UILabel!
    
    @IBOutlet weak var autoresLibro: UILabel!
    
    @IBOutlet weak var portadaLibro: UIImageView!
    

    @IBAction func buscarISBNButton(sender: UIButton) {
        
        buscasrLibro()
        
    }
    
    func buscasrLibro(){
        
        //PORTADA
      
        
        //ISBN
        let ISBN:String = searchISBN.text!
        let urls:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(ISBN)"
        let url = NSURL(string: urls)
        let datos = NSData(contentsOfURL: url!)
        
        
        
        do{
            
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            //TITULO
            let diccionario1 = json as! NSDictionary
            let diccionario2 = diccionario1["ISBN:\(ISBN)"] as! NSDictionary
            tituloLibro.text = diccionario2["title"] as! NSString as String
            let diccionario3 = diccionario2["cover"] as! NSDictionary
         
            //PORTADA
            if let checkedUrl = NSURL(string: "\(diccionario3["medium"]!)") {
                portadaLibro.contentMode = .ScaleAspectFit
                downloadImage(checkedUrl)
            }
            
            //AUTORES
            let diccionario4 = diccionario2["authors"] as! NSArray
            let diccionario5 = diccionario4.valueForKey("name")
            let diccionario6 = diccionario5[0] as! String as String
            autoresLibro.text = diccionario6
           
            
        }
            
        
        catch _{
            
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        

        
        
    }
    
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            
            }.resume()
    }
    
    func downloadImage(url: NSURL){
        
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                guard let data = data where error == nil else { return }
                
                self.portadaLibro.image = UIImage(data: data)
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //*********************Toggle Keboard
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField!)-> Bool{
        textField.resignFirstResponder()
        
        return true
        
    }


}

