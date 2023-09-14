//
//  Timer.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 31.05.2023.
//

import UIKit
class TimerView: UIView {

  enum TimerType {
    case withIcon(IconEnum), time(NSCalendar.Unit)
  }
  var complete: (() -> Void)?
  var timerView: UIView?
  private var type: TimerType!
  private var timeLabel: UILabel?
  
  private let timeLeftShapeLayer = CAShapeLayer()
  private let bgShapeLayer = CAShapeLayer()
  
  private var timeLeft: TimeInterval = 5
  private var endTime: Date?
  private var timer: Timer?

  private let strokeIt = CABasicAnimation(keyPath: "strokeEnd")
  private var allowedUnits: NSCalendar.Unit = [.second]
  private var tick: TimeInterval = 1
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  init(type: TimerType? = .time([.second])){
    self.type = type
    super.init(frame: .zero)
  }
  var rendered:Bool = false
  func render(){
    self.invalidateIntrinsicContentSize()
    renderContent()
    let path = UIBezierPath(
      arcCenter: CGPoint(x: self.frame.width / 2 ,y: self.frame.height / 2),
      radius: 15, startAngle: angleRadius(-90),
      endAngle: angleRadius(270),
      clockwise: true
    )
    if rendered {
      drawTimeLeftShape(path: path)
      return
    }
    drawBgShape(path: path)
    drawTimeLeftShape(path: path)
    rendered = true
  }

  
  func start(timeInterval tick: TimeInterval){
    strokeIt.fromValue = 0
    strokeIt.toValue = 1
    strokeIt.duration = TimeInterval(timeLeft)
    strokeIt.fillMode = CAMediaTimingFillMode.forwards
    strokeIt.isRemovedOnCompletion = true
    timeLeftShapeLayer.add(strokeIt, forKey: "strokeIt")
    endTime = Date().addingTimeInterval(timeLeft + 1)
    self.tick = tick
    timer?.invalidate()
    timer = Timer.scheduledTimer(timeInterval: tick, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
  }
  
  func stop(){
    timer?.invalidate()
    timer = nil
    strokeIt.toValue = 1
    timeLeftShapeLayer.removeFromSuperlayer()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  var colors: (bg: UIColor, timer: UIColor)? = (UIColor.white, UIColor.red){
    didSet {
      bgShapeLayer.strokeColor = colors?.bg.cgColor
      timeLeftShapeLayer.strokeColor = colors?.timer.cgColor
    }
  }
  
  func drawBgShape(path: UIBezierPath) {
      bgShapeLayer.path = path.cgPath
      bgShapeLayer.strokeColor = colors?.bg.cgColor
      bgShapeLayer.fillColor = UIColor.clear.cgColor
      bgShapeLayer.lineWidth = 5
      layer.addSublayer(bgShapeLayer)
  }
  func drawTimeLeftShape(path: UIBezierPath) {
      timeLeftShapeLayer.path = path.cgPath
      timeLeftShapeLayer.strokeColor = colors?.timer.cgColor
      timeLeftShapeLayer.fillColor = UIColor.clear.cgColor
      timeLeftShapeLayer.lineWidth = 5
      layer.addSublayer(timeLeftShapeLayer)
  }
  func renderContent() {
    if timerView != nil {
      return
    }
    switch type {
      case .withIcon(let icon):
        let padding: CGFloat = 7
        let (height, width) = (self.frame.height - 2*padding, self.frame.width - 2*padding)
        let image = UIImageView(frame: CGRect(x: padding, y: padding, width: width, height: height))
        image.image = icon.icon
        timerView = image
      case .time(let allowedUnits):
        self.allowedUnits = allowedUnits
        timeLabel = UILabel(frame: frame)
        timeLabel!.textAlignment = .center
        timeLabel!.text = getTime()
        timerView = timeLabel
      default: break;
    }
    if let timerView = timerView{
      addSubview(timerView)
    }
  }
  
  @objc func updateTime() {
    if timeLeft <= tick {
      clear()
      complete?()
    }
    timeLeft = endTime?.timeIntervalSinceNow ?? 0
    timeLabel?.text = getTime()
  }
  func clear(){
    timer?.invalidate()
    timer = nil
    timeLabel?.text = getTime()
  }
  func angleRadius(_ degree: Int) -> CGFloat{
    return CGFloat(degree) * .pi / 180
  }
  
  func getTime() -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.second, .minute]
    return formatter.string(from: timeLeft)!
  }
  
  deinit {
    timer?.invalidate()
    timer = nil
  }
}
