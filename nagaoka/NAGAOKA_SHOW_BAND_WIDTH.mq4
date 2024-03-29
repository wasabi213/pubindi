//+------------------------------------------------------------------+
//|                                      NAGAOKA_SHOW_BAND_WIDTH.mq4 |
//|                                  Copyright2017, Shunsuke Nagaoka |
//|                                                                  |
//+------------------------------------------------------------------+

#include <Nagaoka\Util.mqh>

#property copyright "Copyright2017, Shunsuke Nagaoka"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

string ReminingTime_sname = "bars_remining_time";
input int UPPER_LIGHT = 1;
input int FontSize = 10;
input color FontColor = White;


input color band_width_color = clrWhite; //スプレッドの表示色

input int X_POS = 350; //縦位置
input int Y_POS = 0; //横位置

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---

   ObjectDelete("band_width");
   return(INIT_SUCCEEDED);
}

int OnDeinit()
{
   ObjectDelete("band_width");
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
   showBandWidth();
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
 
void showBandWidth(){
                      
    double x_pos = 350;
    double y_pos = 0;
   
    string objName = "band_width";
 
	double upper  = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,1,0);
	double lower  = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,2,0);

	double width = (upper - lower) / 2;
	double pips = NormalizeDouble((width / Point()) / 10,1);
	
    string text = "BW:" + DoubleToStr(pips,1);
    
	int font_color = band_width_color; 
    if(pips < 5)
    {
    	font_color = clrRed;
    }

   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, 12, "Arial Black", font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);  

}
