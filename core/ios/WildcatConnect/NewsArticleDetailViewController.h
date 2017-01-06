//
//  NewsArticleDetailViewController.h
//  WildcatConnectGITTest
//
//  Created by Rohith Parvathaneni on 9/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsArticleStructure.h"

@interface NewsArticleDetailViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NewsArticleStructure *NA;
@property (nonatomic, strong) NSData *imageData;
@property BOOL showCloseButton;
@property (nonatomic, strong) NSString *imageURL;

- (instancetype)initWithNewsArticle:(NewsArticleStructure *)newsArticle;

@end
