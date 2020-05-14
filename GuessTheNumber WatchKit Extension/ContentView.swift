//
//  ContentView.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import SwiftUI

struct UserGuessingView: View {
    @Binding var upperRange: Int
    @Binding var userGuessedNumber: Int
    @Binding var userGuessedTimes: Int
    @Binding var showCompareResult: Bool
    
    var body: some View {
        VStack {
            if self.userGuessedNumber == -1 {
                Spacer()
                
                Text("Guess a number between 0 and \(Int(self.upperRange))")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Spacer()
                
                Button(action: {
                    withAnimation {
                        self.userGuessedNumber = 0
                    }
                }, label: {
                    Text("Ready")
                })
            } else {
                Picker(selection: $userGuessedNumber, label: Text("My Guess")) {
                    ForEach(0 ..< Int(self.upperRange) + 1) { index in
                        Text("\(index)")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                    }
                }
                
                Button(action: {
                    self.showCompareResult = true
                    self.userGuessedTimes += 1
                }, label: {
                    Text("Comfirm")
                })
            }
        }
    }
}

struct AiGuessingView: View {
    @Binding var upperRange: Int
    @Binding var aiGuessingLowerLimit: Int
    @Binding var aiGuessingUpperLimit: Int
    @Binding var aiGuessedNumber: Int
    @Binding var aiGuessedTimes: Int
    @Binding var hasAiWon: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            if self.aiGuessedTimes == 0 {
                Spacer()
                
                Text("Choose a number between 0 and \(Int(self.upperRange))")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Spacer()
                
                Button(action: {
                    withAnimation {
                        self.aiGuessedTimes += 1
                    }
                }, label: {
                    Text("Ready")
                })
            } else {
                GeometryReader { geo in
                    ScrollView {
                        VStack(alignment: .center) {
                            if self.aiGuessingLowerLimit == self.aiGuessedNumber || self.aiGuessingUpperLimit == self.aiGuessedNumber {
                                Spacer()
                            }
                            
                            Text(self.aiGuessingLowerLimit == self.aiGuessingUpperLimit ? "   It is \(self.aiGuessedNumber)!   " : "   Is it \(self.aiGuessedNumber)?   ")

                            Spacer()
                            
                            Button(action: {
                                self.hasAiWon = true
                            }, label: {
                                Text("Correct")
                            })
                                .accentColor(.green)
                        
                            if self.aiGuessingLowerLimit != self.aiGuessedNumber {
                                Button(action: {
                                    self.aiGuessedTimes += 1
                                    self.aiGuessingUpperLimit = self.aiGuessedNumber - 1
                                    self.aiGuessedNumber = Int((self.aiGuessingLowerLimit + self.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
                                }, label: {
                                    Text("Too High")
                                }).accentColor(.red)
                            }
                            
                            if self.aiGuessingUpperLimit != self.aiGuessedNumber {
                                Button(action: {
                                    self.aiGuessedTimes += 1
                                    self.aiGuessingLowerLimit = self.aiGuessedNumber + 1
                                    self.aiGuessedNumber = Int((self.aiGuessingLowerLimit + self.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
                                }, label: {
                                    Text("Too Low")
                                }).accentColor(.red)
                            }
                        }
                        .animation(.default)
                        .frame(minWidth: geo.size.width, minHeight: geo.size.height)
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @Binding var upperRange: Int
    @Binding var isEditingSettings: Bool
    @State var pendingUpperRange: Int
    
    var body: some View {
        VStack {
            Picker(selection: $pendingUpperRange, label: Text("Upper Range")) {
                ForEach([9, 99, 255, 999], id: \.self) { upper in
                    Text("\(upper)")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                }
            }
            
            Button(action: {
                self.isEditingSettings = false
                self.upperRange = self.pendingUpperRange
                UserDefaults.standard.set(self.pendingUpperRange, forKey: "userSetUpperRange")
            }, label: {
                Text("Done")
            })
        }
    }
}

struct ContentView: View {
    @State var upperRange = setUpperRange
    @State var userGuessingCorrectNumber = 0
    @State var userGuessedNumber = 0
    @State var userGuessedTimes = 0
    @State var aiGuessingLowerLimit = 0
    @State var aiGuessingUpperLimit = setUpperRange
    @State var aiGuessedNumber = Int((0 + setUpperRange + Int.random(in: 0 ... 1)) / 2)
    @State var aiGuessedTimes = 0
    @State var isUserGuessing = false
    @State var isAiGuessing = false
    @State var isEditingSettings = false
    @State var showCompareResult = false
    @State var hasAiWon = false
    
    private func resetUserGuessing() {
        self.userGuessingCorrectNumber = Int.random(in: 0 ..< self.upperRange + 1)
        self.userGuessedNumber = -1
        self.userGuessedTimes = 0
    }
    
    private func resetAiGuessing() {
        self.aiGuessingLowerLimit = 0
        self.aiGuessingUpperLimit = self.upperRange
        self.aiGuessedNumber = Int((self.aiGuessingLowerLimit + self.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
        self.aiGuessedTimes = 0
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: UserGuessingView(upperRange: $upperRange, userGuessedNumber: $userGuessedNumber, userGuessedTimes: $userGuessedTimes, showCompareResult: $showCompareResult), isActive: $isUserGuessing, label: {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .imageScale(.large)
                    Text("Let Me Guess")
                }
            }).simultaneousGesture(TapGesture().onEnded{
                self.resetUserGuessing()
            }).alert(isPresented: $showCompareResult, content: {
                if self.userGuessedNumber == self.userGuessingCorrectNumber {
                    return Alert(title: Text("Congratulations"), message: Text("You get the number (\(self.userGuessingCorrectNumber)) in \(self.userGuessedTimes) \(self.userGuessedTimes == 1 ? "try" : "tries")!"), primaryButton: .cancel(Text("Home"), action: {
                            self.isUserGuessing = false
                        }), secondaryButton: .default(Text("Restart"), action: {
                            self.resetUserGuessing()
                        }))
                } else {
                     return Alert(title: Text("Try \(self.userGuessedNumber > self.userGuessingCorrectNumber ? "lower" : "higher")"), message: Text("Trial: \(self.userGuessedTimes)"))
                }
            })
            
            NavigationLink(destination: AiGuessingView(upperRange: $upperRange, aiGuessingLowerLimit: $aiGuessingLowerLimit, aiGuessingUpperLimit: $aiGuessingUpperLimit, aiGuessedNumber: $aiGuessedNumber, aiGuessedTimes: $aiGuessedTimes, hasAiWon: $hasAiWon), isActive: $isAiGuessing, label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .imageScale(.large)
                    Text("Let AI Guess")
                }
            }).simultaneousGesture(TapGesture().onEnded{
                self.resetAiGuessing()
            }).alert(isPresented: $hasAiWon, content: {
                Alert(title: Text("Hurray"), message: Text("AI gets the number (\(self.aiGuessedNumber)) in \(self.aiGuessedTimes) \(self.aiGuessedTimes == 1 ? "try" : "tries")!"), primaryButton: .cancel(Text("Home"), action: {
                        self.isAiGuessing = false
                    }), secondaryButton: .default(Text("Restart"), action: {
                        self.resetAiGuessing()
                    }))
            })
            
            NavigationLink(destination: SettingsView(upperRange: $upperRange, isEditingSettings: $isEditingSettings, pendingUpperRange: self.upperRange), isActive: $isEditingSettings, label: {
                HStack {
                    Image(systemName: "gear")
                        .imageScale(.large)
                    Text("Settings")
                }
            })
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
