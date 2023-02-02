//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Bendnaiba on 2/23/23.
//

import SwiftUI
import Journify

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
            Journify.shared().screen(title: "ContentView", properties: ["title": "Growth as a service", "url": "https://journify.io", "path": "/"])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
