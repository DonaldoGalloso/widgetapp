//
//  MyWidget.swift
//  MyWidget
//
//  Created by Luis Donaldo Galloso Tapia on 11/05/23.
//

import WidgetKit
import SwiftUI

// Modelo , donde contendra los campos
struct Modelo :TimelineEntry { // siempre o casi siempre se usa este protocolo
    var date: Date
    var widgetData: [JsonData]
    
}

struct JsonData : Decodable {
    var id : Int
    var name: String
    var email:String
}

// Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Modelo { // nos retorna el propio modelo
        return Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 1))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Modelo) -> Void) {
        completion(Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 1)))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Modelo>) -> Void) {
        //logica principal
        getJson { (modeldata) in
            let data = Modelo(date: Date(), widgetData: modeldata)
            //supongamos que es un api de cambio de dolar
            //actualizar widget
            guard let update = Calendar.current.date(byAdding: .minute,value: 30 ,to: Date()) else {return}
            let timeline = Timeline(entries: [data], policy: .after(update))
            completion(timeline)
        }
        
    }
    
    typealias Entry = Modelo
}

func getJson(completion: @escaping([JsonData]) -> () ){ //vamos a crear nuestro propio completion
    guard let url = URL(string:"https://jsonplaceholder.typicode.com/comments?postId=1") else {return }
    URLSession.shared.dataTask(with: url){data,error,_ in
        guard let data = data else {return}
        do{
            
            let json = try JSONDecoder().decode([JsonData].self, from: data)
            DispatchQueue.main.async {
                completion(json)
            }
            
        }catch let error as NSError{
            print("fallo", error.localizedDescription)
        }
    }.resume()
}

// Diseño - Vista
struct vista: View {
    let entry : Provider.Entry
    @Environment(\.widgetFamily) var family //llamar a los tamaños
    @ViewBuilder
    
    var body: some View{
        switch family {
        case .systemSmall:
            VStack(alignment: .center){
                Text("Mi lista")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                Text(String(entry.widgetData.count)).font(.custom("Arial", size: 80)).bold()
                Spacer()
            }
        case .systemMedium:
            VStack(alignment: .center){
                Text("Mi lista")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading){
                    Text(entry.widgetData[0].name).bold()
                    Text(entry.widgetData[0].email).bold()
                    
                }.padding(.leading)
                Spacer()
            }
        default:
            VStack(alignment: .center){
                Text("Mi lista")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading){
                    ForEach(entry.widgetData,id: \.id){ item in
                        Text(item.name).bold()
                        Text(item.email)
                    }
                }.padding(.leading)
                Spacer()
            }
        }
    }
}

//configuración

struct Hello : Widget {
    var body: some WidgetConfiguration{
        StaticConfiguration(kind: "widget", provider: Provider()){ entry in
            vista(entry: entry)
        }.description("Descripcion del widget")
        .configurationDisplayName("Nombre widget")
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
        
    }
}
