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

enum ABError: Error {
    case noInternet(String)
    case timeOut(String)
    case unAuthorized(String)
    case serverError(String)
    case serialization(String)
    case unKnown(String)
    case validation(String)
    case parse(String)
}

extension ABError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noInternet(let localizedError), .timeOut(let localizedError), .unAuthorized(let localizedError), .serverError(let localizedError), .serialization(let localizedError), .unKnown(let localizedError), .validation(let localizedError), .parse(let localizedError):
            return NSLocalizedString(localizedError,comment: "")
        }
    }
}
