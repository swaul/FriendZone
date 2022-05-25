//
//  HistoryViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 12.05.22.
//

import Foundation
import UIKit
import Combine
import NVActivityIndicatorView

class HistoryViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: HistoryViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: HistoryViewModel!
    @Published var ignoredShowing = false
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var ignoredTableView: UITableView!
    @IBOutlet var loadingWrapper: UIView!
    @IBOutlet var indicatorWrapper: UIView!
    
    lazy var barButton = UIBarButtonItem(title: "Ignoriert", style: .done, target: self, action: #selector(switchScreen))
    var offscreenRight: CGPoint?
    var offscreenLeft: CGPoint?
    var onscreenCenter: CGPoint?
    
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
        viewModel.$usersUpdated.sink { [weak self] updated in
            if updated {
                self?.tableView.reloadData()
                print("false")
                self?.viewModel.usersUpdated = false
            }
        }.store(in: &cancellables)
        
        $ignoredShowing.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
        
        viewModel.$viewModelState.sink { [weak self] state in
            switch state {
            case .loading:
                self?.showLoading(true)
            case .loaded:
                self?.showLoading(false)
            case .empty:
                self?.showLoading(false)
            case .error:
                self?.showLoading(false)
            }
        }.store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        offscreenRight = CGPoint(x: ignoredTableView.frame.midX + ignoredTableView.frame.width, y: ignoredTableView.frame.midY)
        offscreenLeft = CGPoint(x: tableView.frame.midX - tableView.frame.width, y: tableView.frame.midY)
        onscreenCenter = tableView.center
        
        ignoredTableView.center = offscreenRight!
        
        let indicator = NVActivityIndicatorView(frame: indicatorWrapper.bounds, type: .orbit, color: Asset.primaryColor.color, padding: 0)
        indicatorWrapper.addSubview(indicator)
        
        NSLayoutConstraint.activate(
            indicator.alignEdges()
        )
        
        indicator.startAnimating()
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        ignoredTableView.delegate = self
        ignoredTableView.dataSource = self
        
        tableView.register(UINib(nibName: "UserNearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "UserNearbyTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        
        ignoredTableView.register(UINib(nibName: "UserNearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "UserNearbyTableViewCell")
        ignoredTableView.separatorColor = .clear
        ignoredTableView.backgroundColor = .clear
                
        loadingWrapper.layer.cornerRadius = 20
        
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func switchScreen() {
        ignoredShowing = !ignoredShowing
        switchTableViews(ignoredShowing: ignoredShowing)
    }
    
    func switchTableViews(ignoredShowing: Bool) {
        viewModel.retreiveSavedUsers()
        guard let offscreenLeft = offscreenLeft, let offscreenRight = offscreenRight, let onscreenCenter = onscreenCenter else { return }

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            if ignoredShowing {
                self.ignoredTableView.center = onscreenCenter
                self.tableView.center = offscreenLeft
                self.barButton.title = "Gespeichert"
            } else {
                self.ignoredTableView.center = offscreenRight
                self.tableView.center = onscreenCenter
                self.barButton.title = "Ignoriert"
            }
        } completion: { completed in
            print(completed)
        }
    }
    
    func removeSavedUser(user: UserViewModel?) {
        guard let user = user else { return }
        let defaults = UserDefaults.standard
        
        if let savedUsers = defaults.value(forKey: "savedUsers") as? [String: Date] {
            var usersSaved = savedUsers
            usersSaved.removeValue(forKey: user.id)
            defaults.set(usersSaved, forKey: "savedUsers")
        }
        
        viewModel.retreiveSavedUsers()
    }
    
    func removeIgnoredUser(user: UserViewModel?) {
        guard let user = user else { return }
        let defaults = UserDefaults.standard
        
        if let ignoredUsers = defaults.value(forKey: "ignoredUsers") as? [String: Date] {
            var usersToIgnore = ignoredUsers
            usersToIgnore.removeValue(forKey: user.id)
            defaults.set(usersToIgnore, forKey: "ignoredUsers")
        }
        
        viewModel.retreiveSavedUsers()
    }
    
    func showLoading(_ loading: Bool) {
        print("is hidden", !loading)
        loadingWrapper.isHidden = !loading
    }
    
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch tableView {
        case self.tableView:
            let deleteAction = UIContextualAction(style: .destructive, title: "Entfernen") { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }
                self.removeSavedUser(user: self.viewModel.savedUsers[indexPath.row])
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemSymbol: .xCircle)
            deleteAction.backgroundColor = .systemRed
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        case ignoredTableView:
            let deleteAction = UIContextualAction(style: .destructive, title: "Rückgängig") { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }
                self.removeIgnoredUser(user: self.viewModel.ignoredUsers[indexPath.row])
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemSymbol: .arrowClockwiseHeart)
            deleteAction.backgroundColor = Asset.primaryColor.color
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView:
            return viewModel.savedUserIds.count
        case self.ignoredTableView:
            return viewModel.ignoredUserIds.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserNearbyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserNearbyTableViewCell") as!  UserNearbyTableViewCell
        
        switch tableView {
        case self.tableView:
            cell.configure(user: viewModel.savedUsers[indexPath.row])
        case self.ignoredTableView:
            cell.configure(user: viewModel.ignoredUsers[indexPath.row])
        default:
            fatalError()
        }
        
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
