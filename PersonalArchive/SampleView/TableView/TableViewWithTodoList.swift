//
//  TableViewWithTodoList.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import Combine
import UIKit

struct TodoItem: Codable, Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

class TodoViewModel {
    //외부에서 읽기는 가능하지만 내부에서만 set가능
    @Published private(set) var todos: [TodoItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTodos()
        
        // todo값이 바뀔때 마다 자동 저장
        $todos
            .sink { todos in
//                UserDefaults.todolists = todos
            }
            .store(in: &cancellables)
    }
    
    func add(title: String) {
        let newValue = TodoItem(title: title, isDone: false)
        todos.append(newValue)
    }
    
    func remove(id: UUID) {
        if let index = todos.firstIndex(where: {$0.id == id}) {
            todos.remove(at: index)
        }
    }
    
    func loadTodos() {
//        todos = UserDefaults.todolists ?? []
    }
    
    func toggle(id: UUID) {
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].isDone.toggle()
        }
    }
}

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    
    let viewModel = TodoViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        setupInputArea()
        setupTableView()
        
        viewModel.$todos
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupInputArea() {
        textField.placeholder = "할 일을 입력하세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.setTitle("추가", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        
        view.addSubview(textField)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            
            addButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TodoListItemCell.self, forCellReuseIdentifier: "TodoListItemCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func addTodo(){
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        viewModel.add(title: text)
        textField.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItemCell", for: indexPath) as? TodoListItemCell else {
            return UITableViewCell()
        }
        
        let todo = viewModel.todos[indexPath.row]
        cell.configure(with: todo)
        cell.toggleButtonWithUUID = { [weak self] id in
            self?.viewModel.toggle(id: id)
        }
        
        return cell
    }
}
