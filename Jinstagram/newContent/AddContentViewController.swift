//
//  AddContentViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/21.
//

import UIKit
import Firebase
import Photos

class AddContentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var mainVC: UIViewController?
        
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var myInfo = UserModel()
    
    //이미지 처리
    @IBOutlet weak var bigImage: UIImageView!
    var myImages: [UIImage] = []
    var mainImage: UIImage?
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //권한 처리 (카메라, 앨범)
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근허가")
            self.requestCollection()
            self.collectionView.reloadData()
        case .denied:
            print("접근불가")
        case .notDetermined:
            print("응답 대기")
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    self.requestCollection()
                    OperationQueue.main.addOperation {
                        self.collectionView.reloadData()
                    }
                case .denied:
                    print("접근불가")
                default:
                    break
                }
            }
        case .restricted:
            print("접근제한")
        default:
            return
        }

    }
    
    //이미지 처리
    func requestCollection() {
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        guard let cameraRollCollection = cameraRoll.firstObject else {
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOptions)
    }
    
    
    
    @IBAction func cancel_Btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next_Btn(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(identifier: "ContentFinalViewController") as! ContentFinalViewController
        VC.image = self.mainImage
        VC.beforeVC = self
        VC.mainVC = mainVC
        VC.myInfo = self.myInfo
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddContentViewCell", for: indexPath) as! AddContentViewCell
        
        let asset: PHAsset = fetchResult.object(at: indexPath.row)
        let imageSize = CGSize(width: UIScreen.main.bounds.width / 4 - 1, height: UIScreen.main.bounds.width / 4 - 1)
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        DispatchQueue.main.async {
            self.imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .default, options: options) { (image, _) in
                cell.cell_image.image = image
                self.myImages.append(image!)
            }
            self.mainImage = self.myImages[0]
            self.bigImage.image = self.mainImage
            
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.mainImage = self.myImages[indexPath.row]
        self.bigImage.image = self.mainImage
    }

}

extension AddContentViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 4 - 1
        let height = width
        
        return CGSize(width: width, height: height)
    }
}

class AddContentViewCell: UICollectionViewCell {
    @IBOutlet weak var cell_image: UIImageView!
    
}
