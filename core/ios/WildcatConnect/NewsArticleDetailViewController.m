//
//  NewsArticleDetailViewController.m
//  WildcatConnectGITTest
//
//  Created by Rohith Parvathaneni on 9/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "NewsArticleDetailViewController.h"
#import "NewsCenterTableViewController.h"
#import "AppManager.h"
#import <QuartzCore/QuartzCore.h>

@interface NewsArticleDetailViewController ()

@end

@implementation NewsArticleDetailViewController {
     UILabel *likesLabel;
     UILabel *titleLabel;
     UIButton *likesButton;
     UIActivityIndicatorView *activity;
     UIScrollView *scrollView;
     UILabel *authorDateLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     [Utils setNavColorForController:self];
     
     self.navigationItem.title = @"News Story";
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     self.navigationController.navigationBar.translucent = NO;
     
     if ([self.NA.hasImage integerValue] == 0) {
          titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
          titleLabel.text = self.NA.titleString;
          [titleLabel setFont:[UIFont systemFontOfSize:24]];
          titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
          titleLabel.numberOfLines = 0;
          [titleLabel sizeToFit];
          [scrollView addSubview:titleLabel];
          
          UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
          summaryLabel.text = self.NA.summaryString;
          UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
          [summaryLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
          summaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
          summaryLabel.numberOfLines = 0;
          [summaryLabel sizeToFit];
          [scrollView addSubview:summaryLabel];
          
          authorDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(summaryLabel.frame.origin.x, summaryLabel.frame.origin.y + summaryLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
          authorDateLabel.text = [[self.NA.authorString stringByAppendingString:@" | "] stringByAppendingString:self.NA.dateString];
          [authorDateLabel setFont:[UIFont systemFontOfSize:12]];
          authorDateLabel.lineBreakMode = NSLineBreakByWordWrapping;
          authorDateLabel.numberOfLines = 0;
          [authorDateLabel sizeToFit];
          [scrollView addSubview:authorDateLabel];
          
          likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorDateLabel.frame.origin.x, authorDateLabel.frame.origin.y + authorDateLabel.frame.size.height + 10, self.view.frame.size.width - 20, 30)];
          if ([self.NA.likes integerValue] == 1) {
               likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" like"];
          } else
               likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" likes"];
          [likesLabel setFont:[UIFont systemFontOfSize:16]];
          [scrollView addSubview:likesLabel];
          
          likesButton = [[UIButton alloc] init];
          
          NSMutableArray *liked = [[NSUserDefaults standardUserDefaults] objectForKey:@"likedNewsArticles"];
          if (liked) {
               if (! [liked containsObject:self.NA.articleID]) {
                    likesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [likesButton addTarget:self action:@selector(likeMethod) forControlEvents:UIControlEventTouchUpInside];
                    [likesButton setImage:[[UIImage imageNamed:@"like@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                    [likesButton sizeToFit];
                    CGFloat width = likesButton.frame.size.width;
                    likesButton.frame = CGRectMake((self.view.frame.size.width - width - 20), likesLabel.frame.origin.y, likesButton.frame.size.width, likesButton.frame.size.height);
                    [scrollView addSubview:likesButton];
                    [self runSpinAnimationOnView:likesButton duration:2 rotations:1 repeat:0];
               } else {
                    likesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [likesButton addTarget:self action:@selector(likeMethod) forControlEvents:UIControlEventTouchUpInside];
                    [likesButton setImage:[[UIImage imageNamed:@"done@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                    [likesButton sizeToFit];
                    [likesButton setEnabled:false];
                    CGFloat width = likesButton.frame.size.width;
                    likesButton.frame = CGRectMake((self.view.frame.size.width - width - 20), likesLabel.frame.origin.y, likesButton.frame.size.width, likesButton.frame.size.height);
                    [scrollView addSubview:likesButton];
               }
          } else {
               likesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [likesButton addTarget:self action:@selector(likeMethod) forControlEvents:UIControlEventTouchUpInside];
               [likesButton setImage:[[UIImage imageNamed:@"like@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
               [likesButton sizeToFit];
               CGFloat width = likesButton.frame.size.width;
               likesButton.frame = CGRectMake((self.view.frame.size.width - width - 20), likesLabel.frame.origin.y, likesButton.frame.size.width, likesButton.frame.size.height);
               [scrollView addSubview:likesButton];
               [self runSpinAnimationOnView:likesButton duration:2 rotations:1 repeat:0];
          }
          
          CGFloat height = 0;
          if (likesButton != nil) {
               height = likesButton.frame.origin.y + likesButton.frame.size.height + 10;
          } else {
               height = likesLabel.frame.origin.y + likesLabel.frame.size.height + 10;
          }
          
          UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width - 20, 1)];
          separator.backgroundColor = [UIColor blackColor];
          [scrollView addSubview:separator];
          
          [scrollView addSubview:[Utils createWebViewForDelegate:self forString:self.NA.contentURLString withSeparator:separator]];
          
               //Takes care of all resizing needs based on sizes.
          UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 150, 0);
          scrollView.contentInset = adjustForTabbarInsets;
          scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
          CGRect contentRect = CGRectZero;
          for (UIView *view in scrollView.subviews) {
               contentRect = CGRectUnion(contentRect, view.frame);
          }
          scrollView.contentSize = contentRect.size;
          [self.view addSubview:scrollView];
          
          [self getLikesMethodWithCompletion:^(NSInteger integer, NSError *error) {
               
               self.NA.likes = [NSNumber numberWithInteger:integer];
               
               [likesLabel removeFromSuperview];
               likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorDateLabel.frame.origin.x, authorDateLabel.frame.origin.y + authorDateLabel.frame.size.height + 10, self.view.frame.size.width - 20, 30)];
               if ([self.NA.likes integerValue] == 1) {
                    likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" like"];
               } else
                    likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" likes"];
               [likesLabel setFont:[UIFont systemFontOfSize:16]];
               [likesLabel sizeToFit];
               [scrollView addSubview:likesLabel];
               
               [self viewMethodWithCompletion:^(NSUInteger integer, NSError *error) {
                    [activity stopAnimating];
                    if (self.showCloseButton == true) {
                         UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
                         self.navigationItem.rightBarButtonItem = barButtonItem;
                    }
               } forID:self.NA.objectId];
               
          } forID:self.NA.objectId];
          
     } else {
          UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
          UIImage *image = [UIImage imageWithData:self.imageData];
          if (image.size.width > self.view.frame.size.width - 20) {
               image = [[AppManager getInstance] imageFromImage:image scaledToWidth:self.view.frame.size.width - 20];
          }
          if (image.size.height > self.view.frame.size.height - 300) {
               image = [[AppManager getInstance] imageFromImage:image scaledToHeight:self.view.frame.size.height - 300];
          }
          imageView.image = image;
          [imageView sizeToFit];
          imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, 10, imageView.frame.size.width, imageView.frame.size.height);
          [scrollView addSubview:imageView];
          
          titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
          titleLabel.text = self.NA.titleString;
          [titleLabel setFont:[UIFont systemFontOfSize:24]];
          titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
          titleLabel.numberOfLines = 0;
          [titleLabel sizeToFit];
          [scrollView addSubview:titleLabel];
          
          UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
          summaryLabel.text = self.NA.summaryString;
          UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
          [summaryLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
          summaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
          summaryLabel.numberOfLines = 0;
          [summaryLabel sizeToFit];
          [scrollView addSubview:summaryLabel];
          
          authorDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(summaryLabel.frame.origin.x, summaryLabel.frame.origin.y + summaryLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
          authorDateLabel.text = [[self.NA.authorString stringByAppendingString:@" | "] stringByAppendingString:self.NA.dateString];
          [authorDateLabel setFont:[UIFont systemFontOfSize:12]];
          authorDateLabel.lineBreakMode = NSLineBreakByWordWrapping;
          authorDateLabel.numberOfLines = 0;
          [authorDateLabel sizeToFit];
          [scrollView addSubview:authorDateLabel];
          
          likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorDateLabel.frame.origin.x, authorDateLabel.frame.origin.y + authorDateLabel.frame.size.height + 10, self.view.frame.size.width - 20, 30)];
          if ([self.NA.likes integerValue] == 1) {
               likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" like"];
          } else
               likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" likes"];
          [likesLabel setFont:[UIFont systemFontOfSize:16]];
          [likesLabel sizeToFit];
          [scrollView addSubview:likesLabel];
          
          NSMutableArray *liked = [[NSUserDefaults standardUserDefaults] objectForKey:@"likedNewsArticles"];
          if (liked) {
               if (! [liked containsObject:self.NA.articleID]) {
                    likesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [likesButton addTarget:self action:@selector(likeMethod) forControlEvents:UIControlEventTouchUpInside];
                    [likesButton setImage:[[UIImage imageNamed:@"like@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                    [likesButton sizeToFit];
                    CGFloat width = likesButton.frame.size.width;
                    likesButton.frame = CGRectMake((self.view.frame.size.width - width - 20), likesLabel.frame.origin.y, likesButton.frame.size.width, likesButton.frame.size.height);
                    [scrollView addSubview:likesButton];
                    [self runSpinAnimationOnView:likesButton duration:2 rotations:1 repeat:0];
               } else {
                    likesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [likesButton addTarget:self action:@selector(likeMethod) forControlEvents:UIControlEventTouchUpInside];
                    [likesButton setImage:[[UIImage imageNamed:@"done@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                    [likesButton sizeToFit];
                    [likesButton setEnabled:false];
                    CGFloat width = likesButton.frame.size.width;
                    likesButton.frame = CGRectMake((self.view.frame.size.width - width - 20), likesLabel.frame.origin.y, likesButton.frame.size.width, likesButton.frame.size.height);
                    [scrollView addSubview:likesButton];
               }
          } else {
               likesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [likesButton addTarget:self action:@selector(likeMethod) forControlEvents:UIControlEventTouchUpInside];
               [likesButton setImage:[[UIImage imageNamed:@"like@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];               [likesButton sizeToFit];
               CGFloat width = likesButton.frame.size.width;
               likesButton.frame = CGRectMake((self.view.frame.size.width - width - 20), likesLabel.frame.origin.y, likesButton.frame.size.width, likesButton.frame.size.height);
               [scrollView addSubview:likesButton];
               [self runSpinAnimationOnView:likesButton duration:2 rotations:1 repeat:0];
          }
          
          CGFloat height = 0;
          if (likesButton != nil) {
               height = likesButton.frame.origin.y + likesButton.frame.size.height + 10;
          } else {
               height = likesLabel.frame.origin.y + likesLabel.frame.size.height + 10;
          }
          
          UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width - 20, 1)];
          separator.backgroundColor = [UIColor blackColor];
          [scrollView addSubview:separator];
          
          CGFloat x = separator.frame.origin.x;
          CGFloat y = separator.frame.origin.y + separator.frame.size.height + 10;
          CGFloat width = self.view.frame.size.width - 20;
          CGFloat heightTwo = self.view.frame.size.height - 10 - (separator.frame.origin.y + separator.frame.size.height + 10);
          
          UIWebView *webView = [[UIWebView alloc] init];
          webView.frame = CGRectMake(x, y, width, heightTwo);
          x = 0;
          y = 0;
          width = 0;
          heightTwo = 0;
          NSString *html = [Utils convertHTMLString:self.NA.contentURLString];
          [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://"]];
          webView.scrollView.scrollEnabled = YES;
          [webView sizeToFit];
          webView.delegate = self;
          webView.dataDetectorTypes = UIDataDetectorTypeAll;
          
          [scrollView addSubview:webView];
          
               //Takes care of all resizing needs based on sizes.
          UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 150, 0);
          scrollView.contentInset = adjustForTabbarInsets;
          scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
          CGRect contentRect = CGRectZero;
          for (UIView *view in scrollView.subviews) {
               contentRect = CGRectUnion(contentRect, view.frame);
          }
          scrollView.contentSize = contentRect.size;
          [self.view addSubview:scrollView];
          
          [self getLikesMethodWithCompletion:^(NSInteger integer, NSError *error) {
               
               self.NA.likes = [NSNumber numberWithInteger:integer];
               
               [likesLabel removeFromSuperview];
               likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorDateLabel.frame.origin.x, authorDateLabel.frame.origin.y + authorDateLabel.frame.size.height + 10, self.view.frame.size.width - 20, 30)];
               if ([self.NA.likes integerValue] == 1) {
                    likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" like"];
               } else
                    likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" likes"];
               [likesLabel setFont:[UIFont systemFontOfSize:16]];
               [likesLabel sizeToFit];
               [scrollView addSubview:likesLabel];
               
               [self viewMethodWithCompletion:^(NSUInteger integer, NSError *error) {
                    [activity stopAnimating];
                    if (self.showCloseButton == true) {
                         UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
                         self.navigationItem.rightBarButtonItem = barButtonItem;
                    }
               } forID:self.NA.objectId];
               
          } forID:self.NA.objectId];
     }
}

     // Key WebView delegate methods!!!

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
     
     
     if (navigationType == UIWebViewNavigationTypeLinkClicked){
          
          [[UIApplication sharedApplication] openURL:request.URL];
          return NO;
          
     }
     
     else return YES;
     
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, webView.scrollView.contentSize.height);
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 150, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;

}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
     CABasicAnimation* rotationAnimation;
     rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
     rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
     rotationAnimation.duration = duration;
     rotationAnimation.cumulative = YES;
     rotationAnimation.repeatCount = repeat;
     
     [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)viewMethodWithCompletion:(void (^)(NSUInteger integer, NSError *error))completion forID:(NSString *)objectID {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"articleID" equalTo:self.NA.articleID];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          PFObject *object = (PFObject *)[objects firstObject];
          if (object) {
               [object setObject:[NSNumber numberWithInteger:[[object objectForKey:@"views"] integerValue] + 1] forKey:@"views"];
               [self.NA setObject:[NSNumber numberWithInteger:[self.NA.views integerValue] + 1] forKey:@"views"];               [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    dispatch_group_leave(serviceGroup);
               }];
          } else {
               dispatch_group_leave(serviceGroup);
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(0, overallError);
     });
}

- (void)getLikesMethodWithCompletion:(void (^)(NSInteger integer, NSError *error))completion forID:(NSString *)objectID {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSInteger returnInteger;
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"articleID" equalTo:self.NA.articleID];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          PFObject *object = (PFObject *)[objects firstObject];
          if (object)
               returnInteger = [[object objectForKey:@"likes"] integerValue];
          theError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(returnInteger, overallError);
     });
}

- (void)viewWillDisappear:(BOOL)animated {
     [super viewWillDisappear:animated];
          //Run method to pass current structure back to the tableView...
     if (! self.showCloseButton) {
          if ([self.navigationController.viewControllers objectAtIndex:1]) {
               NewsCenterTableViewController *viewController = (NewsCenterTableViewController *)[self.navigationController.viewControllers objectAtIndex:1];
               [viewController replaceNewsArticleStructure:self.NA];
          }
     }
}

- (void)getImageWithCompletion:(void (^)(NSError *error, UIImage *image))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     PFFile *imageFile = self.NA.imageFile;
     UIImage *image = [UIImage alloc];
     __block NSError *theError;
     [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
          [image initWithData:data];
          if (error) {
               theError = error;
          }
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(theError, image);
     });
}

- (void)likeMethod {
     [likesButton setImage:[[UIImage imageNamed:@"done@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
     [likesButton sizeToFit];
     [likesButton setEnabled:false];
     [likesLabel removeFromSuperview];
     NSInteger likes = [self.NA.likes integerValue];
     NSNumber *newLikes = [NSNumber numberWithInt:likes + 1];
     self.NA.likes = newLikes;
     if ([newLikes integerValue] == 1) {
          likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" like"];
     } else
          likesLabel.text = [[self.NA.likes stringValue] stringByAppendingString:@" likes"];
     [likesLabel sizeToFit];
     likesLabel.frame = CGRectMake(10, authorDateLabel.frame.origin.y + authorDateLabel.frame.size.height + 10, likesLabel.frame.size.width, likesLabel.frame.size.height);
     [scrollView addSubview:likesLabel];
     UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     [self likeImageWithCompletion:^(NSUInteger integer) {
          [activity stopAnimating];
          if (self.showCloseButton == true) {
               UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
               self.navigationItem.rightBarButtonItem = barButtonItem;
          }
     } forID:self.NA.objectId];
}

- (void)likeImageWithCompletion:(void (^)(NSUInteger integer))completion forID:(NSString *)objectID {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSNumber *newLikes = self.NA.likes;
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"articleID" equalTo:self.NA.articleID];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          PFObject *object = (PFObject *)[objects firstObject];
          [object setObject:newLikes forKey:@"likes"];
          [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               NSMutableArray *theLikedNews = [[[NSUserDefaults standardUserDefaults] objectForKey:@"likedNewsArticles"] mutableCopy];
               if (! theLikedNews) {
                    theLikedNews = [[NSMutableArray alloc] init];
               }
               if (! [theLikedNews containsObject:self.NA.articleID]) {
                    [theLikedNews addObject:self.NA.articleID];
                    [[NSUserDefaults standardUserDefaults] setObject:theLikedNews forKey:@"likedNewsArticles"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    dispatch_group_leave(serviceGroup);
               }
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(0);
     });
}

- (instancetype)initWithNewsArticle:(NewsArticleStructure *)newsArticle {
     self = [super init];
     self.NA = newsArticle;
     self.navigationItem.title = @"Article";
     return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIStateRestoration

NSString *const ViewControllerProductKey = @"ViewControllerProductKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the product
    [coder encodeObject:self.NA forKey:ViewControllerProductKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the product
    self.NA = [coder decodeObjectForKey:ViewControllerProductKey];
}
@end
