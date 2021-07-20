//
//  BaseTitleBarController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class BaseTitleBarController: UIViewController {

    var titleBarViewController: TitleBarViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? TitleBarViewController {
            titleBarViewController = vc
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleBarViewController?.titleString = self.title ?? ""
    }
}
