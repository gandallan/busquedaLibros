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
    
    func updateDate(data: ObjetoLibro) {
        self.modelo = data
        
    }
}

extension MainTableViewController: NuevoDelegado {

    func mandarTitulo(tituloMandado: String, imagenMandada: UIImage, autorMandado: String) {
        
        self.titulos.append(tituloMandado)
        self.autores.append(autorMandado)
        self.portadas.append(imagenMandada)
        self.imagenTable = imagenMandada
        
    }
    
}

//*********************** variables globales

//var Libros = [String]()
//var urlPortada:NSData!

//***********************

class MainTableViewController: UITableViewController {
    
    
    

//**********Variables
    
    //nos permite entrar al contexto de Core Data
    var contexto : NSManagedObjectContext? = nil
    
    var titulos: [String] = []
    var autores: [String] = []
    var portadas: [UIImage] = []
    var index: Int?
    var modelo: ObjetoLibro = ObjetoLibro(_titulo: [])
    var imagenTable: UIImage = UIImage()
    
    
    
    
//**********Outlets
    @IBOutlet var toDoListTable: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate ).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("peticionLibros")
        
        
        do{
            let librosEntidad = try! self.contexto?.executeFetchRequest(peticion!)
            
            for libro in librosEntidad! {
                
                //declaramos variables asignando el contenido que ya tiene CoreData
                let tituloEntidad = libro.valueForKey("titulo") as! String
                let autoresEntidad = libro.valueForKey("autor") as! String
                let SearchVC = SearchViewController()
                let portadaEntidad = SearchVC.imageWithBorderFromImage(UIImage(data: libro.valueForKey("portada") as! NSData)!)
                
                self.titulos.append(tituloEntidad)
                self.autores.append(autoresEntidad)
                self.portadas.append(portadaEntidad)
                
                
            }
        }
        catch {
            
        }
        
        
        // Cambiar el color de la barra de estado
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.navigationController!.navigationBar.barStyle = .BlackTranslucent;
        self.navigationController!.navigationBar.translucent = true;
        
        /*
        if  NSUserDefaults.standardUserDefaults().objectForKey("Libros") != nil {
            
            Libros = NSUserDefaults.standardUserDefaults().objectForKey("Libros") as! [String]
        
        }
        */
        
        
        
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.titulos.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        
        //configurando la celda
        cell.textLabel?.text = self.titulos[indexPath.row]
        cell.imageView?.image = UIImage(named: "\(portadas)")
        
        
        /*
        if  urlPortada != nil {
            
            cell.imageView?.image = UIImage(data: urlPortada)

            
        }
        */
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let libroSeleccionadoId = indexPath.row
        
        if let _ = tableView.cellForRowAtIndexPath(indexPath){
            
            index = indexPath.row
            self.performSegueWithIdentifier("showDetails", sender: libroSeleccionadoId)
            
        }else{
        
        }
        
        
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        if segue.identifier == "showDetails"{
            
            let libroSeleccinado = sender as! Int
            print(libroSeleccinado)
        
            //let DetailsView: DetailsViewController = segue.destinationViewController as! DetailsViewController
            
            
        }
        */
        
    }
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        toDoListTable.reloadData()
        
    }
    
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //si al hacer swipe a la izquierda, luego presiono Delete se va a eliminar esa linea
        if editingStyle == .Delete {
          
            self.titulos.removeAtIndex(indexPath.row)
            
            NSUserDefaults.standardUserDefaults().setObject(titulos, forKey: "Libros")
            
            toDoListTable.reloadData()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    


}
