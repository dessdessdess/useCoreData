//
//  ViewController.swift
//  useCoreData
//
//  Created by Admin on 05.05.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .brown
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var array = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
           
        self.navigationItem.title="use Core Data"
            
        let newItem = UIBarButtonItem.init(image: UIImage(systemName: "plus.circle"), style: .done, target: self, action: #selector(self.didTapEditButton))
        self.navigationItem.setRightBarButton(newItem, animated: true)
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "SomeEntity")
        
        //3
        do {
            self.array = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc private func didTapEditButton() {
        let alert = UIAlertController(title: "New name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { (action: UIAlertAction!) -> Void in
            
            let textField = alert.textFields![0] //as! UITextField
            self.saveName(text: textField.text!)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,
                animated: true,
                completion: nil)
    }

    func saveName(text: String) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
        
        // 1
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
        NSEntityDescription.entity(forEntityName: "SomeEntity",
                                   in: managedContext)!
        
        let arrayValue = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        
        // 3
        arrayValue.setValue(text, forKeyPath: "firstAttribute")
              
        // 4
        do {
            try managedContext.save()
            array.append(arrayValue)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = .lightGray
        
        cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        cell.layer.borderWidth = 2
        
        let label = UILabel()
        
        let arrayValue = array[indexPath.row]
        label.text = arrayValue.value(forKey: "firstAttribute") as? String
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        cell.contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 30).isActive = true
        label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -30).isActive = true
        label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        //        label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        //        label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
        
        
        //1
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
        NSFetchRequest<SomeEntity>(entityName: "SomeEntity")
        
        
        
        fetchRequest.predicate = NSPredicate.init(format: "firstAttribute == %@",  array[indexPath.row].value(forKey: "firstAttribute") as! String)
        
        //3
        do {
            
            let result = try managedContext.fetch(fetchRequest)
            
            for object in result {
                if object == array[indexPath.row] {
                    managedContext.delete(object)
                    try managedContext.save()
                    array.remove(at: indexPath.row)
                    tableView.reloadData()
                    break
                }
            }
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
}

