//
//  CameraViewModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import AVFoundation
final class CameraViewModel: BaseViewModel {

  override init(coordinator: BaseCoordinator) {
    super.init(coordinator: coordinator)
  }
  var captureSession = AVCaptureSession()
  let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]

  func trySession(with output: AVCaptureMetadataOutput) -> Bool {

    captureSession = AVCaptureSession()

    guard
      let videoCaptureDevice = AVCaptureDevice.default(for: .video),
      let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
      captureSession.canAddInput(videoInput)
    else { return  false}

    captureSession.addInput(videoInput)
    if captureSession.canAddOutput(output) {
      captureSession.addOutput(output)
    }
    return true
  }

  func toogleVideoRecording(run: Bool = false) {
    DispatchQueue.global(qos: .background).async { [weak captureSession, run] in
      guard let session = captureSession else { return }
      if run == session.isRunning {
        return
      }
      run ? session.startRunning() : session.stopRunning()
    }
  }
}
