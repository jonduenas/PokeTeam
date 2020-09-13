//
//  SimpleOver.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/12/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class SimpleOver: NSObject, UIViewControllerAnimatedTransitioning {
    
    var popStyle: Bool = false
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.20
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if popStyle {
            animatePop(using: transitionContext)
            return
        }
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let toVCFinalFrame = transitionContext.finalFrame(for: toVC)
        let fromVCInitialFrame = transitionContext.initialFrame(for: fromVC)
        
        let finalFrameOffset = toVCFinalFrame.offsetBy(dx: toVCFinalFrame.width, dy: 0)
        let initialFrameOffset = fromVCInitialFrame.offsetBy(dx: -fromVCInitialFrame.width, dy: 0)
        toVC.view.frame = finalFrameOffset
        
        transitionContext.containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                toVC.view.frame = toVCFinalFrame
                fromVC.view.frame = initialFrameOffset
        }, completion: {_ in
                transitionContext.completeTransition(true)
        })
    }
    
    func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let fromVCInitialFrame = transitionContext.initialFrame(for: fromVC)
        let toVCFinalFrame = transitionContext.finalFrame(for: toVC)
        
        let initialOffsetPop = fromVCInitialFrame.offsetBy(dx: fromVCInitialFrame.width, dy: 0)
        let finalOffsetPop = toVCFinalFrame.offsetBy(dx: -toVCFinalFrame.width, dy: 0)
        
        toVC.view.frame = finalOffsetPop
        
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = initialOffsetPop
                toVC.view.frame = toVCFinalFrame
        }, completion: {_ in
                transitionContext.completeTransition(true)
        })
    }
}
