//
//  ContentView.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import SwiftUI

struct UserGuessingView: View {
    @EnvironmentObject var data: GuessData
    
    private func resetUserGuessing() {
        self.data.userGuessingCorrectNumber = Int.random(in: 0 ..< self.data.upperRange + 1)
        self.data.userGuessedNumber = -1
        self.data.userGuessedTimes = 0
    }
    
    var body: some View {
        VStack {
            if self.data.userGuessedNumber == -1 {
                Spacer()
                
                Text("Guess a number between 0 and \(Int(self.data.upperRange))")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Spacer()
                
                Button(action: {
                    withAnimation {
                        self.data.userGuessedNumber = 0
                    }
                }, label: {
                    Text("Ready")
                })
            } else {
                Picker(selection: self.$data.userGuessedNumber, label: EmptyView()) {
                    ForEach(0 ..< Int(self.data.upperRange) + 1) { index in
                        Text("\(index)")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                    }
                }
                
                Button(action: {
                    self.data.showCompareResult = true
                    self.data.userGuessedTimes += 1
                }, label: {
                    Text("Comfirm")
                })
            }
        }.navigationBarTitle(Text("Let Me Guess"))
        .alert(isPresented: self.$data.showCompareResult, content: {
            if self.data.userGuessedNumber == self.data.userGuessingCorrectNumber {
                return Alert(title: Text("Yay"), message: Text("You get the number (\(self.data.userGuessingCorrectNumber)) in \(self.data.userGuessedTimes) \(self.data.userGuessedTimes == 1 ? "try" : "tries")!"), primaryButton: .cancel(Text("Home"), action: {
                        self.data.isUserGuessing = false
                    }), secondaryButton: .default(Text("Restart"), action: {
                        self.resetUserGuessing()
                    }))
            } else {
                 return Alert(title: Text("Try \(self.data.userGuessedNumber > self.data.userGuessingCorrectNumber ? "lower" : "higher")"), message: Text("Trial: \(self.data.userGuessedTimes)"))
            }
        })
    }
}

struct AiGuessingView: View {
    @EnvironmentObject var data: GuessData
    
    private func resetAiGuessing() {
        self.data.aiGuessingLowerLimit = 0
        self.data.aiGuessingUpperLimit = self.data.upperRange
        self.data.aiGuessedNumber = Int((self.data.aiGuessingLowerLimit + self.data.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
        self.data.aiGuessedTimes = 0
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if self.data.aiGuessedTimes == 0 {
                Spacer()
                
                Text("Choose a number between 0 and \(Int(self.data.upperRange))")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Spacer()
                
                Button(action: {
                    withAnimation {
                        self.data.aiGuessedTimes += 1
                    }
                }, label: {
                    Text("Ready")
                })
            } else {
                GeometryReader { geo in
                    ScrollView {
                        VStack(alignment: .center) {
                            if self.data.aiGuessingLowerLimit == self.data.aiGuessedNumber || self.data.aiGuessingUpperLimit == self.data.aiGuessedNumber {
                                Spacer()
                            }
                            
                            Text(self.data.aiGuessingLowerLimit == self.data.aiGuessingUpperLimit ? "\(String(repeating: " ", count: max(8 - String(self.data.aiGuessedNumber).count, 0)))It is \(self.data.aiGuessedNumber)!\(String(repeating: " ", count: max(8 - String(self.data.aiGuessedNumber).count, 0)))" : "\(String(repeating: " ", count: max(8 - String(self.data.aiGuessedNumber).count, 0)))Is it \(self.data.aiGuessedNumber)?\(String(repeating: " ", count: max(8 - String(self.data.aiGuessedNumber).count, 0)))")

                            Spacer()
                            
                            Button(action: {
                                self.data.hasAiWon = true
                            }, label: {
                                Text("Correct")
                            })
                                .accentColor(.green)
                        
                            if self.data.aiGuessingLowerLimit != self.data.aiGuessedNumber {
                                Button(action: {
                                    self.data.aiGuessedTimes += 1
                                    self.data.aiGuessingUpperLimit = self.data.aiGuessedNumber - 1
                                    self.data.aiGuessedNumber = Int((self.data.aiGuessingLowerLimit + self.data.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
                                }, label: {
                                    Text("Too High")
                                }).accentColor(.red)
                            }
                            
                            if self.data.aiGuessingUpperLimit != self.data.aiGuessedNumber {
                                Button(action: {
                                    self.data.aiGuessedTimes += 1
                                    self.data.aiGuessingLowerLimit = self.data.aiGuessedNumber + 1
                                    self.data.aiGuessedNumber = Int((self.data.aiGuessingLowerLimit + self.data.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
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
        }.navigationBarTitle(Text("Let AI Guess"))
        .alert(isPresented: self.$data.hasAiWon, content: {
            Alert(title: Text("Hurray"), message: Text("AI gets the number (\(self.data.aiGuessedNumber)) in \(self.data.aiGuessedTimes) \(self.data.aiGuessedTimes == 1 ? "try" : "tries")!"), primaryButton: .cancel(Text("Home"), action: {
                    self.data.isAiGuessing = false
                }), secondaryButton: .default(Text("Restart"), action: {
                    self.resetAiGuessing()
                }))
        })
    }
}

struct RandomizerView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack {
            NavigationLink(destination: RandomNumberView(randomNumber: Int.random(in: 0 ..< self.data.upperRange + 1)), isActive: self.$data.isRandomizingNumber, label: {
                HStack {
                    Image(systemName: "textformat.123")
                        .imageScale(.large)
                    Text("Number")
                }
            })
            
            NavigationLink(destination: RandomColorView(), isActive: self.$data.isRandomizingColor, label: {
                HStack {
                    Image(systemName: "eyedropper")
                        .imageScale(.large)
                    Text("Color")
                }
            })
            
            NavigationLink(destination: RandomBooleanView(), isActive: self.$data.isRandomizingBoolean, label: {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                    Text("Boolean")
                }
            })
        }.navigationBarTitle(Text("Randomizer"))
    }
}

struct RandomNumberView: View {
    @EnvironmentObject var data: GuessData
    @State var randomNumber: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("\(self.randomNumber)")
                .font(.system(.largeTitle, design: .rounded))
            
            Spacer()
            
            Button(action: {
                self.randomNumber = Int.random(in: 0 ..< self.data.upperRange + 1)
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Number"))
    }
}

struct RandomColorView: View {
    @EnvironmentObject var data: GuessData
    @State var randomR = Int.random(in: 0 ..< 256)
    @State var randomG = Int.random(in: 0 ..< 256)
    @State var randomB = Int.random(in: 0 ..< 256)
    
    func isColorTooBright() -> Bool {
        let maxC = [self.randomR, self.randomG, self.randomB].max()!
        let minC = [self.randomR, self.randomG, self.randomB].min()!
        return Double(maxC + minC) / 2 / 255 >= 0.53
    }
    
    var body: some View {
        VStack {
            Button(action: {
                self.data.usingHex.toggle()
                UserDefaults.standard.set(self.data.usingHex, forKey: "userPrefersUsingHex")
            }, label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(red: Double(self.randomR) / 255.0, green: Double(self.randomG) / 255.0, blue: Double(self.randomB) / 255.0))
                        .cornerRadius(8)
                        .animation(.default)
                    
                    Text(self.data.usingHex ? "#\(String(format: "%02X", self.randomR))\(String(format: "%02X", self.randomG))\(String(format: "%02X", self.randomB))" : "(\(self.randomR), \(self.randomG), \(self.randomB))")
                        .foregroundColor(isColorTooBright() ? .black : .white)
                }
            }).buttonStyle(PlainButtonStyle())
            
            Button(action: {
                self.randomR = Int.random(in: 0 ..< 256)
                self.randomG = Int.random(in: 0 ..< 256)
                self.randomB = Int.random(in: 0 ..< 256)
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Color"))
    }
}

struct RandomBooleanView: View {
    @State var randomDouble = Double.random(in: -10.0 ... 10.0)
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text("\(randomDouble >= 0 ? "True" : "False")")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundColor(randomDouble >= 0 ? .green : .red)
                
                Image(systemName: "\(randomDouble >= 0 ? "checkmark" : "xmark")")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundColor(randomDouble >= 0 ? .green : .red)
            }
            
            Spacer()
            
            Button(action: {
                self.randomDouble = Double.random(in: -10.0 ... 10.0)
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Boolean"))
    }
}

struct SettingsView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        List {
            NavigationLink(destination: UpperRangeSettingsView(pendingUpperRange: self.data.upperRange), isActive: self.$data.isEditingUpperRange, label: {
                HStack {
                    Text("Upper Range for Numbers")
                    
                    Spacer()
                    
                    Text("\(String(repeating: "   ", count: max(3 - String(self.data.upperRange).count, 0)))\(self.data.upperRange)")
                        .foregroundColor(.gray)
                }
            })
                .padding(.vertical)

            Toggle(isOn: self.$data.usingHex) {
                Text("Use Hex Value for Colors")
            }
                .padding(.vertical)
                .onReceive([self.data.usingHex].publisher.first()) { _ in
                    UserDefaults.standard.set(self.data.usingHex, forKey: "userPrefersUsingHex")}
                .onTapGesture(perform: {
                    self.data.usingHex.toggle()
                    UserDefaults.standard.set(self.data.usingHex, forKey: "userPrefersUsingHex")
                })
        }.navigationBarTitle(Text("Settings"))
    }
}

struct UpperRangeSettingsView: View {
    @EnvironmentObject var data: GuessData
    @State var pendingUpperRange: Int
    
    var body: some View {
        VStack {
            Picker(selection: $pendingUpperRange, label: EmptyView()) {
                ForEach([9, 99, 255, 999, 1023], id: \.self) { upper in
                    Text("\(upper)")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                }
            }
            
            Button(action: {
                self.data.isEditingUpperRange = false
                self.data.upperRange = self.pendingUpperRange
                UserDefaults.standard.set(self.pendingUpperRange, forKey: "userSetUpperRange")
            }, label: {
                Text("Done")
            })
        }.navigationBarTitle(Text("Upper Range"))
    }
}

struct ContentView: View {
    @EnvironmentObject var data: GuessData
    
    private func resetUserGuessing() {
        self.data.userGuessingCorrectNumber = Int.random(in: 0 ..< self.data.upperRange + 1)
        self.data.userGuessedNumber = -1
        self.data.userGuessedTimes = 0
    }
    
    private func resetAiGuessing() {
        self.data.aiGuessingLowerLimit = 0
        self.data.aiGuessingUpperLimit = self.data.upperRange
        self.data.aiGuessedNumber = Int((self.data.aiGuessingLowerLimit + self.data.aiGuessingUpperLimit + Int.random(in: 0 ... 1)) / 2)
        self.data.aiGuessedTimes = 0
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    NavigationLink(destination: UserGuessingView(), isActive: self.$data.isUserGuessing, label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .imageScale(.large)
                            Text("Let Me Guess")
                        }
                    }).simultaneousGesture(TapGesture().onEnded{
                        self.resetUserGuessing()
                    })
                    
                    NavigationLink(destination: AiGuessingView(), isActive: self.$data.isAiGuessing, label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .imageScale(.large)
                            Text("Let AI Guess")
                        }
                    }).simultaneousGesture(TapGesture().onEnded{
                        self.resetAiGuessing()
                    })
                    
                    NavigationLink(destination: RandomizerView(), isActive: self.$data.isInRandomizer, label: {
                        HStack {
                            Image(systemName: "dial.fill")
                                .imageScale(.large)
                            Text("Randomizer")
                        }
                    })
                    
                    NavigationLink(destination: SettingsView(), isActive: self.$data.isInSettings, label: {
                        HStack {
                            Image(systemName: "gear")
                                .imageScale(.large)
                            Text("Settings")
                        }
                    })
                }
                    .frame(minHeight: geo.size.height)
                    .navigationBarTitle(Text("Guess"))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(guessData)
    }
}
