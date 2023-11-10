//
//  QuizModel.swift
//  TriviaApp_iOS
//
//  Created by Naved  on 08/11/23.
//

import Foundation

struct  QuizModel : Decodable{
    let responseCode : Int
    let results : [Results]
    enum CodingKeys : String , CodingKey{
        case results
        case responseCode = "response_code"
    }
    
}

struct Results : Decodable{
    let category : String
    let difficulty : String
    let question : String
    let correctAns : String
    let incorrectAns : [String]
    enum CodingKeys : String, CodingKey
    {
        case category
        case difficulty
        case question
        case correctAns  = "correct_answer"
        case incorrectAns  = "incorrect_answers"
    }
}

