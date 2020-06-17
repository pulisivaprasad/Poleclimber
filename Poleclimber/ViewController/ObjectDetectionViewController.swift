//
//  ObjectDetectionViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 31/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import AVKit
import Vision
import RMessage

class ObjectDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var detectBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var galleryBtn: UIButton!

    var predictions: [VNRecognizedObjectObservation] = []
    let objectDectectionModel =  MobileNetV2_SSDLite_openreach() //YOLOv3Tiny()
    @IBOutlet weak var noImgView: UIView!
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    var originalmageView = UIImageView()
    var modelRunningLocation = "iPhone"

    var cvpixelBuffer: CVPixelBuffer!
    let rControl = RMController()
    var feedbackObj: Feedback?
    var editPost = 0
    var fileName = ""
    var timeStamp = ""
    var requestMethod = ""
    var imageName = ""
    var detectionTime = ""
    var detectedClasses = ""
    var detections = [AnyObject]()
    var goodCofidanceValueObjArr = [AnyObject]()
    
    var textFiledDataDisc = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Visual Inspection"
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        buttonsView.isHidden = true
        namelabel.isHidden = true

        if editPost == 1 {
            detectBtn.isHidden = false
            noImgView.isHidden = true
            if let imagename = feedbackObj?.originalImg {
                 let image = self.loadeImage(name: imagename)
                imageView.image = image
                originalmageView.image = image
                getCVPixelBuffer(image: image!)
            }
            fileName = feedbackObj!.imgID ?? ""
            timeStamp = feedbackObj!.timeStamp ?? ""
            requestMethod = feedbackObj!.requestMethod ?? ""
            imageName = feedbackObj!.imageName ?? ""
            detectionTime = feedbackObj!.detectionTime ?? ""
            detectedClasses = feedbackObj!.detectedClasses ?? ""
            
//            detections = feedbackObj?.detections as AnyObject]
        }
        else{
            detectBtn.isHidden = true
        }
    }
    
    private func loadeImage(name: String) -> UIImage? {
           guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                                           in: .userDomainMask,
                                                                           appropriateFor:nil,
                                                                           create:false)
            else {
                // May never happen
                print ("No Document directory Error")
                return nil
            }

           // Construct your Path from device Documents Directory
           var imagesDirectory = documentsDirectory

           // Add your file name to path
           imagesDirectory.appendPathComponent(name)

           // Create your UIImage?
           let result = UIImage(contentsOfFile: imagesDirectory.path)
           
           return result
       }
    
   @IBAction func detectBtnAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalHUD(title: "Processing...", view: view)

        if Helper.sharedHelper.isNetworkAvailable() {
           apiCalling()
           // perform(#selector(detectSubImagesInImg), with: nil, afterDelay: 2)
        }
        else{
           rControl.showMessage(withSpec: warningSpec, title: "Info", body: "You don't have internet connection so classification will run using iOS ML model.")
            perform(#selector(detectSubImagesInImg), with: nil, afterDelay: 2)
        }
    }
    
    func imageSavingInS3Bucket() {
        guard let image = originalmageView.image else { return } //1
                  AWSS3Manager.shared.uploadImage(image: image, fileName: fileName, progress: {[weak self] ( uploadProgress) in
                      
                      guard let strongSelf = self else { return }
                     // strongSelf.progressView.progress = Float(uploadProgress)//2
                      
                  }) {[weak self] (uploadedFileUrl, error) in
                      
                      guard let strongSelf = self else { return }
                      if let finalPath = uploadedFileUrl as? String { // 3
                       print("sss == \(finalPath)")
                          //strongSelf.s3UrlLabel.text = "Uploaded file url: " + finalPath
                      } else {
                          print("\(String(describing: error?.localizedDescription))") // 4
                      }
                  }
    }
    
    
    func apiCalling() {
        let filename = "image_" + Date().description
        _ = originalmageView.image?.save(filename)
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: path).appendingPathComponent(filename)
            
        var parameters = [String : AnyObject]()
        parameters["file"] = url as AnyObject
      //  imageSavingInS3Bucket()
        PWebService.sharedWebService.callWebAPIWith(httpMethod: "POST", apiName: kBaseUrl, fileName: fileName, parameters: parameters, uploadImage: originalmageView.image) { (response, error) in
            Helper.sharedHelper.dismissHUD(view: self.view)
            if error == nil, let res = response?["detectedClasses"], res != nil {
              let poleValues = (response!["detectedClasses"] as AnyObject)
              self.detectedClasses = "\(poleValues as! [AnyObject])"
                self.modelRunningLocation = "cloud"

                self.timeStamp = (response!["timeStamp"] as AnyObject) as! String
                self.requestMethod = (response!["requestMethod"] as AnyObject) as! String
                self.imageName = (response!["imageName"] as AnyObject) as! String
                self.detectionTime = "\(response!["detectionTime"] as AnyObject)"
                
            //Pole tip not found in image
             guard (response!["detectedClasses"] as AnyObject).count != 0 else {
                Helper.sharedHelper.showGlobalAlertwithMessage("Pole tip could not be detected in the selected image.", vc: self)
                self.imageView.image = UIImage(named: "")
                self.noImgView.isHidden = false
                self.detectBtn.isHidden = true
                self.namelabel.text = "No pole tip found"
                self.dataSendToServer(reason: "NA", userResult: "NA", navigateToHome: 2)

                return
             }
                
            var myView = DrawRectangle()
            var myLabel = UILabel()
                
              print(poleValues)
              for i in 0 ..< (poleValues as! NSArray).count {
                let poleType = poleValues.object(at: i) as? String
                self.detections.append((response?["detections"] as AnyObject).object(at: i) as! NSArray)
                if poleType != "pole_tip" {
                 let resObj2 = (response?["detections"] as AnyObject).object(at: i)
                                                                                            
                 if let xPos = (resObj2 as AnyObject).object(at: 0) as? NSNumber, let yPos = (resObj2 as AnyObject).object(at: 1) as? NSNumber, let widthPos = (resObj2 as AnyObject).object(at: 2) as? NSNumber, let heightPos = (resObj2 as AnyObject).object(at: 3) as? NSNumber, let confidanceValue = (resObj2 as AnyObject).object(at: 4) as? NSNumber {
                    
                    let devcieHeight = (self.originalmageView.image?.size.height)! - 20
                    let devcieWidth = self.originalmageView.image?.size.width

                  var width1 = CGFloat(truncating: widthPos) - CGFloat(truncating: xPos)
                  width1 = (width1 / devcieWidth!) * self.boxesView.frame.width
                                                                                                
                  var height1 = CGFloat(truncating: heightPos) - CGFloat(truncating: yPos)
                  height1 = (height1 / devcieHeight) * self.boxesView.frame.height
                                                                                                
                  let yPos1 = ((CGFloat(truncating: yPos) / devcieHeight) * self.boxesView.frame.height)
                                                                                                
                    let xPos1 = ((CGFloat(truncating: xPos) / devcieWidth!) * self.boxesView.frame.width)
                                        
              //Removing the pole tip object & checking threshould value
                let confThresh = 0.85
                let objAspectRatio: CGFloat = 0.75

                if CGFloat(truncating: confidanceValue) > CGFloat(confThresh)  {
                let objHeight = height1
                let objWidth = width1
                let objRatio = objHeight / objWidth
        
                if  objRatio > objAspectRatio  {
//            if self.predictions.count > 0, let dummyConfidance = self.predictions.first?.confidence, object.confidence < dummyConfidance {
//                self.predictions.removeAll()
//            }
            
               self.goodCofidanceValueObjArr.append(resObj2 as AnyObject)
               }
             }
                                                                                                
                 myView = DrawRectangle(frame: CGRect(x: CGFloat(xPos1), y: CGFloat(yPos1), width: CGFloat(width1), height: CGFloat(height1)))
                 myView.poleType = poleType!
                                                                                                
                  myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 640, height: 640))
                   myLabel.text = poleType ?? "N/A"
                   myLabel.font = UIFont.systemFont(ofSize: 14)
                   myLabel.textColor = UIColor.black
                   myLabel.backgroundColor = poleType == "good_tip" ? UIColor.green : UIColor.red
                   myLabel.sizeToFit()
                   myLabel.frame = CGRect(x: myView.frame.origin.x, y: myView.frame.origin.y - myLabel.frame.height,
                                        width: myLabel.frame.width, height: myLabel.frame.height)
                    
                    if poleType == "good_tip" {
                        self.namelabel.text = "Good Tip Detected"
                    }
                    else{
                        self.namelabel.text = "Bad Tip Detected"
                    }
                    
               }
            }
          }
                guard self.goodCofidanceValueObjArr.count != 0 else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Quality of the selected image is not good  enough for analysis.", vc: self)
                  self.imageView.image = UIImage(named: "")
                  self.noImgView.isHidden = false
                  self.detectBtn.isHidden = true
                  self.namelabel.text = "No pole tip found"

                  self.dataSendToServer(reason: "Bad quality", userResult: "NA", navigateToHome: 2)

                  return
                }
                
                self.buttonsView.isHidden = false
                self.detectBtn.isHidden = true
                self.namelabel.isHidden = false
                self.boxesView.addSubview(myView)
                self.boxesView.addSubview(myLabel)

        }
        else{
            //Helper.sharedHelper.showGlobalAlertwithMessage(error!.localizedDescription, vc: self)
             self.detectSubImagesInImg()
        }

      }
}
    
    @objc func detectSubImagesInImg() {
        captureImageDetails(pixelBuffer: cvpixelBuffer!)
    }
    
    @IBAction func addPictureFromGallery(sender: UIButton) {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addPictureFromCamera(sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            Helper.sharedHelper.showGlobalAlertwithMessage("You don't have camera.", title: "Alert")
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            originalmageView.image = image
            getCVPixelBuffer(image: image)
            
             guard let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
             print(fileUrl.lastPathComponent) // get file Name
            // print(fileUrl.pathExtension)     // get file extension
             fileName = fileUrl.lastPathComponent
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getCVPixelBuffer(image: UIImage) {
         UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
         image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
         let newImage = UIGraphicsGetImageFromCurrentImageContext()!
         UIGraphicsEndImageContext()
                          
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
                          
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
                    
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
                          
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
                          
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        imageView.image = newImage
        cvpixelBuffer = pixelBuffer

        showAddImgView()
    }
    
     func showAddImgView() {
        noImgView.isHidden = true
        detectBtn.isHidden = false
    }
    
    // MARK: - Capture Session
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
          showAddImgView()

        // Get the pixel buffer from the capture session
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        cvpixelBuffer = pixelBuffer
    }
    
    func captureImageDetails(pixelBuffer: CVPixelBuffer)  {
          // load the Core ML model
        guard let visionModel:VNCoreMLModel = try? VNCoreMLModel(for: objectDectectionModel.model) else { return }
        //  set up the classification request
        let request = VNCoreMLRequest(model: visionModel){(finishedReq, error) in
                    
        guard let result = finishedReq.results as? [VNRecognizedObjectObservation] else {
            return
        }
            Helper.sharedHelper.dismissHUD(view: self.view)

            //Pole tip not found in image
            guard result.count != 0 else {
                  Helper.sharedHelper.showGlobalAlertwithMessage("Pole tip could not be detected in the selected image.", vc: self)
                  self.imageView.image = UIImage(named: "")
                  self.noImgView.isHidden = false
                  self.detectBtn.isHidden = true

                  return
            }
            
            //Removing the pole tip object & checking threshould value
            let confThresh = 0.85
            let objAspectRatio: CGFloat = 0.75
            
            for object in result {
                if (object.label != nil) && object.label != "pole_tip" && object.confidence > VNConfidence(confThresh)  {
                    let objHeight = object.boundingBox.height
                    let objWidth = object.boundingBox.width
                    let objRatio = objHeight / objWidth
                    
                    if  objRatio > objAspectRatio  {
                        if self.predictions.count > 0, let dummyConfidance = self.predictions.first?.confidence, object.confidence < dummyConfidance {
                            self.predictions.removeAll()
                        }
                        
                      self.predictions.append(object)
                    }
                }
            }
            
            guard self.predictions.first != nil else {
                Helper.sharedHelper.showGlobalAlertwithMessage("Quality of the selected image is not good  enough for analysis.", vc: self)
              self.imageView.image = UIImage(named: "")
              self.noImgView.isHidden = false
              self.detectBtn.isHidden = true

              return
            }

        //self.predictions = result
        DispatchQueue.main.async {
          self.buttonsView.isHidden = false
            self.detectBtn.isHidden = true
          self.namelabel.isHidden = false
            
            if self.predictions.first?.label == "good_tip" {
                self.namelabel.text = "Good Tip Detected"
            }
            else{
                self.namelabel.text = "Bad Tip Detected"
            }

            self.boxesView.predictedObjects = self.predictions

          //let objectBounds = VNImageRectForNormalizedRect(result[0].boundingBox, Int(self.videoPreview.frame.size.width), Int(self.videoPreview.frame.size.height))

          }
             //print(firstObservation.identifier, firstObservation.confidence)
        }
                
        request.imageCropAndScaleOption = .scaleFill
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @IBAction func AgreeBtnAction(_ sender: Any) {
        userfeedbackSaving(userKey: "AGREEUSERDETAILS", tipStatus: namelabel.text ?? "", reason: "")

        if Helper.sharedHelper.isNetworkAvailable(){
            dataSendToServer(reason:"NA", userResult: "Ok", navigateToHome: 1)
        }
        else{
            perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 3)
        }
        
        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Thank you. You can find these results in the history tab if you would like to see them again at a later date.")
    }
    
    @objc func navigateToHomeScreen() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func disAgreeBtnAction(_ sender: Any) {
        let pickerView = ToolbarPickerView()
        if self.namelabel.text == "Good Tip Detected"{
            pickerView.sePickerdata(poleType: "Good")
        }
        else{
            pickerView.sePickerdata(poleType: "Bad")
        }
        self.view.addSubview(pickerView)
        self.view.addSubview(pickerView.toolbar!)
        pickerView.toolbarDelegate = self
    }
    
    func submitBtnAction(selectedReason: String) {
        userfeedbackSaving(userKey: "DISAGREEUSERDETAILS", tipStatus: namelabel.text!, reason: selectedReason)

        if Helper.sharedHelper.isNetworkAvailable() {
            dataSendToServer(reason: selectedReason, userResult: "Disagree", navigateToHome: 1)
        }
        else{
            perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 3)
        }
        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Thank you. You can find these results in the history tab if you would like to see them again at a later date.")
    }
    
    func dataSendToServer(reason: String, userResult: String, navigateToHome: Int) {
        var parameters = [String : String]()
        parameters["PoletesterID"] = (userDefault.object(forKey: "USERNAME") as? String)
        parameters["DPno"] = textFiledDataDisc["DP Number"] != nil ? textFiledDataDisc["DP Number"] : feedbackObj?.dpnumber
        parameters["CPno"] = textFiledDataDisc["CP Number"] != nil ? textFiledDataDisc["CP Number"] : feedbackObj?.cpnumber
        parameters["Exchange_area"] = textFiledDataDisc["Exchange Area"] != nil ? textFiledDataDisc["Exchange Area"] : feedbackObj?.exchangeArea
        parameters["Latitude"] = textFiledDataDisc["Latitude"] != nil ? textFiledDataDisc["Latitude"] : feedbackObj?.latitude
        parameters["Longitude"] = textFiledDataDisc["Longitude"] != nil ? textFiledDataDisc["Longitude"] : feedbackObj?.longitude
        parameters["Userresult"] = userResult != nil ? userResult : feedbackObj?.userResult
        parameters["Reason"] = reason != nil ? reason : feedbackObj?.reason
        parameters["MLresult"] = namelabel.text != nil ? namelabel.text : feedbackObj?.mlResult
        parameters["timeStamp"] = timeStamp
        parameters["requestMethod"] = requestMethod
        parameters["imageName"] = imageName
        parameters["detectionTime"] = detectionTime
        parameters["detectedClasses"] = self.detectedClasses
        if editPost == 1 {
            parameters["detections"] = feedbackObj?.detections
        }
        else{
           parameters["detections"] = "\(self.detections as AnyObject)"
        }
        
        
        parameters["userTime"] = ("\(Date())")
        
        var address = "\(textFiledDataDisc["City"] ?? ""), \(textFiledDataDisc["State"] ?? ""), \(textFiledDataDisc["Country"] ?? "")"
               
        if let zipcode = textFiledDataDisc["Zip Code"] {
            address = address + ", " + zipcode
        }
        
        parameters["gpsLocation"] = address
        parameters["mlModelProcessingLocation"] = modelRunningLocation
        
        let newURL =  kBaseUrl.replacingOccurrences(of: "detect", with: "data")
        
        Helper.sharedHelper.showGlobalHUD(title: "Saving...", view: view)

        PWebService.sharedWebService.callWebAPIRequest(httpMethod: "POST",
                                                       apiName: newURL,
                                                   parameters: parameters) { (response, error) in
                                                    Helper.sharedHelper.dismissHUD(view: self.view)

                                                    if error == nil {
                                                        if let messsage = response!["data"] as? MLFeatureValue {
                                                            //Helper.sharedHelper.showGlobalAlertwithMessage("\(messsage)", title: "Success", vc: self)
                                                        //perform(#selector(self.navigateToHomeScreen), with: nil, afterDelay: 3)
                                                            
                                                            if navigateToHome == 1 {
                                                              self.navigateToHomeScreen()
                                                            }
                                                        }

                                                    }
                                                    else{
                                                        self.navigateToHomeScreen()
                                                    }
        }
    }

    func userfeedbackSaving(userKey: String, tipStatus: String, reason: String)  {
        if editPost == 1 {
           updateDB(tipStatus: tipStatus, userKey: userKey, reason: reason)
            return
        }
        
        let dataManager = DataManager.sharedInstance
        let context = dataManager.getContext()
        let feedback = Feedback(context: context!)
        feedback.mlResult = tipStatus
        feedback.poleTesterID = userDefault.object(forKey: "USERNAME") as? String
        if userKey == "DISAGREEUSERDETAILS"{
            feedback.userResult = "Disagree"
            feedback.reason = reason
        }else{
            feedback.userResult = "Ok"
            feedback.reason = "NA"
        }
               
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "dd-MMM-yyy hh:mm:ss a"
        let dateObj = dateFormatter.string(from: Date())
        feedback.date = dateObj
               
        if let image = containerView.pb_takeSnapshot() {
            let filename = "image_" + Date().description
            let filename2 = "orimage_" + Date().description

            _ = image.save(filename)
            _ = imageView.image?.save(filename2)
            
            feedback.image = filename
            feedback.originalImg = filename2
        }
        feedback.exchangeArea = textFiledDataDisc["Exchange Area"]
        feedback.dpnumber = textFiledDataDisc["DP Number"]
        feedback.cpnumber = textFiledDataDisc["CP Number"]
        
        var address = "\(textFiledDataDisc["City"] ?? ""), \(textFiledDataDisc["State"] ?? ""), \(textFiledDataDisc["Country"] ?? "")"
        
        if let zipcode = textFiledDataDisc["Zip Code"] {
            address = address + ", " + zipcode
        }
        
        feedback.gpsLocation = address
        feedback.latitude = textFiledDataDisc["Latitude"]
        feedback.longitude = textFiledDataDisc["Longitude"]
        feedback.detections = "\(self.detections)"
        feedback.timeStamp = timeStamp
        feedback.requestMethod = requestMethod
        feedback.imageName = imageName
        feedback.detectionTime = detectionTime
        feedback.imgID = fileName
        feedback.detectedClasses = self.detectedClasses
        feedback.mlModelProcessingLocation = modelRunningLocation
        dataManager.saveChanges()
    }
    
    func updateDB(tipStatus: String, userKey: String, reason: String) {
        var parameters = [String: String]()
                   parameters["mlResult"] = tipStatus

        let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "dd-MMM-yyy hh:mm:ss a"
        let dateObj = dateFormatter.string(from: Date())
         parameters["date"] = dateObj
                   
        if let image = containerView.pb_takeSnapshot() {
         let filename = "image_" + Date().description
         let filename2 = "orimage_" + Date().description

         _ = image.save(filename)
         _ = imageView.image?.save(filename2)
                       
            parameters["image"] = filename
            parameters["originalImg"] = filename2
        }
                   
        if userKey == "DISAGREEUSERDETAILS"{
            parameters["userResult"] = "Disagree"
            parameters["reason"] = reason
        }else{
            parameters["userResult"] = "Ok"
            parameters["reason"] = "NA"
        }
        
        parameters["detections"] = "\(self.detections)"
        parameters["timeStamp"] = timeStamp
        parameters["requestMethod"] = requestMethod
        parameters["imageName"] = imageName
        parameters["detectionTime"] = detectionTime
        parameters["detectedClasses"] = self.detectedClasses
        parameters["mlModelProcessingLocation"] = modelRunningLocation

        DataManager.sharedInstance.updateFeedback(parameters: parameters, fetchID: feedbackObj!.date!)
    }
}

extension ObjectDetectionViewController: ToolbarPickerViewDelegate {

    func didTapDone(selectedObject: String) {
       submitBtnAction(selectedReason: selectedObject)
        print(selectedObject)
    }
}

class DrawRectangle: DrawingBoundingBoxView {
    var poleType = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else {
            print("could not get graphics context")
            return
        }

        context.setStrokeColor(poleType == "good_tip" ? UIColor.green.cgColor : UIColor.red.cgColor)
        context.setLineWidth(4)
        context.stroke(rect.insetBy(dx: 0, dy: 0))
    }
}
