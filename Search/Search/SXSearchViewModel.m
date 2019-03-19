//
//  SXSearchViewModel.m
//  SXNews
//
//  Created by dongshangxian on 16/3/8.
//  Copyright © 2016年 ShangxianDante. All rights reserved.
//

#import "SXSearchViewModel.h"
#import <HLNetworking/HLNetworking.h>
#import <Tools/NSString+Base64.h>


@implementation SXSearchViewModel
    
- (instancetype)init
    {
        if (self = [super init]) {
            [self setupRACCommand];
        }
        return self;
    }
    
- (void)setupRACCommand
    {
        @weakify(self);
        _fetchHotWordCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestForHotWordSuccess:^(NSArray *array) {
                    [subscriber sendNext:array];
                    [subscriber sendCompleted];
                } failure:^(NSError *error) {
                    [subscriber sendError:error];
                }];
                return nil;
            }];
        }];
        
        _fetchSearchResultListArray = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestForSearchResultListArrayWithSuccess:^(NSArray *array) {
                    [subscriber sendNext:array];
                    [subscriber sendCompleted];
                } failure:^(NSError *error) {
                    [subscriber sendError:error];
                }];
                return nil;
            }];
        }];
    }
    
#pragma mark - **************** 下面相当于service的代码
- (void)requestForHotWordSuccess:(void (^)(NSArray *array))success
                         failure:(void (^)(NSError *error))failure{
    NSString *url = [NSString stringWithFormat:@"http://c.3g.163.com/nc/search/hotWord.html"];
    [[HLAPIRequest request]
     .setMethod(GET)
     .setCustomURL(url)
     .success(^(id response){
        NSArray *array = response[@"hotWordList"];
        if (array) {
            success(array);
        }
    })
     .failure(^(NSError *error){
        failure(error);
    }) start];
}
    
- (void)requestForSearchResultListArrayWithSuccess:(void (^)(NSArray *array))success
                                           failure:(void (^)(NSError *error))failure{
    NSString *searchKeyWord = [self.searchText base64encode];
    NSString *url = [NSString stringWithFormat:@"http://c.3g.163.com/search/comp/MA==/20/%@.html",searchKeyWord];
    [[HLAPIRequest request]
     .setMethod(GET)
     .setCustomURL(url)
     .success(^(id response){
        NSArray *dictArray = response[@"doc"][@"result"];
        if (dictArray) {
            success(dictArray);
        }
    })
     .failure(^(NSError *error){
        failure(error);
    }) start];
}
    
    @end
