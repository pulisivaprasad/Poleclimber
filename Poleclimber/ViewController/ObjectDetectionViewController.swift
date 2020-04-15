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
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!

    @IBOutlet weak var tableView: UITableView!
    var predictions: [VNRecognizedObjectObservation] = []
    let objectDectectionModel = YOLOv3Tiny()
    @IBOutlet weak var noImgView: UIView!
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    var detectBtn = UIBarButtonItem()
    var cvpixelBuffer: CVPixelBuffer!
    let rControl = RMController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Object Detection"
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        tableView.isHidden = true
        tableView.tableFooterView = UIView()
        
        buttonsView.isHidden = true
        
        detectBtn = UIBarButtonItem(title: "Detect", style: .plain, target: self, action: #selector(detectObjects))
        navigationItem.rightBarButtonItem = detectBtn
        detectBtn.isEnabled = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc func detectObjects() {
        if Helper.sharedHelper.isNetworkAvailable() {
        Helper.sharedHelper.showGlobalHUD(title: "Processing...", view: view)
           rControl.showMessage(withSpec: warningSpec, title: "Info", body: "You don't have internet connection so classification will run using ios MI Model.")
            perform(#selector(detectSubImagesInImg), with: nil, afterDelay: 2)
        }
        else{
           rControl.showMessage(withSpec: warningSpec, title: "Info", body: "You don't have internet connection so classification will run using ios MI Model.")
            Helper.sharedHelper.showGlobalHUD(title: "Processing...", view: view)
            perform(#selector(detectSubImagesInImg), with: nil, afterDelay: 2)
        }
    }
    
    @objc func detectSubImagesInImg() {
        Helper.sharedHelper.dismissHUD(view: self.view)
        imageView.image = UIImage(named: "badPole")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        label.text = "Bad Pole"
        label.textAlignment = .center
        tableView.backgroundView = label
        self.tableView.isHidden = false
        buttonsView.isHidden = false

        //captureImageDetails(pixelBuffer: cvpixelBuffer!)
    }
    
    @IBAction func addPicture(_ sender: Any) {
        let alert = UIAlertController(title: "Take Photo", message: nil, preferredStyle: .actionSheet)
           // alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            //    self.imageView.isHidden = true
              //  self.openCamera()
        //}))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.imageView.isHidden = false
                self.openGallary()
        }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                  self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        let captureSession = AVCaptureSession()
               //captureSession.sessionPreset = .photo
         guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
               
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
               
        captureSession.addInput(input)
        captureSession.startRunning()
               
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreview.layer.addSublayer(previewLayer)
        previewLayer.frame = videoPreview.frame
               
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
               captureSession.addOutput(dataOutput)
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
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
        detectBtn.isEnabled = true
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
//      guard let firstObservation = result.first else {
//        return
//      }

        self.predictions = result
        DispatchQueue.main.async {
          self.tableView.isHidden = false
          self.buttonsView.isHidden = false

        //let objectBounds = VNImageRectForNormalizedRect(result[0].boundingBox, Int(self.videoPreview.frame.size.width), Int(self.videoPreview.frame.size.height))

          self.boxesView.predictedObjects = self.predictions
          self.tableView.reloadData()
          }
             //print(firstObservation.identifier, firstObservation.confidence)
        }
                
        request.imageCropAndScaleOption = .scaleFill
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @IBAction func AgreeBtnAction(_ sender: Any) {
        rControl.showMessage(withSpec: successSpec, title: "Success", body: "Your feedback saved successfully.")
    }
}

extension ObjectDetectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") else {
            return UITableViewCell()
        }

        let rectString = predictions[indexPath.row].boundingBox.toString(digit: 2)
        let confidence = predictions[indexPath.row].labels.first?.confidence ?? -1
        let confidenceString = String(format: "%.3f", confidence/*Math.sigmoid(confidence)*/)
        
        cell.textLabel?.text = predictions[indexPath.row].label ?? "N/A"
        cell.detailTextLabel?.text = "\(rectString), \(confidenceString)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: "ObjectDetectionDetailViewController") as! ObjectDetectionDetailViewController
        viewController.title = predictions[indexPath.row].label ?? "N/A"
        viewController.subImgFrame = self.predictions[indexPath.row].boundingBox
        viewController.originlImg = imageView.image!
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
