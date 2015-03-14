#import "DDLog.h"

#ifdef DEBUG
    int ddLogLevel = LOG_LEVEL_INFO;
#else
    int ddLogLevel = LOG_LEVEL_ERROR;
#endif