//
//  FileController.swift
//  DataStorage
//
//  Created by Кристина Максимова on 16.09.2021.
//

import UIKit

class FileController: UITableViewController, FileChiefDelegate {

    // MARK: - Variables -
    
    let chief = FileChief.instance
    
    // MARK: - Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chief.displayFolder()
        setBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chief.delegate = self
    }
    
    func setBarButtons() {
        let fileButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(createFile))
        let folderButton = UIBarButtonItem.init(barButtonSystemItem: .organize, target: self, action: #selector(createFolder))
        
        navigationItem.setRightBarButtonItems([fileButton, folderButton], animated: true)
    }
    
    func setBackItem() {
        let backButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(back))
        navigationItem.setLeftBarButton(backButton, animated: true)
    }
    
    func deleteBackItem() {
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc func back() {
        chief.pop()
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        chief.commitRemovingForRowAt(indexPath)
    }

    // MARK: - Data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chief.elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let file = chief.elements[indexPath.row]
        
        cell.textLabel?.text = file.name
        cell.imageView?.image = UIImage(named: file.isDirectory ? "folder.png" : "file.png")

        return cell
    }

    // MARK: - Managing -
    
    @objc func createFolder() {
        chief.createFolder()
    }
    
    @objc func createFile() {
        chief.createFile()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chief.commitSelectingForRowAt(indexPath)
    }
        
    func presentFolder() {
        let fileController = storyboard?.instantiateViewController(withIdentifier: fileControllerId) as! FileController
        navigationController?.pushViewController(fileController, animated: true)
    }
    
    func updateFolder(_ name: String, isMain: Bool) {
        tableView.reloadData()
        title = name
        isMain ? deleteBackItem() : setBackItem()
    }
}
