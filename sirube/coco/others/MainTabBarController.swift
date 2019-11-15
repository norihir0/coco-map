//  MainTabBarController.swift

import UIKit
import Firebase

class MainTabBarController: UITabBarController,UITabBarControllerDelegate{
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    setupViewController()
    UITabBar.appearance().tintColor = .mainEmerald()
    UITabBar.appearance().backgroundColor = .mainVanilla()
    if Auth.auth().currentUser == nil {
      DispatchQueue.main.async {
        let loginController = LoginController()
        let navController = UINavigationController(rootViewController: loginController)
        self.present(navController, animated: true, completion: nil)
      }
      return
    }
  }
  
  func setupViewController() {
    let mapNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected") ,selectedImage: #imageLiteral(resourceName: "home_selected"),rootViewController: MapController())
    let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"),selectedImage: #imageLiteral(resourceName: "profile_selected"),rootViewController: UserProfileController())
    viewControllers = [mapNavController,userProfileNavController]
    guard let items = tabBar.items else { return }
    for item in items {
      item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
    }
  }
  
  fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
    let viewController = rootViewController
    let navController = UINavigationController(rootViewController: viewController)
    navController.tabBarItem.image = unselectedImage
    navController.tabBarItem.selectedImage = selectedImage
    return navController
  }
}


