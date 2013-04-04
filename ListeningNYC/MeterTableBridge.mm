#import "MeterTableBridge.h"
#import "MeterTable.h"

@implementation MeterTableBridge

+ (float)valueForDB:(float)db {
    static MeterTable *meterTable = nil;
    if (!meterTable) {
        meterTable = new MeterTable(-25.0f, 800, 8.0);
    }
    float outValue = meterTable->ValueAt(db -25.0f);
    static float max = -600.0f;
    if (db > max) {
        max = db;
    }
    return outValue;
}

@end
