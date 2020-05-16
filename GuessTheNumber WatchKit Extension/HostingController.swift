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
    @Published var quickAction = "None"
    @Published var upperRange = 99
    @Published var usingHex = false
    @Published var userGuessingCorrectNumber = 0
    @Published var userGuessedNumber = 0
    @Published var userGuessedTimes = 0
    @Published var aiGuessingLowerLimit = 0
    @Published var aiGuessingUpperLimit = 99
    @Published var aiGuessedNumber = Int((0 + 99 + Int.random(in: 0 ... 1)) / 2)
    @Published var aiGuessedTimes = 0
    @Published var randomNumber = Int.random(in: 0 ..< 99 + 1)
    @Published var randomR = Int.random(in: 0 ..< 256)
    @Published var randomG = Int.random(in: 0 ..< 256)
    @Published var randomB = Int.random(in: 0 ..< 256)
    @Published var randomDouble = Double.random(in: -10.0 ... 10.0)
    @Published var isUserGuessing = false
    @Published var isAiGuessing = false
    @Published var isInRandomizer = false
    @Published var isRandomizingNumber = false
    @Published var isRandomizingColor = false
    @Published var isRandomizingBoolean = false
    @Published var isInSettings = false
    @Published var isEditingQuickAction = false
    @Published var isEditingUpperRange = false
    @Published var showCompareResult = false
    @Published var hasAiWon = false
    @Published var askWhenUserGuessing = false
    @Published var askWhenAiGuessing = false
    
    func wasUserGuessing() -> Bool {
        return (self.isUserGuessing && self.userGuessedNumber != -1)
    }
    
    func wasAiGuessing() -> Bool {
        return (self.isAiGuessing && self.aiGuessedTimes > 0)
    }
    
    func resetUpperRange(_ resetUpperRange: Int) {
        self.upperRange = resetUpperRange
        self.aiGuessingUpperLimit = resetUpperRange
        self.aiGuessedNumber = Int((0 + resetUpperRange + Int.random(in: 0 ... 1)) / 2)
        self.randomNumber = Int.random(in: 0 ..< resetUpperRange + 1)
    }
    
    func resetViews() {
        self.isUserGuessing = false
        self.isAiGuessing = false
        self.isInRandomizer = false
        self.isRandomizingNumber = false
        self.isRandomizingColor = false
        self.isRandomizingBoolean = false
        self.isInSettings = false
        self.isEditingQuickAction = false
        self.isEditingUpperRange = false
        self.showCompareResult = false
        self.hasAiWon = false
    }
    
    func resetUserGuessing() {
        self.userGuessingCorrectNumber = Int.random(in: 0 ..< self.upperRange + 1)
        self.userGuessedNumber = -1
        self.userGuessedTimes = 0
    }
    
    func resetAiGuessing() {
        self.aiGuessingLowerLimit = 0
        self.aiGuessingUpperLimit = self.upperRange
        self.aiGuessedNumber = Int((self.aiGuessingLowerLimit + self.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
        self.aiGuessedTimes = 0
    }
    
    func resetRandomNumber() {
        self.randomNumber = Int.random(in: 0 ..< self.upperRange + 1)
    }
    
    func resetRandomColor() {
        self.randomR = Int.random(in: 0 ..< 256)
        self.randomG = Int.random(in: 0 ..< 256)
        self.randomB = Int.random(in: 0 ..< 256)
    }
    
    func resetRandomBoolean() {
        self.randomDouble = Double.random(in: -10.0 ... 10.0)
    }
    
    func launchUserGuessing() {
        self.resetViews()
        self.resetUserGuessing()
        self.isUserGuessing = true
    }
    
    func launchAiGuessing() {
        self.resetViews()
        self.resetAiGuessing()
        self.isAiGuessing = true
    }
    
    func launchRandomizer() {
        self.resetViews()
        self.isInRandomizer = true
    }
    
    func launchRandomNumber() {
        self.resetViews()
        self.resetRandomNumber()
        self.isInRandomizer = true
        self.isRandomizingNumber = true
    }
    
    func launchRandomColor() {
        self.resetViews()
        self.resetRandomColor()
        self.isInRandomizer = true
        self.isRandomizingColor = true
    }
    
    func launchRandomBoolean() {
        self.resetViews()
        self.resetRandomBoolean()
        self.isInRandomizer = true
        self.isRandomizingBoolean = true
    }
    
    func autoRedirect() {
        switch self.quickAction {
        case "Let Me Guess":
            self.launchUserGuessing()
        case "Let AI Guess":
            self.launchAiGuessing()
        case "Randomizer":
            self.launchRandomizer()
        case "Random Number":
            self.launchRandomNumber()
        case "Random Color":
            self.launchRandomColor()
        case "Random Boolean":
            self.launchRandomBoolean()
        default:
            break
        }
    }
}

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(ContentView().environmentObject(guessData))
    }
}
