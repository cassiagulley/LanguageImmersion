//


import SwiftUI
import RealityKit

struct ContentView : View {
  @StateObject var arController = ViewController()
  
  @State private var showSheet = false
    
    private var handler: (String, NoteColour) -> Void

    internal init(
        handler: @escaping (String, NoteColour) -> Void
    ) {
        self.handler = handler
    }
  
  var body: some View {
    ZStack {
      VStack {
        Spacer()
        VStack {
          Button(action: {
            self.showSheet = true
          }) {
            HStack {
              Image(systemName: "note.text.badge.plus")
                .font(.system(size: 20))
              
              Text("Add Note")
                .font(.headline)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding([.top, .leading, .trailing], 16)
            .padding(.bottom, 8)
          }
          .sheet(isPresented: $showSheet) {
              NoteSheet(handler: self.handler, showSheet: $showSheet)
          }
        }
      }
    }
  }
}
