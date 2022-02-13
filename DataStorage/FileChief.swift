//
//  chief.swift
//  DataStorage
//
//  Created by Кристина Максимова on 23.09.2021.
//

import UIKit

protocol FileChiefDelegate: UIViewController {
    func presentFolder()
    func updateFolder(_ name: String, isMain: Bool)
}

class FileChief {
    
    // MARK: - Models -
    
    struct Element {
        var name: String
        var isDirectory: Bool
    }
    
    static let instance = FileChief()
    private init() {
        if currentURL == nil {
            currentURL = mainURL
        }
    }
    
    // MARK: - Variables -
    
    var delegate: FileChiefDelegate? {
        didSet {
            displayFolder()
        }
    }
    let manager = FileManager.default
    var mainURL: URL? {
        manager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    var currentURL: URL?
    var elements = [Element]()
    
    // MARK: - Methods -
    
    func pop() {
        currentURL?.deleteLastPathComponent()
    }
    
    func displayFolder() {
        var namesOfElements = [String]()
        guard let url = currentURL else { return }
        do {
            namesOfElements = try manager.contentsOfDirectory(atPath: url.path)
        } catch {
            print(error)
        }
        
        elements = namesOfElements.map {
            var isDirectory: ObjCBool = false
            let path = url.appendingPathComponent($0).path
            
            if manager.fileExists(atPath: path, isDirectory: &isDirectory) { 
                return Element(name: $0, isDirectory: isDirectory.boolValue)
            } else {
                return Element(name: "", isDirectory: false)
            }
        }
        elements.sort {
            if $0.isDirectory && $1.isDirectory ||
                !$0.isDirectory && !$1.isDirectory {
                return getNumInString($0.name) < getNumInString($1.name)
            } else {
                return $0.isDirectory
            }
        }
        delegate?.updateFolder(url.lastPathComponent, isMain: currentURL == mainURL)
    }
    
    // MARK: - Managing -
    
    func createFile() {
        guard let url = currentURL else { return }
        let filesCount = getNumInString(elements.filter {!$0.isDirectory}.last?.name ?? "0")
        
        let fileURL = url.appendingPathComponent("file \(filesCount + 1).txt")
        let data = randomText().data(using: .utf8)
        manager.createFile(atPath: fileURL.path, contents: data, attributes: [FileAttributeKey.creationDate : Date()])
        displayFolder()
    }
    
    func createFolder() {
        guard let url = currentURL else { return }
        
        let foldersCount = getNumInString(elements.filter{$0.isDirectory}.last?.name ?? "0")
        
        let folderURL = url.appendingPathComponent("Folder \(foldersCount + 1)")
        do {
            try manager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: [:])
        } catch {
            print(error)
        }
        displayFolder()
    }
    
    func commitSelectingForRowAt(_ indexPath: IndexPath) {
        guard let url = currentURL else { return }
        let element = elements[indexPath.row]
        let elementUrl = url.appendingPathComponent(element.name)
        
        if element.isDirectory {
            currentURL = elementUrl
            guard let realDelegate = delegate else {return}
            realDelegate.presentFolder()
        } else {
            do {
                let text = try String(contentsOf: elementUrl, encoding: .utf8)
                let alert = alert(title: element.name, message: text)
                guard let realDelegate = delegate else {return}
                realDelegate.present(alert, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
    }
    
    func commitRemovingForRowAt(_ indexPath: IndexPath) {
        guard let url = currentURL else { return }
        let fileUrl = url.appendingPathComponent(elements[indexPath.row].name)
        do {
            try manager.removeItem(atPath: fileUrl.path)
            displayFolder()
        } catch  {
            print(error)
        }
    }
    
    // MARK: - Services -
    
    func randomText() -> String {
        let greetings = ["Hello", "Hi", "Hey", "Howdy", "Hiya", "Yo", "G'day"]
        let names = ["Jack", "Alice", "Mike", "Nick", "Sofi", "Kris", "Aice"]
        let phrases = ["How is it going?", "How's life?", "How are things?", "Long time no see!", "What are you up to?", "What have you been up to?", "Good luck!"]
        return greetings.randomElement()! + " " + names.randomElement()! + "\n" + phrases.randomElement()!
    }
    
    func alert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        return alert
    }
    
    func getNumInString(_ str: String) -> Int {
        let numbers = str.components(separatedBy: CharacterSet.decimalDigits.inverted).reduce("", {$0 + $1})
        return Int(numbers) ?? 0
    }
}
