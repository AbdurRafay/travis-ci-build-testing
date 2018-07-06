/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import UIKit

class OutputVC: BaseVC, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imgViewLogo:     UIImageView!
    @IBOutlet weak var tvResponseJSON:  UITextView!
    
    // MARK: - Properties
    
    private lazy var viewModel: OutputVMProtocol = {
        let viewModel = OutputVM()
        return viewModel
    }()
    
    let router = OutputRouter()
    
    // MARK: - Class Methods
    
    static func instance() -> OutputVC {
        let vc = UIConstants.Storyboards.main.instantiateViewController(withIdentifier: String(describing: self)) as? OutputVC
        return vc ?? OutputVC()
    }
    
    // MARK: - UIView life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - viewModel closures
    
    func didParse(_ viewMOdel: OutputVMProtocol) -> Void {
//        self.router.route(to: OuputRoute.shop.rawValue, from: self, parameters: nil)
    }
    
    func failedToParse(_ viewMOdel: OutputVMProtocol, error: Error) -> Void {
        self.toast(error: error)
    }
    
    // MARK: - IBActions
    
    // MARK: - Overrides
    
    override func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func bindUI() -> Void {
        self.tvResponseJSON?.text = viewModel.response()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.tvResponseJSON:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
