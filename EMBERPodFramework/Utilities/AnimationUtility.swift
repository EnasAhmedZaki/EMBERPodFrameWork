//
//  setViewController.swift
//  TheBooth
//
//  Created by Pramod More on 13/12/17.
//  Copyright © 2017 biz4solutions. All rights reserved.
//

import UIKit

class AnimationUtility: UIViewController, CAAnimationDelegate {

    static let kSlideAnimationDuration: CFTimeInterval = 0.4

    static func viewSlideInFromRight(toLeft views: UIView, duration: CFTimeInterval = 0.4) {
        var transition: CATransition?
        transition = CATransition.init()
        transition?.duration = duration
        transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition?.type = CATransitionType.push
        transition?.subtype = CATransitionSubtype.fromRight
        views.layer.add(transition ?? CATransition(), forKey: nil)
    }

    static func viewSlideInFromLeft(toRight views: UIView, duration: CFTimeInterval = 0.4) {
        var transition: CATransition?
        transition = CATransition.init()
        transition?.duration = duration
        transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition?.type = CATransitionType.push
        transition?.subtype = CATransitionSubtype.fromLeft
        views.layer.add(transition ?? CATransition(), forKey: nil)
    }

    static func viewSlideInFromTop(toBottom views: UIView, duration: CFTimeInterval = 0.4) {
        var transition: CATransition?
        transition = CATransition.init()
        transition?.duration = duration
        transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition?.type = CATransitionType.push
        transition?.subtype = CATransitionSubtype.fromBottom
        views.layer.add(transition ?? CATransition(), forKey: nil)
    }

    static func viewSlideInFromBottom(toTop views: UIView, duration: CFTimeInterval = 0.4) {
        var transition: CATransition?
        transition = CATransition.init()
        transition?.duration = duration
        transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition?.type = CATransitionType.push
        transition?.subtype = CATransitionSubtype.fromTop
        views.layer.add(transition ?? CATransition(), forKey: nil)
    }

    static func animateTable(tableView: UITableView) {
        tableView.reloadData()

        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height

        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }

        var index = 0

        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .transitionFlipFromBottom, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)

            index += 1
        }
    }

    static func animateButton(sender: UIButton, image: String) {
        UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
            sender.setImage(UIImage(named: image), for: .normal)
        }, completion: nil)
    }

    static func animatecustomInputView(view: UIView) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                view.layer.opacity = 1
                view.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

    static func animateTabChange(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let tabViewControllers = tabBarController.viewControllers ?? [UIViewController()]
        guard let toIndex = tabViewControllers.firstIndex(of: viewController) else {
            return false
        }

        self.animateToTab(tabBarController: tabBarController, toIndex: toIndex)

        // Other method 2

        /*
         if selectedViewController == nil || viewController == selectedViewController {
         return false
         }

         let fromView = selectedViewController!.view
         let toView = viewController.view

         UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
         */
        return true
    }

    static func setLabelTextWithAnimation(label: UILabel, text: String) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = 0.75
        label.layer.add(animation, forKey: "kCATransitionFade")
        label.text = text
    }

    static func animateToTab(tabBarController: UITabBarController, toIndex: Int) {
        let tabViewControllers = tabBarController.viewControllers ?? [UIViewController()]
        let fromView = tabBarController.selectedViewController?.view
        let toView = tabViewControllers[toIndex].view
        guard let selectedViewController = tabBarController.selectedViewController else { return }
        let fromIndex = tabViewControllers.firstIndex(of: selectedViewController)

        guard fromIndex != toIndex else {return}

        // Add the toView to the tab bar view
        fromView?.superview?.addSubview(toView ?? UIView())

        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollRight = toIndex > (fromIndex ?? 0)
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView?.center = CGPoint(x: (fromView?.center.x ?? CGFloat.zero) + offset, y: (toView?.center.y ?? CGFloat.zero))

        // Disable interaction during animation
        tabBarController.view.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {

            // Slide the views by -offset
            fromView?.center = CGPoint(x: (fromView?.center.x ?? CGFloat.zero) - offset, y: (fromView?.center.y ?? CGFloat.zero))
            toView?.center   = CGPoint(x: (toView?.center.x ?? CGFloat.zero) - offset, y: (toView?.center.y ?? CGFloat.zero))

        }, completion: { _ in

            // Remove the old view from the tabbar view.
            fromView?.removeFromSuperview()
            tabBarController.selectedIndex = toIndex
            tabBarController.view.isUserInteractionEnabled = true
        })
    }

   static func startHeartBeatAnimation(animateView: UIView) {
        // Do any additional setup after loading the view.
                var theAnimation: CABasicAnimation?
                theAnimation = CABasicAnimation(keyPath: "transform.scale")
                theAnimation?.duration = 0.7
                theAnimation?.repeatCount = .infinity
                theAnimation?.autoreverses = true
                theAnimation?.fromValue = 1.0
                theAnimation?.toValue = 0.7
    theAnimation?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                if let anAnimation = theAnimation {
                    animateView.layer.add(anAnimation, forKey: "animateOpacity")
                }
    }

    static func animateBubbleTrnsitionView( selfView: UIView, point: CGPoint) {
        // let button = CGRect.init(x: 30, y: selfView.frame.size.height - 15, width: 45, height: 45)
        let button = CGRect.init(x: point.x, y: point.y, width: 0, height: 0)

        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect.init(x: point.x, y: point.y, width: 1, height: 1))
        let extremePoint = CGPoint(x: point.x, y: 15 - selfView.frame.size.height - 200)
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: (button.insetBy(dx: -radius, dy: -radius)))

        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        selfView.layer.mask = maskLayer

        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration =  0.9
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    // nice animation

    static func animationTransiton(viewToanimate: UIView) {

        viewToanimate.transform = CGAffineTransform(translationX: 0, y: -200).concatenating(CGAffineTransform(scaleX: 0, y: 0))
        viewToanimate.alpha = 1

        UIView.animate(withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: [.curveEaseOut], animations: {
            viewToanimate.transform = .identity
            viewToanimate.alpha = 1

        }, completion: { (_: Bool) in

        })

    }

}
