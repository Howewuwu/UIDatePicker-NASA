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
        
        
        
        
        
    }
    
    
    @IBAction func datePickerChange(_ sender: UIDatePicker) {
        
        fetchAndSetNASAImage(for: sender.date)
        
    }
    
    
    
    
    
    @IBAction func monthSliderValueChange(_ sender: UISlider) {
        
        
    }
    
    
    
    
    
    @IBAction func dateSliderValueChange(_ sender: UISlider) {
        
        
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
                errorLabel.text = ""
            } else {
                // 你也可以設置一個預設的錯誤圖片或顯示錯誤訊息
                self.NASAImageView.image = nil
                errorLabel.text = "NASA 今天休假"
            }
        }
    }
    
    
    
    
}

