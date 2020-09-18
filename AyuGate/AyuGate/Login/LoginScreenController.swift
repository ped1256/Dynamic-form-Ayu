//
//  LoginScreenController.swift
//  AyuGate
//
//  Created by Pedro Azevedo on 25/08/20.
//  Copyright © 2020 AyuGate. All rights reserved.
//

import UIKit
import FormKit
import AyuKit

protocol LoginScreenControllerDelegate {
    func loginScreenControllerDelegateVerifyCPF(field: FormFieldContent)
    func loginScreenControllerDelegateLogin(field: FormFieldContent)
    func loginScreenControllerDelegateRegisterPassword(field: FormFieldContent)
}

class LoginScreenController: AYUActionButtonViewController, AYUActionButtonViewControllerDelegate {
    
    var section: FormSection
    
    let backgroundStepDepence: StepProtocol = {
        return LoginBackgroundStep()
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var fieldStackContent: UIStackView = {
        // coloquei -15 uma gambiarra pra corrigir um problema de espaço.(voltar e confirgurar stack corretamente)
        let stackView = UIStackView().vertical(-15)
        stackView.add([
            fieldContent,
            passwordField,
            confirmPasswordField
        ])
        
        return stackView
    }()
    
    lazy var fieldContent: FormFieldContent = {
        let field = FormFieldContent(maskField: Mock.CPFField())
        field.errorMessageLabel.text = "Senha inválida"
        return field
    }()
    
    lazy var passwordField: FormFieldContent = {
        let passwordField = FormFieldContent(maskField: Mock.ConfirmPasswordField())
        passwordField.model = Mock.PasswordField().formModel
        passwordField.isHidden = true
        passwordField.title.isHidden =  false
        
        return passwordField
    }()
    
    lazy var confirmPasswordField: FormFieldContent = {
        let confirmPasswordField = FormFieldContent(maskField: Mock.ConfirmPasswordField())
        
        confirmPasswordField.model = Mock.ConfirmPasswordField().formModel
        confirmPasswordField.isHidden = true
        confirmPasswordField.title.isHidden =  true
        
        return confirmPasswordField
    }()
    
    var delegate: LoginScreenControllerDelegate?
    private var controllerState: ControllerState = .cpf
    
    var controllerUpConstant: CGFloat? {
        switch controllerState {
        case .cpf:
            return fieldContent.frame.height
        case .register:
            return 130
        case .login:
            return fieldContent.frame.height
        }
    }
    
    private enum ControllerState {
        case cpf
        case login
        case register
    }
    
    var verifyViewModel: CPFVerifyViewModel? {
        didSet {
            updateControllerStatus()
        }
    }
    
    public init(section: FormSection) {
        self.section = section
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        setupComponents()
        
        actionButtonViewControllerDelegate = self
    }
    
    private func setupComponents() {
        fieldStackContent.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .clear
        view.addSubview(fieldStackContent)
        view.addSubview(actionButton)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            fieldStackContent.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            fieldStackContent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fieldStackContent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AYUActionButton.Constants.defaulsConstants),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AYUActionButton.Constants.defaulsConstants),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AYUActionButton.Constants.defaulsConstants),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
        actionButton.delegate = self
        actionButton.status = .enabled
        fieldContent.model = Mock.CPFField().formModel
        imageView.image = Images.womanWithComputer

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        fieldContent.validationSectionHandler = { [weak self] isValid in
            self?.actionButton.status = isValid ? .enabled : .disabled
        }
        
        passwordField.textDidChange = { [weak self] text in
            self?.actionButton.status = text == self?.confirmPasswordField.value ? .enabled : .disabled
        }
        
        confirmPasswordField.textDidChange = { [weak self] text in
            self?.actionButton.status = text == self?.passwordField.value ? .enabled : .disabled
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateControllerStatus() {
        guard let verifyModel = verifyViewModel else { return }
        switch verifyModel.status {
        case .alreadyExists:
            actionButton.status = .loaded
            fieldContent.endEditing(true)
            fieldContent.maskField = Mock.PasswordField()
            fieldContent.model = passwordFieldModel(with: verifyModel.formattedCPF)
            fieldContent.titleAccessoryView.image = Images.checkMarck
            fieldContent.titleAccessoryView.isHidden = false
            self.controllerState = .login
        case .newUser:
            self.controllerState = .register
            actionButton.status = .loaded
            confirmPasswordField.isHidden = false
            passwordField.isHidden = false
            fieldContent.isHidden = true
            actionButton.status = .loaded
            fieldContent.endEditing(true)
            passwordField.model = passwordFieldModel(with: verifyModel.formattedCPF)
            passwordField.titleAccessoryView.image = Images.checkMarck
            passwordField.titleAccessoryView.isHidden = false
            
        case .notFound:
            actionButton.status = .loaded
            fieldContent.fieldIsValid = false
        }
    }
}

extension LoginScreenController: AYUActionButtonDelegate {
    func actionButtonDelegateDidTouch(_ sender: Any) {
        actionButton.status = .loading
        self.view.endEditing(true)
        switch controllerState {
        case .cpf:
            delegate?.loginScreenControllerDelegateVerifyCPF(field: fieldContent)
        case .login:
            delegate?.loginScreenControllerDelegateLogin(field: fieldContent)
        case .register:
            delegate?.loginScreenControllerDelegateRegisterPassword(field: fieldContent)
        }
    }

    func passwordFieldModel(with title: String) -> FormFieldContent.Model {
        return FormFieldContent.Model(placeholder: "Senha", title: title)
    }
}

struct LoginBackgroundStep: StepProtocol {
    var numberOfSteps: Int = 0
    var currentStep: Int = 0
    var delegate: StepProtocolDelegate?
}

enum ProfileStatus {
    case valid
    case needsInfo
    case canBeMei
}
