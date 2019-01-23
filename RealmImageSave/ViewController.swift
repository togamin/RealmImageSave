//
//  ViewController.swift
//  RealmImageSave
//
//  Created by Togami Yuki on 2019/01/22.
//  Copyright © 2019 Togami Yuki. All rights reserved.
//

import UIKit
import RealmSwift

//RealmDB用Imageオブジェクト
class ImageInfo:Object{
    @objc dynamic var image = ""
    //データの書き込み
    func create(imageName:String){
        let realm = try! Realm()
        try! realm.write {
            let imageSave = ImageInfo()
            imageSave.image = imageName
            realm.add(imageSave)
        }
    }
    //データの読み込み
    func readImage()->[String]{
        var getImageList:[String] = []
        let realm = try! Realm()
        let imageInfo = realm.objects(ImageInfo.self)
        
        for image in imageInfo{
            getImageList.append(image.value(forKey: "image") as! String)
        }
        return getImageList
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var myImageView: UIImageView!
    let userdefaults = UserDefaults.standard
    var imageList:[String] = []
    var imageListUIImage:[UIImage] = []
    let margin:CGFloat = 3
    
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デフォルト画像の設定
        myImageView.image = UIImage(named: "togaminnnn.jpg")
        //ユーザーデフォルト
        userdefaults.register(defaults: ["imgNum": 0])
        
        //デリゲート
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        //カスタムセルでxibファイルを使う
        myCollectionView.register(UINib(nibName:"imageCollectionCell",bundle:nil),forCellWithReuseIdentifier:"Cell")
        
    }
    
    //画像の選択
    @IBAction func selectImg(_ sender: UIButton) {
        print("画像の選択")
        imagePickUp()
    }
    //画像の保存
    @IBAction func saveImg(_ sender: UIButton) {
        print("画像の保存")
        //登録する名前の生成
        let imageName:String = fileName()
        //Pathを生成
        let path = "file://" + fileInDocumentsDirectory(filename: imageName)
        //保存する画像
        let image = myImageView.image
        print("保存する画像",image)
        //アプリのDocumentフォルダに画像を保存
        saveImage(image: image!, path: path)
        //Realmに保存
        let imageInfo = ImageInfo()
        imageInfo.create(imageName: imageName)
    }
    //画像の読み込み
    @IBAction func readImg(_ sender: UIButton) {
        print("画像の読み込み")
        let imageInfo = ImageInfo()
        imageList = imageInfo.readImage()
        print("imageList",imageList)
        
        //コレクションViewに表示する
        imageListUIImage = []
        for imageName in imageList{
            imageListUIImage.append(loadImage(fileName:imageName))
            myCollectionView.reloadData()
        }
        
        print("imageListUIImage",imageListUIImage)
    }
}
//画像選択保存関連
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //ImagePickerの表示
    func imagePickUp(){
        let picker: UIImagePickerController! = UIImagePickerController()
        //ライブラリから画像を選択
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //デリゲートの設定
        picker.delegate = self
        //ピッカーの表示
        present(picker, animated: true, completion: nil)
    }
    //画像が選択された時に呼ばれる関数
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            myImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    //画像保存時のPathを生成.ドキュメントフォルダまでのPathを取得.
    func getDocumentsURL()->NSURL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsURL! as NSURL
    }
    //Pathの最後に保存する画像の名前を追加
    func fileInDocumentsDirectory(filename: String)->String{
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL!.path
    }
    //画像の保存.
    func saveImage(image: UIImage, path: String){
        let pngImageData = image.pngData()
        do {
            try pngImageData!.write(to: URL(string: path)!, options: .atomic)
        }catch{
            print("memo:保存失敗 \(error)")
        }
        print("memo:保存の成功")
    }
    //PathからUIImageへの変換
    func loadImage(fileName:String)->UIImage{
        let path = getDocumentsURL().appendingPathComponent(fileName)?.path
        let image = UIImage(contentsOfFile: path!)
        return image!
    }
    //ファイル名の生成
    func fileName()->String{
        var imgNum = userdefaults.object(forKey: "imgNum") as! Int
        imgNum = imgNum + 1
        userdefaults.set(imgNum, forKey: "imgNum")
        return "togamin\(imgNum)"
    }
}

//コレクションViewに関する関数
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageListUIImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! imageCollectionViewCell
        
        
        cell.myImageView.image = imageListUIImage[indexPath.row]
        
        
        return cell
    }
    //セルのサイズ指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = myCollectionView.frame.width//コレクションViewの幅
        let cellNum:CGFloat = 3
        let cellSize = (width - margin * (cellNum + 1))/cellNum//一個あたりのサイズ
        return CGSize(width:cellSize,height:cellSize)
    }
    //セル同士の縦の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    //セル同士の横の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
}


