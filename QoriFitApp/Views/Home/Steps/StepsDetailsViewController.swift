//
//  StepsDetailsViewController.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import UIKit

class StepsDetailsViewController: UIViewController {
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var currentMonthOffset = 0
    private let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
    private let loadMoreButton = UIButton(type: .system)

    @IBOutlet weak var tvStepRecords: UITableView!
    
    private let stepService = StepService()
    private var stepsData: [StepRecordsPerDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLoader()
        setupFooter()
        fetchStepsDetails()
        
    }

    private func setupTableView() {
        tvStepRecords.delegate = self
        tvStepRecords.dataSource = self

    }

    private func fetchStepsDetails(offset: Int = 0) {
        let startDate = "2026-0\(4-offset)-01"
        
        activityIndicator.startAnimating() // Deberías tener uno en el footer también
        
        stepService.getStepsDetails(startDate: startDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let newData):
                    if newData.isEmpty {
                        self?.loadMoreButton.setTitle("Ya no hay más registros", for: .disabled)
                        self?.loadMoreButton.isEnabled = false
                    } else {
                        self?.stepsData.append(contentsOf: newData)
                        self?.tvStepRecords.reloadData()
                    }
                case .failure:
                    print("Error cargando más")
                }
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func setupFooter() {
        loadMoreButton.setTitle("Cargar meses anteriores", for: .normal)
        loadMoreButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loadMoreButton.addTarget(self, action: #selector(loadMoreData), for: .touchUpInside)
        loadMoreButton.frame = footerView.bounds
        
        footerView.addSubview(loadMoreButton)
        tvStepRecords.tableFooterView = footerView
    }

    @objc private func loadMoreData() {
        currentMonthOffset += 1
        fetchStepsDetails(offset: currentMonthOffset)
    }
    
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
}




extension StepsDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stepsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = stepsData[section].records.count
        print("Sección \(section) tiene \(count) filas")
        return count
    }
    
    // 3. Título de la sección (Fecha y Total)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dayData = stepsData[section]
        return "\(dayData.date) - Total: \(dayData.totalStepsPerDay) pasos"
    }
    
    // 4. Configuración de la celda (SubItem)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepRecordCell", for: indexPath)
        let record = stepsData[indexPath.section].records[indexPath.row]
        
        // Icono de pasos (SF Symbol)
        cell.imageView?.image = UIImage(systemName: "figure.walk")
        cell.imageView?.tintColor = .systemGreen
        
        // Formateo de textos
        cell.textLabel?.text = "\(record.stepCount) pasos"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        cell.detailTextLabel?.text = record.recordedAt.toReadableTime()
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let icon = UIImageView(image: UIImage(systemName: "clock.fill"))
        icon.tintColor = .systemOrange
        icon.frame = CGRect(x: 15, y: 10, width: 20, height: 20)
        
        let label = UILabel(frame: CGRect(x: 45, y: 10, width: tableView.frame.width - 60, height: 20))
        let dayData = stepsData[section]
        label.text = "\(dayData.date)  •  \(dayData.totalStepsPerDay) pasos"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
        headerView.addSubview(icon)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}


extension String {
    func toReadableTime() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withTime, .withColonSeparatorInTime]
        // Si tu string es "06:55:34.941707", necesitamos algo más flexible:
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss.SSSSSS"
        
        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a" // Ejemplo: 6:55 PM
            return outputFormatter.string(from: date)
        }
        return self
    }
}
