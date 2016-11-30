//
//  LoginController.swift
//  FlashAudio
//
//  Created by Serena Chan on 29/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Cocoa
import Firebase

class LoginController: NSViewController{

    @IBOutlet var visualEffectView: NSVisualEffectView!
    @IBOutlet weak var emailUsernameText: NSTextField!
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var loginRegisterToggle: NSSegmentedControl!
    @IBOutlet weak var registerUsernameField: NSTextField!
    @IBOutlet weak var registerUsernameText: NSTextField!
    @IBOutlet weak var loginPasswordField: NSSecureTextField!
    @IBOutlet weak var registerPasswordText: NSTextField!
    @IBOutlet weak var registerPasswordField: NSTextField!
    @IBOutlet weak var confirmPasswordText: NSTextField!
    @IBOutlet weak var confirmPasswordField: NSTextField!
    @IBOutlet weak var submitButton: NSButtonCell!
    
    @IBOutlet weak var emailError: NSTextField!
    @IBOutlet weak var usernameError: NSTextField!
    @IBOutlet weak var passwordError: NSTextField!
    @IBOutlet weak var generalError: NSTextField!
    @IBOutlet weak var loginError: NSTextField!
    @IBOutlet var triggerLogin: NSButton!
    
    let firebaseRef = Firebase(url: "https://flashaudio.firebaseio.com");
    let url = "http://flashaudio.firebaseio.com"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchLoginRegisterState(0)
        resetAllErrors()
        visualEffectView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        visualEffectView.material = NSVisualEffectMaterial.Light
        visualEffectView.state = NSVisualEffectState.Active
    }
    
    @IBAction func switchLogin(sender: AnyObject) {
        switchLoginRegisterState(loginRegisterToggle.selectedSegment)
    }
    
    @IBAction func loginOrSignUp(sender: AnyObject) {
        resetAllErrors()
        if(loginRegisterToggle.selectedSegment == 0){
            firebaseRef.authUser(emailField.stringValue, password: loginPasswordField.stringValue,
                         withCompletionBlock: { error, authData in
                            if error != nil {
                                self.loginError.hidden = false
                                print(error.debugDescription)
                            } else{
                                let uid = authData.uid
                                print("logged in with: " + uid)
                                self.moveOn(uid)
                                // We are now logged in
                            }
            })
        }
        else{
            let email = emailField.stringValue
            let username = registerUsernameField.stringValue
            let initPassword = registerPasswordField.stringValue
            let confirmPassword = confirmPasswordField.stringValue
            if(!checkEmail(email)){
                emailError.hidden = false
                return
            }
            if(!checkUsername(username)){
                usernameError.stringValue = "Usernames may only consist of A-z, 0-9 and _"
                usernameError.hidden = false
                return
            }
            firebaseRef.childByAppendingPath("usermap/" + username).observeEventType(.Value, withBlock: { snap in
                if snap.value is NSNull {
                    if(initPassword != confirmPassword){
                        self.passwordError.stringValue = "Passwords do not match each other."
                        self.passwordError.hidden = false
                        return
                    }
                    if(initPassword.characters.count < 5){
                        self.passwordError.stringValue = "Password length must be longer than 5."
                        self.passwordError.hidden = false
                        return
                    }
                    self.firebaseRef.createUser(email, password: initPassword, withValueCompletionBlock: { error, result in
                        if error != nil {
                            self.generalError.stringValue = error.debugDescription
                            print(error.debugDescription)
                            self.generalError.hidden = false
                        } else {
                            let uid = result["uid"] as? String
                            print("Successfully created user account with uid: \(uid)")
                            User.createNewUser(username, email: email, uid: uid!)
                            CurrentSession.uid = uid
                            self.firebaseRef.authUser(email, password: initPassword,
                                withCompletionBlock: { error, authData in
                                    if error != nil {
                                        self.loginError.hidden = false
                                        print(error.debugDescription)
                                    } else {
                                        print("yay logged in")
                                        self.moveOn(uid)
                                    }
                            })
                            
                            
                        }
                    })
                }
                    
                else{
                    self.usernameError.stringValue = "Username already taken."
                    self.usernameError.hidden = false
                    return
                }
            })
        }
    }
    
    @IBAction func mainTest(sender: AnyObject){
        let rsa = EncryptAudio.RSAGenerateKey();
        let publicKey = EncryptAudio.RSAToPublicKeyString(rsa);
        print(publicKey.characters.count)
        print(publicKey);
        let privateKey = EncryptAudio.RSAToPrivateKeyString(rsa);
        print(privateKey.characters.count)
        print(privateKey);
        let rsaPublic = EncryptAudio.RSAFromPublicKeyString(publicKey);
        let rsaPrivate = EncryptAudio.RSAFromPrivateKeyString(privateKey);
        let message = "hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there hi there end";
        print(message.characters.count)
        let encryptedString = EncryptAudio.RSAEncryptStringToString(message, key: rsaPublic);
        print(encryptedString)
        let decryptedString = EncryptAudio.RSADecryptStringFromString(encryptedString, key: rsaPrivate);
        print(decryptedString)
        print(decryptedString!);
    }
    
    func switchLoginRegisterState(state: Int){
        resetAllErrors()
        switch(state){
        case 0:
            registerUsernameText.stringValue = "Password"
            loginPasswordField.hidden = false
            registerUsernameField.hidden = true
            registerPasswordText.hidden = true
            registerPasswordField.hidden = true
            confirmPasswordText.hidden = true
            confirmPasswordField.hidden = true
            submitButton.stringValue = "Log in"
            break
        case 1:
            emailField.stringValue = ""
            registerUsernameText.stringValue = "Username"
            loginPasswordField.hidden = true
            registerUsernameField.hidden = false
            registerPasswordText.hidden = false
            registerPasswordField.hidden = false
            confirmPasswordText.hidden = false
            confirmPasswordField.hidden = false
            submitButton.stringValue = "Sign up"
            break
        default:
            print("oops")
            break
        }
    }
    
    func checkEmail(email: String) -> Bool{
        return Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}").test(email)
    }
    
    func checkUsername(username: String) -> Bool{
        return Regex("^[a-zA-Z0-9_]+$").test(username)
    }
    
    func resetAllErrors(){
        emailError.hidden = true
        usernameError.hidden = true
        passwordError.hidden = true
        generalError.hidden = true
        loginError.hidden = true
    }
    
    func allowsVibrancy() -> Bool{
        return true
    }
    
    func moveOn(uid: String!){
        CurrentSession.uid = uid
        resetAllErrors()
        performSegueWithIdentifier("triggerLogin", sender: triggerLogin)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        self.view.window!.close()
    }
}
