//
//  ContentView.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import SwiftUI

struct UserGuessingView: View {
    let upperRange: Int
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
        }.navigationBarTitle(Text("Let Me Guess"))
    }
}

struct AiGuessingView: View {
    let upperRange: Int
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
        }.navigationBarTitle(Text("Let AI Guess"))
    }
}

struct RandomizerView: View {
    let upperRange: Int
    @Binding var usingHex: Bool
    
    var body: some View {
        VStack {
            NavigationLink(destination: RandomNumberView(upperRange: self.upperRange, randomNumber: Int.random(in: 0 ..< self.upperRange + 1)), label: {
                HStack {
                    Image(systemName: "textformat.123")
                        .imageScale(.large)
                    Text("Number")
                }
            })
            
            NavigationLink(destination: RandomColorView(usingHex: self.$usingHex), label: {
                HStack {
                    Image(systemName: "eyedropper")
                        .imageScale(.large)
                    Text("Color")
                }
            })
            
            NavigationLink(destination: RandomBooleanView(), label: {
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
    let upperRange: Int
    @State var randomNumber: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("\(self.randomNumber)")
                .font(.system(.largeTitle, design: .rounded))
            
            Spacer()
            
            Button(action: {
                self.randomNumber = Int.random(in: 0 ..< self.upperRange + 1)
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Number"))
    }
}

struct RandomColorView: View {
    @Binding var usingHex: Bool
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
                self.usingHex.toggle()
                prefersUsingHex.toggle()
                UserDefaults.standard.set(self.usingHex, forKey: "userPrefersUsingHex")
            }, label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(red: Double(self.randomR) / 255.0, green: Double(self.randomG) / 255.0, blue: Double(self.randomB) / 255.0))
                        .cornerRadius(8)
                        .animation(.default)
                    
                    Text(self.usingHex ? "#\(String(format: "%02X", self.randomR))\(String(format: "%02X", self.randomG))\(String(format: "%02X", self.randomB))" : "(\(self.randomR), \(self.randomG), \(self.randomB))")
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
    @Binding var usingHex: Bool
    @Binding var upperRange: Int
    @Binding var isEditingUpperRange: Bool
    
    func setPrefersUsingHex() -> String {
        UserDefaults.standard.set(self.usingHex, forKey: "userPrefersUsingHex")
        return "Use Hex Value for Colors"
    }
    var body: some View {
        List {
            NavigationLink(destination: UpperRangeSettingsView(upperRange: self.$upperRange, isEditingSettings: self.$isEditingUpperRange, pendingUpperRange: self.upperRange), isActive: self.$isEditingUpperRange, label: {
                HStack {
                    Text("Upper Range for Numbers")
                    
                    Spacer()
                    
                    Text("\(String(repeating: "   ", count: max(3 - String(self.upperRange).count, 0)))\(self.upperRange)")
                        .foregroundColor(.gray)
                }
            })
                .padding(.vertical)

            Toggle(isOn: self.$usingHex) {
                Text(setPrefersUsingHex())
            }
                .padding(.vertical)
                .onReceive([self.usingHex].publisher.first()) { _ in
                    UserDefaults.standard.set(self.usingHex, forKey: "userPrefersUsingHex")}
                .onTapGesture(perform: {
                    self.usingHex.toggle()
                    UserDefaults.standard.set(self.usingHex, forKey: "userPrefersUsingHex")
                })
        }.navigationBarTitle(Text("Settings"))
    }
}

struct UpperRangeSettingsView: View {
    @Binding var upperRange: Int
    @Binding var isEditingSettings: Bool
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
                self.isEditingSettings = false
                self.upperRange = self.pendingUpperRange
                UserDefaults.standard.set(self.pendingUpperRange, forKey: "userSetUpperRange")
            }, label: {
                Text("Done")
            })
        }.navigationBarTitle(Text("Upper Range"))
    }
}

struct ContentView: View {
    @State var upperRange = setUpperRange
    @State var usingHex = prefersUsingHex
    @State var userGuessingCorrectNumber = 0
    @State var userGuessedNumber = 0
    @State var userGuessedTimes = 0
    @State var aiGuessingLowerLimit = 0
    @State var aiGuessingUpperLimit = setUpperRange
    @State var aiGuessedNumber = Int((0 + setUpperRange + Int.random(in: 0 ... 1)) / 2)
    @State var aiGuessedTimes = 0
    @State var isUserGuessing = false
    @State var isAiGuessing = false
    @State var isEditingUpperRange = false
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
        GeometryReader { geo in
            ScrollView {
                VStack {
                    NavigationLink(destination: UserGuessingView(upperRange: self.upperRange, userGuessedNumber: self.$userGuessedNumber, userGuessedTimes: self.$userGuessedTimes, showCompareResult: self.$showCompareResult), isActive: self.$isUserGuessing, label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .imageScale(.large)
                            Text("Let Me Guess")
                        }
                    }).simultaneousGesture(TapGesture().onEnded{
                        self.resetUserGuessing()
                    }).alert(isPresented: self.$showCompareResult, content: {
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
                    
                    NavigationLink(destination: AiGuessingView(upperRange: self.upperRange, aiGuessingLowerLimit: self.$aiGuessingLowerLimit, aiGuessingUpperLimit: self.$aiGuessingUpperLimit, aiGuessedNumber: self.$aiGuessedNumber, aiGuessedTimes: self.$aiGuessedTimes, hasAiWon: self.$hasAiWon), isActive: self.$isAiGuessing, label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .imageScale(.large)
                            Text("Let AI Guess")
                        }
                    }).simultaneousGesture(TapGesture().onEnded{
                        self.resetAiGuessing()
                    }).alert(isPresented: self.$hasAiWon, content: {
                        Alert(title: Text("Hurray"), message: Text("AI gets the number (\(self.aiGuessedNumber)) in \(self.aiGuessedTimes) \(self.aiGuessedTimes == 1 ? "try" : "tries")!"), primaryButton: .cancel(Text("Home"), action: {
                                self.isAiGuessing = false
                            }), secondaryButton: .default(Text("Restart"), action: {
                                self.resetAiGuessing()
                            }))
                    })
                    
                    NavigationLink(destination: RandomizerView(upperRange: self.upperRange, usingHex: self.$usingHex), label: {
                        HStack {
                            Image(systemName: "dial.fill")
                                .imageScale(.large)
                            Text("Randomizer")
                        }
                    })
                    
                    NavigationLink(destination: SettingsView(usingHex: self.$usingHex, upperRange: self.$upperRange, isEditingUpperRange: self.$isEditingUpperRange), label: {
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
        ContentView()
    }
}
