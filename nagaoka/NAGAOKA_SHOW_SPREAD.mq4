//+------------------------------------------------------------------+
//|                                              NAGAOKA_SUPPORT.mq4 |
//|                                  Copyright2017, Shunsuke Nagaoka |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Nagaoka\Util.mqh>

#property copyright "Copyright2017, Shunsuke Nagaoka"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string ReminingTime_sname = "bars_remining_time";
input int UPPER_LIGHT = 1;
input int FontSize = 10;
input color FontColor = White;

//ロット数
input int RISK_PERCENTAGE = 5;  //リスク許容度
input int LOSSCUT_PIPS = 10;    //ロスカットpips

input color spread_color = clrWhite; //スプレッドの表示色

input int X_POS = 280; //縦位置
input int Y_POS = 0; //横位置


//残り時間文字色
int REMAIN_TIME_COLOR = clrAqua;

struct currency_struct{
    string currency;
    double spread;
};


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---

   ObjectDelete("spread");
   showSpread();
   return(INIT_SUCCEEDED);
  }

int OnDeinit()
{
   ObjectDelete("spread");
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   showSpread();
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
 
void showSpread(){
                      
    string objName = "spread";
 
    double spread =  MarketInfo(_Symbol,MODE_SPREAD) / 10;
    string text = "SP:" + DoubleToStr(spread,1);
        
	int spread_font_color = spread_color; 
    if(spread > 3)
    {
    	spread_font_color = clrRed;
    }
    else if(spread > 2)
    {
    	spread_font_color = clrOrange;
    } 
   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, 12, "Arial Black", spread_font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, X_POS);
   	ObjectSet(objName, OBJPROP_YDISTANCE, Y_POS);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);  

}
