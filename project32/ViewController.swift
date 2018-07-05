//
//  ViewController.swift
//  project32
//
//  Created by Sabrina Fletcher on 7/3/18.
//  Copyright © 2018 Sabrina Fletcher. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    var projects = [[String]]()
    var favorites = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"])
        projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        //puts tableView into Editing mode to allow for user selection
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(projects.count)
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        //cell.textLabel?.text = "\(project[0]): \(project[1])"
        cell.textLabel?.attributedText = makeAttributedString(title: project[0], subtitle: project[1])
        
        if favorites.contains(indexPath.row){
            //shows a checkmark if they exist in the favorites array
            cell.editingAccessoryType = .checkmark
        } else{
            cell.editingAccessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        //allows us to tell which rows need which editing style depending on if they are in the favorites array
        if favorites.contains(indexPath.row) {
            return .delete
        } else{
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else{
            if let index = favorites.index(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        item.expirationDate = Date.distantFuture
        
        CSSearchableIndex.default().indexSearchableItems([item]) {
            error in
            
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) {
            error in
            
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else{
                print("Search item successfully removed!")
            }
        }
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedStringKey.foregroundColor: UIColor.purple]
        let subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    func showTutorial(_ which: Int){
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)"){
            let config = SFSafariViewController.Configuration()
            
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }


}

