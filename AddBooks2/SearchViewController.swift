//
//  SearchViewController.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 18/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit
import CoreData


protocol BookSearchDelegate {
    
    func updateData(data: Model)
    
}


protocol NuevoDelegado{
    
    func mandarTitulo(titulo titulo: String, autor:String, portada: UIImage)
    
}


class SearchViewController: UIViewController {
    
  
    
    
//********* Outlets
    

    @IBOutlet weak var searchISBN: UITextField!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var portadaLibro: UIImageView!
    
    @IBOutlet weak var formTitle: UILabel!
    @IBOutlet weak var authorTitle: UILabel!
    
    @IBOutlet weak var addBookFound: UIBarButtonItem!
    
    
    
//********* Variables

    var delegateNuevoDelegado: NuevoDelegado?
    var delegate: BookSearchDelegate?
    
    var modelo:Model = Model(titulo: [], autor: [], portada: [], isbn: [])

    var isbn: String? = nil
    //var imagenData = NSData()
    
    var tituloAMandar = ""
    var autoresAMandar = ""
    var autoresEntidad = ""
    var imagenAMandar:NSData?
    
    var urlImg: NSURL?
    
    //accedemos a la pila de CoreData. Contexto es la parte de memoria en el inter de recuperar datos.
    var contexto : NSManagedObjectContext? = nil
    
    
    
//********* viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        //******** 1. Obtenemos el contexto
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        

        addBookFound.title = ""
    
        
    }

//*********** 3. crearEntidadImagen
    
    func crearEntidadImagen(imagenPortada: UIImage) -> NSObject{
        
        var entidadImagenADevolver : NSObject? = nil
    
        let imagenEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: contexto!)
        
        imagenEntidad.setValue(UIImagePNGRepresentation(imagenPortada), forKey: "portada")
        
        entidadImagenADevolver = imagenEntidad as NSObject
        
            print(entidadImagenADevolver)
        
        return entidadImagenADevolver!
        
    }
    
    
    func imageWithBorderFromImage(source: UIImage) -> UIImage {
        let size: CGSize = source.size
        UIGraphicsBeginImageContext(size)
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        source.drawInRect(rect, blendMode: .Darken, alpha: 1.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBStrokeColor(context, 255, 255, 255, 1.0)
        
        
        let testImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return testImg
    }
    
    
    
//***********Event: Did end on exit
    
    @IBAction func searchISBNButton(sender: UITextField) {
        
        if searchISBN.text != ""{
            //*********** 2. Vamos a revisar si ya se realizó antes la busqueda
        
            //accedemos a nuestra entidad de libro
            let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: contexto!)
        
            //creamos la peticion a nuestra entidad y le asignamos un valor a su parametro "isbn"
            let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("peticionLibro", substitutionVariables: ["isbn": sender.text!])
                print(peticion)
            do{
            
                //ejecuta la peticion para ver si ya se realizó con anterioridad
                let libroEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
            
                if (libroEntidad2?.count > 0){
                
                    let tituloEntidad = libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("titulo") as! String
                    let autorEntidad = libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("autor") as! String
                
                    let SVC = SearchViewController()
                    let portadaEntidad = SVC.imageWithBorderFromImage(UIImage(data: libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("portada") as! NSData)!)


                    bookTitle.text = tituloEntidad
                    bookAuthor.text = autorEntidad
                    portadaLibro.image = portadaEntidad
                
                    
                    formTitle.text = "Title:"
                    authorTitle.text = "Author(s):"
                    addBookFound.title = "Add"
                    sender.text = ""
                
                    return
                }
                print(libroEntidad2)
            }
            catch{
            }
        
        
            //*********** 4. Si no se encontro el isbn en la entidad, entonces vamos a realizar la busqueda en internet
            buscarLibro(isbn: sender.text!)
        
            searchISBN.text = ""
        
            print(self.modelo)
        

            formTitle.text = "Title:"
            authorTitle.text = "Author(s):"
        
        }else{
        
            anadirLibroAlert("Ingresa un ISBN", message: "")
        }
    }

    
    
//**********Funcion buscarLibro
    
    func buscarLibro(isbn isbn: String){

        self.isbn = isbn
        
    
        //ISBN
        let urls:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        let url = NSURL(string: urls)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url, completionHandler:{
            (data, response, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(),{
                if ((response) != nil){
                    
                    ProgressView.sharedInstance.hideProgressView()
                    
                    //los datos obtenidos los codificamos en UTF8
                    let texto = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
                    
                    if texto.containsString(isbn){
                        
                        do{
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            let keyJsonData: String = "ISBN:" + isbn
                            
                            if let datos = jsonData[keyJsonData] as? NSDictionary{
                                
                                self.addBookFound.title = "Add"
                                
                                
                                //TITULO
                                if let titulo = datos["title"] as? String{
                                
                                    self.bookTitle.text = titulo
                                    self.tituloAMandar = titulo
                                    
                                    self.modelo.titulo.append(self.tituloAMandar)
                                    self.delegate?.updateData(self.modelo)
                                    
                                
                                }
                                
                                //AUTORES
                                if let autores = datos["authors"] as? NSArray{
                                    
                                    var index: Int = 0
                                    for nombreAutor in autores {
                                        if index == autores.count - 1 {
                                            
                                            let autores = nombreAutor["name"] as! String
                                            
                                            self.autoresAMandar = autores
                                            print(autores)
                                            self.autoresEntidad = self.autoresEntidad + (nombreAutor["name"] as! String)
                                            
                                        }else{
                                            self.autoresEntidad = self.autoresEntidad + (nombreAutor["name"] as! String) + ", "
                                        }
                                        ++index
                                    }

                                  
                                    self.bookAuthor.text = self.autoresAMandar
                                    self.modelo.author.append(self.autoresAMandar)
                                

                                }
                                
                                //PORTADA
                                if let _ = datos["cover"] as? NSDictionary {
                                    dispatch_async(dispatch_get_main_queue(),{
                                        
                                        let cover = datos["cover"]
                                        if cover != nil && cover is NSDictionary{
                                            
                                            let covers = datos["cover"] as! NSDictionary
                                            self.urlImg = NSURL(string: covers["large"] as! NSString as String)
                                            let img_data = NSData(contentsOfURL: self.urlImg!)
                                            
                                            
                                            self.imagenAMandar = img_data!
                                            let imagen = UIImage(data: img_data!) // la img_data la convertimos en UIImage
                                            self.portadaLibro.image = imagen //ahora esa imagen se la asignamos al UIImageView(portadaLibro)
                                            self.modelo.portada.append(imagen!)//le asignamos al modelo la portada
                                            
                                            
                                            
                                            self.delegateNuevoDelegado?.mandarTitulo(titulo: self.tituloAMandar, autor: self.autoresAMandar, portada: self.portadaLibro.image!)
                                            
                                            // 5. creamos un nuevo objeto dentro de nuestra base de datos
                                            let nuevoLibroEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
                                            
                                            nuevoLibroEntidad.setValue(isbn, forKey: "isbn")
                                            nuevoLibroEntidad.setValue(self.tituloAMandar, forKey: "titulo")
                                            nuevoLibroEntidad.setValue(self.autoresAMandar, forKey: "autor")
                                            nuevoLibroEntidad.setValue(self.imagenAMandar, forKey: "portada")
                                            
                                            
                                            
                                            do {
                                                try self.contexto?.save()
                                            }
                                            catch {
                                                
                                            }
                                
                                        }
                                           ProgressView.sharedInstance.hideProgressView()
                                    })
                                 
                                }

                                
                            }
                            
                            
                        }catch {
                            
                        }
                    }

                }
            })
            
        })
        
        task.resume()
    }
    
    
    
    
//*****************Funcino añadir titulo
    
    @IBAction func addBookFound(sender: UIBarButtonItem) {
        
        anadirLibroAlert("Confirmado", message: "Tu libro se ha añadido a tu lista con éxito")
        
    }
    
//************ function Alert
    func anadirLibroAlert(title: String, message: String){
        
    
        let alerta = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        /*
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel){
            (action:UIAlertAction!) in
            
            print("pulsaste cancelar")
        }
        */
        let OkAction = UIAlertAction(title: "OK", style: .Default){
            (action:UIAlertAction!) in
            
            //print("pulsaste Ok")
        }
        
        alerta.addAction(OkAction)
        
        self.presentViewController(alerta, animated: true, completion: nil)
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
