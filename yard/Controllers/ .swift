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
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [UsedItem] = []
    var user: User!
    let ref = Database.database().reference()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        ref.child("used-items").observe(.value, with: { snapshot in
            var newItems: [UsedItem] = []
            for child in snapshot.children {
                // 4
                if let snapshot = child as? DataSnapshot,
                    let usedItem = UsedItem(snapshot: snapshot) {
                    newItems.append(usedItem)
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })

        let use = Auth.auth().currentUser?.uid 
        self.getUserData(uid:use!) { (user) -> () in
            self.user = user
        }

       /*Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }*/
    }
    
    func getUserData(uid:String, completion: @escaping (User) -> ()) {
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let defaultUser = User()
                defaultUser.uid = uid
                defaultUser.email = value?["email"] as? String ?? ""
                defaultUser.name = value?["name"] as? String ?? ""
                defaultUser.grad = value?["grad"] as? Int ?? 0
                defaultUser.number = value?["number"] as? String ?? ""
                defaultUser.image = UIImage(named: value?["image"] as? String ?? "")!
                completion(defaultUser)
        }){ (error) in
            print("hello")
            print(error.localizedDescription)
        }
    }
   /* func getUserData(uid:String, completion:(user:User) -> Void)
    {
        ref.child("users").child(uid).observe(.value, with: { (snapshot) in
            let defaultUser = User()
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                defaultUser.uid = uid
                defaultUser.email = value?["email"] as? String ?? ""
                defaultUser.name = value?["name"] as? String ?? ""
                defaultUser.grad = value?["grad"] as? Int ?? 0
                defaultUser.number = value?["number"] as? String ?? ""
                defaultUser.image = UIImage(named: value?["image"] as? String ?? "")!
            }
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(
                request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        completion(resultImage: UIImage(data: data))
                    }
            })
        })
            
    }*/


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        if(indexPath.section==0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell
            
            let item = items[indexPath.row]
            cell!.nameLabel.text = item.name
            cell!.userLabel.text = item.user.name
            cell!.priceLabel.text = String(item.price)
            cell!.descriptionLabel.text = item.description
            let url = URL(string: item.imageURL )
            let data = try? Data(contentsOf: url!)
            if let imageData = data {
                cell!.imageItem.image = UIImage( data: imageData )
            }
            
            return cell!
        }
        
        return UITableViewCell()
    }
    
    @IBAction func addSegue(_ sender: Any) {
        performSegue(withIdentifier: "addSegue", sender: user)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? AddItemViewController {
            nextVC.previousVC = self
            nextVC.user = sender as? User
        }
    }
    
}
