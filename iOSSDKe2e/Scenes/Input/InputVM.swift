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

protocol InputVMProtocol {
    func parseRequest(for url: String,
                      withJson json: String,
                      success: ((InputVMProtocol) -> ())?,
                      failure: ((InputVMProtocol, Error) -> ())?) -> Void
    func response() -> String
}

class InputVM : InputVMProtocol {
    
    func parseRequest(for url: String,
                      withJson json: String,
                      success: ((InputVMProtocol) -> ())?,
                      failure: ((InputVMProtocol, Error) -> ())?) -> Void {
        
        guard TestWorker.shared.serialize(testJSON: json, forAPIUrl: url) else {
            let error = ABError.parse(ErrorConstants.ErrorMsg.parse)
            failure?(self, error)
            return
        }
        self.initOptimizely(success: success, failure: failure)
    }
    
    func response() -> String {
        return TestWorker.shared.getResult() ?? ""
    }
    
    private func initOptimizely(success: ((InputVMProtocol) -> ())?, failure: ((InputVMProtocol, Error) -> ())?) {
        guard OptimizelyWorker.shared.optimizelyClient != nil else {
            let error = ABError.validation(ErrorConstants.ErrorMsg.initialization)
            failure?(self, error)
            return
        }
        OptimizelyWorker.shared.setForcedVariations()
        success?(self)
    }
}
