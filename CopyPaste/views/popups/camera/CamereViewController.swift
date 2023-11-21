//
//  CamereViewController.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 13.10.2022.
//

import UIKit
import AVFoundation
import CoreGraphics
final class CamereViewController: UIViewController, CustomPresentable, AVCaptureMetadataOutputObjectsDelegate {
  typealias T = CameraViewModel
  var viewModel: T!
  var completion: ((CustomPresentableCopletion) -> Void)?
  var transitionManager: UIViewControllerTransitioningDelegate?

  private var previewLayer: AVCaptureVideoPreviewLayer! {
    didSet {
      previewLayer.frame = view.layer.bounds
      previewLayer.videoGravity = .resizeAspectFill
      view.layer.addSublayer(previewLayer)
    }
  }
  private var imageview: UIImageView!

  private var qrcode: String? {
    didSet {
      if qrcode != oldValue {
        send(next: qrcode)
      }
    }
  }

  override func loadView() {
    super.loadView()
    setupVideoRecording()
    viewModel.toogleVideoRecording(run: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setViews()
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setViewConstraints()
    setViewsCustomisations()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.toogleVideoRecording()
  }

  func metadataOutput(
    _ output: AVCaptureMetadataOutput,
    didOutput metadataObjects: [AVMetadataObject],
    from connection: AVCaptureConnection
  ) {
    guard
      let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
      object.type == AVMetadataObject.ObjectType.qr
    else { return }

    guard let barCodeObject = previewLayer?.transformedMetadataObject(for: object) else {
      qrcode = object.stringValue
      return
    }
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.imageview.frame = barCodeObject.bounds
    } completion: { _ in
      self.qrcode = object.stringValue
    }
  }

  func send(next: String?) {
    viewModel.toogleVideoRecording(run: false)
    completion?(.emit(callBack: next))
    self.dismiss(animated: true)
  }
}

// MARK: - controll state
private extension CamereViewController {
  func setupVideoRecording() {
    let metadataOutput = AVCaptureMetadataOutput()
    guard viewModel.trySession(with: metadataOutput) else {
      failed()
      return
    }
    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    metadataOutput.metadataObjectTypes = [.qr, .ean13, .pdf417]
    previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)

  }
}
// MARK: - render
private extension CamereViewController {

  func setViews() {
    imageview = UIImageView()
    view.addSubview(imageview)
  }

  func setViewConstraints() {
    let bounds = view.bounds
    let size: CGFloat = 200
    imageview.frame = CGRect(x: (bounds.width - size) / 2, y: (bounds.height - size) / 2, width: size, height: size)
  }

  func setViewsCustomisations() {
    view.backgroundColor = AppColors.black.color
    imageview.image = UIImage(named: "qrCodeBorder")
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
  }

  func failed() {
    let alert = UIAlertController(
      title: Loc(Loc.Alert.camera_title),
      message: Loc(Loc.Alert.camera_message),
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    viewModel.captureSession.stopRunning()
    present(alert, animated: true)
  }
}
