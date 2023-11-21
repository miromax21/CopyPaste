import UIKit

typealias AnyCustomPresentable = (any CustomPresentable)
protocol CustomPresentable: UIViewController {
  associatedtype T: BaseVM
  var transitionManager: UIViewControllerTransitioningDelegate? { get set }
  var completion: ((_ callBack: CustomPresentableCopletion) -> Void)? { get set }
  var dismissalHandlingScrollView: UIScrollView? { get }
  var viewModel: T! { get set }
}


enum CustomPresentableCopletion {
  case cancel, emit(callBack: Any?)
}

extension CustomPresentable {
  var dismissalHandlingScrollView: UIScrollView? { nil }
}
