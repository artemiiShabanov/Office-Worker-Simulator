import UIKit

protocol SelectionProgramDelegate: AnyObject {
    func selected(index: Int)
    func exit()
}

class SelectionProgram: NSObject, Program {
    private let backColor: UIColor
    private let accentColor: UIColor
    private let options: [String]
    
    init(backColor: UIColor, accentColor: UIColor, options: [String]) {
        self.backColor = backColor
        self.accentColor = accentColor
        self.options = options + ["← \(NSLocalizedString("exit", comment: ""))"]
    }
    
    private lazy var view = {
        let tableView = UITableView()
        tableView.backgroundColor = self.backColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = false
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell")
        return tableView
    }()
    
    private var currentIndex = 0 {
        didSet {
            view.selectRow(at: .init(row: currentIndex, section: 0), animated: true, scrollPosition: .middle)
        }
    }
    weak var delegate: SelectionProgramDelegate?
    var keys: [Key] = [
        .init(symbol: "↓", type: .left),
        .init(symbol: "⏎", type: .right)
    ]
    
    func render(in window: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        currentIndex = 0
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            view.widthAnchor.constraint(equalTo: window.widthAnchor),
            view.heightAnchor.constraint(equalTo: window.heightAnchor)
        ])
    }
    
    func react(toInput key: KeyType) {
        switch key {
        case .left:
            currentIndex = (currentIndex == options.count - 1) ? 0 : (currentIndex + 1)
        case .right:
            if currentIndex == options.count - 1 {
                delegate?.exit()
            } else {
                delegate?.selected(index: currentIndex)
            }
        }
    }
}

private class SelectionCell: UITableViewCell {
    private var backColor: UIColor = .black
    private var accentColor: UIColor = .white
    
    private let label = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = false
        addSubview(label)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundColor = selected ? accentColor : backColor
        label.textColor = selected ? backColor : accentColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.intrinsicContentSize
        label.frame = CGRect(x: 16, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
    }
    
    func configure(text: String, backColor: UIColor, accentColor: UIColor) {
        label.text = text
        self.backColor = backColor
        self.accentColor = accentColor
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SelectionProgram: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell") as! SelectionCell
        cell.configure(text: options[indexPath.row], backColor: backColor, accentColor: accentColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.bounds.height / 6.5
    }
}
