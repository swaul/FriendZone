//
//  ValidatedText.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import Combine

struct ValidationInfo: Equatable {
    let isValid: Bool
    let errorMessage: String?
}

extension ValidationInfo {
    static var initial: ValidationInfo {
        return ValidationInfo(isValid: false, errorMessage: nil)
    }
    
    static var valid: ValidationInfo {
        return ValidationInfo(isValid: true, errorMessage: nil)
    }
}

class ValidatedText: ObservableObject {
    
    @Published var value: String?
    @Published var validation: ValidationInfo = .initial
    
    private var formatter: ((String?) -> String?)
    
    init(value: String?, validation: @escaping ((String?) -> ValidationInfo), formatter: @escaping ((String?) -> String?) = { $0 }) {
        self._value = Published(initialValue: value)
        self.formatter = formatter
        
        $value
            .map(formatter)
            .map(validation)
            .assign(to: &$validation)
    }
    
    // MARK: Computed Properties
    
    var formattedValue: String? {
        return formatter(value)
    }
}
