//
//  AlertService.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
final class AlertService {
  var addHeader: Bool           = false
  var alertTimer: Timer?
  var toats: [ToatProtocol] = []
  var currentToat: ToatProtocol?
  enum AlertType {
    case none,
         info(message: String, header: String?),
         warning(message: String, header: String?),
         error(message: String, header: String?),
         custom(message: String, header: String?, color: UIColor)

    var show: Bool {
      switch self {
      case .none: return false
      default: return true
      }
    }
    // swiftlint:disable large_tuple
    var value: (message: String, bgColor: UIColor, header: String?) {
      var val: (message: String, bgColor: UIColor, header: String?)  = ("", #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), nil)
      switch self {
      case .info(let message, let header):    val = (message, AppColors.alertInfo.color, header)
      case .warning(let message, let header): val = (message, AppColors.alertWarning.color, header)
      case .error(let message, let header):   val = (message, AppColors.alertError.color, header)
      case .custom(let message, let header, let color):
        val = (message, color, header)
      default: break
      }
      return val
    }
    var headerValues: (iconColors: (tint: AppColors, background: AppColors?), textColor: AppColors )? {
      return ((tint: .white, background: nil), .white)
    }
  }
  var window: UIWindow? {
    if #available(iOS 13, *) {
      return UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    } else {
      return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
  }

  lazy var statusView: StatusView = {
    let statusView = StatusView()
    statusView.setSattus(frame: CGRect(x: 10, y: 10, width: 20, height: 20), status: .notifications)
    return statusView
  }()

  func next(alert: AlertType, options: ToatOptions? = nil, view: ToatProtocol? = nil) {
    let nextToat = view ?? Toat()
    DispatchQueue.main.async { [weak self] in
      nextToat.initView(
        alert: alert,
        window: self?.window,
        font: FontsEnum.base.getFont(size: 20),
        viewOptions: options
      )
      self?.toats.append(nextToat)
      self?.showMessage()
    }
  }

  func showMessage() {
    if currentToat != nil {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) { [unowned self] in
        showMessage()
      }
      return
    }
    guard let toat = toats.popLast() else {
      return
    }
    currentToat = toat
    currentToat?.complete = removeAlert
    currentToat?.toogle(showAlert: true)
  }

  func removeAlert() {
    currentToat = nil
    showMessage()
  }
}
