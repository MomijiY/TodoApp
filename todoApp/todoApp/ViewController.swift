//
//  ViewController.swift
//  todoApp
//
//  Created by 吉川椛 on 2020/09/18.
//  Copyright © 2020 com.litech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    var tappedCount: Int = 0
    var submitFormY: CGFloat = -50
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submitForm: UIView!
    @IBOutlet weak var submitFormBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var parentStackView: UIStackView!
    
    //配列にtodoを追加
    var todoArray: [String] = []
    var stackViewArray: [UIStackView] = []
    
    let tagLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("開始")
        textField.delegate = self
        // 通知センターの取得
        let notification =  NotificationCenter.default

        // keyboardのframe変化時
        notification.addObserver(self,
                                    selector: #selector(self.keyboardChangeFrame(_:)),
                                    name: UIResponder.keyboardDidChangeFrameNotification,
                                    object: nil)

        // keyboard登場時
        notification.addObserver(self,
                                    selector: #selector(self.keyboardWillBeShow(_:)),
                                    name: UIResponder.keyboardWillShowNotification,
                                    object: nil)

        // keyboard退場時
        notification.addObserver(self,
                                    selector: #selector(self.keyboardWillBeHide(_:)),
                                    name: UIResponder.keyboardDidHideNotification,
                                    object: nil)
        
        //label
        tagLabel.frame = CGRect(x: 5, y: 20, width: UIScreen.main.bounds.size.width, height: 50)
        tagLabel.textAlignment = .left
        tagLabel.textColor = .black
        tagLabel.font = UIFont(name: "Arial", size: 18)
        tagLabel.numberOfLines = 0
    }
    
    @IBAction func tappedGesture(_ sender: UITapGestureRecognizer) {
        if tappedCount % 2 == 1 {
            tappedCount += 1
            self.textField.becomeFirstResponder()
        } else {
            tappedCount += 1
            view.endEditing(true)
        }
    }
    
    //
    func setLayout() {
        let firstStackView = UIStackView()
        stackViewArray.append(firstStackView)
        var todoButtonHeight: CGFloat = 0
        var allWidths: CGFloat = 0
        var stackViewNum = 0
        for view in parentStackView.subviews {
            view.removeFromSuperview()
        }
        for todo in todoArray {
            if allWidths <= stackViewArray[stackViewNum].frame.size.width {
                let todoButton = UIButton()
                todoButton.setTitle(todo, for: .normal)
                todoButton.setTitleColor(.black, for: .normal)
                todoButton.sizeToFit()
                allWidths += todoButton.frame.size.width + 20
                todoButtonHeight = todoButton.frame.size.height
                stackViewArray[stackViewNum].spacing = 20
                stackViewArray[stackViewNum].addArrangedSubview(todoButton)
                stackViewArray[stackViewNum].heightAnchor.constraint(equalToConstant: todoButtonHeight).isActive = true
            } else {
                let stackView = UIStackView()
                stackViewArray.append(stackView)
                stackViewNum += 1
                allWidths = 0
                //stackViewを増やしたい。-> stackViewの配列を作る。
            }
        }
        let marginView = UIView()
        marginView.heightAnchor.constraint(equalToConstant: todoButtonHeight).isActive = true
        stackViewArray[stackViewNum].addArrangedSubview(marginView)
        let parentMarginView = UIView()
        parentMarginView.widthAnchor.constraint(equalToConstant: parentStackView.frame.size.width).isActive = true
        for stackView in stackViewArray {
            parentStackView.addArrangedSubview(stackView)
        }
        parentStackView.addArrangedSubview(parentMarginView)
    }
    
    @objc func keyboardChangeFrame(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let diff = self.submitForm.frame.maxY - keyboardFrame.minY
        
        if (diff > 0) {
            self.submitFormBottomConstraints.constant += diff
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillBeShow(_ notification: NSNotification) {
        submitFormY = self.submitForm.frame.maxY
    }
    //キーボードが退場時の処理
    @objc func keyboardWillBeHide(_ notification: NSNotification) {
        //submitFormのbottomの制約を元に戻す
        self.submitFormBottomConstraints.constant = -submitFormY
        self.view.layoutIfNeeded()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tagLabel.text = textField.text
        todoArray.append(textField.text!)
        setLayout()
        view.endEditing(true)
        return true
    }
}
