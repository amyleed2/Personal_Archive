//
//  TableViewCellTodo.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import UIKit

class TodoListItemCell: UITableViewCell {
    
    let title: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14)
        v.textColor = .black
        return v
    }()
    
    public var toggleButton: (()->Void)?
    public var toggleButtonWithUUID: ((UUID) -> Void)?
    private var currentUUID: UUID?
    
    let btnConfirm: UIButton = {
        let b = UIButton()
        b.setTitle("완료", for: .normal)
        return b
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        title.translatesAutoresizingMaskIntoConstraints = false
        btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(title)
        contentView.addSubview(btnConfirm)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            btnConfirm.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            btnConfirm.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        btnConfirm.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }
    
    func configure(with todo: TodoItem) {
        currentUUID = todo.id
        
        title.text = todo.title
        title.textColor = todo.isDone ? .lightGray : .black
        btnConfirm.setTitleColor(todo.isDone ? .lightGray : .black, for: .normal)
                
        let attribute: NSMutableAttributedString = NSMutableAttributedString(string: todo.title)
        if todo.isDone {
            attribute.addAttribute(.strikethroughStyle,
                                   value: NSUnderlineStyle.single.rawValue,
                                   range: NSMakeRange(0, attribute.length))
            title.attributedText = attribute
        }
    }
    
    @objc private func didTapDone() {
        self.toggleButton?()
        if let uuid = currentUUID {
            self.toggleButtonWithUUID?(uuid)
        }
    }
}
