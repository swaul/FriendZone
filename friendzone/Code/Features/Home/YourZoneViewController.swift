//
//  YourZoneViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 28.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import AlamofireImage
import UIKit
import Combine
import TinyConstraints
import CoreLocation
import FirebaseAuth
import StatefulViewController

class YourZoneViewController: UIViewController, CLLocationManagerDelegate {
    
    public static func createWith(storyboard: Storyboard, viewModel: YourZoneViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        viewController.restartAnimation = true
        return viewController
    }
    
    var viewModel: YourZoneViewModel!
    
    var restartAnimation: Bool = false
    var line1 = [CGPoint]()
    var line2 = [CGPoint]()
    var line3 = [CGPoint]()
    
    var loginRequired: (() -> Void)!
    var onProfile: (() -> Void)!
    var onNews: (() -> Void)!

    // MARK: - Outlets
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var goOfflineLabel: UILabel!
    @IBOutlet var offlineSwitch: UISwitch!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var backgroundBlob: UIImageView!
    @IBOutlet var newsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupUserProfile()
        if restartAnimation {
            makeLines()
        }
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = 20
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            getLocation()
        }
        checkLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUserInfo()
        getLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = 24
    }
    
    func checkLogin() {
        if Auth.auth().currentUser == nil {
            loginRequired()
        }
    }
    
    func setupView() {
        titleLabel.text = "Your Zone"
        offlineSwitch.isOn = false
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "UserNearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "UserNearbyTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        setupStatefulViews(backgroundVisible: true)
        offlineSwitch.onTintColor = .systemGreen
    }

    func updateUserInfo() {
        guard let user = Auth.auth().currentUser else { return }
        let defaults = UserDefaults.standard
        if let name = defaults.value(forKey: "name") as? String {
            userNameLabel.text = name
        } else {
            viewModel.getUserInfo()
        }
        
        guard userImageView.image == nil else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("profilePic.png")
        
        do {
            userImageView.image = try UIImage(data: Data(contentsOf: url))
        } catch {
            viewModel.getImage(id: user.uid)
        }
            
    }
    
    func makeLines() {
        let minX = backgroundView.bounds.minX
        let maxX = backgroundView.bounds.maxX
        let minY = backgroundView.bounds.minY
        let maxY = backgroundView.bounds.maxY
        let firstOne = CGPoint(x: CGFloat.random(in: minX...maxX), y: CGFloat.random(in: minY...(maxY - maxY * 0.8)))
        let secondOne = CGPoint(x: CGFloat.random(in: minX...(maxX - firstOne.x)), y: CGFloat.random(in: minY...(maxY - firstOne.y)))
        let thirdOne = CGPoint(x: CGFloat.random(in: minX...(maxX - secondOne.x)), y: CGFloat.random(in: minY...(maxY - secondOne.y)))
        line1 = [firstOne, secondOne, thirdOne]
        
        let firstTwo = CGPoint(x: CGFloat.random(in: minX...maxX), y: CGFloat.random(in: minY...(maxY - maxY * 0.2)))
        let secondTwo = CGPoint(x: CGFloat.random(in: minX...(maxX - firstTwo.x)), y: CGFloat.random(in: minY...(maxY - firstTwo.y)))
        let thirdTwo = CGPoint(x: CGFloat.random(in: minX...(maxX - secondTwo.x)), y: CGFloat.random(in: minY...(maxY - secondTwo.y)))
        line2 = [firstTwo, secondTwo, thirdTwo]
        
        let firstThree = CGPoint(x: CGFloat.random(in: minX...maxX), y: CGFloat.random(in: minY...(maxY - maxY * 0.5)))
        let secondThree = CGPoint(x: CGFloat.random(in: minX...(maxX - firstThree.x)), y: CGFloat.random(in: minY...(maxY - firstThree.y)))
        let thirdThree = CGPoint(x: CGFloat.random(in: minX...(maxX - secondThree.x)), y: CGFloat.random(in: minY...(maxY - firstThree.y)))
        line3 = [firstThree, secondThree, thirdThree]
        
        animateBackground(color: UIColor.systemRed.cgColor, startPoint: CGPoint(x: 0, y: maxY * 0.8), points: line1)
        animateBackground(color: UIColor.systemGreen.cgColor, startPoint: CGPoint(x: 0, y: maxY * 0.2), points: line2)
        animateBackground(color: UIColor.systemBlue.cgColor, startPoint: CGPoint(x: maxX, y: maxY * 0.5), points: line3)
        restartAnimation = false
    }
    
    func hasContent() -> Bool {
        !viewModel.usersNearby.isEmpty
    }
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        viewModel.$usersUpdated.sink { [weak self] value in
            if value {
                self?.tableView.reloadData()
                self?.viewModel.usersUpdated = false
            }
        }.store(in: &cancellabels)
        
        $currentLocation.sink { [weak self] location in
            guard let location = location else { return }
            self?.uploadLocation(location: location)
        }.store(in: &cancellabels)
        
        viewModel.$userInfo.sink { [weak self] user in
            guard let user = user else { return }
            self?.populateUserProfile(user: UserViewModel(model: user))
        }.store(in: &cancellabels)
        
        viewModel.$profileImage.sink { [weak self] image in
            guard let image = image else { return }
            self?.userImageView.image = image
        }.store(in: &cancellabels)
    }
    
    func animateBackground(color: CGColor, startPoint: CGPoint, points: [CGPoint]) {
        guard let newPoint = points.first else { return }
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: newPoint)
    
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 4
        shapeLayer.path = path.cgPath
        shapeLayer.lineDashPattern = [3, 3, 3]
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        
        // animate it
        var duration = newPoint.y / 100
        
        if newPoint.y < newPoint.x {
            duration = newPoint.x / 100
        }
        
        timer(duration: duration, color: color, endPoint: newPoint, points: points)
                
        backgroundView.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 10
        shapeLayer.add(animation, forKey: "MyAnimation")
    }

    func timer(duration: CGFloat, color: CGColor, endPoint: CGPoint, points: [CGPoint]) {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
            var points = points
            points.removeFirst()
            self.animateBackground(color: color, startPoint: endPoint, points: points)
        })
    }
    
    @IBAction func offlineDidChange(_ sender: Any) {
        onlineIndicatorView.tintColor = offlineSwitch.isOn ? .systemRed : .systemGreen
        viewModel.isOffline = offlineSwitch.isOn
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.backgroundBlob.tintColor = self.offlineSwitch.isOn ? .gray : Asset.primaryColor.color
            self.backgroundView.alpha = self.offlineSwitch.isOn ? 0.0 : 1.0
        } completion: { completed in
            if completed && self.offlineSwitch.isOn {
                print("done")
                self.tableView.reloadData()
            } else {
                self.getLocation()
            }
        }

    }
    
    @IBAction func newsButtonTapped(_ sender: Any) {
        onNews()
    }
    
    // MARK: - Location
    
    var locationManager: CLLocationManager!
    
    @Published var currentLocation: CLLocation? {
        didSet {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            getLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updateLocation")
        guard let location = locations.first else { return }
        print("to ", location)
        let distance = currentLocation?.distance(from: location) ?? 10000
        if distance > 100.0 {
            print("upload location", distance)
            currentLocation = location
        }
    }
    
    func getLocation() {
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func uploadLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard error == nil, let placemarks = placemarks, let postalCode = placemarks.first!.postalCode, let country = placemarks.first!.country else { return }
            print("uploading location")
            self?.viewModel.updateLocation(postalCode: postalCode, country: country)
            print("updating nearby users")
            self?.viewModel.getNearbyUserIds(postalCode: postalCode, country: country)
        }
    }
    
    // MARK: - User
    
    @IBOutlet var userWrapperView: UIView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var onlineIndicatorView: UIImageView!
    @IBOutlet var userScoreLabel: UILabel!
    
    func setupUserProfile() {
        userImageView.layer.borderColor = Asset.accentColor.color.cgColor
        userImageView.layer.borderWidth = 2
        userNameLabel.setStyle(TextStyle.normal)
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        userWrapperView.addGestureRecognizer(profileTap)
        userWrapperView.isUserInteractionEnabled = true
    }
    
    func populateUserProfile(user: UserViewModel) {
        userNameLabel.text = user.name
        userScoreLabel.text = String(user.score)
        userScoreLabel.text! += "🔥"
        onlineIndicatorView.tintColor = offlineSwitch.isOn ? .systemRed : .systemGreen
        
        guard userImageView.image == nil else { return }
        userImageView.image = user.profilePicture
    }
    
    @objc func showProfile() {
        onProfile()
    }
    
    // MARK: - PopUp
    var currentlySelectedUser: UserViewModel?
    
    func showHidePopUp(user: UserViewModel) {
        let popup = UserPopupViewController.createWith(storyboard: .main, viewModel: user)
        popup.transitioningDelegate = popup.presentationManager
        popup.modalPresentationStyle = .custom
        
        let backgroundView = UIView(frame: view.frame)
        backgroundView.backgroundColor = .black.withAlphaComponent(0.22)
        view.addSubview(backgroundView)
        
        popup.onDismiss = { [weak self] in
            self?.currentlySelectedUser = nil
            backgroundView.removeFromSuperview()
        }
        
        present(popup, animated: true)
    }

    func saveUser(user: UserViewModel?) {
        guard let user = user else { return }
        var usersToSave = [String: Date]()
        let defaults = UserDefaults.standard
        
        if let savedUsers = defaults.value(forKey: "savedUsers") as? [String: Date] {
            usersToSave = savedUsers
            usersToSave[user.id] = Date()
        } else {
            usersToSave[user.id] = Date()
        }
        
        defaults.set(usersToSave, forKey: "savedUsers")
    }
    
    func ignoreUser(user: UserViewModel?) {
        guard let user = user else { return }
        var usersToIgnore = [String: Date]()
        let defaults = UserDefaults.standard
        
        if let ignoredUsers = defaults.value(forKey: "ignoredUsers") as? [String: Date] {
            usersToIgnore = ignoredUsers
            usersToIgnore[user.id] = Date()
        } else {
            usersToIgnore[user.id] = Date()
        }
        
        defaults.set(usersToIgnore, forKey: "ignoredUsers")
        
        viewModel.usersNearby.removeAll(where: { $0.id == user.id })
        getLocation()
        tableView.reloadData()
    }
    
}

extension YourZoneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Ignorieren") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.ignoreUser(user: self.viewModel.usersNearby[indexPath.row])
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemSymbol: .xCircle)
        deleteAction.backgroundColor = Asset.errorColor.color
        
        let saveAction = UIContextualAction(style: .normal, title: "Speichern") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.saveUser(user: self.viewModel.usersNearby[indexPath.row])
            completionHandler(true)
        }
        saveAction.image = UIImage(systemSymbol: .clockArrowCirclepath)
        saveAction.backgroundColor = Asset.primaryColor.color
    
        let configuration = UISwipeActionsConfiguration(actions: [saveAction, deleteAction])
                
        return configuration
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.usersNearby.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserNearbyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserNearbyTableViewCell") as! UserNearbyTableViewCell
        
        cell.configure(user: viewModel.usersNearby[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.usersNearby[indexPath.row]
        currentlySelectedUser = selectedUser
        showHidePopUp(user: selectedUser)
    }
    
}

extension YourZoneViewController: StatefulViewController, CommonStatefulViews {
    
    func refetchData() {
    
    }
    
}
