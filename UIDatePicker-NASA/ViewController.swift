//
//  ViewController.swift
//  UIDatePicker-NASA
//
//  Created by Howe on 2023/9/18.
//

// 匯入所需的模組
import UIKit
import Alamofire
import AlamofireImage

// 定義從 NASA API 獲取的結構
struct NASAResponse: Decodable {
    let url: String
}

// 定義主畫面
class ViewController: UIViewController {
    
    // 定義 NASA API 的金鑰和基礎URL
    let apiKey = Secrets.nasaAPIKey
    let baseURL = "https://api.nasa.gov/planetary/apod"
    var timer: Timer?
    
    // 連接 storyboard 中的 UI 元件
    @IBOutlet weak var NASAImageView: UIImageView!
    @IBOutlet weak var datePickerOuelet: UIDatePicker!
    @IBOutlet weak var monthSliderOuelet: UISlider!
    @IBOutlet weak var dateSliderOutlet: UISlider!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var autoPlaySwitchOutlet: UISwitch!
    
    // 當畫面載入完成後，執行的方法
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 預設取得當日的 NASA 圖片
        fetchAndSetNASAImage(for: Date())
        
        // 設定月份和日期的滑動條到當日日期
        let date = Date()
        let calender = Calendar.current
        let Month = calender.component(Calendar.Component.month, from: date)
        let today = calender.component(Calendar.Component.day, from: date)
        monthSliderOuelet.value = Float(Month)
        dateSliderOutlet.value = Float(today)
        autoPlaySwitchOutlet.isOn = false
    }
    
    // 日期選擇器改變後執行的方法
    @IBAction func datePickerChange(_ sender: UIDatePicker) {
        // 根據選擇的日期取得 NASA 圖片
        fetchAndSetNASAImage(for: sender.date)
        
        // 更新月份和日期的滑動條值
        let calender = Calendar.current
        let month = calender.component(Calendar.Component.month, from: sender.date)
        monthSliderOuelet.value = Float(month)
        let day = calender.component(Calendar.Component.day, from: sender.date)
        dateSliderOutlet.value = Float(day)
    }
    
    // 月份滑動條改變後執行的方法
    @IBAction func monthSliderValueChange(_ sender: UISlider) {
        let selectedMonth = Int(sender.value)
        
        // 更新日期選擇器的月份
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: datePickerOuelet.date)
        dateComponents.month = selectedMonth
        
        if let newDate = Calendar.current.date(from: dateComponents) {
            datePickerOuelet.setDate(newDate, animated: true)
        }
        
        // 根據新日期取得 NASA 圖片
        fetchAndSetNASAImage(for: datePickerOuelet.date)
    }
    
    // 日期滑動條改變後執行的方法
    @IBAction func dateSliderValueChange(_ sender: UISlider) {
        let selectedDay = Int(sender.value)
        
        // 更新日期選擇器的日期
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: datePickerOuelet.date)
        dateComponents.day = selectedDay
        
        if let newDate = Calendar.current.date(from: dateComponents) {
            datePickerOuelet.setDate(newDate, animated: true)
        }
        
        // 根據新日期取得 NASA 圖片
        fetchAndSetNASAImage(for: datePickerOuelet.date)
    }
    
    
    
    @IBAction func autoPlaySwitchChange(_ sender: UISwitch) {
        if sender.isOn {
            timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self.datePickerOuelet.date)
                
                if let day = dateComponents.day, day > 1 {
                    // 只需減少日期
                    dateComponents.day! -= 1
                } else if let month = dateComponents.month, month > 1 {
                    // 減少月份並設置為該月的最後一天
                    dateComponents.month! -= 1
                    if let lastDayOfMonth = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: dateComponents)!)?.upperBound {
                        dateComponents.day = lastDayOfMonth - 1
                    }
                } else {
                    // 設為12月31日
                    dateComponents.year! -= 1
                    dateComponents.month = 12
                    dateComponents.day = 31
                }
                
                if let newDate = Calendar.current.date(from: dateComponents) {
                    self.datePickerOuelet.setDate(newDate, animated: true)
                    self.monthSliderOuelet.value = Float(dateComponents.month!)
                    self.dateSliderOutlet.value = Float(dateComponents.day!)
                    // 根據新日期取得 NASA 圖片
                    self.fetchAndSetNASAImage(for: newDate)
                }
            }
        } else {
            timer?.invalidate()
        }
    }
    
    
    
    // 透過 API 取得 NASA 圖片的方法
    func fetchNASAImage(for date: Date, completion: @escaping (URL?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        
        // 設定 API 的參數
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "date": formattedDate
        ]
        
        // 使用 Alamofire 進行 API 請求
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
    
    // 取得並設定 NASA 圖片的方法
    func fetchAndSetNASAImage(for date: Date) {
        fetchNASAImage(for: date) { [weak self] imageUrl in
            guard let self = self else { return }
            
            if let imageUrl = imageUrl {
                // 使用 AlamofireImage 設定圖片
                self.NASAImageView.af.setImage(withURL: imageUrl)
                self.errorLabel.text = ""
            } else {
                self.NASAImageView.image = nil
                // 若該日期沒有圖片，則顯示提示訊息
                self.errorLabel.text = "NASA 這天沒開工"
            }
        }
    }
}

