//
//  ContentView.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import SwiftUI

extension Int {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: self as NSNumber)!
    }
}

extension View {
    func scaleToFitLine(_ lineLimit: Int? = 1) -> some View {
        self
            .scaledToFit()
            .minimumScaleFactor(0.001)
            .lineLimit(lineLimit ?? 1)
    }
}

struct UserGuessingView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        VStack {
            if self.data.userGuessedNumber == -1 {
                Spacer()
                
                Text(self.data.upperRange <= 1023 ? "Guess a number between 0 and \(self.data.upperRange.formatted())" : "Set the upper range lower than \(1024.formatted()) to play")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Spacer()
                
                if self.data.upperRange <= 1023 {
                    Button(action: {
                        withAnimation {
                            self.data.userGuessedNumber = 0
                        }
                    }, label: {
                        Text("Ready")
                    })
                } else {
                    Button(action: {
                        self.data.isUserGuessing = false
                    }, label: {
                        Text("OK")
                    })
                }
            } else {
                Picker(selection: self.$data.userGuessedNumber, label: EmptyView()) {
                    ForEach(0 ..< self.data.upperRange + 1) { index in
                        Text(index.formatted())
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .scaleToFitLine()
                    }
                }
                
                Button(action: {
                    self.data.showCompareResult = true
                    self.data.userGuessedTimes += 1
                    self.data.userLastCheckedNumber = self.data.userGuessedNumber
                }, label: {
                    Text("Confirm")
                })
            }
        }.navigationBarTitle(Text("Let Me Guess"))
        .alert(isPresented: self.$data.showCompareResult, content: {
            if self.data.userGuessedNumber == self.data.userGuessingCorrectNumber && self.data.userLastCheckedNumber == self.data.userGuessedNumber {
                return Alert(title: Text("Yay"), message: Text("You get the number (\(self.data.userGuessingCorrectNumber.formatted())) in \(self.data.userGuessedTimes.formatted()) \(self.data.userGuessedTimes, specifier: "%d")!"), primaryButton: .default(Text("Quit"), action: {
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
                    if self.data.userLastCheckedNumber == self.data.userGuessedNumber {
                        self.data.userLastCheckedNumber = -1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.data.showCompareResult = true
                        }
                    }
                }))
            } else {
                return Alert(title: Text(self.data.userGuessedNumber > self.data.userGuessingCorrectNumber ? "Try lower" : "Try higher"), message: Text("Trial: \(self.data.userGuessedTimes.formatted())"), dismissButton: .default(Text("OK"), action: {
                    self.data.userLastCheckedNumber = -1
                }))
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
                
                Text("Choose a number between 0 and \(self.data.upperRange.formatted())")
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
                            Spacer()
                            
                            Text(self.data.aiGuessingLowerLimit == self.data.aiGuessingUpperLimit ? "It is \(self.data.aiGuessedNumber.formatted())!" : "Is it \(self.data.aiGuessedNumber.formatted())?")
                                .scaleToFitLine()

                            Spacer()
                            
                            VStack(spacing: 5) {
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
            Alert(title: Text("Hurray"), message: Text("AI gets the number (\(self.data.aiGuessedNumber.formatted())) in \(self.data.aiGuessedTimes.formatted()) \(self.data.aiGuessedTimes, specifier: "%d")!"), primaryButton: .default(Text("Quit"), action: {
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
        VStack(spacing: 5) {
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
            
            Text(self.data.randomNumber.formatted())
                .font(.system(.largeTitle, design: .rounded))
                .scaleToFitLine()
            
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
                    
                    Text(self.data.usingHex ? "#\(String(format: "%02X", self.data.randomR))\(String(format: "%02X", self.data.randomG))\(String(format: "%02X", self.data.randomB))" : "(\(self.data.randomR), \(self.data.randomG), \(self.data.randomB))")
                        .foregroundColor(isColorTooBright() ? .black : .white)
                        .animation(nil)
                }
            }).buttonStyle(PlainButtonStyle())
            
            Button(action: {
                withAnimation {
                    self.data.resetRandomColor()
                }
            }, label: {
                Text("Randomize")
            })
        }.navigationBarTitle(Text("Color"))
    }
}

struct RandomBooleanView: View {
    @EnvironmentObject var data: GuessData
    @Environment(\.locale) var locale: Locale
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text(self.data.randomDouble >= 0 ? "True" : "False")
                
                Image(systemName: self.data.randomDouble >= 0 ? (locale.languageCode == "ja" ? "circle" : "checkmark") : "xmark")
            }
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(self.data.randomDouble >= 0 ? (locale.languageCode == "ja" ? .red : .green) : (locale.languageCode == "ja" ? .blue : .red))
            
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
                if self.data.upperRange < 10000 {
                    HStack {
                        Text("Upper Range for Numbers")
                        
                        Spacer()
                        
                        Text(self.data.upperRange.formatted())
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Upper Range for Numbers")
                        
                        Text(self.data.upperRange.formatted())
                            .foregroundColor(.gray)
                    }
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
                        .font(.system(.headline, design: .rounded))
                        .scaleToFitLine()
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
        GeometryReader { geo in
            VStack(spacing: 3) {
                Text("\(self.pendingUpperRange.formatted())")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .frame(width: geo.size.width, height: (geo.size.height - 12) / 5)
                    .scaleToFitLine()
                    .simultaneousGesture(DragGesture().onEnded({ value in
                        if value.translation.width < 0 {
                            self.pendingUpperRange /= 10
                        }
                    }))
                
                ForEach(0 ..< 3) { row in
                    HStack(spacing: 3) {
                        ForEach(0 ..< 3) { col in
                            Button(action: {
                                if !(self.pendingUpperRange >= 100000000) {
                                    self.pendingUpperRange *= 10
                                    self.pendingUpperRange += (row * 3 + col + 1)
                                }
                            }, label: {
                                Text("\((row * 3 + col + 1).formatted())")
                            })
                                .opacity(self.pendingUpperRange >= 100000000 ? 0.5 : 1)
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: (geo.size.width - 6) / 3, height: (geo.size.height - 12) / 5)
                                .background(Color(red: 34.0 / 255.0, green: 34.0 / 255.0, blue: 35.0 / 255.0))
                                .cornerRadius(5)
                        }
                    }
                }
                
                HStack(spacing: 3) {
                    Button(action: {
                        if self.pendingUpperRange <= 1023 {
                            self.data.resetUpperRange(self.pendingUpperRange)
                            self.data.isEditingUpperRange = false
                            UserDefaults.standard.set(self.pendingUpperRange, forKey: "userSetUpperRange")
                        } else {
                            self.data.warnUpperRange = true
                        }
                    }, label: {
                        Text(verbatim: "OK")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.green)
                    })
                        .disabled(self.pendingUpperRange == 0)
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: (geo.size.width - 6) / 3, height: (geo.size.height - 12) / 5)
                        .alert(isPresented: self.$data.warnUpperRange, content: {
                            Alert(title: Text("“Let Me Guess” only supports numbers lower than \(1024.formatted())"), primaryButton: .cancel(Text("OK"), action: {
                                self.data.resetUpperRange(self.pendingUpperRange)
                                self.data.isEditingUpperRange = false
                                UserDefaults.standard.set(self.pendingUpperRange, forKey: "userSetUpperRange")
                            }), secondaryButton: .cancel())
                        })
                    
                    Button(action: {
                        if !(self.pendingUpperRange >= 100000000 || self.pendingUpperRange == 0) {
                            self.pendingUpperRange *= 10
                        }
                    }, label: {
                        Text("\(0.formatted())")
                    })
                        .opacity(self.pendingUpperRange >= 100000000 || self.pendingUpperRange == 0 ? 0.5 : 1)
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: (geo.size.width - 6) / 3, height: (geo.size.height - 12) / 5)
                        .background(Color(red: 34.0 / 255.0, green: 34.0 / 255.0, blue: 35.0 / 255.0))
                        .cornerRadius(5)
                    
                    Button(action: {
                        self.pendingUpperRange /= 10
                    }, label: {
                        Image(systemName: "delete.left.fill")
                            .foregroundColor(.red)
                    })
                        .disabled(self.pendingUpperRange == 0)
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                            self.pendingUpperRange = 0
                        }))
                        .frame(width: (geo.size.width - 6) / 3, height: (geo.size.height - 12) / 5)
                }
            }.navigationBarTitle(Text("Upper Range"))
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var data: GuessData
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 5) {
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
