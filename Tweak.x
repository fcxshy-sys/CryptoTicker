#import <UIKit/UIKit.h>

@interface CryptoTickerManager : NSObject
@property (nonatomic, strong) UIWindow *tickerWindow;
@property (nonatomic, strong) UILabel *priceLabel;
+ (instancetype)sharedManager;
- (void)setupUI;
- (void)fetchPrices;
@end

@implementation CryptoTickerManager
+ (instancetype)sharedManager {
    static CryptoTickerManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)setupUI {
    self.tickerWindow = [[UIWindow alloc] initWithFrame:CGRectMake(20, 10, 100, 20)];
    self.tickerWindow.windowLevel = UIWindowLevelStatusBar + 100;
    self.tickerWindow.hidden = NO;
    self.tickerWindow.backgroundColor = [UIColor clearColor];
    self.tickerWindow.userInteractionEnabled = NO;

    self.priceLabel = [[UILabel alloc] initWithFrame:self.tickerWindow.bounds];
    self.priceLabel.textColor = [UIColor systemGreenColor];
    self.priceLabel.font = [UIFont boldSystemFontOfSize:12];
    self.priceLabel.text = @"BTC: --";
    [self.tickerWindow addSubview:self.priceLabel];
}

- (void)fetchPrices {
    NSURL *url = [NSURL URLWithString:@"https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            double price = [json[@"price"] doubleValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.priceLabel.text = [NSString stringWithFormat:@"B: %.1f", price];
            });
        }
    }];
    [task resume];
}
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CryptoTickerManager sharedManager] setupUI];
        [[CryptoTickerManager sharedManager] fetchPrices];
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:[CryptoTickerManager sharedManager] selector:@selector(fetchPrices) userInfo:nil repeats:YES];
    });
}
%end
