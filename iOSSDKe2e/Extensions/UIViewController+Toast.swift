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

extension UIViewController {
    
    func toast(error: Error) -> Void {
        self.toast(UIConstants.Strings.error, msg: error.localizedDescription)
    }
    
    func toast(_ title: String = "", msg: String, dismissalTime: Double = 2.0) -> Void {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .actionSheet)
        let frame = CGRect.init(x: self.view.bounds.width/4,
                                y: self.view.bounds.height,
                                width: self.view.bounds.width/2,
                                height: self.view.bounds.height)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = frame
        self.present(alert, animated: true, completion: nil)
        
        // Delay the dismissal by 2 seconds
        let time = DispatchTime.now() + dismissalTime
        DispatchQueue.main.asyncAfter(deadline: time){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func displayAlert(title: String, message: String, okTitle: String = "OK", okhandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: UIConstants.Strings.cancel.capitalized, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: okTitle, style: .destructive, handler: okhandler)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
