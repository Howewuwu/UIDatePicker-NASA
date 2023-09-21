//
//  ViewController.swift
//  UIDatePicker-NASA
//
//  Created by Howe on 2023/9/18.
//

import UIKit
import Alamofire
import AlamofireImage


struct NASAResponse: Decodable {
    let url: String
}


class ViewController: UIViewController {
    
    let apiKey = Secrets.nasaAPIKey
    let baseURL = "https://api.nasa.gov/planetary/apod"
    
    @IBOutlet weak var NASAImageView: UIImageView!
    @IBOutlet weak var datePickerOuelet: UIDatePicker!
    @IBOutlet weak var monthSliderOuelet: UISlider!
    @IBOutlet weak var dateSliderOutlet: UISlider!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAndSetNASAImage(for: Date())
        let date = Date()
        let calender = Calendar.current
        let Month = calender.component(Calendar.Component.month, from: date)
        let today = calender.component(Calendar.Component.day, from: date)
        monthSliderOuelet.value = Float(Month)
        dateSliderOutlet.value = Float(today)
        
        
        
        
        
    }
    
    
    @IBAction func datePickerChange(_ sender: UIDatePicker) {
        
        fetchAndSetNASAImage(for: sender.date)
        let calender = Calendar.current
        let month = calender.component(Calendar.Component.month, from: sender.date)
        monthSliderOuelet.value = Float(month)
        let day = calender.component(Calendar.Component.day, from: sender.date)
        dateSliderOutlet.value = Float(day)
        
    }
    
    
    
    
    
    @IBAction func monthSliderValueChange(_ sender: UISlider) {
        let selectedMonth = Int(sender.value)
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: datePickerOuelet.date)
        dateComponents.month = selectedMonth
        
        if let newDate = Calendar.current.date(from: dateComponents) {
            datePickerOuelet.setDate(newDate, animated: true)
        }
        fetchAndSetNASAImage(for: datePickerOuelet.date)
        
    }
    
    
    
    
    
    
    @IBAction func dateSliderValueChange(_ sender: UISlider) {
        let selectedDay = Int(sender.value)
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: datePickerOuelet.date)
        dateComponents.day = selectedDay
        
        if let newDate = Calendar.current.date(from: dateComponents) {
            datePickerOuelet.setDate(newDate, animated: true)
        }
        fetchAndSetNASAImage(for: datePickerOuelet.date)
        
        
    }
    
    
    
    func fetchNASAImage(for date: Date, completion: @escaping (URL?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "date": formattedDate
        ]
        
        AF.request(baseURL, parameters: parameters).responseDecodable(of: NASAResponse.self) { response in
            switch response.result {
            case .success(let data):
                if let url = URL(string: data.url) {
                    completion(url)
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    
    
    
    func fetchAndSetNASAImage(for date: Date) {
        fetchNASAImage(for: date) { [weak self] imageUrl in
            guard let self = self else { return }
            
            if let imageUrl = imageUrl {
                self.NASAImageView.af.setImage(withURL: imageUrl)
                self.errorLabel.text = ""
            } else {
                self.NASAImageView.image = nil
                self.errorLabel.text = "NASA 這天沒開工"
            }
        }
    }
    
    
    
    
}

