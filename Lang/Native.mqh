//+------------------------------------------------------------------+
//| Module: Lang/Native.mqh                                          |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016-2017 Li Ding <dingmaotu@126.com>                  |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict

// Assume MT5 is 64bit, which is the default.
// Even though MT5 can be 32bit, there is no way to detect this
// by using preprocessor macros. Instead, MetaQuotes provides a
// function called IsX64 to detect this dynamically

// This is just absurd. Why do you want to know the bitness of
// the runtime? To define pointer related entities at compile time!
// All integer types in MQL is uniform on both 32bit or 64bit
// architectures, so it is almost useless to have a runtime function IsX64.

// Why not a __X64__?
#ifdef __MQL5__
#define __X64__
#endif

#ifdef __X64__
#define intptr_t long
#define uintptr_t ulong
#define size_t long
#else
#define intptr_t int
#define uintptr_t uint
#define size_t int
#endif

//--- _WIN32_WINNT version constants
#define _WIN32_WINNT_NT4                    0x0400 // Windows NT 4.0
#define _WIN32_WINNT_WIN2K                  0x0500 // Windows 2000
#define _WIN32_WINNT_WINXP                  0x0501 // Windows XP
#define _WIN32_WINNT_WS03                   0x0502 // Windows Server 2003
#define _WIN32_WINNT_WIN6                   0x0600 // Windows Vista
#define _WIN32_WINNT_VISTA                  0x0600 // Windows Vista
#define _WIN32_WINNT_WS08                   0x0600 // Windows Server 2008
#define _WIN32_WINNT_LONGHORN               0x0600 // Windows Vista
#define _WIN32_WINNT_WIN7                   0x0601 // Windows 7
#define _WIN32_WINNT_WIN8                   0x0602 // Windows 8
#define _WIN32_WINNT_WINBLUE                0x0603 // Windows 8.1
#define _WIN32_WINNT_WINTHRESHOLD           0x0A00 // Windows 10
#define _WIN32_WINNT_WIN10                  0x0A00 // Windows 10

//--- define you own for your target platform
#define WINVER 0x0A00
#define _WIN32_WINNT 0x0A00

#define FORMAT_MESSAGE_FROM_SYSTEM 0x00001000
#define FORMAT_MESSAGE_IGNORE_INSERTS 0x00000200

#import "kernel32.dll"
void RtlMoveMemory(intptr_t dest,const uchar &array[],size_t length);
void RtlMoveMemory(uchar &array[],intptr_t src,size_t length);
void RtlMoveMemory(intptr_t &dest,intptr_t src,size_t length);
int lstrlen(intptr_t psz);
int lstrlenW(intptr_t psz);
uintptr_t lstrcpynW(string &s1,uintptr_t s2,int length);
uintptr_t lstrcpynW(uintptr_t s1,string &s2,int length);

int MultiByteToWideChar(uint   codePage,
                        uint   flags,
                        const  intptr_t multiByteString,
                        int    lengthMultiByte,
                        string &str,
                        int    length
                        );
uint FormatMessageW(uint dwFlags,
                    intptr_t lpSource,
                    uint dwMessageId,
                    uint dwLanguageId,
                    ushort &buffer[],
                    uint nSize,
                    intptr_t Arguments
                    );
#import

//--- This is a standard header of the official MetaTrader distribution
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//| Copy the memory contents pointed by src to array                 |
//| array parameter should be initialized to the desired size        |
//+------------------------------------------------------------------+
void ArrayFromPointer(uchar &array[],intptr_t src,int count=WHOLE_ARRAY)
  {
   int size=(count==WHOLE_ARRAY)?ArraySize(array):count;
   RtlMoveMemory(array,src,(size_t)size);
  }
//+------------------------------------------------------------------+
//| Copy array to the memory pointed by dest                         |
//+------------------------------------------------------------------+
void ArrayToPointer(const uchar &array[],intptr_t dest,int count=WHOLE_ARRAY)
  {
   int size=(count==WHOLE_ARRAY)?ArraySize(array):count;
   RtlMoveMemory(dest,array,(size_t)size);
  }
//+------------------------------------------------------------------+
//| For void** type, dereference a level to void*                    |
//+------------------------------------------------------------------+
intptr_t DereferencePointer(intptr_t pointer)
  {
   intptr_t res=0;
   RtlMoveMemory(res,pointer,sizeof(intptr_t));
   return res;
  }
//+------------------------------------------------------------------+
//| Read a valid wide character string to the MQL environment        |
//+------------------------------------------------------------------+
string StringFromPointer(intptr_t psz,int len=0)
  {
   if(len < 0) return NULL;
   if(len==0) {len=lstrlenW(psz);}
   string res;
   StringInit(res,len+1);
   lstrcpynW(res,psz,len+1);
   return res;
  }
//+------------------------------------------------------------------+
//| Get the pointer address of a string                              |
//+------------------------------------------------------------------+
uintptr_t StringToPointer(string &s)
  {
   return lstrcpynW(s,0,0);
  }
//+------------------------------------------------------------------+
//| Read a valid utf-8 string to the MQL environment                 |
//| With this function, there is no need to copy the string to char  |
//| array, and convert with CharArrayToString                        |
//+------------------------------------------------------------------+
string StringFromUtf8Pointer(intptr_t psz,int len)
  {
   if(len < 0) return NULL;
   string res;
   int required=MultiByteToWideChar(CP_UTF8,0,psz,len,res,0);
   StringInit(res,required);
   int resLength = MultiByteToWideChar(CP_UTF8,0,psz,len,res,required);
   if(resLength != required)
     {
      return NULL;
     }
   else
     {
      return res;
     }
  }
//+------------------------------------------------------------------+
//| for null-terminated string                                       |
//+------------------------------------------------------------------+
string StringFromUtf8Pointer(intptr_t psz)
  {
   if(psz==0) return NULL;
   int len=lstrlen(psz);
   if(len==0) return NULL;
   return StringFromUtf8Pointer(psz, len);
  }
//+------------------------------------------------------------------+
//| Convert a utf-8 byte array to a string                           |
//+------------------------------------------------------------------+
string StringFromUtf8(const uchar &utf8[])
  {
   return CharArrayToString(utf8, 0, -1, CP_UTF8);
  }
//+------------------------------------------------------------------+
//| Convert a string to a utf-8 byte array                           |
//+------------------------------------------------------------------+
void StringToUtf8(const string str,uchar &utf8[],bool ending=true)
  {
   if(!ending && str=="") return;
   int count=ending ? -1 : StringLen(str);
   StringToCharArray(str,utf8,0,count,CP_UTF8);
  }
//+------------------------------------------------------------------+
//| Get system defined error code message                            |
//+------------------------------------------------------------------+
string GetErrorMessage(int errorCode)
  {
   static ushort buffer[64*1024];
   FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
                  0,errorCode,0,buffer,ArraySize(buffer),0);
   return ShortArrayToString(buffer);
  }
//+------------------------------------------------------------------+
