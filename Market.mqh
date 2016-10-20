//+------------------------------------------------------------------+
//|                                                     FxSymbol.mqh |
//|                                     Copyright 2014-2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FxSymbol
  {
private:
   string            m_name;

public:
   //-- Constructor
                     FxSymbol(string symbol="")
     {
      if(StringLen(symbol)==0)
        {
         m_name=Symbol();
        }
      else
        {
         m_name=symbol;
        }
     }

   //--- 当前货币对总数
   static int GetTotal() {return SymbolsTotal(false);}
   static string GetName(int i) {return SymbolName(i,false);}

   static int GetTotalSelected() {return SymbolsTotal(true);}
   static string GetNameSelected(int i) {return SymbolName(i,true);}

   //-- Basic properties
   string getName() const {return m_name;}
   void setName(string symbol) {m_name=symbol;}

   string getDescription() const {return SymbolInfoString(m_name,SYMBOL_DESCRIPTION);}
   string getPath() const {return SymbolInfoString(m_name,SYMBOL_PATH);}
   string getBaseCurrency() const {return SymbolInfoString(m_name,SYMBOL_CURRENCY_BASE);}
   string getProfitCurrency() const {return SymbolInfoString(m_name, SYMBOL_CURRENCY_PROFIT);}
   string getMarginCurrency() const {return SymbolInfoString(m_name, SYMBOL_CURRENCY_MARGIN);}

   //-- SymbolWatch Ops
   bool select() {return SymbolSelect(m_name, true);}
   bool remove() {return SymbolSelect(m_name, false);}
  };
//+------------------------------------------------------------------+
