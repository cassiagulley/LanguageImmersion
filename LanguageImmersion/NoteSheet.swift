//
//

import SwiftUI

enum SheetAction: String {
  case add = "Add Note", edit = "Edit Note"
}

enum NoteColour: String, CodingKey {
  case yellow = "yellow", pink = "pink", green = "green"
}

struct NoteSheet: View {
    @Binding var showSheet: Bool
    @State private var noteColour: NoteColour
    @State private var text: String
    var size: CGFloat = 36
    var mode: SheetAction = .add
    
    private var handler: (String, NoteColour) -> Void
//    defined constructor
    internal init(
        // function handle for adding sticky note
        handler: @escaping (String, NoteColour) -> Void,
        showSheet: Binding<Bool>
    ) {
            
        // assign function handle locally so we can use it later
        self.handler = handler
        
        self.noteColour = .yellow
        
        self.text = ""
        self.size = 36
        self.mode = .add
        self._showSheet = showSheet
    }
  

  
  var body: some View {
    NavigationView {
      Form {
        TextField("Note Contents", text: $text)
          
        Section(header: Text("Note Colour")) {
          HStack(spacing: 16) {
            Circle()
              .frame(width: size, height: size)
              .foregroundColor(.yellow)
              .onTapGesture {
                noteColour = .yellow
              }
              .padding(4)
              .background(noteColour == .yellow ? .yellow.opacity(0.5) : .clear)
              .cornerRadius(CGFloat(size / 2 + 4))
            Spacer()
            Circle()
              .frame(width: size, height: size)
              .foregroundColor(.pink)
              .onTapGesture {
                noteColour = .pink
              }
              .padding(4)
              .background(noteColour == .pink ? .pink.opacity(0.5) : .clear)
              .cornerRadius(CGFloat(size / 2 + 4))
            Spacer()
            Circle()
              .frame(width: size, height: size)
              .foregroundColor(.green)
              .onTapGesture {
                noteColour = .green
              }
              .padding(4)
              .background(noteColour == .green ? .green.opacity(0.5) : .clear)
              .cornerRadius(CGFloat(size / 2 + 4))
          }
          .padding(8)
        }
      }
      .listStyle(.insetGrouped)
      .navigationBarTitle(self.mode.rawValue, displayMode: .inline)
      .navigationBarItems(leading: Button("Cancel") {
        self.showSheet = false
      }, trailing: Button("Save") {
        /* Create and add a note to the scene or update its contents */
          self.handler(text, noteColour)
        self.showSheet = false
          
      })
    }
  }
}
