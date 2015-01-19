//
//  DetailViewController.h
//  Notion IOS Demo
//
//  Created by John Pope on 19/01/2015.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

