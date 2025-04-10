import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = [] // To store tasks, including completion status
    @State private var newTask: String = "" // For the input field
    @State private var showAlert = false // To toggle alert visibility
    @State private var taskToDelete: Int? // Store the index of the task to be deleted

    var body: some View {
        NavigationView {
            VStack {
                // Input Section
                HStack {
                    TextField("Enter new task", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        addTask()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .padding()

                // Tasks List
                List {
                    ForEach(tasks.indices, id: \.self) { index in
                        HStack {
                            // Checkbox for task completion
                            Button(action: {
                                toggleTaskCompletion(at: index)
                            }) {
                                Image(systemName: tasks[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tasks[index].isCompleted ? .green : .gray)
                            }

                            // Task description
                            Text(tasks[index].description)
                                .strikethrough(tasks[index].isCompleted, color: .gray)

                            Spacer()

                            // Delete button
                            Button(action: {
                                deleteTaskWithConfirmation(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteTask) // Allow swipe-to-delete
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("To-Do List")
            .onAppear(perform: loadTasks) // Load tasks when the view appears
            .alert(isPresented: $showAlert) { // Attach the alert to the view
                Alert(
                    title: Text("Delete Task"),
                    message: Text("Are you sure you want to delete this task?"),
                    primaryButton: .destructive(Text("Delete"), action: deleteConfirmedTask),
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // Add a new task to the list
    private func addTask() {
        if !newTask.isEmpty {
            let newTask = Task(description: newTask, isCompleted: false)
            tasks.append(newTask)
            saveTasks() // Save updated tasks
            self.newTask = "" // Clear the input field
        }
    }

    // Toggle completion status of a task
    private func toggleTaskCompletion(at index: Int) {
        tasks[index].isCompleted.toggle() // Change the task completion status
        saveTasks() // Save updated tasks
    }

    // Delete a task from the list
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks() // Save updated tasks after deletion
    }

    // Trigger delete confirmation
    private func deleteTaskWithConfirmation(at index: Int) {
        taskToDelete = index
        showAlert = true
    }

    // Perform deletion after confirmation
    private func deleteConfirmedTask() {
        if let index = taskToDelete {
            tasks.remove(at: index)
            saveTasks() // Save updated tasks after deletion
            taskToDelete = nil
        }
        showAlert = false
    }

    // Save tasks to UserDefaults
    private func saveTasks() {
        let taskDescriptions = tasks.map { $0.description }
        let taskCompletionStatuses = tasks.map { $0.isCompleted }
        UserDefaults.standard.set(taskDescriptions, forKey: "taskDescriptions")
        UserDefaults.standard.set(taskCompletionStatuses, forKey: "taskCompletionStatuses")
    }

    // Load tasks from UserDefaults
    private func loadTasks() {
        let savedDescriptions = UserDefaults.standard.stringArray(forKey: "taskDescriptions") ?? []
        let savedCompletionStatuses = UserDefaults.standard.array(forKey: "taskCompletionStatuses") as? [Bool] ?? []
        
        tasks = zip(savedDescriptions, savedCompletionStatuses).map { Task(description: $0.0, isCompleted: $0.1) }
    }
}

// Task model to store task information
struct Task {
    var description: String
    var isCompleted: Bool
}
