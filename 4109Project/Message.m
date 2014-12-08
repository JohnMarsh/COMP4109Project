//
//  Message.m
//  COMP2601class18
//
//  Created by John Marsh on 13-03-28.
//  Copyright (c) 2013 John Marsh. All rights reserved.
//

#import "Message.h"


@implementation Message

@synthesize head = _head;
@synthesize body = _body;


-(Message *)initWithType:(NSString*)type{
    self.head = [[NSMutableDictionary alloc] initWithObjectsAndKeys:type, @"type", nil];
    self.body = [[NSMutableDictionary alloc]init];
    return [super init];
}

-(Message *)initFromJSON:(NSData*)data {
    NSLog(@"building message from json data %@", data);
    Message *msg = [[Message alloc] init];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
   // NSLog(@"objects are %@ and %@", [json objectForKey:@"head"], [json objectForKey:@"body"]);
    msg.head = [json objectForKey:@"head"];
    msg.body = [json objectForKey:@"body"];
    return msg;
}

-(NSData*)toJSON{
    NSDictionary *msg = [[NSDictionary alloc] initWithObjectsAndKeys:self.head, @"head",self.body, @"body", nil];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:msg options:NSJSONWritingPrettyPrinted error:&error];
    
    return data;
}



@end
