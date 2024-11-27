//
//  ContentView.swift
//  JsonSwift-Demo
//
//  Created by Denidu Gamage on 2024-10-17.
//

import SwiftUI

struct DataDTO : Codable, Hashable{
    let postId : Int
    let title : String
    let body : String
    
    enum CodingKeys : String, CodingKey{
        case postId = "id"
        case title
        case body
    }
}

struct ContentView: View {
    
    @State var data : [DataDTO] = []
    @State var isLoading : Bool = true
    
    var body: some View {
        NavigationStack {
            VStack{
                if isLoading{
                    VStack{
                        ProgressView()
                    }
                }else{
                    List(data, id: \.postId){
                        item in
                        VStack{
                            Text("\(item.title)")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Text("\(item.body)")
                                .font(.title2)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("News Feed")
        }
        .refreshable {
            Task{
                await fetchData()
            }
        }
        .onAppear{
            Task{
                await fetchData()
            }
        }
        
        
    }
    
    func fetchData() async{
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        
        guard let unwrappedUrl = url else {return}
        
        do{
            let(data, response) = try await URLSession.shared.data(from: unwrappedUrl)
            
            guard let response = response as? HTTPURLResponse else{
                print("Something Went Wrong")
                return
            }
            
            switch response.statusCode{
            case 200...300:
                let decodeData = try JSONDecoder().decode([DataDTO].self, from: data)
                self.data = decodeData
            case 400...500:
                print("Server Error")
            default:
                print("Something Went Wrong")
            }
            
        }catch{
            print("Something went Wrong. \(error.localizedDescription)")
        }
        self.isLoading = false
    }
}

#Preview {
    ContentView()
}
