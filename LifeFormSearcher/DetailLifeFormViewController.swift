//
//  DetailLifeFormViewController.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import UIKit

class DetailLifeFormViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var kingdomLabel: UILabel!
    @IBOutlet var kingdomInfoLabel: UILabel!
    @IBOutlet var phylumLabel: UILabel!
    @IBOutlet var phylumInfoLabel: UILabel!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var classInfoLabel: UILabel!
    @IBOutlet var familyLabel: UILabel!
    @IBOutlet var familyInfoLabel: UILabel!
    @IBOutlet var genusLabel: UILabel!
    @IBOutlet var genusInfoLabel: UILabel!
    
    
    
    
    let lifeForm: LifeForm? = nil
    let lifeFormId: Int
    let lifeFormTitle: String
    let lifeFormCommonName: String

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            let lifeForm = try? await fetchLifeFormData(for: self.lifeFormId)
            guard let lifeForm = lifeForm else { throw SearchModelsControllerError.fetchingResultsFailed }
            titleLabel.text = lifeForm.title
        }

        // Do any additional setup after loading the view.
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
        let taxonRank = hierarchy?.taxonRank
        let ancestors = hierarchy?.ancestors.map { [$0.taxonRank : $0.rankName] }
        let copyright = itemDetail?.detailData?.first?.rightsHolder
        let copyrightURL = itemDetail?.detailData?.first?.license
        
        let lifeForm = LifeForm(title: title, detailName: detailName, imageUrl: imageUrl, taxonRank: taxonRank, ancestors: ancestors, copyright: copyright, copyrightURL: copyrightURL)
        
        return lifeForm
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
