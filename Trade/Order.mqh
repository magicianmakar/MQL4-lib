//+------------------------------------------------------------------+
//| Module: Trade/Order.mqh                                          |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016 Li Ding <dingmaotu@126.com>                       |
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

#include "../Lang/String.mqh"
//+------------------------------------------------------------------+
//| if current order matches                                         |
//+------------------------------------------------------------------+
interface OrderMatcher
  {
   bool matches();
  };
//+------------------------------------------------------------------+
//| Some contant strings                                             |
//+------------------------------------------------------------------+
const string OrderTypeString[]={"buy","sell","buy limit","sell simit","buy stop","sell stop"};
const string ORDER_FROM_STR="from #";
const string ORDER_PARTIAL_CLOSE_STR="partial close";
const string ORDER_CLOSE_HEDGE_BY_STR="close hedge by #";
//+------------------------------------------------------------------+
//| Order (immutable)                                                |
//| Creating a new Order captures all properties of a current        |
//| selected order                                                   |
//+------------------------------------------------------------------+
class Order
  {
private:
   int               ticket;

   string            symbol;
   int               type;
   double            lots;

   double            openPrice;
   datetime          openTime;
   double            closePrice;
   datetime          closeTime;

   double            takeProfit;
   double            stopLoss;

   datetime          expiration;

   int               magicNumber;
   string            comment;

   double            commission;

   double            profit;
   double            swap;

public:
                     Order();
   string            toString() const;
   int               hash() const;

   static bool       Select(int ticket) {return OrderSelect(ticket,SELECT_BY_TICKET);}

   //--- static wrappers for getting order properties
   //--- this is necessary if you want to use these functions as function pointers
   static int        Ticket() { return OrderTicket();}

   static string     Symbol() { return OrderSymbol();}
   static int        Type() { return OrderType();}
   static double     Lots() { return OrderLots();}

   static double     OpenPrice() { return OrderOpenPrice();}
   static datetime   OpenTime() { return OrderOpenTime();}
   static double     ClosePrice() { return OrderClosePrice();}
   static datetime   CloseTime() { return OrderCloseTime();}

   static double     TakeProfit() { return OrderTakeProfit();}
   static double     StopLoss() { return OrderStopLoss();}

   static datetime   Expiration() { return OrderExpiration();}

   static int        MagicNumber() { return OrderMagicNumber();}
   static string     Comment() { return OrderComment();}

   static double     Commission() { return OrderCommission();}

   static double     Profit() { return OrderProfit();}
   static double     Swap() { return OrderSwap();}

   //+------------------------------------------------------------------+
   //| The order must be open and there are two situations:             |
   //| 1. If the original order is closed partially                     |
   //| 2. If the original order is closed by hedge and it is larger     |
   //|    than required lots                                            |
   //+------------------------------------------------------------------+
   static bool       IsPartialClose()
     {
      return OrderCloseTime()==0 &&
      StringStartsWith(OrderComment(),ORDER_FROM_STR);
     }
   //+------------------------------------------------------------------+
   //| This order is the result of OrderCloseBy (first argument)        |
   //| This can be used for both closed and open orders                 |
   //+------------------------------------------------------------------+
   static bool       IsCloseBy()
     {
      return StringStartsWith(OrderComment(),ORDER_PARTIAL_CLOSE_STR);
     }
   //+------------------------------------------------------------------+
   //| This closed order is the result of OrderCloseBy (second argument)|
   //| The order must be closed and its lots is 0                       |
   //| If it is a partial close, the resulting new order will have the  |
   //| "from #" comment                                                 |
   //+------------------------------------------------------------------+
   static bool       IsCloseByHedge()
     {
      return OrderCloseTime()>0 && OrderLots() == 0.0;
      // supposedly order lots being zero is enough for determining
      // a hedge close, so the following code might not be necessary
      // StringStartsWith(OrderComment(),ORDER_CLOSE_HEDGE_BY_STR);
     }

   //--- instance methods
   bool              isPartialClose() const {return closeTime==0 && StringStartsWith(comment,ORDER_FROM_STR);}
   bool              isCloseBy() const {return StringStartsWith(comment,ORDER_PARTIAL_CLOSE_STR);}
   bool              isCloseByHedge() const {return closeTime>0 && lots==0.0;}

   int               getTicket() const { return ticket;}

   string            getSymbol() const { return symbol;}
   int               getType() const { return type;}
   double            getLots() const { return lots;}

   double            getOpenPrice() const { return openPrice;}
   datetime          getOpenTime() const { return openTime;}
   double            getClosePrice() const { return closePrice;}
   datetime          getCloseTime() const { return closeTime;}

   double            getTakeProfit() const { return takeProfit;}
   double            getStopLoss() const { return stopLoss;}

   datetime          getExpiration() const { return expiration;}

   int               getMagicNumber() const { return magicNumber;}
   string            getComment() const { return comment;}

   double            getCommission() const { return commission;}

   double            getProfit() const { return profit;}
   double            getSwap() const { return swap;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(void)
  {
   ticket=Order::Ticket();

   symbol=Order::Symbol();
   type=Order::Type();
   lots=Order::Lots();

   openPrice=Order::OpenPrice();
   openTime=Order::OpenTime();
   closePrice=Order::ClosePrice();
   closeTime=Order::CloseTime();

   takeProfit=Order::TakeProfit();
   stopLoss=Order::StopLoss();

   expiration=Order::Expiration();

   magicNumber=Order::MagicNumber();
   comment=Order::Comment();

   commission=Order::Commission();

   profit=Order::Profit();
   swap=Order::Swap();
  }
//+------------------------------------------------------------------+
//| mimic OrderPrint but return a string instead                     |
//+------------------------------------------------------------------+
string Order::toString(void) const
  {
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   string res= StringFormat("#%d %s %s %.2f %s "
                            "%s %s %s",
                            ticket,TimeToString(openTime,TIME_DATE|TIME_SECONDS),OrderTypeString[type],lots,symbol,
                            DoubleToString(openPrice,digits),DoubleToString(stopLoss,digits),DoubleToString(takeProfit,digits));

   if(closeTime!=0)
     {
      res+=" "+TimeToString(closeTime);
     }

   res+=StringFormat(" %s %.2f %.2f %.2f",
                     DoubleToString(closePrice,digits),
                     commission,swap,profit);

   if(comment!="")
     {
      res+=" "+comment;
     }

   res+=" "+IntegerToString(magicNumber);

   if(expiration!=0)
     {
      res+=" expiration "+TimeToString(expiration);
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::hash(void) const
  {
   return ticket;
  }
//+------------------------------------------------------------------+
