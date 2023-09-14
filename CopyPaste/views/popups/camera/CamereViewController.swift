//
//  CamereViewController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import UIKit
import AVFoundation
import CoreGraphics
final class CamereViewController: UIViewController, CustomPresentable, AVCaptureMetadataOutputObjectsDelegate {
  var transitionManager: UIViewControllerTransitioningDelegate?
  var completion: ((Any?) -> Void)?
  var viewModel: CameraViewModel!
  var qrcode: String? {
    didSet {
      if qrcode != oldValue {
        send(next: qrcode)
      }
    }
  }
  var previewLayer: AVCaptureVideoPreviewLayer!

  var imageview: UIImageView!
  override func loadView() {
    super.loadView()
    setupVideoRecording()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupVideoRecording()
    initView()
    view.backgroundColor = AppColors.black.color
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.toogleVideoRecording(run: true)
    setUpViews()
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
    let barCodeObject = previewLayer?.transformedMetadataObject(for: object)

    if let bounds = barCodeObject?.bounds {
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
        self?.imageview.frame = bounds
      } completion: {  [weak self] _ in
        self?.qrcode = object.stringValue
      }
    } else {
      qrcode = object.stringValue
    }
  }

  func send(next: String?) {
    viewModel.toogleVideoRecording(run: false)
    completion?(next)
    self.dismiss(animated: true)
  }
}
extension CamereViewController {
  private func setupVideoRecording() {
    let metadataOutput = AVCaptureMetadataOutput()
    if viewModel.trySession(with: metadataOutput) {
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.qr, .ean13, .pdf417]
      previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
      previewLayer.frame = view.layer.bounds
      previewLayer.videoGravity = .resizeAspectFill
      view.layer.addSublayer(previewLayer)
      viewModel.toogleVideoRecording(run: true)
    } else {
      failed()
    }
  }

  private func initView() {
    imageview = UIImageView()
    imageview.image = UIImage(named: "qrCodeBorder")
    view.addSubview(imageview)
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
  }

  private func setUpViews() {
    let bounds = view.bounds
    let size: CGFloat = 200
    imageview.frame = CGRect(x: (bounds.width - size) / 2, y: (bounds.height - size) / 2, width: size, height: size)
  }

  private func failed() {
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
