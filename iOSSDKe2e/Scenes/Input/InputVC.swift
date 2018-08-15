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

class InputVC: BaseVC, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imgViewLogo:     UIImageView!
    @IBOutlet weak var txtRequestURL:   UITextField!
    @IBOutlet weak var tvRequestJSON:  UITextView!
    @IBOutlet weak var btnCallAPI:      UIButton!
    @IBOutlet weak var tvResponseJSON:  UITextView!
    
    // MARK: - Properties
    
    private lazy var viewModel: InputVMProtocol = {
        let viewModel = InputVM()
        return viewModel
    }()
    
    let router = InputRouter()
    
    // MARK: - Class Methods
    
    static func instance() -> InputVC {
        let vc = UIConstants.Storyboards.main.instantiateViewController(withIdentifier: String(describing: self)) as? InputVC
        return vc ?? InputVC()
    }
    
    // MARK: - UIView life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - viewModel closures
    
    func didParse(_ viewMOdel: InputVMProtocol) -> Void {
        self.txtRequestURL.text = ""
        self.tvRequestJSON.text = ""
        //self.router.route(to: InputRoute.output.rawValue, from: self, parameters: nil)
        self.tvResponseJSON?.text = viewModel.response()
    }
    
    func failedToParse(_ viewMOdel: InputVMProtocol, error: Error) -> Void {
        self.txtRequestURL.text = ""
        self.tvRequestJSON.text = ""
        self.toast(error: error)
    }
    
    // MARK: - IBActions
    
    @IBAction func callAPI(_ sender: UIButton) {
        self.view.endEditing(true)
        guard
            let url = self.txtRequestURL.text,
            let json = self.tvRequestJSON.text
            else { return }
        viewModel.parseRequest(for: url, withJson: json, success: self.didParse(_:), failure: self.failedToParse(_:error:))
    }
    
    // MARK: - Overrides
    
    override func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        //self.btnCallAPI.layer.cornerRadius = self.btnCallAPI.layer.bounds.height/2
        let env = Bundle.main.infoDictionary?["NUM_RUNS"] as! String
        print(env)
        self.tvResponseJSON.text = "NUM_RUNS = " + env
    }
    
    override func bindUI() -> Void {
        //self.txtInputRequestJSON?.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.txtRequestURL:
            //self.tvRequestJSON.becomeFirstResponder()
            textField.resignFirstResponder()
        case self.tvRequestJSON:
            textField.resignFirstResponder()
//            self.callAPI(self.btnCallAPI)
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
