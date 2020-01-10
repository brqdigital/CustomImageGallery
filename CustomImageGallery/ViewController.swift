//
//  ViewController.swift
//  CustomImageGallery
//
//  Created by Douglas Rodrigues Pinto Neto on 06/01/20.
//  Copyright © 2020 Douglas Rodrigues Pinto Neto. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var imageGalleryCollectionView: UICollectionView!
    
    var photoGalleryAssets: PHFetchResult<PHAsset>?
    
    let imagesManager = PHImageManager()
    let imagesRequestOptions = PHImageRequestOptions()
    let imagesFetchOptions = PHFetchOptions()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getPhotosFromLibrary()
        setInitialImage()
    }
    
    func setup() {
        imageGalleryCollectionView.delegate = self
        imageGalleryCollectionView.dataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        imageGalleryCollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    func getPhotosFromLibrary() {
        
        let imagesFetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: imagesFetchOptions)
        
        self.photoGalleryAssets = imagesFetchResult
        
        self.imageGalleryCollectionView.reloadData()
        
    }
    
    func setInitialImage() {
        
        guard let asset = self.photoGalleryAssets?[0] else { return }
        
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        imagesManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imagesRequestOptions) { (image, _) in
            self.selectedPhoto(image: image ?? UIImage())
        }
        
    }
    
    
    func getPhotoFromAsset(asset: PHAsset) {
        
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        
        imagesManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imagesRequestOptions) { (image, _) in
            self.selectedPhoto(image: image ?? UIImage())
        }
    }
    
    
    func selectedPhoto(image: UIImage) {
        self.selectedImage.image = image
    }
    
}



extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let asset = self.photoGalleryAssets?[indexPath.row] else { return }
        
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        imagesManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imagesRequestOptions) { (image, _) in
            self.selectedPhoto(image: image ?? UIImage())
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoGalleryAssets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        
        guard let asset = self.photoGalleryAssets?[indexPath.row] else { return UICollectionViewCell() }
        
        let size = CGSize(width: 50, height: 50)
        
        imagesManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imagesRequestOptions) { (image, _) in
            cell.cellImage.image = image
        }
        
        return cell
    }
    
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.imageGalleryCollectionView.frame.width / 4 - 1
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
}

