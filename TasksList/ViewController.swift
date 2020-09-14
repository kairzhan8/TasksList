//
//  ViewController.swift
//  TasksList
//
//  Created by Kairzhan Kural on 9/12/20.
//  Copyright © 2020 Kairzhan Kural. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    //managed object context -- here we save created objects
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        //table view cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func setupView() {
        view.backgroundColor = .white
        setupNavBar()
    }
    
    private func setupNavBar() {
        title = "Tasks list"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        //bar background color
        navigationController?.navigationBar.barTintColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        //large title bar tint color
               let navBarAppearance = UINavigationBarAppearance()
               navBarAppearance.configureWithOpaqueBackground()
               navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
               navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
               navBarAppearance.backgroundColor = UIColor(
               displayP3Red: 21/255,
               green: 101/255,
               blue: 192/255,
               alpha: 1)
               navigationController?.navigationBar.standardAppearance = navBarAppearance
               navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask))
        //font color
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(edit))
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New task", message: "What do you want to do?")
    }
    
    @objc private func edit() {
        if tableView.isEditing {
            tableView.isEditing = false
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.leftBarButtonItem?.title = "Edit"
        } else {
            tableView.isEditing = true
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }
            
            self.save(task)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func save(_ taskName: String) {
        
        //entity name
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        //model instance
        let task = NSManagedObject(entity: entityDescription, insertInto: managedContext) as! Task
        
        task.name = taskName
        
        do {
            try managedContext.save()
            tasks.append(task)
            //add new row to table without reloadData
            self.tableView.insertRows(
                at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                with: .automatic)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchData() {
        
        //запрос выборки из базы по ключу Task
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            try tasks = managedContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func update(_ updatedTask: String) {
        
    }
        
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedTask = tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            managedContext.delete(deletedTask as NSManagedObject)
            do {
            try managedContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tasks.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //entity name
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        //model instance
        let task = NSManagedObject(entity: entityDescription, insertInto: managedContext) as! Task
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        guard let taskk = cell.textLabel?.text else { return }
        
        let alert = UIAlertController(title: "Edit task", message: "Edit your task", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = taskk
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let updatedTask = alert.textFields?.first!.text else { return }
            task.name = updatedTask
            print(updatedTask)
            do {
                let currentTask = self.tasks.remove(at: indexPath.row)
                self.managedContext.delete(currentTask as NSManagedObject)
                self.tasks.insert(task, at: indexPath.row)
                try self.managedContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        
    }
    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
}
