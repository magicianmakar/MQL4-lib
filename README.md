# mql4-lib

MQL4 Foundation Library For Professional Developers

## Introduction

MQL4 programming language provided by MetaQuotes is a very limited
version of C++, and its standard library is a clone of the (ugly) MFC,
both of which I am very uncomfortable of.  Most MQL4 programs have not
adapted to the MQL5 (Object Oriented) style yet, let alone reuable and
elegant component based design and programming.

mql4-lib is a simple library that tries to make MQL4 programming
pleasant with a more object oriented approach and a coding style like
Java, and encourages writing reusable components. This library has the
ambition to become the de facto Foundation Library for MQL4.

## Installation

Just copy the library to your MQL4 Data Folder's `Include` directory,
with the root directory name of your choice, for example:
`<MQL4Data>\Include\MQL4\<mql4-lib content>`.

## Usage

The library is in its early stage. However, most components are pretty
stable and can be used in production. Here are the main components:

1. `Lang` directory contains modules that enhance the MQL4 language
2. `Collection` directory contains useful collection types
3. `Charts` directory contains several chart types and common chart tools
4. `Trade` directory contains useful abstractions for trading
5. `Utils` directory contains various utilities

In `Lang`, I abstract three Program types (Script, Indicator, and
 Expert Advisor) to three base classes that you can inherit.

The general usage is as below:

```
input string InpEaName = "My EA";
input double InpBaseLot = 0.1;

#include <MQL4/Lang/ExpertAdvisor.mqh>

class MyEa: public ExpertAdvisor
{
private:
  string m_name;
  double m_baseLot;
public:
  void setName(string name) {m_name = name;}
  void setBaseLot(double lot) {m_baseLot = lot;}

  void main() {Print(m_name);}
};

DECLARE_EA(MyEa,
           PARAM(Name, InpEaName)
           PARAM(BaseLot, InpBaseLot))
```

You noticed that in the DECLARE_EA macro, the second part is not
separated by comma, as MQL4 preprocessor does not support variable
arguments for macros.

The `PARAM` macro injects parameters to the EA by its setters. Just
follow the Java Beans(TM) convention.

For Indicators and Scripts you can find their usage by reading the
source code. I used some macro tricks to work around limits of MQL4. I
will document the library in detail when I have the time.

With this approach, you can write reusable EAs, Scripts, or
Indicators.  You do not need to worry about the OnInit, OnDeinit,
OnStart, OnTick, etc.  You never use a input parameter directly in
your EA. You can write a base EA, and extend it easily.
