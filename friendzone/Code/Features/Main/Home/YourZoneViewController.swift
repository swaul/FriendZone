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

    // MARK: - Outlets
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userScoreLabel: UILabel!
    @IBOutlet var yourZoneHeaderLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var goOfflineLabel: UILabel!
    @IBOutlet var offlineSwitch: UISwitch!
    @IBOutlet var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUpPop()
        setupBindings()
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
    
    func checkLogin() {
        if Auth.auth().currentUser == nil {
            loginRequired()
        }
    }
    
    func setupView() {
        guard let user = Auth.auth().currentUser else { return }
        let defaults = UserDefaults.standard
        if let name = defaults.value(forKey: "name") as? String {
            userNameLabel.text = name
        } else {
            viewModel.getUserInfo()
        }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("profilePic.png")
        
        do {
            userImageView.image = try UIImage(data: Data(contentsOf: url))
        } catch {
            viewModel.getImage(id: user.uid)
        }
        
        userImageView.layer.cornerRadius = 20
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "UserNearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "UserNearbyTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
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
            self?.userNameLabel.text = user.name
            self?.userScoreLabel.text = String(user.score)
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
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate(
            [
                blurView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                blurView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                blurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                blurView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
            ])
    }

    func timer(duration: CGFloat, color: CGColor, endPoint: CGPoint, points: [CGPoint]) {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
            var points = points
            points.removeFirst()
            self.animateBackground(color: color, startPoint: endPoint, points: points)
        })
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
        guard let location = locations.first else { return }
        currentLocation = location
    }
    
    func getLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func uploadLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard error == nil, let placemarks = placemarks, let postalCode = placemarks.first!.postalCode, let country = placemarks.first!.country else { return }
            self?.viewModel.updateLocation(postalCode: postalCode, country: country)
            self?.viewModel.getNearbyUserIds(postalCode: postalCode, country: country)
        }
    }
    
    // MARK: - PopUp
    
    @IBOutlet var popupBackgroundView: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var selectedUserImageView: UIImageView!
    @IBOutlet var selectedUserNameLabel: UILabel!
    @IBOutlet var selectedUserBioLabel: UILabel!
    @IBOutlet var selectedUserScoreLabel: UILabel!
    @IBOutlet var tiktokButton: UIButton!
    @IBOutlet var instagramButton: UIButton!
    @IBOutlet var snapchatButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var selectedUserImageLeftView: UIImageView!
    @IBOutlet var selectedUserImageMiddleView: UIImageView!
    @IBOutlet var selectedUserImageRightView: UIImageView!
    @IBOutlet var selectedUserLeftVisitsLabel: UILabel!
    @IBOutlet var selectedUserMiddleVisitsLabel: UILabel!
    @IBOutlet var selectedUserRightVisitsLabel: UILabel!
    @IBOutlet var centerxConstraint: NSLayoutConstraint!
    
    lazy var popUpHiddenCenter = CGPoint(x: popUpView.frame.midX, y: view.frame.maxY + popUpView.frame.height / 2)
    
    func setupUpPop() {
        popupBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        popupBackgroundView.isHidden = true
        popUpView.center = popUpHiddenCenter
        popUpView.alpha = 0
        popUpView.layer.cornerRadius = 20
                
        selectedUserImageView.layer.cornerRadius = 60
        selectedUserImageView.layer.borderWidth = 4
        selectedUserImageView.layer.borderColor = Asset.accentColor.color.cgColor
        
        selectedUserImageLeftView.layer.cornerRadius = 10
        selectedUserImageMiddleView.layer.cornerRadius = 10
        selectedUserImageRightView.layer.cornerRadius = 10

    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        showHidePopUp(hide: true)
    }
    
    func showHidePopUp(hide: Bool) {
        if hide {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.popUpView.center = self.popUpHiddenCenter
                self.popupBackgroundView.alpha = 0
                self.popUpView.alpha = 0
            }, completion: { _ in
                self.popupBackgroundView.isHidden = true
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.popUpView.isHidden = false
                self.popupBackgroundView.isHidden = false
                self.popUpView.center = self.view.center
                self.popupBackgroundView.alpha = 1
                self.popUpView.alpha = 1
            }, completion: nil)
        }
    }
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            checkLogin()
        } catch {

        }
        
    }
}

extension YourZoneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.usersNearby.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserNearbyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserNearbyTableViewCell") as!  UserNearbyTableViewCell
        
        cell.configure(user: viewModel.usersNearby[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.usersNearby[indexPath.row]
        selectedUserImageView.image = selectedUser.profilePicture
        selectedUserNameLabel.text = selectedUser.name
        selectedUserBioLabel.text = selectedUser.bio
        selectedUserScoreLabel.text = String(selectedUser.score)
        
        showHidePopUp(hide: false)
    }
    
}
