//
//  MainTableViewController.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 17/01/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit
import CoreData


extension MainTableViewController: BookSearchDelegate {
    func updateData(data: Model) {
        self.modelo = data
        
    }
}


extension MainTableViewController: NuevoDelegado{
    func mandarTitulo(titulo titulo: String, autor: String, portada: UIImage) {
        
        self.titulos.append(titulo)
        self.autores.append(autor)
        self.portadas.append(portada)
    }

}


class MainTableViewController: UITableViewController {

    
    
//********* Variables
    
    var titulos: [String] = []
    var autores: [String] = []
    var portadas: [UIImage] =  []
    var index: Int?
    var portadaBorde:NSData!
    
    var modelo:Model = Model(titulo: [], autor: [], portada: [], isbn: [])
    
    //accedemos a la pila de CoreData. Contexto es la parte de memoria en el inter de recuperar datos.
    var contexto : NSManagedObjectContext? = nil
    
    
//**********Outlets
    //toDoList es mi tableView
@IBOutlet var toDoListTable: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //******** 1. Obtenemos el contexto
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        
        
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("peticionLibros")
    
        
        do{
            let librosEntidad = try self.contexto?.executeFetchRequest(peticion!)
            
            for libro in librosEntidad!{
                
                let tituloEntidad = libro.valueForKey("titulo") as! String
                let autorEntidad = libro.valueForKey("autor") as! String
                
                let SVC = SearchViewController()
                let portadaEntidad = SVC.imageWithBorderFromImage(UIImage(data: libro.valueForKey("portada") as! NSData)!)
                self.portadaBorde = libro.valueForKey("portada") as! NSData
                
                self.titulos.append(tituloEntidad)
                self.autores.append(autorEntidad)
                self.portadas.append(portadaEntidad)
                
                
            }
            
        }catch{
            
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        self.toDoListTable!.reloadData()
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "sigVistaSearch" {
            let bookSearch = segue.destinationViewController as? SearchViewController
            bookSearch!.delegate = self
            bookSearch!.delegateNuevoDelegado = self
        }
        
        if segue.identifier == "showDetails"{
            
            if let destination = segue.destinationViewController as? DetailsViewController{
                
                let tituloParaDetails = self.titulos[index!]
                destination.detalleTitulo = tituloParaDetails
                
                
                let autoresParaDetails = self.autores[index!]
                destination.detalleAuthor = autoresParaDetails
                
                let portadaParaDetails = self.portadas[index!]
                destination.detallePortada = portadaParaDetails
                
                
                
            }
            
        }
        
    }
    
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        
        
        let scale = CGFloat(max(size.width/image.size.width,
            size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRectMake( 0, 0, width, height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.drawInRect(rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.titulos.count
        
        
    }

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        
        return 5 // space b/w cells
    }
   

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = self.titulos[indexPath.row]
        cell.imageView?.image = self.portadas[indexPath.row]
        cell.imageView?.layer.cornerRadius =  10
        cell.imageView?.layer.masksToBounds = true;


        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let libroSeleccionadoId = indexPath.row
        index = indexPath.row
        self.performSegueWithIdentifier("showDetails", sender: libroSeleccionadoId)
        
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //si al hacer swipe a la izquierda, luego presiono Delete se va a eliminar esa linea
        if editingStyle == .Delete {
          
            titulos.removeAtIndex(indexPath.row)
            /*
            NSUserDefaults.standardUserDefaults().setObject(Titulos, forKey: "Titulos")
            */
            self.toDoListTable!.reloadData()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

}
