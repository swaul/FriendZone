import friendzoneKit
import Combine
import Fetch
import UIKit
import Firebase

@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLogging(for: Environment.current)
        log.info(Environment.current.appInfo)

        FirebaseApp.configure()
        
        Appearance.setup()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        AppCoordinator.shared.start(window: window!)
        
        return true
    }
    
    func applicationWillResignActive(_: UIApplication) {}
    
    func applicationDidEnterBackground(_: UIApplication) {}
    
    func applicationWillEnterForeground(_: UIApplication) {}
    
    func applicationDidBecomeActive(_: UIApplication) {}
    
    func applicationWillTerminate(_: UIApplication) {}
}
