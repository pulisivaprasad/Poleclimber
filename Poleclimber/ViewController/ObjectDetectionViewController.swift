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

class ObjectDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!

    @IBOutlet weak var tableView: UITableView!
    var predictions: [VNRecognizedObjectObservation] = []
    let objectDectectionModel = YOLOv3Tiny()

    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        
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
    
    // MARK: - Capture Session
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Get the pixel buffer from the capture session
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // load the Core ML model
        guard let visionModel:VNCoreMLModel = try? VNCoreMLModel(for: objectDectectionModel.model) else { return }
        //  set up the classification request
        let request = VNCoreMLRequest(model: visionModel){(finishedReq, error) in
            
            guard let result = finishedReq.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
//            guard let firstObservation = result.first else {
//                return
//            }
                                
              self.predictions = result
              DispatchQueue.main.async {
                self.boxesView.predictedObjects = self.predictions
              self.tableView.reloadData()
            }
            //print(firstObservation.identifier, firstObservation.confidence)
        }
        
        request.imageCropAndScaleOption = .scaleFill
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

extension ObjectDetectionViewController: UITableViewDataSource {
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
}


