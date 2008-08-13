//
//  PasoriRequest.h
//  PasoriKit
//
//  Created by GNUE(鵺) on 08/04/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PasoriRequest : NSObject {
	SEL		_selector;			///< 実行するメソッドのセレクタ
	id		_object;			///< ユーザデータ
}

+ (id)pasoriRequestWithSelector:(SEL)selector;
+ (id)pasoriRequestWithSelector:(SEL)selector withObject:(id)obj;

- (id)initWithSelector:(SEL)selector;
- (id)initWithSelector:(SEL)selector withObject:(id)obj;

- (id)param;
- (id)perform:(id)reciver;

@end
