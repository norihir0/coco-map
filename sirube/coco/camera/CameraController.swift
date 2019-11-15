//  CameraController.swift

import Foundation
import UIKit
import AVFoundation
import Photos

class CameraController: UIViewController,AVCaptureFileOutputRecordingDelegate{
  
  let captureSession = AVCaptureSession()
  let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
  let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
  let fileOutput = AVCaptureMovieFileOutput()
  var isRecording = false
  
  let dismissButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "exit"), for: .normal)
    button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
    button.tintColor = UIColor.white
    return button
  }()
  
  @objc func handleDismiss() {
    tabBarController?.selectedIndex = 0;
    print("押せてる")
    tabBarController?.tabBar.isHidden = false
  }
  
  let captureMovieButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "capture_photo"),for:. normal)
    button.addTarget(self, action: #selector(onClickRecordButton),for:.touchUpInside)
    button.tintColor = UIColor.white
    return button
  }()
  
  override func viewDidLoad() {
    setVideo()
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
  }
  
  private func setVideo(){
    do {
      if self.videoDevice == nil || self.audioDevice == nil {
        throw NSError(domain: "device error", code: -1, userInfo: nil)
      }
      
      let videoInput = try AVCaptureDeviceInput(device: self.videoDevice!)
      captureSession.addInput(videoInput)
      
      // audio inputを capture sessionに追加
      let audioInput = try AVCaptureDeviceInput(device: self.audioDevice!)
      captureSession.addInput(audioInput)
      
      // max 30sec
      self.fileOutput.maxRecordedDuration = CMTimeMake(value: 30, timescale: 1)
      captureSession.addOutput(fileOutput)
      
      // プレビュー
      let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoLayer.frame = self.view.bounds
      videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
      self.view.layer.addSublayer(videoLayer)
      
      captureSession.startRunning()
      
      setButton()
    }catch{
      print(error);
    }
  }
  
  private func setButton() {
    view.addSubview(captureMovieButton)
    captureMovieButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 100, height: 100)
    //横の真ん中に
    captureMovieButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    view.addSubview(dismissButton)
    dismissButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 90, height: 90)
    
  }
  
  @objc func onClickRecordButton(sender: UIButton) {
    if !isRecording {
      // 録画開始
      let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
      let documentsDirectory = paths[0] as String
      let filePath : String? = "\(documentsDirectory)/temp.mp4"
      let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
      fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
      
      isRecording = true
      
    } else {
      // 録画終了
      fileOutput.stopRecording()
      
      isRecording = false
    }
  }
  
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    // ライブラリへ保存
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
    }) { completed, error in
      if completed {
        print("Video is saved!")
      }
    }
  }
  
}
