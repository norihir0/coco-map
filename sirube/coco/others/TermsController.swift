//  TermsController.swift

import UIKit
import WebKit

class TermsController: UIViewController{
  
  private var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView = WKWebView()
    webView.frame = self.view.bounds
    self.view.addSubview(webView)
    let url = URL(string: "https://co-co.site/terms")!
    let request = URLRequest(url: url as URL)
    webView.load(request as URLRequest)
    navigationItem.title = "利用規約"
  }
  
}
