//
//  ContentView.swift
//  LearnCoreData
//
//  Created by Sachin Sharma on 26/09/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    @FetchRequest(
        entity: FruitEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FruitEntity.name, ascending: true)])
    var fruits: FetchedResults<FruitEntity>

    @State var textFeildText: String = ""
    @State var alertText: String = ""
    @State var showAlert: Bool = false
    @State var showAddFruit: Bool = false
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Add Fruit Here...", text: $textFeildText)
                    .focused($isInputActive)
                    .font(.headline)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isInputActive = false
                            }
                        }
                    }
                
                Button {
                    if !textFeildText.isEmpty {
                        addItem()
                        textFeildText = ""
                    } else {
                        showAlert.toggle()
                        alertText = "Enter Fruit name first!"
                    }
                } label: {
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.blue)
                        .cornerRadius(10)
                }.padding(.horizontal)
                
                
                List {
                    ForEach(fruits) { fruit in
                        NavigationLink {
                            HStack {
                                Text("Fruit is: \(fruit.name!)")
                                Text("at \(fruit.timestamp!, formatter: itemFormatter)")
                            }
                        } label: {
                            HStack {
                                Text(fruit.name ?? "")
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button("Update") {
                                             updateFruit(fruit: fruit)
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                        
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Fruits")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Add Item"), message: Text("\(alertText)"), dismissButton: .default(Text("OK")))
            })
        }
    }

    private func addItem() {
        withAnimation {
            let newFruit = FruitEntity(context: viewContext)
            newFruit.name = textFeildText
            newFruit.timestamp = Date()
            saveItems()
        }
    }
    
    private func updateFruit(fruit: FruitEntity) {
        withAnimation() {
            let currentName = fruit.name ?? ""
            let newName = currentName + "!"
            fruit.name = newName
            
            saveItems()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            guard let index = offsets.first else { return }
            let fruitEntity = fruits[index]
            viewContext.delete(fruitEntity)
            
            // offsets.map { fruits[$0] }.forEach(viewContext.delete)
            saveItems()
        }
    }
    
    private func saveItems() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
