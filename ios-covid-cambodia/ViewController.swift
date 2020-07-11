//
//  ViewController.swift
//  ios-covid-cambodia
//
//  Created by Samrith Yoeun on 6/23/20.
//  Copyright © 2020 Sammi Yoeun. All rights reserved.
//

import UIKit

typealias DataSource = (icon: String, title: String, description: String)

struct CovidStatistic: Decodable {
    var confirmed: Int
    var active: Int
    
    enum CodingKeys: String, CodingKey {
       case confirmed = "Confirmed"
        case active = "Active"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        confirmed = try values.decode(Int.self, forKey: .confirmed)
        active = try values.decode(Int.self, forKey: .active)
        
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    var dataSource = [DataSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let brightRed = UIColor(hex: "#dd1818")
        let lightBlack = UIColor(hex: "#333333")
        self.view.setupGradient(startColor: brightRed, endColor: lightBlack)
        
        requestData { data in
            self.dataSource.append(DataSource(icon: "bandage.fill", title: "Total Confirmed", description: "\(data.confirmed) people"))
                 
            self.dataSource.append(DataSource(icon: "person.crop.circle.fill.badge.checkmark", title: "Total Active", description: "\(data.active) people"))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    func requestData(callback: @escaping (CovidStatistic) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://api.covid19api.com/country/cambodia?from=2020-06-24T00:00:00Z&to=2020-06-25T00:00:00Z")!
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
           
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            do {
                let data = try JSONDecoder().decode([CovidStatistic].self, from: data! )
                    
                if let last = data.last {
                    callback(last)
                }
                
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }

        })
        task.resume()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.bind(dataSource[indexPath.row])
        return cell
    }
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addBlurEffect()
            containerView.backgroundColor = .clear
            containerView.layer.cornerRadius = 20
            containerView.clipsToBounds = true

        }
    }
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func bind(_ data: DataSource) {
        containerView.bringSubviewToFront(iconImageView)
        containerView.bringSubviewToFront(titleLabel)
        containerView.bringSubviewToFront(descriptionLabel)
        bind(icon: data.icon, title: data.title, description: data.description)
    }
    
    func bind(icon: String, title: String, description: String) {
        
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
      var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

      if (cString.hasPrefix("#")) { cString.removeFirst() }

      if ((cString.count) != 6) {
        self.init(hex: "ff0000") // return red color for wrong hex input
        return
      }

      var rgbValue: UInt64 = 0
      Scanner(string: cString).scanHexInt64(&rgbValue)

      self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
    }

    
}
extension UIView {
    
    func setupGradient(startColor: UIColor, endColor: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.frame = self.frame
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addBlurEffect() {
       if !UIAccessibility.isReduceTransparencyEnabled {
            self.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.addSubview(blurEffectView)
        } else {
            self.backgroundColor = .black
        }
    }
}
