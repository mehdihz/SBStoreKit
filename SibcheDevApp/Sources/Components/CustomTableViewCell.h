//
//  CustomTableViewCell.h
//  SibcheDevApp
//
//  Created by Mehdi on 3/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *packageName;
@property (weak, nonatomic) IBOutlet UILabel *packageDescription;
@property (weak, nonatomic) IBOutlet UIButton *packageActionButton;
@property (weak, nonatomic) IBOutlet UILabel *packagePrice;

@end

NS_ASSUME_NONNULL_END
