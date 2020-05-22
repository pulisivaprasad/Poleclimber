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
import AMPopTip

class ObjectDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NavigationDelegate {
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var detectBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var galleryBtn: UIButton!

    @IBOutlet var poleStatusSubView: PoleStatusView!
    var predictions: [VNRecognizedObjectObservation] = []
    let objectDectectionModel =  MobileNetV2_SSDLite_openreach() //YOLOv3Tiny()
    @IBOutlet weak var noImgView: UIView!
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    var cvpixelBuffer: CVPixelBuffer!
    let rControl = RMController()
    var feedbackObj: Feedback?
    var editPost = 0
    
    @IBOutlet weak var textfiledView: UIView!
    @IBOutlet weak var idTField: UITextField!
    @IBOutlet weak var exchangeIDTFiled: UITextField!
    @IBOutlet weak var dpIDTFiled: UITextField!
    
    @IBOutlet weak var idInformationButton: UIButton!
    @IBOutlet weak var exchangeIDInformationButton: UIButton!
    @IBOutlet weak var dpIDInformationButton: UIButton!
    
    enum ButtonType: Int {
           case center, topLeft, topRight, bottomLeft, bottomRight
    }
    
    let popTip = PopTip()
    var direction = PopTipDirection.up
    var topRightDirection = PopTipDirection.down
    var textFiledDataDisc = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Visual Inspection"
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        buttonsView.isHidden = true

        if editPost == 1 {
            detectBtn.isHidden = false
            noImgView.isHidden = true
            textfiledView.isHidden = true
            if let imagename = feedbackObj?.originalImg {
                 let image = self.loadeImage(name: imagename)
                imageView.image = image
                getCVPixelBuffer(image: image!)
            }
        }
        else{
            namelabel.isHidden = true
            detectBtn.isHidden = true
        }
        
        galleryBtn.backgroundColor = UIColor.lightGray
                   galleryBtn.isUserInteractionEnabled = false
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
    
    @IBAction func informationButtonAction(_ sender: UIButton, forEvent event: UIEvent)  {
           guard let button = ButtonType(rawValue: sender.tag) else { return }
           
           //popTip.arrowRadius = 0
           
           switch button {
           case .topLeft: break
               
           case .topRight:
               popTip.bubbleColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
               topRightDirection = .up
               
               let touchPosition = UIButton(frame: CGRect(x: sender.frame.origin.x, y: (20 + (sender.superview?.superview?.frame.origin.y)!), width: 95, height: 40))
               popTip.textColor = UIColor.lightGray
               popTip.show(text: "Please enter ID", direction: topRightDirection, maxWidth: 150, in: view, from: touchPosition.frame)
           case .bottomLeft: break
              
           case .bottomRight:
           popTip.bubbleColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
           topRightDirection = .up
           
           let touchPosition = UIButton(frame: CGRect(x: sender.frame.origin.x, y: (85 + (sender.superview?.superview?.frame.origin.y)!), width: 95, height: 40))
           popTip.textColor = UIColor.lightGray
           popTip.show(text: "Please enter Exchange ID", direction: topRightDirection, maxWidth: 150, in: view, from: touchPosition.frame)
              
           case .center: break
               
           }
       }

    
   @IBAction func detectBtnAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalHUD(title: "Processing...", view: view)

        if Helper.sharedHelper.isNetworkAvailable() {
//            let filename = "image_" + Date().description
//            _ = imageView.image?.save(filename)
//            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//            let url = URL(fileURLWithPath: path).appendingPathComponent(filename)
//
//            var parameters = [String : AnyObject]()
//            parameters["file"] = url as AnyObject
//            PWebService.sharedWebService.callWebAPIWith(httpMethod: "POST",
//                                                                  apiName: "",
//                                                                  parameters: parameters, uploadImage: imageView.image) { (response, error) in
//
//                                                                    print(response)
//
//            }
            perform(#selector(detectSubImagesInImg), with: nil, afterDelay: 2)
        }
        else{
           rControl.showMessage(withSpec: warningSpec, title: "Info", body: "You don't have internet connection so classification will run using iOS ML model.")
            perform(#selector(detectSubImagesInImg), with: nil, afterDelay: 2)
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
            getCVPixelBuffer(image: image)
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
        textfiledView.isHidden = true
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
                self.textfiledView.isHidden = true

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
                self.textfiledView.isHidden = true

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
        
        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Thank you. You can find these results in the history tab if you would like to see them again at a later date.")
        perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 5)
    }
    
    @objc func navigateToHomeScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func disAgreeBtnAction(_ sender: Any) {
        poleStatusSubView.frame = view.bounds
        if self.namelabel.text == "Good Tip Detected"{
            poleStatusSubView.reason1.setTitle(" Rot present on the pole tip", for: .normal)
            poleStatusSubView.reason2.setTitle(" Side chipping looks like rot", for: .normal)
            //poleStatusSubView.reason3.setTitle(" Reason3", for: .normal)
            poleStatusSubView.reason3.isHidden = true
        }
        else{
            poleStatusSubView.reason1.setTitle(" Cracks on tip are natural", for: .normal)
            poleStatusSubView.reason2.setTitle(" Tip covered by bird droppings", for: .normal)
            poleStatusSubView.reason3.setTitle(" Chipping on tip is not rot", for: .normal)
        }
        poleStatusSubView.delegate = self
        view.addSubview(poleStatusSubView)
    }
    
    func submitBtnAction(selectedReason: String) {
        userfeedbackSaving(userKey: "DISAGREEUSERDETAILS", tipStatus: namelabel.text!, reason: selectedReason)

        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Thank you. You can find these results in the history tab if you would like to see them again at a later date.")
        perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 5)
    }
        
    func userfeedbackSaving(userKey: String, tipStatus: String, reason: String)  {
        if editPost == 1 {
            var parameters = [String: String]()
            parameters["tipStatus"] = tipStatus

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
                parameters["userAcceptance"] = "Disagree"
                parameters["reason"] = reason
            }else{
                parameters["userAcceptance"] = "Ok"
                parameters["reason"] = "NULL"
            }

            DataManager.sharedInstance.updateFeedback(parameters: parameters, fetchID: feedbackObj!.date!)
            return
        }
        
        let dataManager = DataManager.sharedInstance
        let context = dataManager.getContext()
        let feedback = Feedback(context: context!)
        feedback.tipStatus = tipStatus
        feedback.poleTesterID = userDefault.object(forKey: "USERNAME") as? String
        if userKey == "DISAGREEUSERDETAILS"{
            feedback.userAcceptance = "Disagree"
            feedback.reason = reason
        }else{
            feedback.userAcceptance = "Ok"
            feedback.reason = "NULL"
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
        feedback.id = textFiledDataDisc["id_value"]
        feedback.exchangeID = textFiledDataDisc["exchangeID_value"]
        feedback.dpID = textFiledDataDisc["dpID_value"]

        dataManager.saveChanges()
    }
}


extension ObjectDetectionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == idTField {
            textFiledDataDisc["id_value"] = textField.text
        }
        else if textField == exchangeIDTFiled {
            textFiledDataDisc["exchangeID_value"] = textField.text
        }
        else {
            textFiledDataDisc["dpID_value"] = textField.text
        }
        
        if textFiledDataDisc["id_value"] != "" && textFiledDataDisc["exchangeID_value"] != "" && textFiledDataDisc["dpID_value"] != "" {
            galleryBtn.backgroundColor = pAppStatusBarColor
            galleryBtn.isUserInteractionEnabled = true
        }
        else{
            galleryBtn.backgroundColor = UIColor.lightGray
            galleryBtn.isUserInteractionEnabled = false
        }
    }
}

extension PopTipDirection {
    func cycleDirection() -> PopTipDirection {
      switch self {
        case .up:
            return .right
        case .right:
            return .down
        case .down:
            return .left
        case .left:
            return .up
        case .none:
            return .none
        case .auto:
           return .none
      case .autoHorizontal:
           return .right
      case .autoVertical:
           return .up
        }
    }
}
