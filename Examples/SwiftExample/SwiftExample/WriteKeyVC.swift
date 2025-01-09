//
//  WriteKeyVC.swift
//  SwiftExample
//
//  Created by Bendnaiba on 2/13/23.
//

#if canImport(UIKit)

import UIKit

#endif

import Journify

class WriteKeyVC: UIViewController {
    
    @IBOutlet weak var writeKeyTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let writeKey = UserDefaults.standard.object(forKey: "WriteKey") as? String {
            self.writeKeyTextField.text = writeKey
        }
    }

    @IBAction func StartTapped(_ sender: Any) {
        guard let writeKey = self.writeKeyTextField.text else {
            startButton.shake()
            return
        }
        guard writeKey.count > 10 else {
            startButton.shake()
            return
        }
        UserDefaults.standard.set(writeKey, forKey: "WriteKey")
        UserDefaults.standard.synchronize()
        initJournify(writeKey: writeKey)
        pushViewController()
    }
    
    func initJournify(writeKey: String) {
        //init Journify
        let configuration = Configuration(writeKey: writeKey)
            .trackApplicationLifecycleEvents(true)
            .flushInterval(10)
        
        Journify.debugLogsEnabled = true
        Journify.setup(with: configuration)
    }
    
    func pushViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.show(viewController, sender: self)
    }
    
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

