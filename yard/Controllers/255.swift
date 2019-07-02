//
//  ItemsTableViewController.swift
//  yard
//
//  Created by Dara Ladjevardian on 5/5/19.
//  Copyright © 2019 Dara Ladjevardian. All rights reserved.
//

import UIKit
import Firebase

class ItemsTableViewController: UITableViewController {
    
    // MARK: Constants
    let searchController = UISearchController(searchResultsController: nil)
    
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [UsedItem] = []
    var filteredItems =  [UsedItem] ()
    var user: User!
    let ref = Database.database().reference()
    var college = ""
    var fromLogIn = false
    var previousVC = UITabBarController()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredItems = items.filter({( item : UsedItem) -> Bool in
            let doesCategoryMatch = (scope == "All") || (item.itemType == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && item.name.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if fromLogIn{
            let profileNav = self.previousVC.viewControllers?[2] as! UINavigationController
            let profileVC = profileNav.viewControllers.first as! ProfileViewController
            profileVC.college = self.college
            let notNav = self.previousVC.viewControllers?[1] as! UINavigationController
            let notVC = notNav.viewControllers.first as! NotificationTableTableViewController
            notVC.college = self.college
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Furniture", "School", "Clothing", "Misc."]
        searchController.searchBar.delegate = self
        let greenColor = UIColor(red: 79/255, green: 181/255, blue: 50/255, alpha: 1.00)
        searchController.searchBar.tintColor = greenColor
        
        let use = Auth.auth().currentUser?.uid
        tableView.delegate = self
        tableView.dataSource = self
        
        ref.child(college).child("used-items").observe(.value, with: { snapshot in
            var newItems: [UsedItem] = []
            for child in snapshot.children {
                
                if let snapshot = child as? DataSnapshot,
                    let usedItem = UsedItem(snapshot: snapshot) {
                    /*if self.fromLogIn {
                        newItems.insert(usedItem, at: 0) //only if its straight from the log in page?
                    }
                    else{*/
                        newItems.insert(usedItem, at: 0)
                    //}
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
        self.getUserData(uid:use!) { (user) -> () in
            self.user = user
        }

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 380
    }
    
    func getUserData(uid:String, completion: @escaping (User) -> ()) {
        ref.child(college).child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let defaultUser = User()
            defaultUser.uid = uid
            defaultUser.email = value?["email"] as? String ?? ""
            defaultUser.name = value?["name"] as? String ?? ""
            defaultUser.grad = value?["grad"] as? Int ?? 0
            defaultUser.number = value?["number"] as? String ?? ""
            defaultUser.imageURL = value?["imageURL"] as? String ?? ""
            defaultUser.imageName = value?["imageName"] as? String ?? ""
            defaultUser.college = value?["college"] as? String ?? ""
            completion(defaultUser)
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItems.count
        }
        
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        if(indexPath.section==0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemTableViewCell
            
            let item: UsedItem
            if isFiltering() {
                item = filteredItems[indexPath.row]
            } else {
                item = items[indexPath.row]
            }
            cell.nameLabel.text = item.name
            let refOne = ref.child(college).child("users").child(item.userID).child("name")
            refOne.observeSingleEvent(of: .value, with: { (snapshot) in
                if let name = snapshot.value as? String {
                   cell.userLabel.text = name
                }
            })
            let refTwo = ref.child(college).child("users").child(item.userID).child("grad")
            refTwo.observeSingleEvent(of: .value, with: { (snapshot) in
                if let grad = snapshot.value as? String {
                    cell.gradLabel.text = "Class of \(grad)"
                }
            })
            
            let refURL = ref.child(college).child("users").child(item.userID).child("imageURL")
            refURL.observeSingleEvent(of: .value, with: { (snapshot) in
                if let imageURL = snapshot.value as? String {
                    if imageURL != "" {
                    let url = URL(string: imageURL )
                    let data = try? Data(contentsOf: url!)
                    if let imageData = data {
                        cell.userProfile.image = UIImage( data: imageData )
                    }
                    }
                    else{
                        cell.userProfile.image = UIImage( named: "Profile" )
                    }
                }
            })
            
            var money = "$" + String(item.price)
            if money.components(separatedBy: ".")[1].count == 1 {
                money = money + "0"
            }
            cell.interestLabel.text = "\(item.interestedUserIDs.count)"
            cell.priceLabel.text = money
            cell.descriptionLabel.text = item.description
            let url = URL(string: item.imageURL )
            let data = try? Data(contentsOf: url!)
            if let imageData = data {
                cell.imageItem.image = UIImage( data: imageData )
            }
            cell.connectButton.tag = indexPath.row
            
            // cell.connectButton
            if item.isOfTheCurrentUser || item.currentUserInterested {
                cell.connectButton.isHidden = true
            } else {
                cell.connectButton.isHidden = false
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    @IBAction func addSegue(_ sender: Any) {
        performSegue(withIdentifier: "addSegue", sender: user)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? AddItemViewController {
            nextVC.previousVC = self
            nextVC.user = user
            nextVC.college = college
        }
    }
    
    @IBAction func connectTapped(_ button: UIButton) {
        var item = items[button.tag]
        
        var notification = Notification(dictionary: item.toAnyObject() as! [String : AnyObject], ref: item.ref)!
        notification.notificationType = .request
        notification.fromuserID = Auth.auth().currentUser?.uid ?? ""
        notification.ref = ref.child(college).child("notification").childByAutoId()
        
        let userName = ref.child(college).child("users").child(notification.fromuserID).child("name")
        userName.observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value as? String {
                notification.notificationText = "\(name) is interested in your item, '\(notification.name)'. Share info?"
                notification.save()
                item.interestedUserIDs[Auth.auth().currentUser!.uid] = "1"
                item.save()
            }
        })
    }
}; extension ItemsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}; extension ItemsTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
}
