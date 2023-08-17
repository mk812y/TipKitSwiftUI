//
//  ContentView.swift
//  TipKitSwiftUI
//
//  Created by Михаил Куприянов on 17.8.23..
//

import SwiftUI
import TipKit

struct ContentView: View {
    private let myTip = FavoriteBackyardTip()
    private let edge: Edge = .top
    private let edgeLeading: Edge = .leading
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TipView(
                myTip,
                arrowEdge: edge,
                action: actionHandler
            )
            Text("Hello, world!")
                .popoverTip(
                    myTip,
                    arrowEdge: edgeLeading,
                    action: actionHandler
                )
        }
        .onAppear {//для демонстрации Rule вызовем event с donate и передадим параметры если они есть у event
            simpleEvent.donate()
            complexEvent.donate(
                .init(id: 123, name: "name")
            )
        }
        .padding()
    }
    
    func actionHandler(action: Tip.Action) {
        debugPrint("button tapped \(action.id)")
    }
}

#Preview {
    ContentView()
        .task {
            //Tips.configure(options:) должен быть вызван до того, как ваш Tip будет допущен к отображению.
            try? await Tips.configure {
                //The frequency your tips display. immediate, hourly, daily, weekly, monthly or custom Timeinterval
                DisplayFrequency(.immediate)
                //A location for persisting your application's tips and associated data.
                DatastoreLocation(.applicationDefault)
            }
            //скроет или покажет при запуске приложения
            Tips.showAllTips()
            //Tips.hideAllTips()
//            Tips.showTips([FavoriteBackyardTip.self])
//            Tips.hideTips([FavoriteBackyardTip.self])
        }
}

struct User {
    //набор параметров пользователя для var rules: [Rule]
    @Parameter
    static var isLoggedIn: Bool = false
}

struct FavoriteBackyardTip: Tip {
    var title: Text { //единственно обязательное условие
        Text("заголовок подсказки")
    }
    var message: Text? {
        Text("описание подсказки")
    }
    var actions: [Action] {
        [
            Tip.Action(
                id: "buttonOne",//по ид можно отследить нажатие конкретной кнопки
                title: "ButtonOne"
            ),
            Tip.Action(
                id: "buttonTwo",
                title: "ButtonTwo"
            )
        ]
    }
    var options: [TipOption] {//можно описать условия появления подсказок
        [
            IgnoresDisplayFrequency(true),//игнорировать ли предварительно настроенну частоту показа подсказки? (в Tips.configure DisplayFrequency(.immediate))
            MaxDisplayCount(1) //максимальное количество показов подсказки, прежде чем система автоматически аннулирует ее
        ]
    }
    
    var rules: [Rule] { //массив шаблонов условий/правил показа подсказок
        //если пользователь залогинен
        #Rule(User.$isLoggedIn) { $0 == true }
        //если simpleEvent был donate больше 3 или более за неделю
        #Rule(simpleEvent) {
            $0.donations.donatedWithin(.week).count >= 3
        }
        //если complexEvent был donate больше 3 за неделю для name != "Timmy"
        #Rule(complexEvent) {
            $0.donations.filter({
                $0.name != "Timmy"
            }).count > 3
        }
    }
}

//для демонстрации работы simpleEvent в var rules: [Rule]
let simpleEvent = Tips.Event(id: "simpleEvent")

struct EventData: Codable, Sendable {
    let id: Int
    let name: String
}

//для демонстрации работы simpleEvent в var rules: [Rule]
let complexEvent = Tips.Event<EventData>(id: "complexEvent")
