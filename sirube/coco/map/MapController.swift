//  MapController.swift

import UIKit
import CoreLocation
import Firebase
import Mapbox

class MapController: UIViewController,CLLocationManagerDelegate,MGLMapViewDelegate{
  
  var mapManager: CLLocationManager = CLLocationManager()
  var latitude: CLLocationDegrees! = CLLocationDegrees()
  var longitude: CLLocationDegrees! = CLLocationDegrees()
  var pinView: UIImageView?
  var source: MGLShapeSource!
  var mapView = MGLMapView()
  var partnerPin = MGLPointAnnotation()
  var timer = Timer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.isNavigationBarHidden = true
    mapManager.delegate = self
    mapManager.desiredAccuracy = kCLLocationAccuracyBest
    mapManager.distanceFilter = 1000
    view.backgroundColor = .white
    mapSetting()
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updatePin), userInfo: nil, repeats: true)
  }
  
  func mapSetting() {
    let url = URL(string: "mapbox://styles/mapbox/streets-v11")
    mapView = MGLMapView(frame: view.bounds, styleURL: url)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.attributionButton.isHidden = true
    mapView.userTrackingMode = .follow
    mapView.showsUserHeadingIndicator = true
    mapView.delegate = self
    view.addSubview(mapView)
  }
  
  @objc func updatePin() {
    let user = Auth.auth().currentUser
    if let user = user {
      let uid = user.uid
      let db = Firestore.firestore()
      let ref = db.collection("users").document(uid)
      ref.getDocument { (document, error) in
        if let document = document, document.exists {
          let dataDictionary = document.data() ?? ["partner": "", "email": "", "lat": "", "uid": "", "name": "", "lon": ""]
          print("dataDictionary:\(dataDictionary)")
          let userData = UserData(dictionary: dataDictionary)
          print("userData:\(userData)")
          let partner = userData.partner
          if partner != "" {
            print("partner:\(partner)")
            let partnerRef = db.collection("users").document(partner)
            partnerRef.getDocument { (partnerDocument, error) in
              if let partnerDocument = partnerDocument, partnerDocument.exists {
                let partnerDictionary = partnerDocument.data() ?? ["partner": "", "email": "", "lat": "", "uid": "", "name": "", "lon": ""]
                print("partnerDictionary:\(partnerDictionary)")
                let partnerData = UserData(dictionary: partnerDictionary)
                print("partnerData:\(partnerData)")
                let lat = partnerData.latitude
                let lon = partnerData.longitude
                print("partnerlat:\(lat)")
                print("partnerlon:\(lon)")
                let name = partnerData.name
                print(name)
                let comment = "ここにいるよ！"
                self.partnerPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                self.partnerPin.title = name
                self.partnerPin.subtitle = comment
                self.mapView.addAnnotation(self.partnerPin)
              }else{
                print("Document does not exist")
                
              }
            }
          }
          else{
            print("パートナーがいません")
            return
          }
        }else{
          print("Document does not exist")
        }
      }
    }
  }
  
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    return nil
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
      mapManager.requestWhenInUseAuthorization()
      break
    case .denied:
      alertMessage(message: "位置情報の利用が許可されていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「アプリ名」")
      break
    case .restricted:
      alertMessage(message: "位置情報サービスの利用が制限されているため利用できません。「設定」⇒「一般」⇒「機能制限」")
      break
    case .authorizedAlways:
      print("常時位置情報の取得が許可されています。")
      mapManager.startUpdatingLocation()
      break
    case .authorizedWhenInUse:
      print("起動時のみ位置情報の取得が許可されています。")
      mapManager.startUpdatingLocation()
      break
    @unknown default:
      fatalError()
    }
  }
  
  func alertMessage(message:String) {
    let alertController = UIAlertController(title: "注意", message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title:"OK", style: .default, handler:nil)
    alertController.addAction(defaultAction)
    alertController.popoverPresentationController?.sourceView = self.view
    alertController.popoverPresentationController?.sourceRect = CGRect(x: 100.0,y: 100.0,width: 20.0,height: 20.0)
    present(alertController, animated:true, completion:nil)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let userLocation:CLLocation = locations[0] as CLLocation
    latitude = userLocation.coordinate.latitude
    longitude = userLocation.coordinate.longitude
    print("\(String(describing: latitude ?? 35.68040000000000))","\(String(describing: longitude ?? 139.76900000000000))")
    let user = Auth.auth().currentUser
    if let user = user {
      let uid = user.uid
      let db = Firestore.firestore()
      db.collection("users").document("\(uid)").updateData([
        "lat": latitude ?? 35.68040000000000,
        "lon": longitude ?? 139.76900000000000
      ]) { err in
        if let err = err {
          print("Error updating document: \(err)")
        } else {
          print("Document successfully updated")
        }
      }
    }
  }

}
