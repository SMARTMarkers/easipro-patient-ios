//
//  MainCell.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 5/2/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import UIKit
import SMARTMarkers

class MainCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
	var upcomingBgColor : UIColor? = UIColor.init(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.0)

    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblStatus.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
		upcomingBgColor = self.superview?.backgroundColor
		chartView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(for task: TaskController) {
        lblTitle.text = task.instrument?.sm_title ?? task.request?.rq_title
        lblSubtitle.text = "REQUESTED BY \(task.request?.rq_requesterName?.uppercased() ?? "---")"
        
        let status = task.schedule?.status
        if let duedate = task.schedule?.dueDate {
            if status == .Due {
                lblStatus.text = "DUE ON " + (duedate.shortDate)
                backgroundColor = UIColor.white
            }
            else if status == .Upcoming || status == .Completed {
                lblStatus.text = "NEXT ON " + (duedate.shortDate)
                backgroundColor = upcomingBgColor
            }
            else {
                lblStatus.text = "Last: " + (duedate.shortDate)
                backgroundColor = upcomingBgColor
            }
        }
        else {
            backgroundColor = UIColor.white
            lblStatus.text = status?.rawValue.uppercased() ?? "-"
        }
        
        
        if let ssc = task.reports?.reports {
            let scores = ssc.filter{ $0.rp_observation != nil }.map { Double($0.rp_observation!)! }
            chartView.setThresholds([55,60,70], highNormal: false, _grayScale: false)
            chartView.points = scores
        }
        else {
            chartView.points = nil
        }
    }

}
