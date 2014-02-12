#import "BETURLSessionResponseSerializerJSON.h"



@interface NSArray (BETURLSessionSerializers)
-(void)BETURLSession_recursivelyRemoveNulls;
@end

@interface NSDictionary (BETURLSessionSerializers)
-(void)BETURLSession_recursivelyRemoveNulls;
@end



@interface BETURLSessionResponseSerializerJSON ()
@property(nonatomic,assign) NSJSONReadingOptions JSONReadingOptions;
@property(nonatomic,assign) BOOL withoutNull;
@end

@implementation BETURLSessionResponseSerializerJSON
@synthesize acceptHeader = _acceptHeader;
@synthesize acceptableMIMETypes = _acceptableMIMETypes;

-(instancetype)init; {
  self = [super init];
  if(self) {
    _acceptableMIMETypes = [NSSet setWithArray:@[@"application/json", @"text/json", @"text/javascript"]];
    _acceptHeader = [_acceptableMIMETypes.allObjects componentsJoinedByString:@","];
  }
  return self;
}

+(instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)theJSONReadingOptions withoutNull:(BOOL)theNoNullFlag;
 {
  if(theNoNullFlag) theJSONReadingOptions = theJSONReadingOptions && NSJSONReadingMutableContainers;


  BETURLSessionResponseSerializerJSON * serializer = [[self alloc] init];
  serializer.JSONReadingOptions  = theJSONReadingOptions;
  serializer.withoutNull = theNoNullFlag;
  return serializer;
}

-(void)buildObjectForResponse:(NSURLResponse *)theResponse
                 responseData:(NSData *)theResponseData
                 onCompletion:(BETURLSessionSerializerErrorBlock)theBlock; {
  
  NSParameterAssert(theBlock);
  
  __block id theResponseObject = nil;
  
  [self validateResponse:(NSHTTPURLResponse *)theResponse data:theResponseData onCompletion:^(id obj, NSError *error) {
    NSError * JSONParseError = nil;
    
    if(theResponseData){
      theResponseObject =[NSJSONSerialization JSONObjectWithData:theResponseData options:self.JSONReadingOptions error:&JSONParseError];
      if(self.withoutNull && JSONParseError == nil) [theResponseObject BETURLSession_recursivelyRemoveNulls];
      
    }
    
    
    theBlock(theResponseObject, error);
    
  }];
  
}

@end







@implementation NSMutableDictionary (BETURLSessionSerializers)

-(void)BETURLSession_recursivelyRemoveNulls; {
  
  NSMutableArray * nullKeys       = @[].mutableCopy;
  NSMutableArray * arrayKeys      = @[].mutableCopy;
  NSMutableArray * dictionaryKeys = @[].mutableCopy;
  
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
     if ([obj isEqual:[NSNull null]])                     [nullKeys addObject:key];
     else if ([obj isKindOfClass:[NSDictionary  class]])  [dictionaryKeys addObject:key];
     else if ([obj isKindOfClass:[NSArray class]])        [arrayKeys addObject:key];

   }];
  
  [self removeObjectsForKeys:nullKeys];
  
  
  [arrayKeys enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
    NSMutableArray * arrayToCleanse = self[obj];
    [arrayToCleanse BETURLSession_recursivelyRemoveNulls];
  }];
  
  [dictionaryKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSMutableDictionary * dictionaryToCleanse = self[obj];
    [dictionaryToCleanse BETURLSession_recursivelyRemoveNulls];
  }];
  

}

@end

@implementation NSMutableArray (BETURLSessionSerializers)

-(void)BETURLSession_recursivelyRemoveNulls; {
  // First, filter out directly stored nulls if required
  [self filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,
                                                                     NSDictionary *bindings){
    return ([evaluatedObject isEqual:[NSNull null]] == NO);
  }]];
    

  
  NSMutableIndexSet * arrayIndexes      = [NSIndexSet indexSet].mutableCopy;
  NSMutableIndexSet * dictionaryIndexes = [NSIndexSet indexSet].mutableCopy;
  
  [self enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, __unused BOOL *stop) {
     if ([obj isKindOfClass:[NSDictionary  class]]) [dictionaryIndexes addIndex:idx];

     else if ([obj isKindOfClass:[NSArray class]]) [arrayIndexes addIndex:idx];

   }];
  
  
  [[self objectsAtIndexes:arrayIndexes] enumerateObjectsUsingBlock:^(NSMutableArray * obj, __unused NSUInteger idx, __unused BOOL *stop) {
    [obj BETURLSession_recursivelyRemoveNulls];
  }];
  
  
  [[self objectsAtIndexes:dictionaryIndexes] enumerateObjectsUsingBlock:^(NSMutableDictionary * obj, __unused NSUInteger idx, __unused BOOL *stop) {
    [obj BETURLSession_recursivelyRemoveNulls];
  }];
  
}

@end