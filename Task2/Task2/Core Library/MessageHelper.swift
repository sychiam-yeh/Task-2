//
//  MessageHelper.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//


import Foundation
import SwiftEntryKit

extension MessageHelper {
    enum MessageTheme {
        case success
        case error
        case info
    }
    enum MessageType {
        case toast
        case note
    }
    enum MessagePosition {
        case center
        case top
    }
}

struct MessageHelper {
    
    /* =================================================================
     *                   MARK: - Local Initialization
     * ================================================================= */
    static var successMessage: EKColor {
        return EKColor(.systemGreen)
    }
    static var errorMessage: EKColor {
        return EKColor(.systemRed)
    }
    static var infoMessage: EKColor {
        return EKColor(.systemGray)
    }
    
    static let textfieldDelegate = CustomTextFieldDelegate()
    
    /* =================================================================
     *                   MARK: - Class Functions
     * ================================================================= */
    static func showTopMessage(type: MessageType, theme: MessageTheme, message: String, duration: Double = 2.0,
                               file: String = #file, function: String = #function, line: Int = #line) {
        var attributes = EKAttributes()
        switch type {
        case .note:
            attributes = .topNote
        case .toast:
            attributes = .topToast
        }
        switch theme {
        case .success:
            attributes.entryBackground = .color(color: MessageHelper.successMessage)
        case .error:
            attributes.entryBackground = .color(color: MessageHelper.errorMessage)
//            logger.error(message, file: file, function: function, line: line)
        case .info:
            attributes.entryBackground = .color(color: MessageHelper.infoMessage)
        }
        attributes.displayDuration = duration
        attributes.precedence.priority = .high
        
        let text = message
        let style = EKProperty.LabelStyle(font: MainFont.medium.with(size: 15), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        let contentView = EKNoteMessageView(with: labelContent)
        
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showBottomMessage(type: MessageType, theme: MessageTheme, message: String, duration: Double = 2.0,
                                  file: String = #file, function: String = #function, line: Int = #line) {
        var attributes = EKAttributes()
        
        switch type {
        case .note:
            attributes = .bottomNote
        case .toast:
            attributes = .bottomToast
        }
        switch theme {
        case .success:
            attributes.entryBackground = .color(color: MessageHelper.successMessage)
        case .error:
            attributes.entryBackground = .color(color: MessageHelper.errorMessage)
//            logger.warn(message, file: file, function: function, line: line)
        case .info:
            attributes.entryBackground = .color(color: MessageHelper.infoMessage)
        }
        attributes.displayDuration = duration
        
        let text = message
        let style = EKProperty.LabelStyle(font: MainFont.medium.with(size: 15), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        let contentView = EKNoteMessageView(with: labelContent)
        
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showUIBlockingDefaultAlertController(_ viewController: UIViewController,
                                                     message: String,
                                                     title: String = "Message") {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showDefaultAlertController(_ viewController: UIViewController,
                                           message: String,
                                           title: String = "Message",
                                           proceedButtonTitle: String = "Okay",
                                           proceedButtonStyle: UIAlertAction.Style = .default,
                                           withCancelOption: Bool = false,
                                           cancelButtonTitle: String = "Cancel",
                                           cancelButtonStyle: UIAlertAction.Style = .cancel,
                                           completion: ((Bool) -> ())?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        if withCancelOption {
            alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: cancelButtonStyle, handler: { action in
                completion?(false)
            }))
        }
        alertController.addAction(UIAlertAction(title: proceedButtonTitle, style: proceedButtonStyle, handler: { action in
            completion?(true)
        }))
        viewController.present(alertController, animated: true, completion: nil)
    }
  
    static func showDefaultAlertControllerWithDropDown(_ viewController: UIViewController,
                                           message: String,
                                           title: String = "Message",
                                           dropDowntitle: String = "Select",
                                           optionArray: [String],
                                           completion: ((Bool, String) -> ())?) {
        guard optionArray.count > 0 else { return }
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: { (_ textField: UITextField) -> Void in
            let dropDownButton = UIButton()
            var salesMoreAction = [UIAction]()
            for option in optionArray {
                let action = UIAction(title: option) {  _ in
                    textField.text = option
                }
                salesMoreAction.append(action)
            }
            dropDownButton.menu = UIMenu(title: dropDowntitle, children: salesMoreAction)
            dropDownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            dropDownButton.showsMenuAsPrimaryAction = true
        
            textField.rightView = dropDownButton
            textField.rightViewMode = .always
            textField.addSubview(dropDownButton)
            textField.delegate = textfieldDelegate
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            completion?(false, alertController.textFields?[0].text ?? "")
        }))
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
            completion?(true, alertController.textFields?[0].text ?? "")
        }))
        viewController.present(alertController, animated: true, completion: nil)
    }
}

class CustomTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
