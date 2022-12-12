//
//  ApplicationBackgroundTask.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//
import BackgroundTasks
import UIKit
enum ConstantsEnum: String {
  case taskID  = "myTaskId.backgroundSync"
}
@available(iOS 13.0, *)
class ApplicationBackgroundTask {

  let interval: Double = 15.0
  var timer: Timer? = Timer()
  var date: Date = Date()

  func registredBackgroundTask() {
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: ConstantsEnum.taskID.rawValue,
        using: nil
      ) { [unowned self] task in
          handleAppRefreshTask(task: task)
      }
      timer = Timer.scheduledTimer(timeInterval: interval * 60,
                                   target: self,
                                   selector: #selector(timerAction),
                                   userInfo: nil,
                                   repeats: true
      )
  }

  func scheduleAppRefresh() {
    cancelAllPandingBGTask()
    let request = BGProcessingTaskRequest(identifier: ConstantsEnum.taskID.rawValue)
    request.requiresNetworkConnectivity = true
    request.requiresExternalPower = false
    request.earliestBeginDate = Date(timeIntervalSinceNow: interval * 60)
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
//      Utils.shared.log(
//        dictionaryData: ["xxx": "submit(request) error: \(error)"]
//      )
    }
  }

  func handleAppRefreshTask(task: BGTask) {
//    Utils.shared.log(
//      dictionaryData: ["xxx": "handleAppRefreshTask"]
//    )
    date = Date()
    timer?.invalidate()
    scheduleAppRefresh()
    // run smth...
    task.setTaskCompleted(success: true)
  }

  func cancelAllPandingBGTask() {
    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: ConstantsEnum.taskID.rawValue)
  }

  @objc func timerAction() {
    if Double(Date().timeIntervalSince1970 - date.timeIntervalSince1970) / 60 <= interval { return }

    scheduleAppRefresh()
    // run smth...
  }
}
