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
  @IBOutlet weak var defaultTitle: UILabel!
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
  let TEXT = "screugnen+asian+elephant"
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
        let parsedResults: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        //set json data into a dictionary
        if let photosDictionary = parsedResults?.valueForKey("photos") as? NSDictionary{
          
          var totalPhotosVal = 0
          if let totalPhotos = photosDictionary["total"] as? String {
            totalPhotosVal = (totalPhotos as NSString).integerValue
          }
          
          if totalPhotosVal > 0 {
            //set dictionary content into an array
            if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
              
              //grab a single, random image
              let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
              let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
              
              //get the image url and thte titla
              let imageUrlString = photoDictionary["url_m"] as? String
              let imageURL = NSURL(string: imageUrlString!)
              let photoTitle = photoDictionary["title"] as? String
              
              //debug
              println(imageURL)
              
              //check if image exists at the url
              if let imageData = NSData(contentsOfURL: imageURL!){
                dispatch_async(dispatch_get_main_queue(), {
                  self.defaultTitle.hidden = true
                  self.imagePlaceholder.image = UIImage(data: imageData)
                  self.titlePlaceholder.text = photoTitle
                })
              }
              else{
                println("Image doesn't exist at \(imageURL)")
                dispatch_async(dispatch_get_main_queue(), {
                  
                })
              }
            }
          }
          else{
            println("There is no photo available.")
            dispatch_async(dispatch_get_main_queue(), {
              self.imagePlaceholder.image = UIImage(named: "no image available")
              self.defaultTitle.enabled = false
              self.titlePlaceholder.text = "Oups, nothing found... Try another search"
              self.titlePlaceholder.textAlignment = NSTextAlignment.Center
            })
          }
        }
      
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

