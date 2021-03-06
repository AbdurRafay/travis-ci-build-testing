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

enum InputRoute: String {
    case output
}

class InputRouter: Router {
    
    func route( to routeID: String, from context: UIViewController, parameters: Any?) {
        guard let route = InputRoute(rawValue: routeID) else {
            return
        }
        switch route {
        case .output:
            let outputVC = OutputVC.instance()
            context.navigationController?.pushViewController(outputVC, animated: true)
            break
        }
    }
}


