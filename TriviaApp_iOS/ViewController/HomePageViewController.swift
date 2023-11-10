//
//  HomePageViewController.swift
//  TriviaApp_iOS
//
//  Created by Naved  on 08/11/23.
//

import UIKit

class HomePageViewController: UIViewController, ScoreResult {
 
    @IBOutlet weak var discriptionLabel: UILabel!
    var finalScore: String = "" {
        didSet{
            if finalScore != ""{
                discriptionLabel.text = "You Total Score is " + finalScore + "\n continue to next Quiz.."
            }
        }
    }
  
    @IBAction func LetGoButton(_ sender: Any) {
        let destinationVc = storyboard?.instantiateViewController(withIdentifier: "QuizViewController")
        as! QuizViewController
        destinationVc.finalDelegate = self
        self.navigationController?.pushViewController(destinationVc, animated: true)
    }
}

