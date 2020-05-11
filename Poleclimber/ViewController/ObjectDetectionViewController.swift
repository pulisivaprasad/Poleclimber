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

class ObjectDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NavigationDelegate {
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var detectBtn: UIButton!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet var poleStatusSubView: PoleStatusView!
    var predictions: [VNRecognizedObjectObservation] = []
    let objectDectectionModel =  MobileNetV3_640_SSDLite() //YOLOv3Tiny()
    @IBOutlet weak var noImgView: UIView!
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    var cvpixelBuffer: CVPixelBuffer!
    let rControl = RMController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Visual Inspection"
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        buttonsView.isHidden = true
        namelabel.isHidden = true
        
        detectBtn.isHidden = true
    }
    
   @IBAction func detectBtnAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalHUD(title: "Processing...", view: view)

        if Helper.sharedHelper.isNetworkAvailable() {
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

            self.dismiss(animated: true, completion: nil)
        }
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
                    if  objRatio > objAspectRatio {
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

//            if self.predictions.first?.label == "pole_tip" {
//                self.predictions.remove(at: 0)
//            }
            
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

        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Thank's for your feedback.")
        perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 5)
    }
    
    func uploadPostWithImage(folderNamePath: String) {
          if let postImage = imageView.image {
              Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
              PWebService.sharedWebService.uploadImage(image: postImage,
                                                       imageName: Helper.sharedHelper.generateName(),
                                                       folderNamePath: folderNamePath) { status, response, message in
                  Helper.sharedHelper.dismissHUD(view: self.view)
                  if status == 100 {
                      let str = NSString(format: "%@", response as! CVarArg)
                      //self.uploadPost(imageString: str as String, tumbString: nil)
                  } else {
                      Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                  }
              }
          } else {
            
          }
      }
    
//     func uploadPost(imageString: String?, tumbString: String?) {
//            let feedDict = NSMutableDictionary()
//            if let imageString = imageString {
//                feedDict.setValue(imageString, forKey: "source_path")
//            }
//
//
//            // Post creater user detail
//            feedDict.setValue(PWebService.sharedWebService.currentUser?.email ?? "", forKey: kEmailKey)
//
//
//            feedDict.setValue(postObj?.row_Key, forKey: "row_key")
//            PWebService.sharedWebService.updatePost(parameters: feedDict as! [String: AnyObject],
//                                                        rowKey: postObj!.row_Key!,
//                                                        childName: "kFEEDS",
//                                                        completion: { status, _, message in
//
//                                                            if status == 100 {
//                                                                Helper.sharedHelper.showGlobalAlertwithMessage(message!, vc: self, completion: {
//                                                                    self.navigationController?.popViewController(animated: true)
//                                                                })
//                                                            } else {
//                                                                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
//                                                            }
//                })
//
//    }
    
    func userfeedbackSaving(userKey: String, tipStatus: String, reason: String)  {
        
        let dataManager = DataManager.sharedInstance
        let context = dataManager.getContext()
        let feedback = Feedback(context: context!)
        feedback.tipStatus = tipStatus
        if userKey == "DISAGREEUSERDETAILS"{
            feedback.userAcceptance = "Disagree"
            feedback.reason = reason
        }else{
            feedback.userAcceptance = "Ok"
            feedback.reason = "NULL"
        }
               
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "dd-MM-yyy hh:mm:ss a"
        let dateObj = dateFormatter.string(from: Date())
        feedback.date = dateObj
               
        if let image = containerView.pb_takeSnapshot() {
            let filename = "image_" + Date().description
            _ = image.save(filename)
            feedback.image = filename
        }

        dataManager.saveChanges()
        
    }
    

    
}
