// Copyright 2007-2010 Baptiste Lepilleur
// Distributed under MIT license, or public domain if desired and
// recognized in your jurisdiction.
// See file LICENSE for detail or copy at http://jsoncpp.sourceforge.net/LICENSE

#ifndef JSON_CONFIG_H_INCLUDED
#define JSON_CONFIG_H_INCLUDED

// ############################################################################
// Last Modified: Derek Barnett, 6 June 2012

#ifndef LIBRARY_EXPORT
#  if defined(WIN32)
#    define LIBRARY_EXPORT __declspec(dllexport)
#  else
#    define LIBRARY_EXPORT __attribute__((visibility("default")))
#  endif
#endif // LIBRARY_EXPORT

#ifndef LIBRARY_IMPORT
#  if defined(WIN32)
#    define LIBRARY_IMPORT __declspec(dllimport)
#  else
#    define LIBRARY_IMPORT
#  endif
#endif // LIBRARY_IMPORT

#ifdef JSONCPP_LIBRARY
#  define JSON_API LIBRARY_EXPORT
#else
#  define JSON_API LIBRARY_IMPORT
#endif

// ############################################################################

#if defined(_MSC_VER)  &&  _MSC_VER <= 1200 // MSVC 6
// Microsoft Visual Studio 6 only support conversion from __int64 to double
// (no conversion from unsigned __int64).
#  define JSON_USE_INT64_DOUBLE_CONVERSION 1
#endif // if defined(_MSC_VER)  &&  _MSC_VER < 1200 // MSVC 6

namespace Json {

#if defined(JSON_NO_INT64)
   typedef int Int;
   typedef unsigned int UInt;
#else // if defined(JSON_NO_INT64)
   // For Microsoft Visual use specific types as long long is not supported
#  if defined(_MSC_VER) // Microsoft Visual Studio
     typedef __int64 Int;
     typedef unsigned __int64 UInt;
#  else // if defined(_MSC_VER) // Other platforms, use long long
     typedef long long int Int;
     typedef unsigned long long int UInt;
#  endif // if defined(_MSC_VER)
#endif // if defined(JSON_NO_INT64)

} // end namespace Json

#endif // JSON_CONFIG_H_INCLUDED
