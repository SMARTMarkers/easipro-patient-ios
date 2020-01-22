//
//  MainViewController.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 5/1/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import UIKit
import SMARTMarkers
import ResearchKit
import SMART


class MainViewController: UITableViewController {
    
    // Get fhir manager from the appDelegate
    lazy var fhir: FHIRManager! = {
        
        let fhr = (UIApplication.shared.delegate as! AppDelegate).fhir
        
        fhr?.onPatientSet = { [weak self] in
            DispatchQueue.main.async {
                self?.loadAllRequestsAndReports()
            }
        }
        return fhr
    }()
    
    public var sessionController : SessionController?
    
    public var tasks : [TaskSet]? {
        didSet {
            reloadOnMain()
        }
    }
    

    @IBOutlet weak var btnLogin: UIBarButtonItem!
    
    lazy var Today: String = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }()
	

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?[section].tasks.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        let status = tasks?[section].status
        return (status == TaskSchedule.ActivityStatus.Due.rawValue) ? Today : status?.uppercased()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! MainCell
        let measure = tasks?[indexPath.section].tasks[indexPath.row]
        cell.configure(for: measure!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func showPatientProfile(_ sender: Any) {
		
        if fhir.patient == nil {
            loginAction(sender)
        }
    }
    
    
    @IBAction func refreshPage(_ sender: Any) {
        loadAllRequestsAndReports()
    }
	
	@IBAction func loginAction(_ sender: Any) {
        
        fhir.authorize { [weak self] (success, userName, error) in
            if success {
                if let patientName = userName {
                    self?.title = patientName
                }
            }
            else {
                if let error = error {
                    self?.showMsg(msg: "Authorization Failed.\n\(error.asOAuth2Error.localizedDescription)")
                }
            }
        }
	}
	
	func reloadOnMain() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
            if let dueCount = self.tasks?.filter({ $0.status == TaskSchedule.ActivityStatus.Due.rawValue }).first?.tasks.count {
                self.navigationController?.tabBarItem.badgeValue = String(dueCount)
            }
		}
	}
	
	open func loadAllRequestsAndReports() {
        
		guard let p = fhir.patient else { return }
        self.title = "Loading.."
        let srv = fhir.main.server
        TaskController.Requests(requestType: ServiceRequest.self, for: p, server: srv, instrumentResolver: self) { [weak self] (controllers, error) in
            DispatchQueue.main.async {
                if let controllers = controllers {
                    self?.tasks = self?.sort(controllers)
                }
                if nil != error { print(error! as Any) }
                self?.markStandby()
            }
        }
    }
	
	
	
	open func markStandby() {
		DispatchQueue.main.async {
			let _title = self.fhir.patient?.humanName ?? "PGHD Requests"
			self.title = _title
			self.tableView.reloadData()
			if self.fhir.patient != nil {
				self.btnLogin.title = ""
			}
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let detailVC = segue.destination as? DetailViewController, segue.identifier == "showDetail" {
			if let indexPath = tableView.indexPathForSelectedRow {
                let task = tasks?[indexPath.section].tasks[indexPath.row]
                detailVC.task = task
			}
		}
	}
    
}




extension MainViewController {
    
    // Sort TaskControllers
    func sort(_ tasks: [TaskController]?) -> [TaskSet]? {
        
        var sets = [TaskSet]()
        let statuses = SMARTMarkers.TaskSchedule.ActivityStatus.allCases
        for status in statuses {
            if let filters = tasks?.filter ({ $0.schedule?.status == status }),
                filters.count > 0 {
                sets.append(TaskSet(tasks: filters, status: status.rawValue))
            }
        }
        
        let iOS = TaskSet(tasks: [
            TaskController(instrument: Instruments.HealthKit.HealthRecords.instance)
        ], status: "iOS Health Record")
        sets.append(iOS)
        
        return sets
    }
}



public struct TaskSet {
    let tasks : [TaskController]
    var status : String
}



extension MainViewController: InstrumentResolver {
    
    
    func resolveInstrument(in controller: TaskController, callback: @escaping ((_ instrument: Instrument?, _ error: Error?) -> Void)) {
        
        if let url = controller.request?.rq_instrumentMetadataQuestionnaireReferenceURL {
            // PROMIS/AssessmentCenter hosted Questionnaire
            if url.absoluteString.contains("https://mss.fsm.northwestern.edu"), let promisServer = fhir.promis?.server {
                let questionnaireId = url.lastPathComponent
                let semaphore = DispatchSemaphore(value: 0)
                Questionnaire.read(questionnaireId, server: promisServer) { (resource, error) in
                    if let questionnaire = resource as? Questionnaire {
                        callback(questionnaire, nil)
                    }
                    else {
                        callback(nil, error)
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
            else {
                callback(nil, nil)
            }
        }
        else
        if let code = controller.request?.rq_code {
            if code.system?.absoluteString == "http://omronhealthcare.com" {
                callback(Instruments.Web.OmronBloodPressure.instance(authSettings: FHIRManager.OmronAuthSettings()!, callbackManager: &fhir.callbackManager!), nil)
            }
            else {
                callback(nil, nil)
            }
        }
        else {
            callback(nil, nil)
        }
    }

    
    
}
