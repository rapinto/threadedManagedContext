//
//  ThreadedContextManager.m
//
//
//  Created by Raphaël Pinto on 20/06/2014.
//
// The MIT License (MIT)
// Copyright (c) 2015 Raphael Pinto.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



#import "ThreadedContextManager.h"


typedef void (^PerformBlock)(void);


@implementation ThreadedContextManager


#pragma mark -
#pragma mark Object Life Cycle Methods



- (id)initWithContext:(NSManagedObjectContext*)_Context
{
    self = [super init];
    
    if (self)
    {
        NSManagedObjectContext* lContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext = lContext;
        [_managedObjectContext setParentContext:_Context];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ThreadedContextManager_Init object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ThreadedContextManager_Release object:nil];
}



#pragma mark -
#pragma mark Data Management Methods



#pragma mark - Public


- (void)performBlockWaitUntilDone:(NSArray * (^)(NSManagedObjectContext * context))block
                          success:(void (^)(NSArray *))success
                          failure:(void (^)(NSError * error))failure
{
    PerformBlock performBlock = [self getPerformBlockWithBlock:block success:success failure:failure];
    [_managedObjectContext performBlockAndWait:performBlock];
}


- (void)performBlock:(NSArray * (^)(NSManagedObjectContext * context))block
             success:(void (^)(NSArray * ))success
             failure:(void (^)(NSError* error))failure
{
    PerformBlock performBlock = [self getPerformBlockWithBlock:block success:success failure:failure];
    [_managedObjectContext performBlock:performBlock];
}


#pragma mark - Private


- (PerformBlock)getPerformBlockWithBlock:(NSArray * (^)(NSManagedObjectContext * context))block
                                 success:(void (^)(NSArray * ))success
                                 failure:(void (^)(NSError* error))failure
{
    return ^(void)
    {
        NSArray * managedObjects = nil;
        
        
        if (block)
        {
            managedObjects = block(_managedObjectContext);
        }
        
        
        
        NSError * saveError = nil;
        [_managedObjectContext save:&saveError];
        
        if (saveError)
        {
            if (failure)
            {
                failure (saveError);
            }
            return;
        }
        
        [_managedObjectContext.parentContext performBlock:
         ^(void)
         {
             NSError * parentSaveError = nil;
             
             [_managedObjectContext.parentContext save:&parentSaveError];
             
             if (parentSaveError)
             {
                 if (failure)
                 {
                     failure (parentSaveError);
                 }
                 return;
             }
             
             NSMutableArray * readableObjects = [NSMutableArray arrayWithCapacity:[managedObjects count]];
             
             for (NSManagedObject * object in managedObjects)
             {
                 NSManagedObject * readableObject = [_managedObjectContext.parentContext objectWithID:object.objectID];
                 if (readableObjects && readableObject)
                 {
                     [readableObjects addObject:readableObject];
                 }
             }
             
             if (success)
             {
                 success (readableObjects);
             }
         }];
    };
}


@end
