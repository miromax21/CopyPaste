//
//  PushNotificationsService.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//
/*
import Foundation
import Foundation
import Firebase
import UserNotifications
import FirebaseDatabase

final class PushNotifications: PushNotificationsBase, PushNotificationsProtocol {

  static var shared: PushNotificationsProtocol = PushNotifications()

  func getItems() -> [NotificationModel] {
    return items
  }

  func clear() {
    items = []
    UserDataWrapper.shared.notifications = []
  }

  func setAsRead(id: String) {
    if let index = items.firstIndex(where: {$0.id == id}) {
      items[index].new = 0
    }
  }

  func readAll(ids: [String]? = nil ) {
    let readAll = ids == nil
    var updateItems: [NotificationModel] = []
    items.forEach {
      var item = $0
      if readAll || ids!.contains(item.id) {
        item.new = 0
      }
      updateItems.append(item)
    }

    items = updateItems
    save()
  }

  func save() {
    UserDataWrapper.shared.notifications = items
  }

  func showAlertNotification(
    message: String? = nil,
    title: String? = nil,
    systemType: SystemNotificationsEnum? = nil
  ) {
    let identifier = "terminate\(Date().millisecondsSince1970)\(Int.random(in: 100..<10000))"
    let content   = UNMutableNotificationContent()
    content.title = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Appmeter"
    content.body  = message ?? NSLocalizedString("notifications_app_will_terminate", comment: "")
    content.sound = UNNotificationSound.default
    var optDictionaryData: [String: String] =
      [NotificationsDataModel.CodingKeys.type.rawValue: NotificationtypeEnum.system.rawValue]
    if let sType = systemType {
      optDictionaryData[NotificationsDataModel.CodingKeys.systemType.rawValue] = sType.rawValue
    }
    let opt =  Utils.shared.dicrionaryToJsonString(dictionaryData: optDictionaryData)
    content.userInfo[NotificationModel.userInfoDataKey] = opt
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
     _ = self.notificationCenter?.add(request)
  }
}
*/
