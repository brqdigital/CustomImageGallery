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
    @IBOutlet weak var selectAlbumButton: UIButton!
    @IBOutlet weak var albumListTableView: UITableView!
    
    var photoGalleryAssets: PHFetchResult<PHAsset>?
    var albums: PHFetchResult<PHAssetCollection>?
    var isAlbumDown: Bool = false

    
    let imagesManager = PHImageManager()
    let imagesRequestOptions = PHImageRequestOptions()
    let imagesFetchOptions = PHFetchOptions()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getPhotosFromLibrary()
        setInitialImage()
        self.albums = getAlbums()
    }
    
    func setup() {
        imageGalleryCollectionView.delegate = self
        imageGalleryCollectionView.dataSource = self
        let collectionNib = UINib(nibName: "CollectionViewCell", bundle: nil)
        imageGalleryCollectionView.register(collectionNib, forCellWithReuseIdentifier: "CollectionViewCell")
        
        albumListTableView.delegate = self
        albumListTableView.dataSource = self
        let tableNib = UINib(nibName: "albumTableViewCell", bundle: nil)
        albumListTableView.register(tableNib, forCellReuseIdentifier: "albumTableViewCell")
        
        albumListTableView.isHidden = true
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
    
    func showAlbumList() {
        if isAlbumDown {
            self.albumListTableView.isHidden = true
            isAlbumDown = !isAlbumDown
            return
        }
        
        self.albumListTableView.isHidden = false
        isAlbumDown = !isAlbumDown
    }
    
    @IBAction func dropAlbumList(_ sender: Any) {
        showAlbumList()
    }
    
    func getPhotoFromAsset(asset: PHAsset) {
        
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        
        imagesManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imagesRequestOptions) { (image, _) in
            self.selectedPhoto(image: image ?? UIImage())
        }
    }
    
    func getAlbums() -> PHFetchResult<PHAssetCollection> {
        let fetchOptions = PHFetchOptions()
        
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        return albumList
    }
    
    func fetchPhotosFromAlbum(album: PHAssetCollection) -> UIImage {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        guard let photos = PHAsset.fetchAssets(in: album, options: fetchOptions) as? PHFetchResult<AnyObject> else { return UIImage() }
        let imageManager = PHCachingImageManager()
        var resultImage = UIImage()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        
        guard let asset = photos[0] as? PHAsset else { return UIImage() }
        
        let imageSize = CGSize(width: asset.pixelWidth,
                               height: asset.pixelHeight)
        
        
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { (image, _) -> Void in
            resultImage = image ?? UIImage()
        })
        
        return resultImage
    }

    func allPhotosAlbum() {
        self.selectAlbumButton.setTitle("Todas as Fotos", for: .normal)
        self.getPhotosFromLibrary()
    }
    
    func getPhotosFromAlbum(selectedAlbum: PHAssetCollection) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let photos = PHAsset.fetchAssets(in: selectedAlbum, options: fetchOptions) as PHFetchResult<PHAsset>
        
        
        self.photoGalleryAssets? = photos
        
        
        self.imageGalleryCollectionView.reloadData()
    }

    
    func selectedAlbum(album: PHAssetCollection) {
        self.selectAlbumButton.setTitle(album.localizedTitle, for: .normal)
        self.getPhotosFromAlbum(selectedAlbum: album)
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

extension ViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.showAlbumList()
            
            if indexPath.row == 0 {
                self.allPhotosAlbum()
                return
            }
            
            self.selectedAlbum(album: albums?[indexPath.row - 1] ?? PHAssetCollection())
            
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableSize = albums?.count ?? 0
        return tableSize + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "albumTableViewCell") as? albumTableViewCell else { return UITableViewCell() }

        
        if indexPath.row == 0 {
            
            cell.cellImage.image = self.selectedImage.image
            cell.cellLabel.text = "Todas as Fotos"
            
            return cell
        }
        
        let album = self.albums?.object(at: indexPath.row - 1)
        
        let thumbnail = self.fetchPhotosFromAlbum(album: album ?? PHAssetCollection())
        
        cell.cellImage.image = thumbnail
        cell.cellLabel.text = album?.localizedTitle

        return cell
    }
}



