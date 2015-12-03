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

#import "Macros.h"


@implementation ThreadedContextManager


@synthesize mManagedObjectContext_;


#pragma mark - Object Life Cycle


- (id)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    
    if (self)
    {
        self.mManagedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [mManagedObjectContext_ setParentContext:context];
        [mManagedObjectContext_ setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ThreadedContextManager_Init object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ThreadedContextManager_Release object:nil];
}


#pragma mark - Public Management


- (NSManagedObjectContext*)managedObjectContext
{
    return mManagedObjectContext_;
}


- (void)performBlockWaitUntilDone:(void (^)(NSManagedObjectContext* context))block
                          success:(void (^)())success
                          failure:(void (^)(NSError* error))failure
{
    [self.managedObjectContext performBlockAndWait:^
     {
         BlockSafe(block, self.managedObjectContext);
         
         NSError* error = nil;
         [self.managedObjectContext save:&error];
         
         if (error)
         {
             BlockSafe(failure, error);
             return;
         }
         
         [self.managedObjectContext.parentContext performBlock:^
          {
              NSError* error2 = nil;
              
              [self.managedObjectContext.parentContext save:&error2];
              
              if (error2)
              {
                  BlockSafe(failure, error2);
                  return;
              }
              
              BlockSafe (success);

          }];
     }];
}


- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
             success:(void (^)())success
             failure:(void (^)(NSError* error))failure
{
    [self.managedObjectContext performBlock:^
     {
         BlockSafe(block, self.managedObjectContext);
         
         NSError* error = nil;
         [self.managedObjectContext save:&error];
         
         if (error)
         {
             BlockSafe(failure, error);
             return;
         }
         
         [self.managedObjectContext.parentContext performBlock:^
          {
              NSError* error2 = nil;
              
              [self.managedObjectContext.parentContext save:&error2];
              
              if (error2)
              {
                  BlockSafe(failure, error2);
                  return;
              }
              
              BlockSafe (success);
          }];
     }];
}
@end
