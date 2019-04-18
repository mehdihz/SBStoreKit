#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

+ (id)initView {
    LoginViewController* loginVc = [[LoginViewController alloc] init];

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    [bundle loadNibNamed:@"LoginViewController" owner:loginVc options:nil];
        
    return loginVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //always fill the view
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView]; //if you have more UIViews, use an insertSubview API to place it where needed
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)closeButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
