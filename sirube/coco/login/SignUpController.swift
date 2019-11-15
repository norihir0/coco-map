//  SignUpController.swift

import UIKit
import Firebase
import SVProgressHUD

class SignUpController: UIViewController{
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UINavigationBar.appearance().barTintColor = .mainVanilla()
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
    UINavigationBar.appearance().tintColor = .mainBlue()
    navigationItem.title = "新規登録"
    view.addSubview(logoContainerView)
    let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 44
    logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: statusBarHeight + navigationBarHeight + 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
    setupInputFields()
    view.backgroundColor = .mainVanilla()
  }
  
  let logoContainerView: UIView = {
    let view = UIView()
    let logo = UIImageView(image: #imageLiteral(resourceName: "logotypo"))
    logo.contentMode = .scaleAspectFill
    view.addSubview(logo)
    logo.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
    logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    logo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    return view
  }()
  
  func setupInputFields() {
    let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, termsButton, signUpButton])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 10
    view.addSubview(stackView)
    stackView.anchor(top: logoContainerView.bottomAnchor, left:view.leftAnchor , bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 290)
  }
  
  let emailTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "メールアドレス"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  let usernameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "ニックネーム"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  let passwordTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "パスワード(6文字以上）"
    tf.isSecureTextEntry = true
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  let termsButton: UIButton = {
    let button = UIButton(type: .system)
    let attributedTitle = NSMutableAttributedString(string: "登録前に必ず",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    attributedTitle.append(NSAttributedString(string: "利用規約", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14) ,NSAttributedString.Key.foregroundColor: UIColor.lightGray
      ]))
    attributedTitle.append(NSAttributedString(string: "をお読みください", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12) ,NSAttributedString.Key.foregroundColor: UIColor.lightGray
      ]))
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.addTarget(self, action: #selector(handleShowTerms), for: .touchUpInside)
    return button
  }()
  
  @objc func handleShowTerms() {
    let nextController = TermsController()
    navigationController?.pushViewController(nextController, animated: true)
  }
  
  let signUpButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("利用規約に同意して登録する", for: .normal)
    button.backgroundColor = .lightEmerald()
    button.layer.cornerRadius = 25
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    button.isEnabled = false
    return button
  }()
  
  @objc func handleTextInputChange() {
    let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 >= 6
    if isFormValid {
      signUpButton.isEnabled = true
      signUpButton.backgroundColor = .mainEmerald()
    } else {
      signUpButton.isEnabled = false
      signUpButton.backgroundColor = .lightEmerald()
    }
  }
  
  @objc func handleSignUp() {
    guard let email = emailTextField.text, email.count > 0 else { return }
    guard let username = usernameTextField.text, username.count > 0 else { return }
    guard let password = passwordTextField.text, password.count >= 6 else { return }
    SVProgressHUD.show(withStatus: "新規登録中")
    SVProgressHUD.setDefaultMaskType(.black)
    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error: Error?) in
      
      if let err = error {
        print("Failed to create user:", err)
        self.alertMessage(message:"エラーが発生しました")
        SVProgressHUD.dismiss()
        return
      }
      print("Successfully created user:", user?.user.uid ?? "")
      guard let uid = user?.user.uid else { return }
      let db = Firestore.firestore()
      db.collection("users").document("\(uid)").setData([
        "email": email,
        "name": username,
        "uid": uid,
        "lat": 35.6804,
        "lon": 139.7690,
        "partner": ""
      ]) { err in
        if let err = err {
          print("Error adding document: \(err)")
        }
        else {
          print("Document added with ID: \(uid)")
        }
      }
      guard let mainTabBarController =
        UIApplication.shared.keyWindow?.rootViewController as?
        MainTabBarController else { return }
      mainTabBarController.setupViewController()
      SVProgressHUD.dismiss()
      self.dismiss(animated: true, completion: nil)
    })
  }
  
  func alertMessage(message:String) {
    let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title:"OK", style: .default, handler:nil)
    alertController.addAction(defaultAction)
    alertController.popoverPresentationController?.sourceView = self.view
    alertController.popoverPresentationController?.sourceRect = CGRect(x: 100.0,y: 100.0,width: 20.0,height: 20.0)
    present(alertController, animated:true, completion:nil)
  }
  
}
