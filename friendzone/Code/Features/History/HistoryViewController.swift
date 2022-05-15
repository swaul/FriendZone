//
//  HistoryViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 12.05.22.
//

import Foundation
import UIKit
import Combine

class HistoryViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: HistoryViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: HistoryViewModel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.retreiveSavedUsers()
    }
    
    var cancellables = Set<AnyCancellable>()
    
    func setupBindings() {
        viewModel.$savedUsers.sink { [weak self] users in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "UserNearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "UserNearbyTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Entfernen") { (_, _, completionHandler) in
            // delete the item here
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemSymbol: .xCircle)
        deleteAction.backgroundColor = Asset.primaryColor.color
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.savedUserIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserNearbyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserNearbyTableViewCell") as!  UserNearbyTableViewCell
        
        cell.configure(user: viewModel.savedUsers[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedUser = viewModel.usersNearby[indexPath.row]
//        currentlySelectedUser = selectedUser
//        selectedUserImageView.image = selectedUser.profilePicture
//        selectedUserNameLabel.text = selectedUser.name
//        selectedUserBioLabel.text = selectedUser.bio
//        selectedUserScoreLabel.text = String(selectedUser.score)
//        selectedUserScoreLabel.text! += "🔥"
//
//        showHidePopUp(hide: false)
    }
    
}
