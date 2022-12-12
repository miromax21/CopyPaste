//
//  PushNotifications.extentions.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//
/*
import UIKit
import Firebase
import UserNotifications
import FirebaseDatabase

extension PushNotificationsBase: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    self.firebaseToken = fcmToken!
    subscribeIds.forEach {
      Messaging.messaging().subscribe(toTopic: $0)
    }
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

@available(iOS 14, *)
extension PushNotificationsBase: UNUserNotificationCenterDelegate {

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let options: UNNotificationPresentationOptions = [.list]
    showMesseges()
    completionHandler(options)
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    clickedOnReceived = true
    let request = response.notification.request
    let newMessage = NotificationModel(
      id: request.identifier,
      content: request.content,
      date: response.notification.date.string(),
      isPending: true
    )
    let model = newMessage.getDataModel()
    let isSystem = model?.notificationType == .system
    insertItems( notifications: [newMessage])
    completionHandler()
    guard !isSystem else { return }
    showMesseges()
  }

  func showMesseges() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      (self?.appCoordinator.initialCoordinator as? MainCoordinator)?.showNotifications()
    }
  }
}
*/
