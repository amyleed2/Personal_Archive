//
//  StepViewController.swift
//  PersonalArchive
//
//  Created by ezyeun on 9/25/25.
//

import Foundation
import UIKit
import Combine

class StepViewController: UIViewController {
    var viewModel: StepViewModel!
    private var cancellables = Set<AnyCancellable>()
        
    private let stepsLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.text = "걸음 수 로딩중..."
        return label
    }()
    private let todayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("오늘 걸음수 가져오기", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return btn
    }()
    private let recentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("최근 7일 걸음수 가져오기", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return btn
    }()
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(StepCell.self, forCellReuseIdentifier: StepCell.identifier)
        return tv
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil, "ViewModel 할당 필요")
        
        setupUI()
        bindViewModel()
        authorizeHealthKit()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        [stepsLabel, todayButton, recentButton, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            stepsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stepsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stepsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            todayButton.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 15),
            todayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recentButton.topAnchor.constraint(equalTo: todayButton.bottomAnchor, constant: 10),
            recentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: recentButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        todayButton.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        recentButton.addTarget(self, action: #selector(recentButtonTapped), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.$todayStepsText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.stepsLabel.text = text
            }
            .store(in: &cancellables)
        
        viewModel.$stepList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in self?.showErrorAlert(message: msg) }
            .store(in: &cancellables)
    }
    
    private func authorizeHealthKit() {
        HealthKitManager.shared.requestAuthorization { [weak self] authorized in
            DispatchQueue.main.async {
                guard authorized else {
                    self?.showErrorAlert(message: "HealthKit 권한 필요")
                    return
                }
            }
        }
    }
    
    @objc private func todayButtonTapped() {
        viewModel.loadTodaySteps()
    }
    
    @objc private func recentButtonTapped() {
        viewModel.loadRecentSteps()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension StepViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stepList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StepCell.identifier, for: indexPath) as? StepCell else {
                return UITableViewCell()
            }
            let step = viewModel.stepList[indexPath.row]
            cell.configure(with: step)
            return cell
    }
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteStep(at: indexPath.row)
        }
    }
}

final class StepCell: UITableViewCell {
    static let identifier = "StepCell"

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let stepsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    // 초기 셀 구성
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(stepsLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            stepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stepsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: stepsLabel.leadingAnchor, constant: -10)
        ])
    }

    func configure(with stepData: HealthRecordDTO) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = formatter.string(from: stepData.date)
        stepsLabel.text = "\(stepData.step) 걸음"
    }
}
