//
//  ContentView.swift
//  task list
//
//  Created by Azhagusundaram Tamil on 20/02/20.
//  Copyright © 2020 Azhagusundaram Tamil. All rights reserved.
//

import SwiftUI
import CoreData

struct TaskName: View {
    
    var task: Task
    
    var body: some View {
        Text(task.name ?? "No name")
    }
}

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    
    @State private var taskName = ""
    
    @State private var hideAddTask: Bool = true
    @State private var showAlert: Bool = false
    
    
    @FetchRequest(entity: Task.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Task.dateAdded, ascending: false)],
                  predicate: NSPredicate(format: "isCompleted == %@", NSNumber(value: false))
    ) var notCompletedTasks: FetchedResults<Task>
    
    var body: some View {
        
        NavigationView {
            
            VStack{
                
                HStack {
                    TextField("Enter the task name", text: $taskName)
                        .padding()
                    
                    Button(action: {
                        self.addTask()
                    }){
                        Text("Add Task")
                        .padding(12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(.infinity)
                    }
                    .alert(isPresented: self.$showAlert) {
                        self.emptyTaskAlert
                    }
                }
                .remove(remove: self.hideAddTask)
                .padding()
                
                
                List{
                    ForEach(notCompletedTasks) { task in
                        Button(action: {
                            self.updateTask(task)
                        }){
                            TaskName(task: task)
                        }
                    }
                    
                }.navigationBarTitle("Task Manager")
                    .navigationBarItems(trailing: Button(action: {
                        self.hideAddTask.toggle()
                    }){
                        
                             !self.hideAddTask ?  Image(systemName: "arrow.up") : Image(systemName: "arrow.down")
                        
                       
                    })
                
            }
            
        }
    }
    
    private func updateTask(_ task: Task) {
        let isCompleted = true
        let taskID = task.id! as NSUUID
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let test = try context.fetch(fetchRequest)
            let taskUpdate = test[0] as! NSManagedObject
            taskUpdate.setValue(isCompleted, forKey: "isCompleted")
        } catch {
            print(error)
        }
        
    }
    
    private func addTask() {
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.name = taskName
        newTask.isCompleted = false
        newTask.dateAdded = Date()
        
        do {
            if newTask.name! == "" {
                self.showAlert.toggle()
            }else {
                try context.save()
            }
        } catch  {
            print(error)
        }
        
        self.taskName = ""
    }
    
    var emptyTaskAlert: Alert {
        Alert(title: Text("Task cannot be empty"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
                .previewDisplayName("iPhone 11 Pro")
            
            //            ContentView()
            //                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            //                .previewDisplayName("iPhone 11")
        }
        
        
    }
}

extension View {
    func hide(hidden: Bool, remove: Bool = true) -> some View {
        modifier(HiddenModifier(isHidden: hidden, remove: remove))
    }
    
    func remove(remove: Bool) -> some View {
        modifier(RemoveModifier(remove: remove))
            .animation(.spring())
    }
}

struct RemoveModifier: ViewModifier {
    
    let remove: Bool
    
    init(remove: Bool) {
        self.remove = remove
    }
    
    func body(content: Content) -> some View {
        Group {
            if remove {
                EmptyView()
            } else {
                content
            }
        }
    }
}

struct HiddenModifier: ViewModifier {
    
    let isHidden: Bool
    let remove: Bool
    
    init(isHidden: Bool, remove: Bool) {
        self.isHidden = isHidden
        self.remove = remove
    }
    
    func body(content: Content) -> some View {
        
        Group {
            if isHidden {
                if remove {
                    EmptyView()
                } else {
                    content.hidden()
                }
            } else {
                content
            }
        }
    }
}
