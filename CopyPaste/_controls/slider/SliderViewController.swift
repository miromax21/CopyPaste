//
//  SliderViewController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import UIKit

final class SliderViewController: UIViewController, PresentableViewController {

  var presentSize: PresentSize?
  var complete: ((Any?) -> Void)?

  private var curentIndex: Int = 0 {
    willSet {
      let isLast = newValue == slides.count - 1
    //  button.configure(view: view, type: isLast ? .button : .icon)
      button.contentHorizontalAlignment = .center
      pageControl.currentPage = newValue
      pageControl.alpha = isLast ? 0 : 1
    }
  }
  private var button = CustomButton()
  private var slides: [SlideView] = []
  private var scale = 1

  @IBOutlet weak var scrollView: UIScrollView! {
    didSet {
      scrollView.delegate = self
    }
  }

  @IBOutlet weak var pageControl: UIPageControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    slides = createSlides() ?? []
  }

  override func viewDidAppear(_ animated: Bool) {
    pageControl.numberOfPages = slides.count
    pageControl.currentPage = 0
    setupSlideScrollView(slides: slides)

    view.bringSubviewToFront(pageControl)
    // button.configure(iconparent: self.view, title: NSLocalizedString("close", comment: ""))

    button.onClick = { [weak self] in
      guard let self = self else {return}
      self.scrollView.delegate = nil
      self.dismiss(animated: true)
      if let complete = self.complete {
        complete(nil)
      }
    }
    view.addSubview(button)
  }

// MARK: - Private -

  private func createSlides() -> [SlideView]? {
    let aboutData = SliderViewModel()
    let data = aboutData.getSlides(owner: self)
    scale = data.count
    return data
  }

  private func setupSlideScrollView(slides: [SlideView]) {
    scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
    scrollView.isPagingEnabled = true

    for index in 0 ..< slides.count {
      let frame = view.frame
      slides[index].frame = CGRect(x: frame.width * CGFloat(index), y: 0, width: frame.width, height: frame.height)
      scrollView.addSubview(slides[index])
    }
  }
}

extension SliderViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = Int(round(scrollView.contentOffset.x/view.frame.width))
    curentIndex = pageIndex
    if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
      scrollView.contentOffset.y = 0
    }
  }
}
