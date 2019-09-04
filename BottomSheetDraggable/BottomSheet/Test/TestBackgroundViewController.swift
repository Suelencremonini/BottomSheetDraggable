//
//  TestBackgroundViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 27/08/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class TestBackgroundViewController: UIViewController {

    private var listCell: [TestActionSheetTableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        delegate = self
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        var i = 0
        while i < 3 {
            let cell = TestActionSheetTableViewCell()
            listCell.append(cell)
            i += 1
        }
        ActionSheet2ViewController(backgroundViewController: self)
//        ActionSheetTableClientViewController(backgroundViewController: self)
    }
}

extension TestBackgroundViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestActionSheetTableViewCell", for: indexPath) as? TestActionSheetTableViewCell
        cell?.config(row: indexPath.row)
        return cell ?? UITableViewCell()
    }
}

extension TestBackgroundViewController: ActionSheetBackgroundDelegate {
    func actionSheetBackgroundRegisterCellsForTableView(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "TestActionSheetTableViewCell", bundle: nil), forCellReuseIdentifier: "TestActionSheetTableViewCell")
    }
}
