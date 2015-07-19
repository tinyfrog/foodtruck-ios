    //
//  TruckDetailsViewControllerWithScroll.swift
//  foodtruck-ios
//
//  Created by Shaobo Sun on 3/22/15.
//  Copyright (c) 2015 Shaobo Sun. All rights reserved.
//

class TruckDetailViewController : UIViewController, UICollectionViewDelegate, MWPhotoBrowserDelegate {
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        println("pressed, pressed!")
        self.dismissViewControllerAnimated(false, completion: {})
    }
        
    //restore
    @IBOutlet weak var theTitle: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var url: UILabel!
    
    
    var truckId: String?
    
    func truckId(truckId:String) {
        self.truckId = truckId
    }
    
    var imageFetcher = ImageFetcher()
    var prevViewController: UIViewController?
    var previousViewControllerName:String = ""
    var scheduleToTableSegueID : String = "ScheduleToTableSegue"
    var scheduleToMapSegueID : String = "ScheduleToMapSegue"
    var inputLabel:String = ""
    var currentImage:UIImage?
    var photos = [UIImage]()
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    var collectionCellReusableId = "TruckDetailCollectionCell"
    
    @IBOutlet weak var anotherLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("who is my previous controller \(self.previousViewControllerName)")

        
        // Do any additional setup after loading the view.
        theTitle.text = inputLabel
        
        imageFetcher.fetchImageByTruckId(self.truckId, callback: {
            self.theCollectionView.reloadData()
        })
        renderView()
    }
    func renderView() {
        if let truckId = self.truckId {
            if let truck = Trucks.trucks[truckId] {
                theTitle.text = truck["name"]
                url.text = truck["url"]
                category.text = truck["category"]
                if let theImage: Image = Images.truckImages[truckId] {
                    image?.image =  theImage.image
                }
            }
        } else {
            println("TruckDetailsScrollViewController - truckId is unset")
        }
    }
    
    /*
    
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let truckImages = TruckDetailImages.truckImages[self.truckId!] {
            return truckImages.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionCellReusableId, forIndexPath: indexPath) as! CollectionViewCell
        cell.imageView.image = photoForIndexPath(indexPath)
        return cell
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> UIImage {
        let truckImages:[UIImage] = TruckDetailImages.truckImages[self.truckId!]!
        return truckImages[indexPath.row]
    }
    
    /*
        When an image is clicked
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("An image was clicked!! \(indexPath.length) \(indexPath.item) \(indexPath.section) and \(indexPath.row)")

        var cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        currentImage = cell.imageView.image
//        performSegueWithIdentifier("TruckDetailToLargeImageSegue", sender: nil)
        
        
        
        //let photo:MWPhoto = MWPhoto(image:image)
        
        self.photos = TruckDetailImages.truckImages[self.truckId!]!
        
        let browser:MWPhotoBrowser = MWPhotoBrowser(delegate: self)
        
        browser.displayActionButton = true
        browser.displayNavArrows = false
        browser.displaySelectionButtons = false
        browser.zoomPhotosToFill = true
        browser.alwaysShowControls = false
        browser.enableGrid = false
        browser.startOnGrid = false
        browser.enableSwipeToDismiss = true
        
//        var index:Int = 3
        browser.setCurrentPhotoIndex(CUnsignedLong(indexPath.row    ))
        
//        println("my navigation here \(self.navigationController!)")
        var nav = UINavigationController(rootViewController: browser)
        nav.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(nav, animated: true, completion: nil)
       // self.navigationController?.pushViewController(browser, animated: true)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        var image = self.photos[Int(index)]
        var mwPhoto:MWPhoto = MWPhoto(image: image)
        
        return mwPhoto
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier! == "TruckDetailToLargeImageSegue") {
            println("going to large image view")
            var destViewController = segue.destinationViewController as! LargeImageViewController
            if let theImage = currentImage {
                destViewController.setImage(theImage)
                destViewController.setImageList(TruckDetailImages.truckImages[self.truckId!]!)
                //destViewController.setShit("hi")
            } else {
                println("currentImage is unset")
            }
        }else if (segue.identifier! == "TruckDetailContainerToTable") {
            var destViewController = segue.destinationViewController as! TableViewController
            destViewController.truckId(truckId!)
        } else {
            println("Unknown segue in TruckDetialScrollViewController")
        }
    }
    

}