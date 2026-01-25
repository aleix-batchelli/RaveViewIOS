//
//  RegisterViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

final class RegisterViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    @IBOutlet weak var errorLabel: UILabel!
    
    private let auth = AuthAPI(client: SupabaseManager.shared.client)

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel?.text = ""

        email.autocapitalizationType = .none
        email.autocorrectionType = .no
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func registerBtnPressed(_ sender: Any) {
        let user = (username.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let mail = (email.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let p1 = password1.text ?? ""
        let p2 = password2.text ?? ""

        guard !user.isEmpty, !mail.isEmpty, !p1.isEmpty, !p2.isEmpty else {
            errorLabel?.text = "Fill all fields"
            return
        }

        guard p1 == p2 else {
            errorLabel?.text = "Passwords do not match"
            return
        }

        guard p1.count >= 6 else {
            errorLabel?.text = "Password too short"
            return
        }

        Task {
            do {
                try await auth.register(email: mail, password: p1, username: user, displayName: user)

                await MainActor.run {
                    self.performSegue(withIdentifier: "Register_Home", sender: self)
                }
            } catch {
                print("REGISTER ERROR:", error)
                await MainActor.run {
                    self.errorLabel?.text = "Something went wrong."
                }
            }
        }
    }
}

