//
//  ViewController.swift
//  Todoey
//
//  Created by Karina on 4/10/19.
//  Copyright © 2019 Karina Carmin. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    var itemArray = [Item]() //array de objetos tipo Item

    let defaults = UserDefaults.standard
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //added to github
        
          print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
//            itemArray = items
//        }
       
        
    }

    //MARK - tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user click the add button on out UIAlert
            print("Success")
            print("in action \(textField.text!)")
            
            //using a singleton to acces to our AppDelegate as an object
            
            
            let newItem = Item(context: self.context)
            newItem.title  = textField.text!
            newItem.done = false
            newItem.newRelationship = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
           
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField //sabe alertTextField information into local variable textField
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        
        //this func save data into a plist
        
        do {
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "newRelationship.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            
            //nsConpoundPredicate helps to evalulate a combination of predicates (queries)
            //in this case, with set 2 NSPredicates for category list and search
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
        } else {
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try context.fetch(request)
        }catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest() //collects a criteria for a search
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //query in objective-c
        
        request.predicate = predicate //add predicate property
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true) //sort our result
        
        request.sortDescriptors = [sortDescriptor] // sortDescriptor is an array that can contain many sort criterias
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
}
