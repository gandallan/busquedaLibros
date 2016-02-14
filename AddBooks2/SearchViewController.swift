//
//  SearchViewController.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 18/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit
import CoreData

//***********Protocolos
protocol BookSearchDelegate{
    
    func updateDate(data: ObjetoLibro)
    
}

protocol NuevoDelegado{
    
    func mandarTitulo(tituloMandado: String, imagenMandada: UIImage, autorMandado: String)
}




class SearchViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {
 
    var contexto: NSManagedObjectContext? = nil
    
    var delegate: BookSearchDelegate?
    var delegateNuevoDelegado: NuevoDelegado?
    
    
    
//********* Variables
    
    var tituloAMandar = ""
    var autoresAMandar = ""
    var autoresEntidad = ""
    var isbn: String? = nil
    var urlImg: NSURL?
    
    var modelo: ObjetoLibro = ObjetoLibro(_titulo: [])
    
    var iphone: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
    }
    var ipad: Bool{
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    }
    
    var url = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    
    
    
    
    
//********* Outlets

    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var searchISBN: UITextField!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var portadaLibro: UIImageView!
    
    @IBOutlet weak var formTitle: UILabel!
    @IBOutlet weak var authorTitle: UILabel!
    
    @IBOutlet weak var addBookFound: UIBarButtonItem!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        formTitle.text = ""
        authorTitle.text = ""
        //addBookFound.title = ""
        
        
        //*********Cambiar el color de la barra de estado
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        
        
        //*********MARK: EfectoBlur
        imgBackground.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blureffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blureffectView.frame = imgBackground.bounds
        blureffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        imgBackground.addSubview(blureffectView)
        
        
        
        //********* hacer el NavigationBar translucido
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        self.navigationController?.navigationBar.translucent = true
        
        
    
    }

    
//***********Event: Did end on exit
    
    @IBAction func searchISBNButton(sender: UITextField) {
        searchISBN.resignFirstResponder()
        
        
        if searchISBN.text != ""{
    
            // Antes de hacer la busqueda consultar si ese terminó ya fue consultado
           let libroEntidad = NSEntityDescription.entityForName("Libros", inManagedObjectContext: self.contexto!)
        
            //Hacer la peticion
            let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("peticionLibro", substitutionVariables: ["isbn": self.searchISBN.text!])
        
            do{
                //se ejecuta la peticion
                let libroEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
            
                if libroEntidad2?.count > 0{
                    //ya se realizo la consulta antes
                    //ya no se hace nada
                
                    let tituloEntidad = libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("titulo") as! String
                    let autorEntidad = libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("autor") as! String
                    
                    let searchViewController = SearchViewController()
                    
                    let portadaEntidadBackground = UIImage(data: libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("portada") as! NSData)
                    
                    let portadaEntidad = searchViewController.imageWithBorderFromImage(UIImage(data: libroEntidad2![(libroEntidad2?.count)! - 1].valueForKey("portada") as! NSData)!)
               
                
                
                    bookTitle.text = tituloEntidad
                    bookAuthor.text = autorEntidad
                    portadaLibro.image = portadaEntidad
                    imgBackground.image = portadaEntidadBackground
                    
                
                
                }
            
            
            }catch{
        
            }
            buscarLibro(searchISBN.text!)
            searchISBN.text = ""
        
            formTitle.text = "Title:"
            authorTitle.text = "Author(s):"
            
        }else{
        
            
        }
        
        
    
    }

    
//********* Funcion crear imagenEntidad
    
    func crearImagenEntidad(imagenPortadaLista: UIImage) -> NSObject{
    
        var entidadADevolver: NSObject? = nil
        
        let imagenEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
        
        imagenEntidad.setValue(UIImagePNGRepresentation(imagenPortadaLista), forKey: "Portada")
        
        entidadADevolver = imagenEntidad as NSObject
        
        return entidadADevolver!
        
        
    }
    
    
//********Funcion imageWithBorderFromImage
    func imageWithBorderFromImage(source: UIImage) -> UIImage {
        
        let size: CGSize = source.size
        UIGraphicsBeginImageContext(size)
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        source.drawInRect(rect, blendMode: .Darken, alpha: 1.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBStrokeColor(context, 255, 255, 255, 1.0)
        
        if Device.IS_3_5_INCHES() || Device.IS_4_INCHES() {
            CGContextStrokeRectWithWidth(context, rect, 4.5)
        }
        else  {
            CGContextStrokeRectWithWidth(context, rect, 10.0)
        }
        
        let testImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return testImg
    }
    
    
    
    
//**********Funcion buscarLibro
    
    func buscarLibro(isbnText: String){
        
        //*******Crear un spinerLoad en lo que se realiza la búsqueda
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.center = CGPointMake(self.portadaLibro.frame.width / 2.0, self.portadaLibro.frame.height / 2.0)
        self.portadaLibro.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        
        
        //ISBN
        let apiurl:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbnText)"
        let url = NSURL(string: apiurl)!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {
            (data, response, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if ((response) != nil) {
                    
                    let texto = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
                    
                    if (texto.containsString(isbnText)){
                        
                        do{
                            let jsonDatos = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            
                            
                            let keyJsonData :String = "ISBN:" + isbnText
                            
                            self.isbn = isbnText
                            
                            if let datos = jsonDatos[keyJsonData] as? NSDictionary{
                                
                                
                                //obtenemos el TITULO de los datos del json
                                
                                if let nombreTitulo = datos["title"] as? String{
                                    self.bookTitle.text = nombreTitulo
                                    
                                    //agregamos el titulo consultado al modelo
                                    self.modelo.titulo.append(nombreTitulo)
                                    
                                    self.delegate?.updateDate(self.modelo)
                                    
                                    self.tituloAMandar = nombreTitulo
                                    
                                    
                                }
                                
                                
                                
                                
                                //obtenemos los AUTORES de los datos del json
                                
                                if let autores = datos["authors"] as? NSArray{
                                    self.bookAuthor.text = "Por "
                                    
                                    self.autoresEntidad = ""
                                    var index = 0
                                    for nombreAutores in autores {
                                        if index == autores.count - 1{
                                            self.autoresEntidad = self.autoresEntidad + (nombreAutores["name"] as! String)
                                            self.bookAuthor.text = self.bookAuthor.text! + (nombreAutores["name"] as! String)
                                            
                                        }else{
                                            self.autoresEntidad = self.autoresEntidad + (nombreAutores["name"] as! String)
                                            self.bookAuthor.text = self.bookAuthor.text! + (nombreAutores["name"] as! String)
                                        }
                                        index++
                                    }
                                    
                                   self.autoresAMandar = self.bookAuthor.text!
                                    
                                }
                                
                                
                                
                                //obtenemos la PORTADA de los datos del json
                                if let _ = datos["cover"] as? NSDictionary {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                        // Obtenemos el url de la imagen de portada y se lo pasamos a el UIImage
                                        //let cover = datos["cover"]
                                        
                                        /*
                                        if cover != nil && cover is NSDictionary{
                                            let covers = datos["cover"] as! NSDictionary
                                            
                                            
                                            if self.iPhone {
                                                if Device.IS_3_5_INCHES() {
                                                    self.urlImg = NSURL(string: covers["small"] as! NSString as String)
                                                }
                                                else if Device.IS_4_INCHES() {
                                                    self.urlImg = NSURL(string: covers["medium"] as! NSString as String)
                                                }
                                                else if Device.IS_4_7_INCHES() {
                                                    self.urlImg = NSURL(string: covers["medium"] as! NSString as String)
                                                }
                                                else if Device.IS_5_5_INCHES() {
                                                    self.urlImg = NSURL(string: covers["large"] as! NSString as String)
                                                }
                                            } else if self.iPad {
                                                self.urlImg = NSURL(string: covers["large"] as! NSString as String)
                                            }
                                        

                                        }
                                        */
                                        
                                        
                                        let data = NSData(contentsOfURL: self.urlImg!)
                                        self.portadaLibro.image = UIImage(data: data!)
                                        
                                        
                                        self.delegateNuevoDelegado?.mandarTitulo(self.tituloAMandar, imagenMandada: self.portadaLibro.image!, autorMandado: self.autoresAMandar)
                                        
                                        
                                        
                                        spinner.stopAnimating()
                                        spinner.removeFromSuperview()
                                        
                                        
                                        let nuevoLibroEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
                                        
                                        
                                        //almacenar titulos
                                        nuevoLibroEntidad.setValue(self.tituloAMandar, forKey: "titulo")
                                        
                                        //almacenar imagen
                                        nuevoLibroEntidad.setValue(data!, forKey: "portada")
                                        
                                        //almacenar autores
                                        nuevoLibroEntidad.setValue(self.autoresEntidad, forKey: "autor")
                                        
                                        //almacenar el ISBN
                                        nuevoLibroEntidad.setValue(self.isbn, forKey: "isbn")
                                        
                                        do{
                                            try self.contexto?.save()
                                        }catch{
                                        
                                        }
        
                                        
                                    })
                                }
                                
                            }
                            
                        }catch _ {
                            
                        }
                        
                    }else{
                        self.anadirLibroAlert(title: "", message: "No se encontró información con el ISBN introducido")
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                    }
                    
                }else{
                    self.anadirLibroAlert(title: "", message: "Error al conectar, compruebe su conexión a internet")
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                }
            })
        })
        task.resume()
    }

/*

        if datos != nil {
            
            addBookFound.title = "Add"
            
            do{
                
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                
                
                //TITULO
                let diccionario1 = json as! NSDictionary
                let diccionario2 = diccionario1["ISBN:\(ISBN)"] as! NSDictionary
                bookTitle.text = diccionario2["title"] as! NSString as String
                
                
                //PORTADA
                
                if diccionario2["cover"] != nil{
                    
                    let diccionario3 = diccionario2["cover"] as! NSDictionary
                    let img_urls = diccionario3["large"] as! String //convertimos el link de la imagen en String
                    let img_url = NSURL(string: img_urls) // la convertimos a url
                    let img_data = NSData(contentsOfURL: img_url!) //obtenemos el contenido de esa url (la imagen)
                    let imagen = UIImage(data: img_data!) // la imagen la convertimos en UIImage
                
                    if imagen != nil {
                    
                        portadaLibro.image = imagen //ahora esa imagen se la asignamos al UIImageView(portadaLibro)
                    
                    }
                    
                //Portada para la lista de libros
                //urlPortada = img_data
                
                }
                
                
    
                //AUTORES
                let diccionario4 = diccionario2["authors"] as! NSArray
                let diccionario5 = diccionario4.valueForKey("name")
                let diccionario6 = diccionario5[0] as! String as String
                bookAuthor.text = diccionario6

                
                
            }
                
            catch {}
            
        }else{
            
            let alert = UIAlertController(title: "Sin Conexión a Internet", message: "Verifica tu conexión a internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
*/
    
//*****************Funcino añadir titulo
    
    @IBAction func addBookFound(sender: UIBarButtonItem) {
    
      //self.tituloAMandar.append(bookTitle.text!)

       
        searchISBN.text = ""

        //NSUserDefaults.standardUserDefaults().setObject(Libros, forKey: "Libros")
        anadirLibroAlert(title: "Confirmado", message: "tu libro se ha añadido a tu lista")
        
    }
    
//************ function Alert
    func anadirLibroAlert(title title:String, message: String){
    
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
    
    func textFieldShouldReturn(textField: UITextField)-> Bool{
        textField.resignFirstResponder()
        
        return true
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */





}

