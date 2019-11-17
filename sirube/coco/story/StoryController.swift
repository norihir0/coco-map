//  StoryController.swift

import Foundation
import AVFoundation
import UIKit
import Firebase

class StoryController: UIViewController{
  
  var filePath = "https://drive.google.com/uc?id=1RnUv4efmk6NRAaFbxs51pS1bccq4SfoI"
  var pageIndex = 0
  var player: AVPlayer?
  var ActivityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    self.view.backgroundColor = UIColor.black
    setupActiveIndicator()
    setupMovies()
  }

  private func setupMovies() {

    let url = URL(string: filePath)
    
    player = AVPlayer(url: url!)

    let playerLayer = AVPlayerLayer(player: player)
    
    playerLayer.frame = self.view.bounds
    self.view.layer.addSublayer(playerLayer)
    
    player!.play()
    
    //おそらく他の動画が終了したときにもこれが作動しちゃってる
    NotificationCenter.default.addObserver(
      self, selector: #selector(self.endOfMovie),
      name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    
    
    player!.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main, using: {time in
      if self.player!.timeControlStatus == .waitingToPlayAtSpecifiedRate {
        self.ActivityIndicator.startAnimating()
      } else if self.player!.timeControlStatus == .playing {
        self.ActivityIndicator.stopAnimating()
      }
    })
  }
  
  fileprivate func setupActiveIndicator() {
    ActivityIndicator = UIActivityIndicatorView()
    ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    ActivityIndicator.center = self.view.center
    
    ActivityIndicator.style = UIActivityIndicatorView.Style.white
    
    ActivityIndicator.hidesWhenStopped = true
    
    self.view.addSubview(ActivityIndicator)
    
    self.ActivityIndicator.startAnimating()
  }
  
  @objc func endOfMovie() {
    player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    player?.play()
  }
}




