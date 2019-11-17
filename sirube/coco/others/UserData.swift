//  UserData.swift

import Foundation
import CoreLocation

struct UserData {
  
  var email: String
  var uid: String
  var name: String
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var partner: String
  
  init(dictionary: [String:Any]) {
    
    self.latitude = dictionary["lat"] as? CLLocationDegrees ?? 35.6804
    
    self.longitude = dictionary["lon"] as? CLLocationDegrees ?? 139.7690
    
    self.email = dictionary["email"] as? String ?? ""
    
    self.uid = dictionary["uid"] as? String ?? ""
    
    self.name = dictionary["name"] as? String ?? ""
    
    self.partner = dictionary["partner"] as? String ?? ""
  }
  
}
