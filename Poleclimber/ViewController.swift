//
//  ViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 18/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import AXPhotoViewer
import NVActivityIndicatorView

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NVActivityIndicatorViewable {
    var imagePicker:UIImagePickerController!
    var selectedImages = [UIImage]()
    var selectedImageMediaTypes = [String]()
    var photos = [AXPhoto]()
    var photosViewController: AXPhotosViewController? {
        didSet {
            photosViewController?.delegate = self
        }
    }
    @IBOutlet weak var createClime: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var noImgView: UIView!
    var assets = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        createClime.isHidden = true
        self.title = "Poleclimber"
        let dataSource = AXPhotosDataSource(photos: self.photos, initialPhotoIndex: 0)
        self.photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: nil)
        self.photosViewController?.delegate = self
        self.photosViewController?.dataSource = AXPhotosDataSource(photos: self.photos, initialPhotoIndex: 0)
        self.photosViewController?.overlayView.rightBarButtonItem = nil
        self.photosViewController?.overlayView.leftBarButtonItem = nil
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "add-1"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(self.addPicture(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func addPicture(_ sender: Any) {
        
        let alert = UIAlertController(title: "Take Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { (action) in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            Helper.sharedHelper.showGlobalAlertwithMessage("You don't have camera.", vc: self)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
     // MARK: - UIImagePickerControllerDelegate Methods
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
                let data = image.jpegData(compressionQuality: 0.8),
                let mediaMetadata = info[UIImagePickerController.InfoKey.mediaType] as? String {
                selectedImageMediaTypes.append(mediaMetadata)
                selectedImages.append(image)
                let dataString = String(decoding: data, as: UTF8.self)

    //            let dataString = data.base64EncodedString(options: .endLineWithLineFeed)
                assets.append(dataString)

                self.dismiss(animated: true, completion: nil)
                
                self.photos.append(AXPhoto(attributedTitle: NSAttributedString(string: ""), image: image))
                self.photosViewController?.dataSource = AXPhotosDataSource(photos: self.photos, initialPhotoIndex: self.photos.count - 1)
                
               self.photosViewController!.view.frame = self.containerView.bounds
                self.containerView.addSubview(self.photosViewController!.view)
                
                showAddImgView()
            }
        }
    
    func showAddImgView() {
        if assets.count == 0 {
            noImgView.isHidden = false
            containerView.isHidden = true
            createClime.isHidden = true
        }
        else {
            noImgView.isHidden = true
            containerView.isHidden = false
            createClime.isHidden = false
        }
    }
    
   @IBAction func uploadAction(_ sender: Any) {
          let parameters = [String: AnyObject]()

          showLoader()
          PWebService.sharedWebService.callWebAPIWith(httpMethod: "POST",
                                                             apiName: "createclime",
                                                             parameters: parameters) { (response, error) in
                                                              DispatchQueue.main.async(execute: {
                                                                  //self.stopLoader()
             if let response = response as? [String: AnyObject] {
                if let status = response["status"] as? String, status == "success" {
                                                                                                      
                }
                else{
                  Helper.sharedHelper.showGlobalAlertwithMessage((response["message"] as? String)!, vc: self)
                }
             }
          })
        }
    }

}

extension ViewController: AXPhotosViewControllerDelegate {
    
}

extension ViewController {
    func showLoader() {
           startAnimating(message: "Loading...", type: .circleStrokeSpin, color: kAppColor, backgroundColor: UIColor.clear)
       }
       
       func stopLoader() {
           DispatchQueue.main.async {
               self.stopAnimating()
           }
       }
}
