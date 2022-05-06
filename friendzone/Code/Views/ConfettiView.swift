//
//  ConfettiView.swift
//  friendzone
//
//  Created by Paul Kühnel on 06.05.22.
//

import Foundation
import SwiftUI
import ConfettiSwiftUI

public struct ConfettiView: View {
    
    @State public var counter: Int = 0 {
        didSet {
            print("+++++ counter ++ ++++++++")
        }
    }
    
    public var body: some View {
        Text(" ")
            .confettiCannon(counter: $counter, repetitions: 3)
            .onAppear {
                counter += 1
            }
    }
}
