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
    @IBOutlet weak var  buttonsView: UIView!
    @IBOutlet weak var  boxesView: DrawingBoundingBoxView!
    @IBOutlet weak var  namelabel: UILabel!
    @IBOutlet weak var  detectBtn: UIButton!
    @IBOutlet var       poleStatusSubView: PoleStatusView!
    @IBOutlet weak var  noImgView: UIView!
    @IBOutlet weak var  imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var predictions: [VNRecognizedObjectObservation] = []
    let objectDectectionModel =  MobileNetV3_SSDLite() //YOLOv3Tiny()
    
    var imagePicker:UIImagePickerController!
    
    var cvpixelBuffer: CVPixelBuffer!
    let rControl = RMController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Visual inspection"
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
           rControl.showMessage(withSpec: warningSpec, title: "Info", body: "You don't have internet connection so classification will run using ios ML model.")
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
            Helper.sharedHelper.showGlobalAlertwithMessage("You don't have camera.")
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
      guard result.first != nil else {
        self.rControl.showMessage(withSpec: errorSpec, title: "Error", body: "We didn't found any tip rot, please select proper pole tip image for ML Model.")
        self.imageView.image = UIImage(named: "")
        self.noImgView.isHidden = false
        self.detectBtn.isHidden = true
        return
      }

        self.predictions = result
        DispatchQueue.main.async {
          self.buttonsView.isHidden = false
            self.detectBtn.isHidden = true
          self.namelabel.isHidden = false

            if self.predictions.first?.label == "good_tip" {
                self.namelabel.text = "Good tip detected"
            }
            else{
                self.namelabel.text = "Bad tip detected"
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
        var detailsSaving = UserDefaults.standard.object(forKey: "USERDETAILS") as? [[String: AnyObject]]

        if detailsSaving == nil {
            detailsSaving = [[String: AnyObject]]()
        }

        var disc = [String: AnyObject]()
        disc["title"] = self.namelabel.text as AnyObject
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyy hh:mm:ss a"
        let dateObj = dateFormatter.string(from: Date())
        
        disc["time"] = dateObj as AnyObject
        
        if let image = containerView.pb_takeSnapshot() {
            let filename = "image_" + Date().description
            image.save(filename)
            disc["image"] = filename as AnyObject
        }
        
        disc["isGood"] = (self.predictions.first?.label == "good_tip") as AnyObject
        
        detailsSaving?.append(disc)
        UserDefaults.standard.set(detailsSaving, forKey: "USERDETAILS")
        UserDefaults.standard.synchronize()
        
        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Your feedback is saved successfully.")
        perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 2)
    }
    
    @objc func navigateToHomeScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func disAgreeBtnAction(_ sender: Any) {
        poleStatusSubView.frame = view.bounds
        if self.namelabel.text == "Good tip detected"{
            poleStatusSubView.reason1.setTitle("Reason1", for: .normal)
            poleStatusSubView.reason2.setTitle("Reason2", for: .normal)
            poleStatusSubView.reason3.setTitle("Reason3", for: .normal)
        }
        else{
            poleStatusSubView.reason1.setTitle("Reason4", for: .normal)
            poleStatusSubView.reason2.setTitle("Reason5", for: .normal)
            poleStatusSubView.reason3.setTitle("Reason6", for: .normal)
        }
        poleStatusSubView.delegate = self
        view.addSubview(poleStatusSubView)
    }
    
    func submitBtnAction() {
        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Thank you for your feedback.")
        perform(#selector(navigateToHomeScreen), with: nil, afterDelay: 2)
    }
}
