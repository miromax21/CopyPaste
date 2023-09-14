//
//  SectionBackgroundDecorationView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 21.04.2023.
//

import UIKit
class SectionBackgroundDecorationView: UICollectionReusableView {
  var configured: Bool = false
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .red
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    if !configured{
      configure()
    }
  }
  
  
  func configure(){
    let fmt = DateFormatter()
    fmt.dateFormat = "cccc"
    fmt.locale = .current
    let data = (1...7).map {
      let label = UILabel()
      label.text = fmt.shortWeekdaySymbols[$0 - 1]
      label.textAlignment = .center
      return label
    }
    
    let constraint = ""
    data.forEach{
      addSubview($0)
      addConstraintsWithFormat("V:|[v0(40)]|", views: $0)
    }
    let str = (1...data.count).map{"[v\($0)(==v0)]"}.joined(separator: "-")
    addConstraintsWithFormat("H:|-[v0]-\(str)-|", views: [data[0]] + data)
    configured = true
  }
}
