//  userProfileController.swift

import UIKit
import Firebase
import Social
import SVProgressHUD

class UserProfileController: UIViewController {
  override func viewDidLoad() {
    self.view.backgroundColor = .mainVanilla()
    let user = Auth.auth().currentUser
    if let user = user {
      let uid = user.uid
      let db = Firestore.firestore()
      let ref = db.collection("users").document(uid)
      ref.getDocument { (document, error) in
        if let document = document, document.exists {
          let dataDictionary = document.data() ?? ["partner": "", "email": "", "lat": "", "uid": "", "name": "", "lon": ""]
          let userData = UserData(dictionary: dataDictionary)
          let name = userData.name
          self.navigationItem.title = "\(name)"
        }else{
          print("Document does not exist")
        }
      }
    }
    UINavigationBar.appearance().barTintColor = .mainVanilla()
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
    UINavigationBar.appearance().tintColor = .mainBlue()
    setupSendButtons()
    setupCertification()
    setupSettingButton()
  }
  
  fileprivate func setupSendButtons() {
    let stackView = UIStackView(arrangedSubviews: [sendLINEButton, sendLinkButton])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 20
    view.addSubview(stackView)
    let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 44
    stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: statusBarHeight + navigationBarHeight + 60, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
  }
  
  fileprivate func setupCertification() {
    let stackView = UIStackView(arrangedSubviews: [codeTextField, codeButton])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 20
    view.addSubview(stackView)
    stackView.anchor(top: sendLinkButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 60, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
  }
  
  fileprivate func setupSettingButton() {
    let image = #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal)
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleSetting) )
  }
  
  @objc func handleSetting() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "利用規約", style: .default, handler: { (_) in
      self.hidesBottomBarWhenPushed = true
      let nextController = TermsController()
      self.navigationController?.pushViewController(nextController, animated: true)
      self.hidesBottomBarWhenPushed = false
    }))
    alertController.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { (_) in
      do {
        try Auth.auth().signOut()
        let loginController = LoginController()
        let navController = UINavigationController(rootViewController: loginController)
        self.present(navController, animated: true, completion: nil)
      } catch let signOutErr {
        print("Failed to sign out:", signOutErr)
      }
    }))
    alertController.addAction(UIAlertAction(title: "パートナーを解消する", style: .destructive, handler: { (_) in
      self.handlePartnerRemove()
    }))
    alertController.addAction(UIAlertAction(title: "退会する", style: .destructive, handler: { (_) in
      self.handleWithdraw()
    }))
    alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
    alertController.popoverPresentationController?.sourceView = self.view
    alertController.popoverPresentationController?.sourceRect = CGRect(x: 100.0,y: 100.0,width: 20.0,height: 20.0)
    present(alertController, animated: true, completion: nil)
  }
  
  func handlePartnerRemove() {
    let alertController = UIAlertController(title: "パートナーを解消する", message: "本当にパートナーを解消しますか？\nパートナーを解消するとパートナーの情報はすべて閲覧できなくなります。", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "パートナーを解消する", style: .destructive, handler: { (_) in
      let user = Auth.auth().currentUser
      guard let uid = user?.uid else {return}
      let db = Firestore.firestore()
      let ref = db.collection("users").document(uid)
      ref.getDocument { (document, error) in
        if let document = document, document.exists {
          let dataDictionary = document.data() ?? ["partner": "", "email": "", "lat": "", "uid": "", "name": "", "lon": ""]
          let userData = UserData(dictionary: dataDictionary)
          let partner = userData.partner
          if partner != "" {
            let paernerRef = db.collection("users").document(partner)
            paernerRef.updateData([
              "partner": FieldValue.delete(),
              ])
            ref.updateData([
              "partner": FieldValue.delete(),
              ])
          } else{
            return
          }
        }
      }
    }))
    alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
    alertController.popoverPresentationController?.sourceView = self.view
    alertController.popoverPresentationController?.sourceRect = CGRect(x: 100.0,y: 100.0,width: 20.0,height: 20.0)
    present(alertController, animated: true, completion: nil)
  }
  
  func handleWithdraw() {
    let alertController = UIAlertController(title: "退会する", message: "本当に退会しますか？\n退会するとユーザー情報は全て削除されます。パートナー情報はそのまま保持されます。", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "退会", style: .destructive, handler: { (_) in
      let user = Auth.auth().currentUser
      guard let uid = user?.uid else {return}
      let db = Firestore.firestore()
      let ref = db.collection("users").document(uid)
      ref.delete()
      let signupController = SignUpController()
      let navController = UINavigationController(rootViewController: signupController)
      self.present(navController, animated: true, completion: nil)
    }))
    alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
    alertController.popoverPresentationController?.sourceView = self.view
    alertController.popoverPresentationController?.sourceRect = CGRect(x: 100.0,y: 100.0,width: 20.0,height: 20.0)
    present(alertController, animated: true, completion: nil)
  }
  
  let sendLINEButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("LINEで恋人に招待コードを送る", for: .normal)
    button.backgroundColor = .LINEGreen()
    button.layer.cornerRadius = 30
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleSendLINE), for: .touchUpInside)
    button.isEnabled = true
    return button
  }()
  
  private func openURL(url: URL?) {
    guard let url = url else { return }
    if UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
  }
  
  @objc func handleSendLINE() {
    let user = Auth.auth().currentUser
    if let user = user {
      let uid = user.uid
      let shareText = "cocoで恋人と常につながろう！"
      let shareURL = "https://co-co.site"
      guard let scheme: String = "line://msg/text/\(shareText) URL:\(shareURL) 認証コード:\(uid)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
      self.openURL(url: URL(string: scheme))
    }
  }
  
  let sendLinkButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("恋人に招待コードを送る", for: .normal)
    button.backgroundColor = .mainEmerald()
    button.layer.cornerRadius = 30
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleSendLink), for: .touchUpInside)
    button.isEnabled = true
    return button
  }()
  
  @objc private func handleSendLink() {
    let user = Auth.auth().currentUser
    if let user = user {
      let uid = user.uid
    let activities: [Any] = [
      "cocoで恋人と常につながろう！",
      URL(string: "https://co-co.site")!,
      "認証コード:\(uid)"
    ]
    let controller = UIActivityViewController(activityItems: activities,
                                              applicationActivities: nil)
    present(controller, animated: true, completion: nil)
    }
  }
  
  let codeTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "招待コード"
    tf.isSecureTextEntry = true
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
//    tf.addBorderBottom(height: 1.0, color: UIColor.lightGray)
//    let border = CALayer()
//    let width = CGFloat(2.0)
//    border.borderColor = UIColor.gray.cgColor
//    border.frame = CGRect(x: 0, y: tf.frame.size.height - width, width:  tf.frame.size.width, height: 1)
//    border.borderWidth = width
//    tf.layer.addSublayer(border)
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
//    let underline: UIView = UIView()
//    tf.frame.size.height = 50
//    underline.frame = CGRect(
//      x: 0,
//      y: tf.frame.height,
//      width: tf.frame.width,
//      height: 2.5)
//    underline.backgroundColor = UIColor(red:0.36, green:0.61, blue:0.93, alpha:1.0)
//    tf.addSubview(underline)
//    tf.bringSubviewToFront(underline)
    return tf
  }()
  
  @objc func handleTextInputChange() {
    let isFormValid = codeTextField.text?.count ?? 0 > 6
    if isFormValid {
      codeButton.isEnabled = true
      codeButton.backgroundColor = .darkPurple()
    } else {
      codeButton.isEnabled = false
      codeButton.backgroundColor = .subPurple()
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  let codeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("届いた招待コードを認証する", for: .normal)
    button.backgroundColor = .subPurple()
    button.layer.cornerRadius = 30
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleCode), for: .touchUpInside)
    button.isEnabled = false
    return button
  }()
  
  @objc func handleCode() {
    let user = Auth.auth().currentUser
//    SVProgressHUD.showProgress(2, status: "認証中")
//    SVProgressHUD.setDefaultMaskType(.black)
    if let user = user {
      let uid = user.uid
      let code = codeTextField.text ?? ""
      let db = Firestore.firestore()
      db.collection("users").document("\(code)").updateData([
        "partner": uid
      ]) { err in
        if let err = err {
          print("Error adding document: \(err)")
        }
        else {
          print("Document added with ID: \(uid)")
        }
      }
      db.collection("users").document("\(uid)").updateData([
        "partner": code
      ]) { err in
        if let err = err {
          print("Error adding document: \(err)")
        }
        else {
          print("Document added with ID: \(uid)")
        }
      }
    }
    SVProgressHUD.showSuccess(withStatus: "認証が完了しました")
    SVProgressHUD.setDefaultMaskType(.black)
    SVProgressHUD.dismiss(withDelay: 1)
    codeTextField.text = ""
    codeButton.isEnabled = false
    codeButton.backgroundColor = .subGray()
  }
  
}
