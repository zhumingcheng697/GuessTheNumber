//
//  ContentView.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import SwiftUI

func formatNumber(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: number as NSNumber)!
}

struct UserGuessingView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack {
            if self.data.userGuessedNumber == -1 {
                Spacer()
                
                Text("Guess a number between 0 and \(formatNumber(self.data.upperRange))")
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
                    ForEach(0 ..< self.data.upperRange + 1) { index in
                        Text(formatNumber(index))
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                    }
                }
                
                Button(action: {
                    self.data.showCompareResult = true
                    self.data.userGuessedTimes += 1
                }, label: {
                    Text("Confirm")
                })
            }
        }.navigationBarTitle(Text("Let Me Guess"))
        .alert(isPresented: self.$data.showCompareResult, content: {
            if self.data.userGuessedNumber == self.data.userGuessingCorrectNumber {
                return Alert(title: Text("Yay"), message: Text("You get the number (\(formatNumber(self.data.userGuessingCorrectNumber))) in \(formatNumber(self.data.userGuessedTimes)) \(self.data.userGuessedTimes, specifier: "%d")!"), primaryButton: .default(Text("Quit"), action: {
                    if self.data.askWhenUserGuessing {
                        self.data.autoRedirect()
                        self.data.askWhenUserGuessing = false
                    } else {
                        self.data.isUserGuessing = false
                    }
                }), secondaryButton: .default(Text("Restart"), action: {
                    self.data.resetUserGuessing()
                    self.data.askWhenUserGuessing = false
                }))
            } else if self.data.askWhenUserGuessing {
                return Alert(title: Text("You have an unfinished game"), primaryButton: .default(Text("Quit"), action: {
                    self.data.autoRedirect()
                    self.data.askWhenUserGuessing = false
                }), secondaryButton: .default(Text("Resume"), action: {
                    self.data.askWhenUserGuessing = false
                }))
            } else {
                 return Alert(title: Text(self.data.userGuessedNumber > self.data.userGuessingCorrectNumber ? "Try lower" : "Try higher"), message: Text("Trial: \(formatNumber(self.data.userGuessedTimes))"))
            }
        })
    }
}

struct AiGuessingView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack(alignment: .center) {
            if self.data.aiGuessedTimes == 0 {
                Spacer()
                
                Text("Choose a number between 0 and \(formatNumber(self.data.upperRange))")
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
                            
                            Text(self.data.aiGuessingLowerLimit == self.data.aiGuessingUpperLimit ? "It is \(formatNumber(self.data.aiGuessedNumber))!" : "Is it \(formatNumber(self.data.aiGuessedNumber))?")

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
                        .alert(isPresented: self.$data.askWhenAiGuessing, content: {
                            Alert(title: Text("You have an unfinished game"), primaryButton: .default(Text("Quit"), action: {
                                self.data.autoRedirect()
                            }), secondaryButton: .default(Text("Resume")))
                        })
                    }
                }
            }
        }.navigationBarTitle(Text("Let AI Guess"))
        .alert(isPresented: self.$data.hasAiWon, content: {
            Alert(title: Text("Hurray"), message: Text("AI gets the number (\(formatNumber(self.data.aiGuessedNumber))) in \(formatNumber(self.data.aiGuessedTimes)) \(self.data.aiGuessedTimes, specifier: "%d")!"), primaryButton: .default(Text("Quit"), action: {
                if self.data.askWhenAiGuessing {
                    self.data.autoRedirect()
                    self.data.askWhenAiGuessing = false
                } else {
                    self.data.isAiGuessing = false
                }
            }), secondaryButton: .default(Text("Restart"), action: {
                self.data.resetAiGuessing()
                self.data.askWhenAiGuessing = false
            }))
        })
    }
}

struct RandomizerView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack {
            NavigationLink(destination: RandomNumberView(), isActive: self.$data.isRandomizingNumber, label: {
                HStack {
                    Image(systemName: "textformat.123")
                        .imageScale(.large)
                    Text("Number")
                }
            }).simultaneousGesture(TapGesture().onEnded{
                self.data.resetRandomNumber()
            })
            
            NavigationLink(destination: RandomColorView(), isActive: self.$data.isRandomizingColor, label: {
                HStack {
                    Image(systemName: "paintbrush")
                        .imageScale(.large)
                    Text("Color")
                }
            }).simultaneousGesture(TapGesture().onEnded{
                self.data.resetRandomColor()
            })
            
            NavigationLink(destination: RandomBooleanView(), isActive: self.$data.isRandomizingBoolean, label: {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                    Text("Boolean")
                }
            }).simultaneousGesture(TapGesture().onEnded{
                self.data.resetRandomBoolean()
            })
        }.navigationBarTitle(Text("Randomizer"))
    }
}

struct RandomNumberView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(formatNumber(self.data.randomNumber))
                .font(.system(.largeTitle, design: .rounded))
            
            Spacer()
            
            Button(action: {
                self.data.resetRandomNumber()
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Number"))
    }
}

struct RandomColorView: View {
    @EnvironmentObject var data: GuessData
    
    func isColorTooBright() -> Bool {
        let maxC = [self.data.randomR, self.data.randomG, self.data.randomB].max()!
        let minC = [self.data.randomR, self.data.randomG, self.data.randomB].min()!
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
                        .foregroundColor(Color(red: Double(self.data.randomR) / 255.0, green: Double(self.data.randomG) / 255.0, blue: Double(self.data.randomB) / 255.0))
                        .cornerRadius(8)
                        .animation(.default)
                    
                    Text(self.data.usingHex ? "#\(String(format: "%02X", self.data.randomR))\(String(format: "%02X", self.data.randomG))\(String(format: "%02X", self.data.randomB))" : "(\(self.data.randomR), \(self.data.randomG), \(self.data.randomB))")
                        .foregroundColor(isColorTooBright() ? .black : .white)
                }
            }).buttonStyle(PlainButtonStyle())
            
            Button(action: {
                self.data.resetRandomColor()
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Color"))
    }
}

struct RandomBooleanView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text(self.data.randomDouble >= 0 ? "True" : "False")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundColor(self.data.randomDouble >= 0 ? .green : .red)
                
                Image(systemName: self.data.randomDouble >= 0 ? "checkmark" : "xmark")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundColor(self.data.randomDouble >= 0 ? .green : .red)
            }
            
            Spacer()
            
            Button(action: {
                self.data.resetRandomBoolean()
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
            NavigationLink(destination: QuickActionSettingsView(pendingQuickAction: self.data.quickAction), isActive: self.$data.isEditingQuickAction, label: {
                VStack(alignment: .leading) {
                    Text("Quick Action")
                    
                    Text(LocalizedStringKey(self.data.quickAction.rawValue))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            })
                .padding(.vertical)
            
            NavigationLink(destination: UpperRangeSettingsView(pendingUpperRange: self.data.upperRange), isActive: self.$data.isEditingUpperRange, label: {
                HStack {
                    Text("Upper Range for Numbers")
                    
                    Spacer()
                    
                    Text(formatNumber(self.data.upperRange))
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

struct QuickActionSettingsView: View {
    @EnvironmentObject var data: GuessData
    @State var pendingQuickAction: GuessData.QuickAction
    
    var body: some View {
        VStack {
            Picker(selection: self.$pendingQuickAction, label: EmptyView()) {
                ForEach(GuessData.QuickAction.allCases, id: \.self) { menu in
                    Text(LocalizedStringKey(menu.rawValue)).tag(menu)
                        .font(.system(Font.TextStyle.headline, design: Font.Design.rounded))
                    .lineLimit(nil)
                }
            }
            
            Button(action: {
                self.data.isEditingQuickAction = false
                self.data.quickAction = self.pendingQuickAction
                UserDefaults.standard.set(self.pendingQuickAction.rawValue, forKey: "userSetQuickAction")
            }, label: {
                Text("Done")
            })
        }.navigationBarTitle(Text("Quick Action"))
    }
}

struct UpperRangeSettingsView: View {
    @EnvironmentObject var data: GuessData
    @State var pendingUpperRange: Int
    
    var body: some View {
        VStack {
            Picker(selection: $pendingUpperRange, label: EmptyView()) {
                ForEach([9, 99, 255, 999, 1023], id: \.self) { upper in
                    Text(formatNumber(upper))
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                }
            }
            
            Button(action: {
                self.data.resetUpperRange(self.pendingUpperRange)
                self.data.isEditingUpperRange = false
                UserDefaults.standard.set(self.pendingUpperRange, forKey: "userSetUpperRange")
            }, label: {
                Text("Done")
            })
        }.navigationBarTitle(Text("Upper Range"))
    }
}

struct ContentView: View {
    @EnvironmentObject var data: GuessData
    
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
                        self.data.resetUserGuessing()
                    })
                    
                    NavigationLink(destination: AiGuessingView(), isActive: self.$data.isAiGuessing, label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .imageScale(.large)
                            Text("Let AI Guess")
                        }
                    }).simultaneousGesture(TapGesture().onEnded{
                        self.data.resetAiGuessing()
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
