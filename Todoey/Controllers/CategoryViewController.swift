//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Karina on 5/3/19.
//  Copyright © 2019 Karina Carmin. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    //get lazy variable context from appDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }


    
    //MARK: - tableview Datasource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
            
    }
    
    //MARK: - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - manipulation method
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest() ){
        
        do{
            categoryArray = try context.fetch(request)
            
        }catch {
            print("Error fetching data form context: \(error)")
            
        }
        tableView.reloadData()
    }
    
    func saveCategories(){
        do{
            try context.save()
            
        }catch{
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //create  a local textInput
        var textInput = UITextField()
        
        //create UIalertcontroller
        
        let alert = UIAlertController(title:"Add a new Cateogory", message: nil, preferredStyle: .alert)
        
        //create an action for our uiAlertcontroller
        let action = UIAlertAction(title: "Add category", style: .default, handler: ({ (action) in
            
            //create an NSManagedObject and set its context to call it
            let newCat = Category(context: self.context)
            
            newCat.name = textInput.text!
            
            self.categoryArray.append(newCat)
            
            self.saveCategories()
            
            self.tableView.reloadData()
            
        }))
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Groceries, Goals, New Year resolutions"
            textInput = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
}
