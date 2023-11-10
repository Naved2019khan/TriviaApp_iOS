//
//  QuizViewController.swift
//  TriviaApp_iOS
//
//  Created by Naved  on 08/11/23.
//

import UIKit
import Alamofire

protocol ScoreResult{
    var finalScore: String { get set}
}

class QuizViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var quizTableView: UITableView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    let baseUrl = "https://opentdb.com/api.php?amount=10&amp;category=18&amp;difficulty=easy&amp;type=multiple"
    var totalOption = [String]()
    var correctAnswer = ""
    var quizData : [Results]? = nil
    var questionCount = 0
    var score = 0
    var optionLabels = ["A","B","C","D"]
    var notAnswered = true
    var loader: UIActivityIndicatorView!
    var finalDelegate : ScoreResult?
    
    // MARK: - Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        quizApiCall()
        loaderMethod()
    }
    
    // MARK: - Actions  Method
    @IBAction func nextButton(_ sender: Any) {
        if questionCount != 9  && quizData != nil && !notAnswered
        {
            questionCount += 1
            newQuiz()
        }
        else if questionCount == 9  && !notAnswered {
            finalDelegate?.finalScore = String(score)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: -  Methods
    fileprivate func newQuiz() { ///`New State of Quiz`
        guard let data = quizData?[questionCount] else { return }
        totalOption = data.incorrectAns // three option without correctAns
        totalOption.append(data.correctAns) // four option
        correctAnswer = data.correctAns // save correct for later
        totalOption.shuffle() // shuffle otherwise last will be always right ans
        quizTableView.reloadData()
        questionLabel.text = "Q" + "\(questionCount + 1) " + data.question.decodingSymbols()
        notAnswered = true // it reset the didselect behavior
        accessibilityProvider(
            accessibilityLabel: questionLabel,
            accessibilityText: "Question Number" + "\(questionCount + 1) " + data.question.decodingSymbols() + "Options are"
        )
    }
    
    fileprivate func loaderMethod() {
        loader = UIActivityIndicatorView(style: .large)
        loader.color = .gray
        loader.center = view.center
        view.addSubview(loader)
        loader.startAnimating()

    }
    
    /**This Code Give Accessibiltiy to any view**/
    func accessibilityProvider(accessibilityLabel : UIView , accessibilityText : String){
        accessibilityLabel.isAccessibilityElement = true
        accessibilityLabel.accessibilityLabel = accessibilityText
    }
}
// MARK: - TableView Delgate Method
extension QuizViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return totalOption.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = quizTableView.dequeueReusableCell(withIdentifier: "QuizTableViewCell", for: indexPath) as! QuizTableViewCell
        cell.viewInside.backgroundColor = UIColor(named: "AppWhiteColor") // default backgroundColor
        cell.optionsButton.setTitle(optionLabels[indexPath.row], for: .normal) // set Options
        cell.labelOption.text = totalOption[indexPath.row].decodingSymbols()
        accessibilityProvider(
            accessibilityLabel: cell,
            accessibilityText: "Option" + optionLabels[indexPath.row] + totalOption[indexPath.row].decodingSymbols()
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableView.automaticDimension }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cell animation
        cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
        cell.alpha = 0
        let delay = 0.2 * Double(indexPath.row)
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseInOut, animations: {
            cell.transform = .identity
            cell.alpha = 1
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = quizTableView.cellForRow(at: indexPath) as! QuizTableViewCell
        if notAnswered{
            if totalOption[indexPath.row] == correctAnswer //  wrong answer show in red and green for correct
            {
                selectedCell.viewInside.backgroundColor = .systemGreen
                score += 1
                scoreLabel.text = "Score : " + String(score)
            }
        
            else{
                let correctAnsIndex = Int(totalOption.firstIndex(of : correctAnswer) ?? 0) // correct ans form option
                let ansCell =  tableView.cellForRow(at:  [0,correctAnsIndex]) as! QuizTableViewCell
                ansCell.viewInside.backgroundColor = .systemGreen
                selectedCell.viewInside.backgroundColor = .systemRed
            }
            notAnswered = false
        }
    }
}

// MARK: - Api Method
extension QuizViewController {
    func quizApiCall(){
        AF.request(baseUrl).responseDecodable(of: QuizModel.self){
            [self] (response) in
            guard let data = response.value else { return }
            quizData = data.results
            loader.stopAnimating()
            newQuiz()
            
        }
    }
}

extension String {
    // Decode Special Character in Sentence
    func decodingSymbols() -> String {
        var decodedString = self
        let entities = ["&quot;": "\"", "&apos;": "'", "&#039;": "'", "&amp;": "&", "&lt;": "<", "&gt;": ">"]
        for (entity, character) in entities {
            decodedString = decodedString.replacingOccurrences(of: entity, with: character)
        }
        return decodedString
    }
}
