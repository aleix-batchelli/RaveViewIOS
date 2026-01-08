//
//  LoginViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerBtnPressed(_ sender: Any) {
        // Trigger the segue using the identifier set in Storyboard
        performSegue(withIdentifier: "Login_Register", sender: self)
    }
    
    // Optional: Use this to pass data to the Register screen before it loads
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Login_Register" {
            // let destinationVC = segue.destination as? RegisterViewController
            // destinationVC?.someProperty = "Hello"
        }
    }
}


