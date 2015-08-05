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


@implementation ThreadedContextManager



@synthesize mManagedObjectContext_;



#pragma mark -
#pragma mark Object Life Cycle Methods



- (id)initWithContext:(NSManagedObjectContext*)_Context
{
    self = [super init];
    
    if (self)
    {
        NSManagedObjectContext* lContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.mManagedObjectContext_ = lContext;
        [mManagedObjectContext_ setParentContext:_Context];
        [mManagedObjectContext_ setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ThreadedContextManagerInit" object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ThreadedContextManagerRelease" object:nil];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}



#pragma mark -
#pragma mark Data Management Methods



- (NSManagedObjectContext*)managedObjectContext
{
    return mManagedObjectContext_;
}


- (void)performBlockWaitUntilDone:(void (^)(NSManagedObjectContext* _Context))_Block  success:(void (^)(NSManagedObjectContext* _Context))_Success
{
    [self.managedObjectContext performBlockAndWait:^
     {
         _Block(self.managedObjectContext);
         NSError* lError = nil;
         [self.managedObjectContext save:&lError];
         
         if (lError)
         {
             NSLog(@"%@", [lError localizedDescription]);
         }
         
         [self.managedObjectContext.parentContext performBlock:^
          {
              NSError* lError2 = nil;
              
              [self.managedObjectContext.parentContext save:&lError2];
              
              if (lError2)
              {
                  NSLog(@"%@", [lError localizedDescription]);
              }
              
              _Success(self.managedObjectContext);
          }];
     }];
}


- (void)performBlock:(void (^)(NSManagedObjectContext* _Context))_Block  success:(void (^)(NSManagedObjectContext* _Context))_Success
{
    [self.managedObjectContext performBlock:^
     {
         _Block(self.managedObjectContext);
         NSError* lError = nil;
         [self.managedObjectContext save:&lError];
         
         if (lError)
         {
             NSLog(@"%@", [lError localizedDescription]);
         }
         
         [self.managedObjectContext.parentContext performBlock:^
          {
              NSError* lError2 = nil;
              
              [self.managedObjectContext.parentContext save:&lError2];
              
              if (lError2)
              {
                  NSLog(@"%@", [lError localizedDescription]);
              }
              
              _Success(self.managedObjectContext);
          }];
     }];
}
@end
