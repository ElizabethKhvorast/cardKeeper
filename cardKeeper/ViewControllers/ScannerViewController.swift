//
//  ScannerViewController.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 10/03/2023.
//

import UIKit
import AVFoundation
import CoreImage
import PhotosUI

class ScannerViewController: UIViewController
{
    @IBOutlet weak var videoStreamView: UIView!
    let cropView = UIView(frame: CGRect.zero)
    
    let session = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var isFound = false
    private var barcode: String?
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.session.sessionPreset = .photo
        self.reigisterObservers()
        
        //
        self.cropView.backgroundColor = .clear
        self.cropView.layer.borderColor = UIColor.red.cgColor
        self.cropView.layer.borderWidth = 2
        self.cropView.isHidden = true
        self.view.addSubview(self.cropView)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
        debugPrint("DEINIT ViewController")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //self.setupCamera()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.setupCamera()
        self.isFound = false
        self.barcode = nil
        self.cropView.isHidden = true
        //self.videoPreviewLayer?.frame = self.videoStreamView.bounds
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.videoPreviewLayer?.frame = self.videoStreamView.bounds
    }
    
    //MARK: - Actions
    
    @IBAction func closePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func photoLibraryPressed(_ sender: Any)
    {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        let photoPicker = PHPickerViewController(configuration: configuration)
        photoPicker.delegate = self
        self.present(photoPicker, animated: true)
    }
    
    //MARK: - Helpers
    
    private func takePhoto()
    {
        if let videoConnection = self.stillImageOutput.connection(with: .video)
        {
            if videoConnection.isEnabled && videoConnection.isActive
            {
                self.stillImageOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }
    
    func setupCamera()
    {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }
            
            var error: NSError?
            var input: AVCaptureDeviceInput!
            do
            {
                input = try AVCaptureDeviceInput(device: backCamera)
            }
            catch let error1 as NSError
            {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
            
            if error == nil && self.session.canAddInput(input)
            {
                self.session.addInput(input)
                
                let metaDataOutput = AVCaptureMetadataOutput()
                if self.session.canAddOutput(metaDataOutput)
                {
                    self.session.addOutput(metaDataOutput)

                    metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metaDataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
                }
                
                if self.session.canAddOutput(self.stillImageOutput)
                {
                    self.session.addOutput(self.stillImageOutput)
                }
                if self.videoPreviewLayer == nil
                {
                    self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                    self.videoPreviewLayer?.videoGravity = .resizeAspectFill
                }
                self.videoPreviewLayer?.connection?.videoOrientation = .portrait
                
                DispatchQueue.main.async { [weak self] in
                    if let videoLayer = self?.videoPreviewLayer
                    {
                        self?.videoPreviewLayer?.frame = self?.videoStreamView.bounds ?? CGRect.zero
                        self?.videoStreamView.layer.addSublayer(videoLayer)
                        DispatchQueue.global(qos: .userInitiated).async {
                            if self?.session.isRunning == false
                            {
                                self?.session.startRunning()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reigisterObservers()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidEnterBackground(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationWillEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification)
    {
        self.session.stopRunning()
    }
    
    @objc func applicationWillEnterForeground(notification: NSNotification)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning == false
            {
                self.session.startRunning()
            }
        }
    }
    
    func found(code: String)
    {
        self.barcode = code
        self.isFound = true
        self.takePhoto()
    }
    
    private func showCropFor(_ image: UIImage?)
    {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "CropViewController") as? CropViewController
            {
                let item = CardItem(barcode: self?.barcode, image: image)
                vc.cardItem = item
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate
{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        if self.isFound == false, let metadataObject = metadataObjects.first
        {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.found(code: stringValue)
            if let transformed = self.videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            {
                self.cropView.frame = transformed.bounds
                self.cropView.isHidden = false
            }
            else
            {
                self.cropView.isHidden = true
            }
        }
    }
}

//MARK: - AVCapturePhotoCaptureDelegate

extension ScannerViewController: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        if let error = error
        {
            debugPrint(error.localizedDescription)
        }
        if let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData)?.fixedOrientation()
        {
            self.showCropFor(image)
        }
    }
}

extension ScannerViewController: PHPickerViewControllerDelegate
{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        self.dismiss(animated: true)
        if let itemProvider = results.map(\.itemProvider).first
        {
            if itemProvider.canLoadObject(ofClass: UIImage.self)
            {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    if let img = image as? UIImage
                    {
                        self?.barcode = UUID().uuidString
                        self?.showCropFor(img)
                    }
                }
            }
        }
    }
}




