#ifndef __STDDEFS_H__
#define __STDDEFS_H__

#define assert(__e) ((void)0)
#include <stdint.h>
#include <stdlib.h>

void *memcpy (void *dest, const void *src, size_t len);
int memcmp (const void *str1, const void *str2, size_t count);
void *memset (void *dest, int val, size_t len);
size_t strlen(const char*s);

#endif // __STDDEFS_H__
