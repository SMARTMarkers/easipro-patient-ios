//
//  DetailViewController.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 5/2/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import UIKit
import SMARTMarkers
import SMART
import ResearchKit

class DetailViewController: UITableViewController {
    
    // Get fhir manager from the appDelegate
    var fhir: FHIRManager! = (UIApplication.shared.delegate as! AppDelegate).fhir
    
    public var task: TaskController!
	
	var sessionController : SessionController?
    
	@IBOutlet weak var graphView: PROLineChart!
	
    @IBOutlet weak var btnSession: RoundedButton!
    
    var reports: [Report]? {
        return task.reports?.reports
    }
    
    convenience init(_task: TaskController) {
        self.init(style: .plain)
        self.task = _task
    }
    
    @IBAction func sessionAction(_ sender: RoundedButton) {
        
        let pt = fhir.patient!
        let srv = fhir.main.server

        sessionController = SessionController([task], patient: pt, server: srv)
   
        
        sessionController?.prepareController(callback: { (controller, error) in
            
            if let controller = controller {
                controller.view.tintColor = .red
                self.present(controller, animated: true, completion: nil)
            }
            
            else if let error = error {
                self.showMsg(msg: "Error occurred when creating a session\n\(error.localizedDescription)")
            }
            
        })
        
        sessionController?.onConclusion = { [weak self] session in
            
            self?.reload()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "REQ: #" + (task.request?.rq_identifier ?? "-")
        graphView.title = task.instrument?.sm_title ?? task.request?.rq_title ?? "-"
        graphView.subTitle = (task.request?.rq_categoryCode ?? "CODE: --")
        reload()
    }
	
	
	func reload() {
		DispatchQueue.main.async {
            if let sorted = self.reports?.filter({ $0.rp_observation != nil}).sorted(by: {$0.rp_date < $1.rp_date }) {
                self.graphView.dataEntries = sorted
            }
            self.tableView.reloadData()
		}
	}
	
	
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "History"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OCell", for: indexPath)
        let result = reports![indexPath.row]
        cell.textLabel?.text = "\(result.rp_date.shortDate): \(result.rp_description ?? "--")"
        cell.detailTextLabel?.text = result.rp_observation ?? nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let report = reports![indexPath.row]
        if let viewer = report.rp_viewController {
            self.show(viewer, sender: nil)
        }
    }


}


extension DetailViewController : SessionControllerDelegate {
    
    
    func sessionEnded(_ session: SessionController, taskViewController: ORKTaskViewController, reason: ORKTaskViewControllerFinishReason, error: Error?) {
    
        if let error = error {
            print(error as Any)
            print(reason.rawValue)
        }
        reload()
    }
    
    func sessionShouldBegin(_ session: SessionController, taskViewController: ORKTaskViewController, reason: ORKTaskViewControllerFinishReason, error: Error?) -> Bool {
        
        return true
    }
}
