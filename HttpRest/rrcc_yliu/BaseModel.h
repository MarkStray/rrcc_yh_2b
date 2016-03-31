//
//  BaseModel.h
//


#import <Foundation/Foundation.h>

@interface BaseModel : NSObject <NSCoding>

//构造方法
- (id)initWithDictionary:(NSDictionary *)jsonDic;
+ (id)creatWithDictionary:(NSDictionary *)jsonDic;

//归档专用
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
