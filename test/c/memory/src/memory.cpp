#include <cstdlib>
#include <string>
#include <format>

#include "../include/memory.h"

EXPORT const char *version() { return "0.0.1"; }

typedef void (*LogFnCallback)(char *);

LogFnCallback callocCallback = NULL;
LogFnCallback freeCallback = NULL;

EXPORT void setCallocLog(LogFnCallback callback)
{
  callocCallback = callback;
}
EXPORT void setFreeLog(LogFnCallback callback)
{
  freeCallback = callback;
}

int notFree = 0;
EXPORT int getNotFreeNum() { return notFree; }

EXPORT void *myCalloc(size_t num, size_t size)
{
  void *ptr = std::calloc(num, size);
  notFree++;
  if (callocCallback != NULL)
  {
    char buf[100];
    std::sprintf(buf, std::string(std::format("[C] myCalloc num:{}, size:{}, ptr:{}", num, size, ptr)).c_str());
    callocCallback(buf);
  }
  return ptr;
}

EXPORT void myFree(void *ptr)
{
  notFree--;
  if (freeCallback != NULL)
  {
    char buf[100];
    std::sprintf(buf, std::string(std::format("[C] myFree ptr:{}", ptr)).c_str());
    freeCallback(buf);
  }
  return std::free(ptr);
}
