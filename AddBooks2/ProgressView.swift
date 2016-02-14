//
//  ProgressView.swift
//  AddBooks2
//
//  Created by Gandhi Mena Salas on 04/02/16.
//  Copyright © 2016 Trenx. All rights reserved.
//

import UIKit


public class ProgressView {
    
    private var containerView = UIView()
    private var progressView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    
    public class var sharedInstance: ProgressView {
        
        struct Static {
            
            static let instance: ProgressView = ProgressView()
        }
        
        return Static.instance
    }
    
    public func showProgressView(view: UIView) {
        
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        
        progressView.frame = CGRectMake(0, 0, 80, 80)
        progressView.center = view.center
        progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideProgressView() {
        
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        
        let r = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let g = CGFloat((hex & 0xFF00) >> 8)/256.0
        let b = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}