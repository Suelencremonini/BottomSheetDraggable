//
//  ViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 28/08/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func buttonTapped(_ sender: Any) {
        let testBackgroundViewController = TestBackgroundViewController()
        navigationController?.pushViewController(testBackgroundViewController, animated: true)
    }
}
