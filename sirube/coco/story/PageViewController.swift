//  PageViewController.swift

import Foundation
import UIKit
import CoreLocation

class PageViewController : UIViewController, CLLocationManagerDelegate{
  
  private var basePageViewController:UIPageViewController!
  private var pageIndex = 0
  private var videoFiles = ["https://drive.google.com/open?id=1v5Nx06cOSwUAmJBRFgLWbX61T74mfv5o","https://drive.google.com/uc?id=1NpCFQHuaje2B7RS3rcZ_v-CUXP4GOLVY","https://drive.google.com/open?id=12gvmpqiNm8_5WkJ1ASlnZzFU3yst7xbI","https://drive.google.com/file/d/1YqU7MPivptaKoM4n5OfTc3iY6M_-1mbl/view?usp=sharing","https://drive.google.com/open?id=1gNtwhVl6taY1kiWNDOkz6qo8vAq26hF0","https://drive.google.com/open?id=1wPqTxclUVthJrjQGf8NKvHF8uZ3zuxiP","https://drive.google.com/open?id=1KPYCrZOHci90eMGXCcL0DR1JxZ_Ctd5p"]
  var locationManager: CLLocationManager!
  
  override func viewDidLoad() {
    setupPageViewController()
  //   setupNavigationBar()
    setupLocationManager()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
  }
  
  func setupPageViewController(){
    basePageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    if let pageViewController = basePageViewController {
      pageViewController.dataSource = self
      pageViewController.setViewControllers([StoryController()],
                                            direction: .forward,
                                            animated: false,
                                            completion: {done in})
      pageViewController.view.frame = self.view.frame
      addChild(pageViewController)
      self.view.addSubview(pageViewController.view)
    }
  }
  
  private func setupNavigationBar() {
    let allMenuButton = UIBarButtonItem(title: "すべて", style: UIBarButtonItem.Style.plain, target: self, action: #selector(getVideo))
    allMenuButton.tintColor = UIColor.white
    
    let eatMenuBarButton = UIBarButtonItem(title: "たべる", style: UIBarButtonItem.Style.plain, target: self, action: #selector(getVideo))
    eatMenuBarButton.tintColor = UIColor.white
    
    let playMenuBarButton = UIBarButtonItem(title: "あそぶ", style: UIBarButtonItem.Style.plain, target: self, action: #selector(getVideo))
    playMenuBarButton.tintColor = UIColor.white
    
    let buyMenuBarButton = UIBarButtonItem(title: " かう ", style: UIBarButtonItem.Style.plain, target: self, action: #selector(getVideo))
    buyMenuBarButton.tintColor = UIColor.white
    
    let restMenuBarButton = UIBarButtonItem(title: "やすむ", style: UIBarButtonItem.Style.plain, target: self, action: #selector(getVideo))
    restMenuBarButton.tintColor = UIColor.white
    
    let buttonGap: UIBarButtonItem = UIBarButtonItem(title: "｜", style: UIBarButtonItem.Style.plain, target: self, action: nil)
    buttonGap.tintColor = UIColor.white
    
    self.navigationItem.leftBarButtonItems = [allMenuButton,buttonGap,eatMenuBarButton,buttonGap,playMenuBarButton,buttonGap,buyMenuBarButton,buttonGap,restMenuBarButton]
  }
  
  @objc
  fileprivate func getVideo() {
    
  }
  
  func setupLocationManager() {
    locationManager = CLLocationManager()
    guard let locationManager = locationManager else { return }
    
    locationManager.requestWhenInUseAuthorization()
    
    
    let status = CLLocationManager.authorizationStatus()
    if status == .authorizedWhenInUse {
      locationManager.delegate = self
      locationManager.distanceFilter = 100
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.first
    let latitude = location?.coordinate.latitude
    let longitude = location?.coordinate.longitude
    print("latitude: \(latitude!)\nlongitude: \(longitude!)")
  }
}

extension PageViewController : UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! StoryController).pageIndex
    if index == 0 || index == NSNotFound {
      return nil
    }
    index -= 1
    print(index)
    
    return self.viewControllerAtIndex(index: index)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! StoryController).pageIndex
    if index == NSNotFound {
      return nil;
    }
    index += 1
    print(index)
    
    if index == videoFiles.count {
      return nil;
    }
    
    return self.viewControllerAtIndex(index: index)
  }
  
  private func viewControllerAtIndex(index:Int) -> StoryController? {
    
    if videoFiles.count == 0 || index >= videoFiles.count {
      return nil
    }
    let vc = StoryController()
    vc.filePath = videoFiles[index]
    vc.pageIndex = index
    return vc
  }
}

extension UIStoryboard {
  
  static func getViewController<T: UIViewController>(storyboardName: String, identifier: String) -> T? {
    return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: identifier) as? T
  }
}

extension PageViewController: UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    
    if let vc = pageViewController.viewControllers?.first as? StoryController {
      print(vc.pageIndex)
    }
  }
}
