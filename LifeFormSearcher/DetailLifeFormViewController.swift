//
//  DetailLifeFormViewController.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import UIKit
import SafariServices

class DetailLifeFormViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var commonNameLabel: UILabel!
    @IBOutlet var copyrightLabel: UILabel!
    @IBOutlet var copyrightButton: UIButton!
    
    @IBOutlet var kingdomLabel: UILabel!
    @IBOutlet var kingdomInfoLabel: UILabel!
    @IBOutlet var phylumLabel: UILabel!
    @IBOutlet var phylumInfoLabel: UILabel!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var classInfoLabel: UILabel!
    @IBOutlet var orderLabel: UILabel!
    @IBOutlet var orderInfoLabel: UILabel!
    @IBOutlet var familyLabel: UILabel!
    @IBOutlet var familyInfoLabel: UILabel!
    @IBOutlet var genusLabel: UILabel!
    @IBOutlet var genusInfoLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var taxonomySourceUpperLabel: UILabel!
    @IBOutlet var taxonomySourceLabel: UILabel!
    
    
    
    var lifeForm: LifeForm? = nil
    let lifeFormId: Int
    let lifeFormTitle: String
    let lifeFormCommonName: String

    override func viewDidLoad() {
        super.viewDidLoad()
        hideUI()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        Task {
            self.lifeForm = try? await fetchLifeFormData(for: self.lifeFormId)
            guard let lifeForm = lifeForm else { throw SearchModelsControllerError.fetchingResultsFailed }
            updateUI(with: lifeForm)
            try await updateImage(with: lifeForm)
        }

        // Do any additional setup after loading the view.
    }
    
    func updateUI(with lifeForm: LifeForm) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        titleLabel.text = lifeForm.title
        commonNameLabel.text = lifeForm.detailName
        commonNameLabel.isHidden = false
        if let taxonomySource = lifeForm.taxonSource {
            taxonomySourceLabel.text = taxonomySource
            taxonomySourceUpperLabel.isHidden = false
            taxonomySourceLabel.isHidden = false
        }
        if let copyrightName = lifeForm.copyright {
            copyrightLabel.text = copyrightName
            copyrightLabel.isHidden = false
        }
        if let copyrightUrl = lifeForm.copyrightURL {
            copyrightButton.setTitle(copyrightUrl.absoluteString, for: .normal)
            copyrightButton.isHidden = false
        }
        updateAncestors(lifeForm.ancestors)
        
    }
    
    func updateImage(with lifeForm: LifeForm) async throws {
        guard let imageType = lifeForm.imageType,
              imageType == "image/jpeg",
              let url = lifeForm.imageUrl
        else { return }
        
        let image = try await SearchModelsController.shared.fetchImage(url)
        imageView.image = image
        imageView.isHidden = false
    }
    
    func updateAncestors(_ acnestors: [[String?: String?]]?) {
        var unwrapperdAncestors = unwrapAncestors(acnestors)
        var lowerkeysedKeyAncestors: [String: String] = [:]
        
        for key in unwrapperdAncestors.keys {
            lowerkeysedKeyAncestors[key.lowercased()] = unwrapperdAncestors.removeValue(forKey: key)
        }
        
        if hasKeywordKey("kingdom", in: lowerkeysedKeyAncestors) {
            kingdomLabel.isHidden = false
            kingdomInfoLabel.isHidden = false
            kingdomInfoLabel.text = lowerkeysedKeyAncestors["kingdom"]
        }
        if hasKeywordKey("phylum", in: lowerkeysedKeyAncestors) {
            phylumLabel.isHidden = false
            phylumInfoLabel.isHidden = false
            phylumInfoLabel.text = lowerkeysedKeyAncestors["phylum"]
        }
        if hasKeywordKey("class", in: lowerkeysedKeyAncestors) {
            classLabel.isHidden = false
            classInfoLabel.isHidden = false
            classInfoLabel.text = lowerkeysedKeyAncestors["class"]
        }
        if hasKeywordKey("order", in: lowerkeysedKeyAncestors) {
            orderLabel.isHidden = false
            orderInfoLabel.isHidden = false
            orderInfoLabel.text = lowerkeysedKeyAncestors["order"]
        }
        if hasKeywordKey("family", in: lowerkeysedKeyAncestors) {
            familyLabel.isHidden = false
            familyInfoLabel.isHidden = false
            familyInfoLabel.text = lowerkeysedKeyAncestors["family"]
        }
        if hasKeywordKey("genus", in: lowerkeysedKeyAncestors) {
            genusLabel.isHidden = false
            genusInfoLabel.isHidden = false
            genusInfoLabel.text = lowerkeysedKeyAncestors["genus"]
        }
        
        
    }
    
    func hideUI() {
        imageView.isHidden = true
        commonNameLabel.isHidden = true
        copyrightLabel.isHidden = true
        copyrightButton.isHidden = true
        taxonomySourceUpperLabel.isHidden = true
        taxonomySourceLabel.isHidden = true
        kingdomLabel.isHidden = true
        kingdomInfoLabel.isHidden = true
        phylumLabel.isHidden = true
        phylumInfoLabel.isHidden = true
        classLabel.isHidden = true
        classInfoLabel.isHidden = true
        orderLabel.isHidden = true
        orderInfoLabel.isHidden = true
        familyLabel.isHidden = true
        familyInfoLabel.isHidden = true
        genusLabel.isHidden = true
        genusInfoLabel.isHidden = true
    }
    
    init?(coder: NSCoder, id: Int, lifeFormTitle: String, lifeFormCommonName: String) {
        self.lifeFormId = id
        self.lifeFormTitle = lifeFormTitle
        self.lifeFormCommonName = lifeFormCommonName
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchLifeFormData(for id: Int) async throws -> LifeForm? {
        let itemDetail = try await SearchModelsController.shared.fetchItemDetail(for: id)
        guard let id = itemDetail?.detailIDs.first!.id else { throw SearchModelsControllerError.fethingItemDetailFailed }
        let hierarchy = try await SearchModelsController.shared.fetchHierarchyItemInfo(for: id)
        
        let title = lifeFormTitle
        let detailName = lifeFormCommonName
        let imageUrl = itemDetail?.detailData?.first?.imageURL
        let imageType = itemDetail?.detailData?.first?.mimeType
        let taxonRank = hierarchy?.taxonRank
        let ancestors = hierarchy?.ancestors.map { [$0.taxonRank : $0.rankName] }
        let copyright = itemDetail?.detailData?.first?.rightsHolder
        let copyrightURL = itemDetail?.detailData?.first?.license
        let taxonSource = hierarchy?.sources.first
        
        let lifeForm = LifeForm(title: title, detailName: detailName, imageType: imageType, imageUrl: imageUrl, taxonRank: taxonRank, ancestors: ancestors, copyright: copyright, copyrightURL: copyrightURL, taxonSource: taxonSource)
        
        return lifeForm
    }
    
    @IBAction func copyrightButtonTapped() {
        if let url = self.lifeForm?.copyrightURL {
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true)
        }
    }
    
    func unwrapAncestors(_ ancestors: [[String?: String?]]?) -> [String: String] {
        var unwrappedAncestors: [String: String] = [:]
        
        if let ancestors = ancestors {
            for ancestor in ancestors {
                for (key, value) in ancestor {
                    if let unwrappedKey = key, let unwrappedValue = value {
                        unwrappedAncestors[unwrappedKey] = unwrappedValue
                    }
                }
            }
        }
        
        return unwrappedAncestors
    }

    func hasKeywordKey(_ keyword: String, in ancestors: [String: String]) -> Bool {
        return ancestors.keys.contains { $0.lowercased() == keyword.lowercased() }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
