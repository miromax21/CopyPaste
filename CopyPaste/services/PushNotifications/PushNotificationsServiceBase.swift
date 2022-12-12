//
//  PushNotificationsServiceBase.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//
//
// import Foundation
// import Firebase
// import UserNotifications
// import FirebaseDatabase
// private let INSERT_COUNT = 2
// class PushNotificationsBase: UIResponder {
//
//  enum PushTypeEnum {
//    case massage, update
//  }
//
//  var isEnabled: Bool {
//    return UIApplication.shared.isRegisteredForRemoteNotifications
//  }
//
//  var hasPermissions: Dynamic<Bool> = Dynamic(false)
//  var notificationCenter: UNUserNotificationCenter?
//  var clickedOnReceived = false
//  var items: [NotificationModel] = []
//
//  var newItems: Dynamic<[NotificationModel]> = Dynamic([])
//
//  var subscribeIds: [String] = [
//    "allDevices",
//  ]
//  var firebaseToken: String = ""
//  var application: UIApplication!
//  var appCoordinator: AppCoordinator!
//  var insertCount = INSERT_COUNT
//
//  override init() {
//    super.init()
//    if application != nil {
//      checkBaseApp()
//    }
//    hasPermissions.value = isEnabled
//    items = UserDataWrapper.shared.notifications
//    if Utils.shared.buildType != .prod {
//      subscribeIds.append(Utils.shared.buildType.prefix)
//    }
//  }
//
//  func configure(withNotification: Bool? = false) {
//    checkBaseApp()
//    FirebaseConfiguration.shared.setLoggerLevel(.min)
//    let settings: UNAuthorizationOptions = [.alert, .badge, .sound]
//    notificationCenter = UNUserNotificationCenter.current()
//    notificationCenter?.delegate = self
//    Messaging.messaging().delegate = self
//    Messaging.messaging().isAutoInitEnabled = true
//    notificationCenter?.requestAuthorization(options: settings) { [unowned self] success, _  in
//      hasPermissions.value = success
//      registerForRemoteNotifications()
//      guard success else {
//        if #available(iOS 14, *), withNotification ?? false {
//          showNotificationPermissions()
//        }
//        return
//      }
//    }
//    fetchData()
//  }
//
//  func fetchData() {
//    let center = UNUserNotificationCenter.current()
//    center.getPendingNotificationRequests(completionHandler: { [unowned self] requests in
//      insertItems(notifications:
//        requests.map { NotificationModel(
//          id: $0.identifier, content: $0.content, date: Date().string(), isPending: true
//        )},
//        atFirst: true
//      )
//    })
//    center.getDeliveredNotifications { [unowned self] notifications in
//      insertItems(notifications:
//        notifications.map { NotificationModel(
//          id: $0.request.identifier, content: $0.request.content, date: $0.date.string()
//        )}
//      )
//    }
//  }
//
//  func insertItems(notifications: [NotificationModel], atFirst: Bool = true) {
//    insertCount -= 1
//    if notifications.count == 0 {
//      if insertCount == 0 {
//        updateView(pushType: .update)
//        insertCount = INSERT_COUNT
//      }
//      return
//    }
//    insertCount = INSERT_COUNT
//    var newNots = notifications.filter { !items.map {$0.id}.contains($0.id)}
//    if newNots.contains(where: {$0.getDataModel()?.notificationType == .system && $0.isNew}) {
//      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) { [weak self] in
//        self?.appCoordinator.navigationController?.showAlert(
//          alert: .info(
//            message: NSLocalizedString("activity_restored", comment: ""),
//            header: "\(NSLocalizedString("hello", comment: ""))!"
//          ),
//          options: nil
//        )
//      }
//
//      newNots = newNots.filter {$0.getDataModel()?.notificationType == .system}
//      if newNots.count  == 0 {
//        return
//      }
//    }
//    checkNotifications(notifications: newNots)
//
//    let nextItems: [NotificationModel] = newNots.map { not in
//      var currebtNot = not
//      currebtNot.new = 1
//      return currebtNot
//    }
//    items.insert(contentsOf: nextItems, at: 0)
//    newItems.value = nextItems
//    updateView(pushType: .update)
//  }
//
//  func showNotificationPermissions() {
//    if !DeviceUtilsService.shared.uiIsVisible {
//      return
//    }
//    let url: URL = URL(string: "\(UIApplication.openSettingsURLString)")!
//    DispatchQueue.main.async { [weak self] in
//      let alert = UIAlertController(
//        title: NSLocalizedString("notifications_off_title", comment: ""),
//        message: NSLocalizedString("notifications_off_message", comment: ""),
//        preferredStyle: .actionSheet
//      )
//      [
//        UIAlertAction(title: NSLocalizedString("open_settings", comment: ""), style: .default) { [weak self] (_) in
//          UIApplication.shared.open(url) { _ in
//            NotificationCenter.default.addObserver(
//              self as Any,
//              selector: #selector(self?.applicationWillEnterForeground(notification:)),
//              name: UIApplication.willEnterForegroundNotification,
//              object: nil)
//            alert.dismiss(animated: true)
//          }
//        }
//      ].forEach {
//        alert.addAction($0)
//      }
//      self?.appCoordinator.navigationController?.showAlert(alertVC: alert)
//    }
//  }
//  // swiftlint:disable notification_center_detachment
//  @objc private func applicationWillEnterForeground(notification: NSNotification) {
//    hasPermissions.value = isEnabled
//    NotificationCenter.default.removeObserver(self)
//  }
//
//  private func checkBaseApp() {
//    if FirebaseApp.app() == nil {
//      FirebaseApp.configure()
//    }
//  }
//
//  private func registerForRemoteNotifications() {
//    DispatchQueue.main.async { [unowned self] in
//      application.registerForRemoteNotifications()
//    }
//  }
//
//  private func checkNotificationsAuthorizationStatus() {
//    var success = false
//    let userNotificationCenter = UNUserNotificationCenter.current()
//    userNotificationCenter.getNotificationSettings { (notificationSettings) in
//      switch notificationSettings.authorizationStatus {
//      case .authorized: success = true
//      default: break
//      }
//    }
//    DeviceUtilsService.shared.notificationsIsAvalable.value = success
//  }
//
//  private func updateView(pushType: PushTypeEnum = .massage) {
//    DispatchQueue.main.async { [weak self] in
//      if pushType == .update { self?.appCoordinator.navigationController?.updateUi(next: .AppVersion) }
//    }
//  }
//
//  private func checkNotifications(notifications: [NotificationModel]) {
//    let newSystemNot = notifications.filter {$0.getDataModel()?.notificationType.isSystem ?? false}
//    if newSystemNot.count > 0 {
//      newSystemNot.forEach {
//        if $0.getDataModel()?.notificationType == .update {
//          let serverVersion: String! = $0.getDataModel()?.getValue(for: .version) ?? ""
//          if Utils.shared.checkVersion(serverVersion: serverVersion) == .lower {
//            return
//          }
//          UserDataWrapper.shared.serverVersion = serverVersion
//          let needUpdate = Utils.shared.checkVersion(serverVersion: serverVersion) != .current
//          if needUpdate {
//            updateView(pushType: .update)
//          }
//        }
//      }
//    }
//  }
// }
