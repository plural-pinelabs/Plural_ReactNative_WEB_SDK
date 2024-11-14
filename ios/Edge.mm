#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <React/RCTUtils.h>

@interface RCT_EXTERN_MODULE(EdgeModule, NSObject)

// Expose the startPayment method to React Native
RCT_EXTERN_METHOD(startPayment:(NSString *)redirectUrl
                     callback:(RCTResponseSenderBlock)callback)

@end
