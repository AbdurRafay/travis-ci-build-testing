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

import Foundation
import UIKit

struct ErrorConstants {
    
    static let errorDomain = "ABErrorDomain"
    static let errorCode = 909
    
    struct ErrorMsg {
        static let noInternet = "Internet could not be reached."
        static let timeout = "Server time out occurred."
        static let serialization = "A data serialization error occured."
        static let unknown = "Any unKnown error occurred"
        static let validation = "One or more fields are missing"
        static let parse = "Could not parse server response."
        static let initialization = "Optimizely initialization error occured."
    }
    
    struct ErrorKey {
        static let code = "ErrorCode"
        static let message = "ErrorMessage"
    }
}

struct UIConstants {
    
    struct Strings {
        static let error = "Error"
        static let success = "Success"
        static let okay = "Ok"
        static let submit = "Submit"
        static let cancel = "Cancel"
        static let done = "DONE"
        static let space = " "
        static let clear = "Clear"
    }
    
    struct Colors {
        static let tint = UIColor.init(red: 21/255, green: 57/255, blue: 81/255, alpha: 255/255)
        static let separator = UIColor.init(red: 193/255, green: 193/255, blue: 193/255, alpha: 255/255)
        static let link = UIColor.init(red: 0/255, green: 123/255, blue: 255/255, alpha: 255/255)
    }
    
    struct Storyboards {
        private static let mainStoryboardName = "Main"
        static let main = UIStoryboard(name: mainStoryboardName, bundle: nil)
    }
    
    struct StoryboardIDs {
        static let inputVC = "InputVC"
        static let outputVC = "OutputVC"
    }
    
    struct Images {
        struct Names {
            static let logo = "logo"
        }
        
        static let logo = UIImage(named: Names.logo)
    }
    
    struct Fonts {
        static let systemFontOfSize10 = UIFont.systemFont(ofSize: 10)
    }
}
