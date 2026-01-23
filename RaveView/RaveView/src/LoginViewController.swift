//
//  LoginViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
private let auth = AuthAPI(client: SupabaseManager.shared.client)

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        let mail = email.text ?? ""
        let pass = password.text ?? ""

        guard !mail.isEmpty, !pass.isEmpty else {
            errorLabel.text = "Fill all fields"
            return
        }
        
        print(mail)
        print(pass)

        Task {
            do {
                try await auth.login(email: mail, password: pass)
                await MainActor.run {
                    self.performSegue(withIdentifier: "Login_Home", sender: self)
                }
            }catch {
                print("LOGIN ERROR:", error)
                await MainActor.run {
                    self.errorLabel.text = "Invalid Credentials"
                }
            }
        }
    }

    @IBAction func registerBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "Login_Register", sender: self)
    }

    func goToHome() {
        performSegue(withIdentifier: "Login_Home", sender: self)
    }
}


