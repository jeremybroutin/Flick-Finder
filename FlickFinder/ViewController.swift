//
//  ViewController.swift
//  FlickFinder
//
//  Created by Jeremy Broutin on 6/11/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var titleOne: UILabel!
  @IBOutlet weak var titleTwo: UILabel!
  @IBOutlet weak var imagePlaceholder: UIImageView!
  @IBOutlet weak var titlePlaceholder: UILabel!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var searchLatField: UITextField!
  @IBOutlet weak var searchLongField: UITextField!
  @IBOutlet weak var textSearchButton: UIButton!
  @IBOutlet weak var coordinatesSearchButton: UIButton!
  
  //Define constants
  let BASE_URL = "https://api.flickr.com/services/rest/"
  let METHOD_NAME = "flickr.photos.search"
  let API_KEY = "aed5bae79e7824cc4a13e45c49163a88"
  let EXTRAS = "url_m"
  let TEXT = "baby+asian+elephant"
  let DATA_FORMAT = "json"
  let NO_JSON_CALLBACK = "1"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Do any additional setup after loading the view, typically from a nib.
  }
  

  func getSearchedImage(){
    //API method arguments
    let methodArguments = [
      "method": METHOD_NAME,
      "api_key": API_KEY,
      "text": TEXT,
      "extras": EXTRAS,
      "format": DATA_FORMAT,
      "nojsoncallback": NO_JSON_CALLBACK
    ]
    
    //Initialize session and url
    let session = NSURLSession.sharedSession()
    let urlString = BASE_URL + escapedParameters(methodArguments)
    let url = NSURL(string: urlString)!
    let request = NSURLRequest(URL: url)
    
    //Initialize task for getting data
    let task = session.dataTaskWithRequest(request) {data, response, downloadError in
      if let error = downloadError {
        println("Could not complete the request \(error)")
      }
      else {
        // simply printing te request for debugging
        println(request)
        //parse the received data
        var parsingError: NSError? = nil
        let parsedResults: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        println(parsedResults)
      }
    }
    task.resume()
  }
  
  //Helper function: Given a dictionary of parameters, convert to a string for a url
  func escapedParameters(parameters: [String : AnyObject]) -> String {
    var urlVars = [String]()
    for (key, value) in parameters {
      //Make sure that it is a string value
      let stringValue = "\(value)"
      //Escape it
      let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      //Append it
      urlVars += [key + "=" + "\(escapedValue!)"]
    }
    return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
  }

  @IBAction func searchPhotosByPhraseButton(sender: AnyObject) {
    getSearchedImage()
  }
  
  @IBAction func searchPhotosByLatLonButton(sender: AnyObject) {
  }
  

}

