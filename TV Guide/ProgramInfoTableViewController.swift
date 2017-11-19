
import UIKit
import Moya
import Foundation
import SDWebImage

class ProgramInfoTableViewController: UITableViewController {
    
    // MOCK DATA
	var startTime: Date = Date() {
		didSet {
			updateStuff()
		}
	}
	
	var endTime: Date = Date() {
		didSet {
			updateStuff()
		}
	}
	
	var show: Show!
    
    private var timer: Timer?
    
	@IBOutlet weak var showPreviewImage: UIImageView!
	@IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var showDescription: UILabel!
	@IBOutlet weak var showGenre: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
		
		navigationItem.title = show.title ?? "No Title Available"
		showPreviewImage.sd_setImage(with: show.images?.first?.url, completed: nil)
		
		startTime = Date(timeIntervalSince1970: TimeInterval(show.startTime))
		endTime = Date(timeIntervalSince1970: TimeInterval(show.endTime))
		
		showDescription.text = show.description ?? "No Description Available"
		showGenre.text = show.genres.first?.first?.value ?? "No Genre Available"
        
        updateStuff()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
	
	private func updateStuff() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		timeLabel.text = dateFormatter.string(from: startTime) + " - " + dateFormatter.string(from: endTime)
		timer  = Timer.scheduledTimer(
			timeInterval: 10,
			target: self,
			selector: #selector(self.updateTimeProgressView),
			userInfo: nil,
			repeats: true
		)
		updateTimeProgressView()
	}
    
    @objc private func updateTimeProgressView() {
        let now = Date()
		
        if  now <= endTime && now >= startTime {
            let duration = endTime.timeIntervalSince(startTime)
            let progress = now.timeIntervalSince(startTime)
            timeProgressView.setProgress((Float) (progress / duration), animated: true)
        } else if now > endTime {
            timeProgressView.setProgress(1, animated: true)
        } else if now < startTime {
            timeProgressView.setProgress(0, animated: true)
        }
    }

    private func createDate(hour: Int, minute: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        let now = Date()
        dateComponents.year = calendar.component(.year, from: now)
        dateComponents.month = calendar.component(.month, from: now)
        dateComponents.day = calendar.component(.day, from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        return Calendar.current.date(from: dateComponents)
    }
}


