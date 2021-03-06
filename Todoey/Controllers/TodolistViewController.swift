//
//  ViewController.swift
//  Todoey
//
//  Created by Mick Mossman on 24/8/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//
//This runs really slow n the cimulate and a"Unable to nsert copy_send" error appears
//it works on a device
import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework

class TodolistViewController: SwipeTableViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var darkenkenpc : CGFloat = 2.0
    
    //disSet proc wll get executed when we set th selected catgeory from Categoryview controller
    var selectedCategory : Category? {
        didSet {
            loadItems()
            
        }
    }
    
    var todoItems : Results<Item>?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let colourHex = selectedCategory?.backcolour else {fatalError("No backcolor")}
        
            title = selectedCategory?.name
            
        updateNavBar(withhexCode: colourHex)
        
            
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withhexCode: "6ED6FF")
//        guard let origcolour = UIColor(hexString: "6ED6FF") else {fatalError("Fick off")}
//        
//        navigationController?.navigationBar.barTintColor = origcolour
//        navigationController?.navigationBar.tintColor = FlatWhite()
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : FlatWhite()]
    }
    //MARK - Add new ietms
    
    func updateNavBar(withhexCode colourHexCode:String) {
        guard let navbar = navigationController?.navigationBar else {fatalError("No Navbar")}
        guard let navbarColour = UIColor(hexString:colourHexCode) else {fatalError("No nav colour")}
        
        searchBar.barTintColor = navbarColour
        
        navbar.tintColor = ContrastColorOf(navbarColour, returnFlat: true)
        navbar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navbarColour, returnFlat: true)]
        
        navbar.barTintColor = navbarColour
        
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        var userTextField = UITextField() //module lel textfile used in the closure
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            //var item = Item(thetitle: userTextField.text!)
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = userTextField.text!
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    
                    }
                } catch {
                    print("Error saving items: \(error)")
                }
                //self.saveData(item: item)
                self.tableView.reloadData()
                
            }
           
//            let newItem = Item(context: self.context)
//            newItem.title = userTextField.text!
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
            //self.itemArray.append(Item(thetitle: userTextField.text!))
            
            //            self.itemArray.append(userTextField.text!)
            //
            //            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            //print("Reloading")
            
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            userTextField = alertTextField
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Tableview shite
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let catcolor = selectedCategory?.backcolour {
                let cellcolour = UIColor(hexString: catcolor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
                cell.backgroundColor = cellcolour
                cell.textLabel?.textColor = ContrastColorOf(cellcolour!, returnFlat: true)

            }
            
            
        
            //[color darkenByPercentage:(CGFloat)percentage];
            //cell.backgroundColor = UIColor(hexString: (selectedCategory?.backcolour)!)?.darken(byPercentage: darkenkenpc)
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items found"
        }
        darkenkenpc += 5.0
        return cell
    }
    //MARK - Tableview delegate methinds
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        if let item = todoItems?[indexPath.row] {
            
            //saveData(item: item)
            do {
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item) //to delete from Realm
                    tableView.reloadData()
                }
            } catch {
                print("Error updating: \(error)")
            }
        }
            
        //itemArray?[indexPath.row].done = !itemArray[indexPath.row].done
        
        //DELETION
        //context.delete(itemArray[indexPath.row]) do this one first duh
        //itemArray.remove(at: indexPath.row)
        //END DELETION
        
       // item.done = !item.done
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        //saveData(itemArray[indexPath.row])
        
       tableView.deselectRow(at: indexPath, animated: true)
    
        
    }
    
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath:"title", ascending:true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    
                    self.realm.delete(item) //to delete from Realm
                    self.loadItems()
                    //self.tableView.reloadData()
                }
                
            } catch {
                print("Error updating: \(error)")
            }
        }
    }

}

extension TodolistViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)).sorted(byKeyPath: "dateCreated", ascending: false)
        
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        //google NSpredicate cheatsheet
//        //[cd] case and diacritic insensitive
//
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        request.sortDescriptors?.append(NSSortDescriptor(key: "title", ascending: false))
//
//        loadItems(with: request)

        tableView.reloadData()
         searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {

            loadItems()

            tableView.reloadData()

            DispatchQueue.main.async {
                 searchBar.resignFirstResponder()
            }

        }
    }
}
