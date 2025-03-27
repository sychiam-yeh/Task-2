//
//  CustomDateViewController.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-27.
//

import UIKit
import IBAnimatable

class CustomDateViewController: AnimatableModalViewController {

    /* =================================================================
     *                   MARK: - Local Initialization
     * ================================================================== */
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPresentationController()
    }
    
    fileprivate func setupPresentationController() {
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width * 0.5
        let height = screenSize.height * 0.4
        self.preferredContentSize = CGSize(width: width, height: height)
    }
}
