//
//  FilterVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/31/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class FilterVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource{
    
    var RSTypeArray = [String]()
    var PlayTypeArray = [String]()
    var CSTypeArray = [String]()
    var HoleTypeArray = [String]()
    var CoursesTypeArray = [String]()
    
    var commanArray = [String]()
    var allSections : [NSArray] = []
    var isSmartCaddie = false
    var isMyScoreParent = false
    var section1 = [String]()
    var section2 = [String]()
    var section3 = [String]()
    var section4 = [String]()
    
    var fromSwingPerform = Bool()
    var fromSwingSession = Bool()
    var fromScorePutting = Bool()

    @IBOutlet weak var fliterCollectionView: UICollectionView!
    @IBAction func doneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Filters".localized()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.fliterCollectionView.allowsMultipleSelection = true
        
        let backBtn = UIBarButtonItem(image:(UIImage(named: "backArrow")), style: .plain, target: self, action: #selector(self.backAction(_:)))
        backBtn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)

        if self.fromSwingSession{
            section2 = ["Practice", "Regular", "Tournament", "All".localized()]
            allSections.append(section2 as NSArray)
        }
        else if self.fromSwingPerform{
            section1 = ["10 " + "Rounds".localized(), "20 " + "Rounds".localized(), "50 " + "Rounds".localized(), "30 " + "Days".localized(), "90 " + "Days".localized(), "180 " + "Days".localized(), "All".localized()]
            section2 = ["Practice", "Regular", "Tournament", "All".localized()]
            section3 = ["Dr", "3w", "5w", "Hy", "3i", "4i","5i", "6i","7i","8i","9i", "Pw","Sw","Pu","All".localized()]
            
            allSections.append(section1 as NSArray)
            allSections.append(section2 as NSArray)
            allSections.append(section3 as NSArray)
        }
        else{
            section1 = ["10 " + "Rounds".localized(), "20 " + "Rounds".localized(), "50 " + "Rounds".localized(), "30 " + "Days".localized(), "90 " + "Days".localized(), "180 " + "Days".localized(), "All".localized()]
            if !(self.fromScorePutting){
                section3 = ["Dr", "3w", "5w", "Hy", "3i", "4i","5i", "6i","7i","8i","9i", "Pw","Sw","Pu","All".localized()]
                }
            section4 = ["9 Holes".localized(), "18 Holes".localized(),"All".localized()]

            if  Constants.section5.count>0 {
            Constants.section5 = Constants.section5.removeDuplicates()
                if Constants.section5.contains("All".localized().localized()){
                    for i in 0..<Constants.section5.count{
                        if Constants.section5[i] == "All".localized(){
                            Constants.section5.remove(at: i)
                            Constants.section5.insert("All".localized(), at: Constants.section5.count)
                            break
                        }
                    }
                }
                else{
                    Constants.section5.insert("All".localized(), at: Constants.section5.count)
                }
                allSections.append(section1 as NSArray)
                if !(self.fromScorePutting){
                allSections.append(section3 as NSArray)
                }
                allSections.append(section4 as NSArray)
                allSections.append(Constants.section5 as NSArray)
            }
        }
        if isSmartCaddie{
            FBSomeEvents.shared.singleParamFBEvene(param: "View Smart Caddie Filter")
        }
        if isMyScoreParent{
            FBSomeEvents.shared.singleParamFBEvene(param: "View My Scores Filter")
        }
        /*var indexPath = IndexPath()
//        var cell = FilterCollectionViewCell()
        for index in 0..<allSections.count{
            
             indexPath = IndexPath(item: allSections[index].count, section: index)

            print("indexPath.section:\(indexPath.section) and indexPath.row:\(indexPath.row)")
            
            //cell = self.fliterCollectionView.cellForItem(at: IndexPath(row: allSections[index].count, section: indexPath.section)) as! FilterCollectionViewCell
            //print("indexPath.section:\(cell)")
        }*/
    }
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSections[section].count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterButtons", for: indexPath as IndexPath) as! FilterCollectionViewCell
        cell.filterButton.layer.borderWidth = 1.0
        cell.filterButton.layer.cornerRadius = 3.0
        cell.filterButton.layer.borderColor = UIColor.glfBluegreen.cgColor

        let array = allSections[indexPath.section]
        commanArray = array as! [String]

        cell.filterButton.text = (array[indexPath.row]) as? String

        /*if indexPath.section == 0 {
            cell.filterButton.text = section1[indexPath.item]
        }
        else if indexPath.section == 1{
            cell.filterButton.text = section2[indexPath.item]
        }
        else if indexPath.section == 2{
            cell.filterButton.text = section3[indexPath.item]
        }
        else if indexPath.section == 3{
            cell.filterButton.text = section4[indexPath.item]
        }
        else if indexPath.section == 4{
            cell.filterButton.text = section5[indexPath.item]
        }*/
        
        // -------- For Selection / deselection in Cell ---------------

        /*if indexPath.section == 0{
            commanArray = section1
        }
        else if indexPath.section == 1{
            commanArray = section2
        }
        else if indexPath.section == 2{
            commanArray = section3
        }
        else if indexPath.section == 3{
            commanArray = section4
        }
        else if indexPath.section == 4{
            commanArray = section5
        }*/
        
        if self.fromSwingSession{
             if indexPath.section == 0{
                if commanArray.count>0 {
                    
                    var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                    
                    for  i in 0..<PlayTypeArray.count{
                        
                        if PlayTypeArray[i] == commanArray[indexPath.item]{
                            
                            selectedIndexPaths = [indexPath]
                            cell.isSelected = true
                            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                            
                            let rowIsSelected = selectedIndexPaths.contains(indexPath)
                            cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                            cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            
                        }
                    }
                }
            }
        }
        else if self.fromSwingPerform{
            if indexPath.section == 0 {
                if commanArray.count>0 {
                    var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                    
                    for  i in 0..<RSTypeArray.count{
                        
                        if RSTypeArray[i] == commanArray[indexPath.item]{
                            
                            selectedIndexPaths = [indexPath]
                            cell.isSelected = true
                            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                            
                            let rowIsSelected = selectedIndexPaths.contains(indexPath)
                            cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                            cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                        }
                    }
                }
            }
            else if indexPath.section == 1{
                if commanArray.count>0 {
                    
                    var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                    
                    for  i in 0..<PlayTypeArray.count{
                        
                        if PlayTypeArray[i] == commanArray[indexPath.item]{
                            
                            selectedIndexPaths = [indexPath]
                            cell.isSelected = true
                            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                            
                            let rowIsSelected = selectedIndexPaths.contains(indexPath)
                            cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                            cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack

                        }
                    }
                }
            }
            else if indexPath.section == 2{
                if commanArray.count>0 {
                    
                    var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                    
                    for  i in 0..<CSTypeArray.count{
                        
                        if CSTypeArray[i] == commanArray[indexPath.item]{
                            
                            selectedIndexPaths = [indexPath]
                            cell.isSelected = true
                            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                            
                            let rowIsSelected = selectedIndexPaths.contains(indexPath)
                            cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                            cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack

                        }
                    }
                }
            }
        }
        else{
            if (self.fromScorePutting){
                if indexPath.section == 0 {
                    
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<RSTypeArray.count{
                            
                            if RSTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
                else if indexPath.section == 1{
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<HoleTypeArray.count{
                            
                            if HoleTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
                else if indexPath.section == 2{
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<CoursesTypeArray.count{
                            
                            if CoursesTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
            }
            else{
                if indexPath.section == 0 {
                    
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<RSTypeArray.count{
                            
                            if RSTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
                else if indexPath.section == 1{
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<CSTypeArray.count{
                            
                            if CSTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
                else if indexPath.section == 2{
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<HoleTypeArray.count{
                            
                            if HoleTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
                else if indexPath.section == 3{
                    if commanArray.count>0 {
                        
                        var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                        
                        for  i in 0..<CoursesTypeArray.count{
                            
                            if CoursesTypeArray[i] == commanArray[indexPath.item]{
                                
                                selectedIndexPaths = [indexPath]
                                cell.isSelected = true
                                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                                
                                let rowIsSelected = selectedIndexPaths.contains(indexPath)
                                cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
                                cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                            }
                        }
                    }
                }
            }
        }
        /*if indexPath.section == 0 {
            
            if commanArray.count>0 {
                
                var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                
                for  i in 0..<RSTypeArray.count{
                    
                    if RSTypeArray[i] == commanArray[indexPath.item]{
                        
                        selectedIndexPaths = [indexPath]
                        cell.isSelected = true
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                        
                        let rowIsSelected = selectedIndexPaths.contains(indexPath)
         cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
         cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                    }
                }
            }
        }
        else if indexPath.section == 1{
            if commanArray.count>0 {
                
                var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                
                for  i in 0..<PlayTypeArray.count{
                    
                    if PlayTypeArray[i] == commanArray[indexPath.item]{
                        
                        selectedIndexPaths = [indexPath]
                        cell.isSelected = true
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                        
                        let rowIsSelected = selectedIndexPaths.contains(indexPath)
         cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
         cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                    }
                }
            }
        }
        else if indexPath.section == 2{
            if commanArray.count>0 {
                
                var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                
                for  i in 0..<CSTypeArray.count{
                    
                    if CSTypeArray[i] == commanArray[indexPath.item]{
                        
                        selectedIndexPaths = [indexPath]
                        cell.isSelected = true
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                        
                        let rowIsSelected = selectedIndexPaths.contains(indexPath)
         cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
         cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                    }
                }
            }
        }
        else if indexPath.section == 3{
            if commanArray.count>0 {
                
                var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                
                for  i in 0..<HoleTypeArray.count{
                    
                    if HoleTypeArray[i] == commanArray[indexPath.item]{
                        
                        selectedIndexPaths = [indexPath]
                        cell.isSelected = true
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                        
                        let rowIsSelected = selectedIndexPaths.contains(indexPath)
         cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
         cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                    }
                }
            }
        }
        else if indexPath.section == 4{
            if commanArray.count>0 {
                
                var selectedIndexPaths = collectionView.indexPathsForSelectedItems!
                
                for  i in 0..<CoursesTypeArray.count{
                    
                    if CoursesTypeArray[i] == commanArray[indexPath.item]{
                        
                        selectedIndexPaths = [indexPath]
                        cell.isSelected = true
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                        
                        let rowIsSelected = selectedIndexPaths.contains(indexPath)
         cell.filterButton.backgroundColor =  rowIsSelected ? UIColor.glfBluegreen : UIColor.glfWhite
         cell.filterButton.textColor = rowIsSelected ? UIColor.glfWhite : UIColor.glfBlack
                    }
                }
            }
        }*/
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var cell = FilterCollectionViewCell()

        /*if indexPath.section == 0{
            commanArray = section1
        }
        else if indexPath.section == 1{
            commanArray = section2
        }
        else if indexPath.section == 2{
            commanArray = section3
        }
        else if indexPath.section == 3{
            commanArray = section4
        }
        else if indexPath.section == 4{
            commanArray = section5
        }*/
        
        let array = allSections[indexPath.section]
        commanArray = array as! [String]
        
        // -------------------- For all Selection ----------------------------
        
        if commanArray[indexPath.item] == "All".localized(){
            
            for i in 0..<commanArray.count{
                
                if self.fromSwingSession{
                    if indexPath.section == 0{
                        PlayTypeArray = Array(Set(PlayTypeArray))
                        PlayTypeArray.append(commanArray[i])
                    }
                }
                else if self.fromSwingPerform{
                    
                    if indexPath.section == 0{
                        
                        RSTypeArray = Array(Set(RSTypeArray))
                        RSTypeArray.append(commanArray[i])
                    }
                    else if indexPath.section == 1{
                        PlayTypeArray = Array(Set(PlayTypeArray))
                        PlayTypeArray.append(commanArray[i])
                    }
                    else if indexPath.section == 2{
                        CSTypeArray = Array(Set(CSTypeArray))
                        CSTypeArray.append(commanArray[i])
                    }
                }
                else{
                    
                    if self.fromScorePutting{
                        if indexPath.section == 0{
                            
                            RSTypeArray = Array(Set(RSTypeArray))
                            RSTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 1{
                            HoleTypeArray = Array(Set(HoleTypeArray))
                            HoleTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 2{
                            CoursesTypeArray = Array(Set(CoursesTypeArray))
                            CoursesTypeArray.append(commanArray[i])
                        }
                    }
                    else{
                        if indexPath.section == 0{
                            
                            RSTypeArray = Array(Set(RSTypeArray))
                            RSTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 1{
                            CSTypeArray = Array(Set(CSTypeArray))
                            CSTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 2{
                            HoleTypeArray = Array(Set(HoleTypeArray))
                            HoleTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 3{
                            CoursesTypeArray = Array(Set(CoursesTypeArray))
                            CoursesTypeArray.append(commanArray[i])
                        }
                    }

                }
                /*if indexPath.section == 0{
                    
                    RSTypeArray = Array(Set(RSTypeArray))
                    RSTypeArray.append(commanArray[i])
                }
                else if indexPath.section == 1{
                    PlayTypeArray = Array(Set(PlayTypeArray))
                    PlayTypeArray.append(commanArray[i])
                }
                else if indexPath.section == 2{
                    CSTypeArray = Array(Set(CSTypeArray))
                    CSTypeArray.append(commanArray[i])
                }
                else if indexPath.section == 3{
                    HoleTypeArray = Array(Set(HoleTypeArray))
                    HoleTypeArray.append(commanArray[i])
                }
                else if indexPath.section == 4{
                    CoursesTypeArray = Array(Set(CoursesTypeArray))
                    CoursesTypeArray.append(commanArray[i])
                }*/
                Constants.finalFilterDic = ["RSTypeArray": RSTypeArray, "PlayTypeArray": PlayTypeArray, "CSTypeArray": CSTypeArray, "HoleTypeArray": HoleTypeArray, "CoursesTypeArray": CoursesTypeArray]
                //print("finalFilterDic \(finalFilterDic)!")
                
                cell = collectionView.cellForItem(at: IndexPath(row: i, section: indexPath.section)) as! FilterCollectionViewCell
                cell.filterButton.backgroundColor = UIColor.glfBluegreen
                cell.filterButton.textColor = UIColor.glfWhite
                
                cell.isSelected = true
                collectionView.selectItem(at: IndexPath(row: i, section: indexPath.section), animated: false, scrollPosition: .left)
            }
        }
        else{
            //---------------- For Single Selection -------------------
//            var cell = FilterCollectionViewCell()
            
            if self.fromSwingSession{
                if indexPath.section == 0{
                    PlayTypeArray.append(commanArray[indexPath.item])
                }
            }
            else if self.fromSwingPerform{
                if indexPath.section == 0{
                    RSTypeArray.removeAll()
                    RSTypeArray = [String]()
                    RSTypeArray.append(commanArray[indexPath.item])
                }
                else if indexPath.section == 1{
                    PlayTypeArray.append(commanArray[indexPath.item])
                    
                }
                else if indexPath.section == 2{
                    CSTypeArray.append(commanArray[indexPath.item])
                    
                }
            }
            else{
                if self.fromScorePutting{
                    if indexPath.section == 0{
                        RSTypeArray.removeAll()
                        RSTypeArray = [String]()
                        RSTypeArray.append(commanArray[indexPath.item])
                    }
                    else if indexPath.section == 1{
                        HoleTypeArray.append(commanArray[indexPath.item])
                    }
                    else if indexPath.section == 2{
                        CoursesTypeArray.append(commanArray[indexPath.item])
                    }
                }
                else{
                    if indexPath.section == 0{
                        RSTypeArray.removeAll()
                        RSTypeArray = [String]()
                        RSTypeArray.append(commanArray[indexPath.item])
                    }
                    else if indexPath.section == 1{
                        CSTypeArray.append(commanArray[indexPath.item])
                    }
                    else if indexPath.section == 2{
                        HoleTypeArray.append(commanArray[indexPath.item])
                    }
                    else if indexPath.section == 3{
                        CoursesTypeArray.append(commanArray[indexPath.item])
                    }
                }
            }
            /*if indexPath.section == 0{
                RSTypeArray.removeAll()
                RSTypeArray = [String]()
                RSTypeArray.append(commanArray[indexPath.item])
            }
            else if indexPath.section == 1{
                PlayTypeArray.append(commanArray[indexPath.item])

            }
            else if indexPath.section == 2{
                CSTypeArray.append(commanArray[indexPath.item])

            }
            else if indexPath.section == 3{
                HoleTypeArray.append(commanArray[indexPath.item])
                
            }
            else if indexPath.section == 4{
                CoursesTypeArray.append(commanArray[indexPath.item])
                
            }*/
            if (RSTypeArray.count>0 && commanArray.contains(RSTypeArray[0])) || (PlayTypeArray.count>0 && commanArray.contains(PlayTypeArray[0])) || (CSTypeArray.count>0 && commanArray.contains(CSTypeArray[0])) || (HoleTypeArray.count>0 && commanArray.contains(HoleTypeArray[0])) || (CoursesTypeArray.count>0 && commanArray.contains(CoursesTypeArray[0])){
                
                Constants.finalFilterDic = ["RSTypeArray": RSTypeArray, "PlayTypeArray": PlayTypeArray, "CSTypeArray": CSTypeArray, "HoleTypeArray": HoleTypeArray, "CoursesTypeArray": CoursesTypeArray]
            }
            //print("finalFilterDic \(finalFilterDic)!")
            
            if indexPath.section == 0 && RSTypeArray.count==1{

                for i in 0..<commanArray.count{
                cell = collectionView.cellForItem(at: IndexPath(row: i, section: indexPath.section)) as! FilterCollectionViewCell
                cell.filterButton.backgroundColor = UIColor.glfWhite
                cell.filterButton.textColor = UIColor.glfBlack
                
                cell.isSelected = false
                collectionView.deselectItem(at: IndexPath(row: i, section: indexPath.section), animated: false)
                
                }
                let index = commanArray.index(of: commanArray[indexPath.item])!
                
                cell = collectionView.cellForItem(at: IndexPath(row: index, section: indexPath.section)) as! FilterCollectionViewCell
                cell.filterButton.backgroundColor = UIColor.glfBluegreen
                cell.filterButton.textColor = UIColor.glfWhite
                
                cell.isSelected = true
                collectionView.selectItem(at: IndexPath(row: index, section: indexPath.section), animated: false, scrollPosition: .left)
            
            }
            else{
                cell = collectionView.cellForItem(at: indexPath) as! FilterCollectionViewCell
                cell.filterButton.backgroundColor = UIColor.glfBluegreen
                cell.filterButton.textColor = UIColor.glfWhite
                
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
            
            //---------- For secend last index selected, make all -----------
            
            /*if ((indexPath.section==0) && (RSTypeArray.count == commanArray.count-1) && !(RSTypeArray.contains("All".localized()))) ||
                ((indexPath.section==1) && (PlayTypeArray.count == commanArray.count-1) && !(PlayTypeArray.contains("All".localized()))) ||
                ((indexPath.section==2) && (CSTypeArray.count == commanArray.count-1) && !(CSTypeArray.contains("All".localized()))) ||
                ((indexPath.section==3) && (HoleTypeArray.count == commanArray.count-1) && !(HoleTypeArray.contains("All".localized()))) ||
                ((indexPath.section==4) && (CoursesTypeArray.count == commanArray.count-1) && !(CoursesTypeArray.contains("All".localized()))){*/
            if ((RSTypeArray.count == commanArray.count-1) && !(RSTypeArray.contains("All".localized()))) ||
                ((PlayTypeArray.count == commanArray.count-1) && !(PlayTypeArray.contains("All".localized()))) ||
                ((CSTypeArray.count == commanArray.count-1) && !(CSTypeArray.contains("All".localized()))) ||
                ((HoleTypeArray.count == commanArray.count-1) && !(HoleTypeArray.contains("All".localized()))) ||
                ((CoursesTypeArray.count == commanArray.count-1) && !(CoursesTypeArray.contains("All".localized()))){
                
                for i in 0..<commanArray.count{
                    
                    if self.fromSwingSession{
                         if indexPath.section == 0{
                            PlayTypeArray = Array(Set(PlayTypeArray))
                            PlayTypeArray.append(commanArray[i])
                        }
                    }
                    else if self.fromSwingPerform{
                        if indexPath.section == 0{
                            RSTypeArray = Array(Set(RSTypeArray))
                            RSTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 1{
                            PlayTypeArray = Array(Set(PlayTypeArray))
                            PlayTypeArray.append(commanArray[i])
                        }
                        else if indexPath.section == 2{
                            CSTypeArray = Array(Set(CSTypeArray))
                            CSTypeArray.append(commanArray[i])
                        }
                    }
                    else{
                        if self.fromScorePutting{
                            
                            if indexPath.section == 0{
                                RSTypeArray = Array(Set(RSTypeArray))
                                RSTypeArray.append(commanArray[i])
                            }
                            else if indexPath.section == 1{
                                HoleTypeArray = Array(Set(HoleTypeArray))
                                HoleTypeArray.append(commanArray[i])
                            }
                            else if indexPath.section == 2{
                                CoursesTypeArray = Array(Set(CoursesTypeArray))
                                CoursesTypeArray.append(commanArray[i])
                            }
                        }
                        else{
                            if indexPath.section == 0{
                                RSTypeArray = Array(Set(RSTypeArray))
                                RSTypeArray.append(commanArray[i])
                            }
                            else if indexPath.section == 1{
                                CSTypeArray = Array(Set(CSTypeArray))
                                CSTypeArray.append(commanArray[i])
                            }
                            else if indexPath.section == 2{
                                HoleTypeArray = Array(Set(HoleTypeArray))
                                HoleTypeArray.append(commanArray[i])
                            }
                            else if indexPath.section == 3{
                                CoursesTypeArray = Array(Set(CoursesTypeArray))
                                CoursesTypeArray.append(commanArray[i])
                            }
                        }
                    }
                    /*if indexPath.section == 0{
                        RSTypeArray = Array(Set(RSTypeArray))
                        RSTypeArray.append(commanArray[i])
                    }
                    else if indexPath.section == 1{
                        PlayTypeArray = Array(Set(PlayTypeArray))
                        PlayTypeArray.append(commanArray[i])
                    }
                    else if indexPath.section == 2{
                        CSTypeArray = Array(Set(CSTypeArray))
                        CSTypeArray.append(commanArray[i])
                    }
                    else if indexPath.section == 3{
                        HoleTypeArray = Array(Set(HoleTypeArray))
                        HoleTypeArray.append(commanArray[i])
                    }
                    else if indexPath.section == 4{
                        CoursesTypeArray = Array(Set(CoursesTypeArray))
                        CoursesTypeArray.append(commanArray[i])
                    }*/
                    
                    Constants.finalFilterDic = ["RSTypeArray": RSTypeArray, "PlayTypeArray": PlayTypeArray, "CSTypeArray": CSTypeArray, "HoleTypeArray": HoleTypeArray, "CoursesTypeArray": CoursesTypeArray]
                    //print("finalFilterDic \(finalFilterDic)!")
                    
                    cell = collectionView.cellForItem(at: IndexPath(row: i, section: indexPath.section)) as! FilterCollectionViewCell
                    cell.filterButton.backgroundColor = UIColor.glfBluegreen
                    cell.filterButton.textColor = UIColor.glfWhite
                    
                    cell.isSelected = true
                    collectionView.selectItem(at: IndexPath(row: i, section: indexPath.section), animated: false, scrollPosition: .left)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        var cell = FilterCollectionViewCell()
        
        // -------------------- For all Deselection ----------------------------
        /*if indexPath.section == 0{
            commanArray = section1
        }
        else if indexPath.section == 1{
            commanArray = section2
        }
        else if indexPath.section == 2{
            commanArray = section3
        }
        else if indexPath.section == 3{
            commanArray = section4
        }
        else if indexPath.section == 4{
            commanArray = section5
        }*/
        let array = allSections[indexPath.section]
        commanArray = array as! [String]
        
        if commanArray[indexPath.item] == "All".localized(){
            if self.fromSwingSession{
                 if indexPath.section == 0{
                    PlayTypeArray.removeAll()
                    PlayTypeArray = [String]()
                }
            }
            else if self.fromSwingPerform{
                if indexPath.section == 0{
                    RSTypeArray.removeAll()
                    RSTypeArray = [String]()
                }
                else if indexPath.section == 1{
                    PlayTypeArray.removeAll()
                    PlayTypeArray = [String]()
                }
                else if indexPath.section == 2{
                    CSTypeArray.removeAll()
                    CSTypeArray = [String]()
                }
            }
            else{
                if self.fromScorePutting{
                    if indexPath.section == 0{
                        RSTypeArray.removeAll()
                        RSTypeArray = [String]()
                    }
                    else if indexPath.section == 1{
                        HoleTypeArray.removeAll()
                        HoleTypeArray = [String]()
                    }
                    else if indexPath.section == 2{
                        CoursesTypeArray.removeAll()
                        CoursesTypeArray = [String]()
                    }
                }
                else{
                    if indexPath.section == 0{
                        RSTypeArray.removeAll()
                        RSTypeArray = [String]()
                    }
                    else if indexPath.section == 1{
                        CSTypeArray.removeAll()
                        CSTypeArray = [String]()
                    }
                    else if indexPath.section == 2{
                        HoleTypeArray.removeAll()
                        HoleTypeArray = [String]()
                    }
                    else if indexPath.section == 3{
                        CoursesTypeArray.removeAll()
                        CoursesTypeArray = [String]()
                    }
                }

            }
            /*if indexPath.section == 0{
                RSTypeArray.removeAll()
                RSTypeArray = [String]()
            }
            else if indexPath.section == 1{
                PlayTypeArray.removeAll()
                PlayTypeArray = [String]()
            }
            else if indexPath.section == 2{
                CSTypeArray.removeAll()
                CSTypeArray = [String]()
            }
            else if indexPath.section == 3{
                HoleTypeArray.removeAll()
                HoleTypeArray = [String]()
            }
            else if indexPath.section == 4{
                CoursesTypeArray.removeAll()
                CoursesTypeArray = [String]()
            }*/
            
            Constants.finalFilterDic = ["RSTypeArray": RSTypeArray, "PlayTypeArray": PlayTypeArray, "CSTypeArray": CSTypeArray, "HoleTypeArray": HoleTypeArray, "CoursesTypeArray": CoursesTypeArray]
            //print("finalFilterDic \(finalFilterDic)!")
            
            for i in 0..<commanArray.count{
                
                cell = collectionView.cellForItem(at: IndexPath(row: i, section: indexPath.section)) as! FilterCollectionViewCell
                cell.filterButton.backgroundColor = UIColor.glfWhite
                cell.filterButton.textColor = UIColor.glfBlack
                
                cell.isSelected = false
                collectionView.deselectItem(at: IndexPath(row: i, section: indexPath.section), animated: false)
            }
        }
        else{
            // ----------- For Single Deselection -------------
            if self.fromSwingSession{
                if indexPath.section == 0{
                    PlayTypeArray = Array(Set(PlayTypeArray))
                }
            }
            else if self.fromSwingPerform{
                if indexPath.section == 0{
                    RSTypeArray = Array(Set(RSTypeArray))
                }
                else if indexPath.section == 1{
                    PlayTypeArray = Array(Set(PlayTypeArray))
                }
                else if indexPath.section == 2{
                    CSTypeArray = Array(Set(CSTypeArray))
                }
            }
            else{
                if self.fromScorePutting{
                    if indexPath.section == 0{
                        RSTypeArray = Array(Set(RSTypeArray))
                    }
                    else if indexPath.section == 1{
                        HoleTypeArray = Array(Set(HoleTypeArray))
                    }
                    else if indexPath.section == 2{
                        CoursesTypeArray = Array(Set(CoursesTypeArray))
                    }
                }
                else{
                    if indexPath.section == 0{
                        RSTypeArray = Array(Set(RSTypeArray))
                    }
                    else if indexPath.section == 1{
                        CSTypeArray = Array(Set(CSTypeArray))
                    }
                    else if indexPath.section == 2{
                        HoleTypeArray = Array(Set(HoleTypeArray))
                    }
                    else if indexPath.section == 3{
                        CoursesTypeArray = Array(Set(CoursesTypeArray))
                    }
                }

            }
            /*if indexPath.section == 0{
                RSTypeArray = Array(Set(RSTypeArray))
            }
            else if indexPath.section == 1{
                PlayTypeArray = Array(Set(PlayTypeArray))
            }
            else if indexPath.section == 2{
                CSTypeArray = Array(Set(CSTypeArray))
            }
            else if indexPath.section == 3{
                HoleTypeArray = Array(Set(HoleTypeArray))
            }
            else if indexPath.section == 4{
                CoursesTypeArray = Array(Set(CoursesTypeArray))
            }*/
            if commanArray.count>0{
                
                if RSTypeArray.count>0 && RSTypeArray.contains(commanArray[indexPath.item]){
                    for j in 0..<RSTypeArray.count{
                        if RSTypeArray[j] == commanArray[indexPath.item]{
                            RSTypeArray.remove(at: j)
                            break
                        }
                    }
                }
                else if PlayTypeArray.count>0 && PlayTypeArray.contains(commanArray[indexPath.item]){
                    for j in 0..<PlayTypeArray.count{
                        if PlayTypeArray[j] == commanArray[indexPath.item]{
                            PlayTypeArray.remove(at: j)
                            break
                        }
                    }
                }
                else if CSTypeArray.count>0 && CSTypeArray.contains(commanArray[indexPath.item]){
                    for j in 0..<CSTypeArray.count{
                        if CSTypeArray[j] == commanArray[indexPath.item]{
                            CSTypeArray.remove(at: j)
                            break
                        }
                    }
                }
                else if HoleTypeArray.count>0 && HoleTypeArray.contains(commanArray[indexPath.item]){
                    for j in 0..<HoleTypeArray.count{
                        if HoleTypeArray[j] == commanArray[indexPath.item]{
                            HoleTypeArray.remove(at: j)
                            break
                        }
                    }
                }
                else if CoursesTypeArray.count>0 && CoursesTypeArray.contains(commanArray[indexPath.item]){
                    for j in 0..<CoursesTypeArray.count{
                        if CoursesTypeArray[j] == commanArray[indexPath.item]{
                            CoursesTypeArray.remove(at: j)
                            break
                        }
                    }
                }
                Constants.finalFilterDic = ["RSTypeArray": RSTypeArray, "PlayTypeArray": PlayTypeArray, "CSTypeArray": CSTypeArray, "HoleTypeArray": HoleTypeArray, "CoursesTypeArray": CoursesTypeArray]
                //print("finalFilterDic\(finalFilterDic)!")
                
                cell = collectionView.cellForItem(at: indexPath) as! FilterCollectionViewCell
                cell.filterButton.backgroundColor = UIColor.glfWhite
                cell.filterButton.textColor = UIColor.glfBlack
                
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: false)
                //break
            }
            
            //------- if all index selected, on single tap ~ make "All button" deslected -------
            
            if  (RSTypeArray.count>0 && (RSTypeArray.contains("All".localized()))) || (PlayTypeArray.count>0 && (PlayTypeArray.contains("All".localized()))) || (CSTypeArray.count>0 && (CSTypeArray.contains("All".localized()))) || (HoleTypeArray.count>0 && (HoleTypeArray.contains("All".localized()))) || (CoursesTypeArray.count>0 && (CoursesTypeArray.contains("All".localized()))){
                
                var index: Int = 0
                
                if self.fromSwingSession{
                    if indexPath.section == 0 && PlayTypeArray.count>0 && (PlayTypeArray.contains("All".localized())){
                        index = PlayTypeArray.index(of: "All".localized())!
                        PlayTypeArray.remove(at: index)
                    }
                }
                else if self.fromSwingPerform{
                    if indexPath.section == 0 && RSTypeArray.count>0 && (RSTypeArray.contains("All".localized())){
                        //index = RSTypeArray.index(of: "All".localized())!
                        RSTypeArray.removeAll()
                        RSTypeArray = [String]()
                    }
                    else if indexPath.section == 1 && PlayTypeArray.count>0 && (PlayTypeArray.contains("All".localized())){
                        index = PlayTypeArray.index(of: "All".localized())!
                        PlayTypeArray.remove(at: index)
                    }
                    else if indexPath.section == 2 && CSTypeArray.count>0 && (CSTypeArray.contains("All".localized())){
                        index = CSTypeArray.index(of: "All".localized())!
                        CSTypeArray.remove(at: index)
                    }
                }
                else
                {
                    if self.fromScorePutting{
                        if indexPath.section == 0 && RSTypeArray.count>0 && (RSTypeArray.contains("All".localized())){
                            //index = RSTypeArray.index(of: "All".localized())!
                            RSTypeArray.removeAll()
                            RSTypeArray = [String]()
                        }
                        else if indexPath.section == 1 && HoleTypeArray.count>0 && (HoleTypeArray.contains("All".localized())){
                            index = HoleTypeArray.index(of: "All".localized())!
                            HoleTypeArray.remove(at: index)
                        }
                        else if indexPath.section == 2 && CoursesTypeArray.count>0 && (CoursesTypeArray.contains("All".localized())){
                            index = CoursesTypeArray.index(of: "All".localized())!
                            CoursesTypeArray.remove(at: index)
                        }
                    }
                    else{
                        if indexPath.section == 0 && RSTypeArray.count>0 && (RSTypeArray.contains("All".localized())){
                            //index = RSTypeArray.index(of: "All".localized())!
                            RSTypeArray.removeAll()
                            RSTypeArray = [String]()
                        }
                        else if indexPath.section == 1 && CSTypeArray.count>0 && (CSTypeArray.contains("All".localized())){
                            index = CSTypeArray.index(of: "All".localized())!
                            CSTypeArray.remove(at: index)
                        }
                        else if indexPath.section == 2 && HoleTypeArray.count>0 && (HoleTypeArray.contains("All".localized())){
                            index = HoleTypeArray.index(of: "All".localized())!
                            HoleTypeArray.remove(at: index)
                        }
                        else if indexPath.section == 3 && CoursesTypeArray.count>0 && (CoursesTypeArray.contains("All".localized())){
                            index = CoursesTypeArray.index(of: "All".localized())!
                            CoursesTypeArray.remove(at: index)
                        }
                    }
                }
                /*if indexPath.section == 0 && RSTypeArray.count>0 && (RSTypeArray.contains("All".localized())){
                    //index = RSTypeArray.index(of: "All".localized())!
                    RSTypeArray.removeAll()
                    RSTypeArray = [String]()
                }
                else if indexPath.section == 1 && PlayTypeArray.count>0 && (PlayTypeArray.contains("All".localized())){
                    index = PlayTypeArray.index(of: "All".localized())!
                    PlayTypeArray.remove(at: index)
                }
                else if indexPath.section == 2 && CSTypeArray.count>0 && (CSTypeArray.contains("All".localized())){
                    index = CSTypeArray.index(of: "All".localized())!
                    CSTypeArray.remove(at: index)
                }
                else if indexPath.section == 3 && HoleTypeArray.count>0 && (HoleTypeArray.contains("All".localized())){
                    index = HoleTypeArray.index(of: "All".localized())!
                    HoleTypeArray.remove(at: index)
                }
                else if indexPath.section == 4 && CoursesTypeArray.count>0 && (CoursesTypeArray.contains("All".localized())){
                    index = CoursesTypeArray.index(of: "All".localized())!
                    CoursesTypeArray.remove(at: index)
                }*/
                
                Constants.finalFilterDic = ["RSTypeArray": RSTypeArray, "PlayTypeArray": PlayTypeArray, "CSTypeArray": CSTypeArray, "HoleTypeArray": HoleTypeArray, "CoursesTypeArray": CoursesTypeArray]
                //print("finalFilterDic\(finalFilterDic)!")
                
                if indexPath.section == 0 {
                    for i in 0..<commanArray.count{
                        cell = collectionView.cellForItem(at: IndexPath(row: i, section: indexPath.section)) as! FilterCollectionViewCell
                        cell.filterButton.backgroundColor = UIColor.glfWhite
                        cell.filterButton.textColor = UIColor.glfBlack
                        
                        cell.isSelected = false
                        collectionView.deselectItem(at: IndexPath(row: i, section: indexPath.section), animated: false)
                    }
                }
                else{
                let endIndex = commanArray.index(of: "All".localized())!

                cell = collectionView.cellForItem(at: IndexPath(row: endIndex, section: indexPath.section)) as! FilterCollectionViewCell
                    cell.filterButton.backgroundColor = UIColor.glfWhite
                    cell.filterButton.textColor = UIColor.glfBlack
                
                cell.isSelected = false
                collectionView.deselectItem(at: IndexPath(row: endIndex, section: indexPath.section), animated: false)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Dequeue Reusable Supplementary View
        if let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FilterCollectionReusableView", for: indexPath) as? FilterCollectionReusableView {
            
//            let array = allSections[indexPath.section]
            
            if self.fromSwingSession{
                if indexPath.section == 0 {
                    supplementaryView.sectionHeaderLabel.text =  "Play Type"
                }
            }
            else if self.fromSwingPerform{
                
                if indexPath.section == 0 {
                    supplementaryView.sectionHeaderLabel.text = "Numbers of Rounds/Duration".localized()
                }
                else if indexPath.section == 1 {
                    supplementaryView.sectionHeaderLabel.text =  "Play Type"
                }
                else if indexPath.section == 2 {
                    supplementaryView.sectionHeaderLabel.text = "Club Used"
                }
            }
            else{
                
                if self.fromScorePutting{
                    if indexPath.section == 0 {
                        supplementaryView.sectionHeaderLabel.text = "Numbers of Rounds/Duration".localized()
                    }
                    else if indexPath.section == 1 {
                        supplementaryView.sectionHeaderLabel.text = "Holes Type"
                    }
                    else if indexPath.section == 2 {
                        supplementaryView.sectionHeaderLabel.text = "Courses".localized()
                    }
                }
                else{
                    if indexPath.section == 0 {
                        supplementaryView.sectionHeaderLabel.text = "Numbers of Rounds/Duration".localized()
                    }
                    else if indexPath.section == 1 {
                        // put condition on my score: putting
                        supplementaryView.sectionHeaderLabel.text =  "Club Used"
                    }
                    else if indexPath.section == 2 {
                        supplementaryView.sectionHeaderLabel.text = "Holes Type"
                    }
                    else if indexPath.section == 3 {
                        supplementaryView.sectionHeaderLabel.text = "Courses".localized()
                    }
                }

            }
            // Configure Supplementary View
            /*if indexPath.section == 0 {
                supplementaryView.sectionHeaderLabel.text = "Number of Rounds / Duration"
            }
            else if indexPath.section == 1 {
                supplementaryView.sectionHeaderLabel.text =  "Play Type"
            }
            else if indexPath.section == 2 {
                supplementaryView.sectionHeaderLabel.text = "Club Used"
            }
            else if indexPath.section == 3 {
                supplementaryView.sectionHeaderLabel.text = "Holes Type"
            }
            else if indexPath.section == 4 {
                supplementaryView.sectionHeaderLabel.text = "Courses"
            }*/
            
            return supplementaryView
        }
        
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize = CGSize()
        
            let array = allSections[indexPath.section]
            size = ((array[indexPath.row]) as! String).size()
        
        /*if indexPath.section == 0 {
            size = section1[indexPath.row].size()
        }
        else if indexPath.section == 1 {
            size = section2[indexPath.row].size()
        }
        else if indexPath.section == 2 {
            size = section3[indexPath.row].size()
        }
        else if indexPath.section == 3 {
            size = section4[indexPath.row].size()
        }
        else if indexPath.section == 4 {
            size = section5[indexPath.row].size()
        }*/
        return CGSize(width: size.width + 30.0, height:30)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        self.fromSwingSession = false
        self.fromSwingPerform = false
        self.fromScorePutting = false
    }
}

