//
//  WebView.m
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 7/5/13.
//
//

#import "WebView.h"

@interface WebView ()

@end

@implementation WebView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //NSString *fullURL = @"http://ericrosenbaum.com";
    NSString *fullURL = @"http://melodymorph2.xvm.mit.edu:8080/thumbs_page";
    
    NSURL *url =[NSURL URLWithString:fullURL];
    NSURLRequest *requestObj =[NSURLRequest requestWithURL:url];
    [_browser loadRequest:requestObj];
}

- (void)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"shouldStartLoadWithRequest");
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *requestedURL = [request URL];
        // ...Check if the URL points to a file you're looking for...
        // Then load the file
        NSData *fileData = [[NSData alloc] initWithContentsOfURL:requestedURL];
        // Get the path to the App's Documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        [fileData writeToFile:[NSString stringWithFormat:@"%@%@", documentsDirectory, [requestedURL lastPathComponent]] atomically:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_browser release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBrowser:nil];
    [super viewDidUnload];
}
@end
