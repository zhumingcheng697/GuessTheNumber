//
//  HostingController.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

var guessData = GuessData()

class GuessData: ObservableObject {
    @Published var upperRange = 99
    @Published var usingHex = false
    @Published var userGuessingCorrectNumber = 0
    @Published var userGuessedNumber = 0
    @Published var userGuessedTimes = 0
    @Published var aiGuessingLowerLimit = 0
    @Published var aiGuessingUpperLimit = 99
    @Published var aiGuessedNumber = Int((0 + 99 + Int.random(in: 0 ... 1)) / 2)
    @Published var aiGuessedTimes = 0
    @Published var isUserGuessing = false
    @Published var isAiGuessing = false
    @Published var isInRandomizer = false
    @Published var isRandomizingNumber = false
    @Published var isRandomizingColor = false
    @Published var isRandomizingBoolean = false
    @Published var isInSettings = false
    @Published var isEditingUpperRange = false
    @Published var showCompareResult = false
    @Published var hasAiWon = false
}

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(ContentView().environmentObject(guessData))
    }
}
