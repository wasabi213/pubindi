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
    ApplyTemplate();
    ObjectDelete(0,OBJ_LABEL);
//---
   return(INIT_SUCCEEDED);
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
 
 	string currency_list[];
 	ArrayResize(currency_list,SymbolsTotal(true));
 	 
	for(int i = 0; i < SymbolsTotal(true); i++)
	{
		Print(SymbolName(i, true));
		currency_list[i] = SymbolName(i,true);
	}
                        
    //int currencies_size = ArraySize(currencies);                    
    currency_struct cs[];
    ArrayResize(cs,ArraySize(currency_list));
       
    for(int i = 0;i < ArraySize(currency_list);i++){
        cs[i].currency = currency_list[i];
        cs[i].spread =  MarketInfo(currency_list[i],MODE_SPREAD);
        //Print(cs[i].currency + ":" + cs[i].spread);

    }

    double x_pos = 20;
    double y_pos = 50;

    for(int j = 0; j < ArraySize(currency_list);j++){
    
    	if(j != 0 && j % 20 == 0){
    		x_pos += 200;
    		y_pos = 50;
    	}
    
        string objName = "spread_" + IntegerToString(j);
 
        double spread = cs[j].spread / 10;
        string text = cs[j].currency + " " + DoubleToStr(spread,1);
        
        int spread_font_color;
        if(spread < 1){
            spread_font_color = clrAqua;
         }else if(spread >= 1 && spread < 1.5){
            spread_font_color = clrWhite;
         }else if(spread >= 1.5 && spread < 2){
            spread_font_color = clrYellow;
         }else{
            spread_font_color = clrRed;
         }
 
        
    	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    	ObjectSetText(objName, text, 14, "arial", spread_font_color);
    	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
    	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
    	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);  
    
        y_pos += 25;
    
    } 


}

//使用中の証拠金の割合を取得する。
double getMarginRate(){

   double wk = AccountMargin() / AccountBalance();

   wk = wk * 100;
   return NormalizeDouble(wk,2);

}

//エントリする際のロットを表示する。


//ロットを計算する。
double calculateLot(){
 
   //1Lot 1pips 1000円固定で考える。

    //input parameter
    //リスク許容度（％）
    double risk = RISK_PERCENTAGE / 100;
       
    //残高
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);

    //最大ロスカット金額
    double max_losscut_price = risk * balance;

    //10pipsが500円になるようなロットは
    double lot = max_losscut_price / LOSSCUT_PIPS / 1000;

    return lot;

}



void ApplyTemplate(){


/*
    Print("Working directory is ",TerminalPath());

    string temp = TerminalInfoString(TERMINAL_DATA_PATH) + "\\" + "templates" + "\\" + "caputure_spanmodel_special.tpl";

    if(ChartApplyTemplate(0,temp) == false){
        Alert("Failuer.");
    }

    Print("Template is ",temp);
*/

    /*+-----------------------------------------------------------------------------*/
     //背景が白の場合

    ChartSetInteger(0,CHART_MODE,CHART_LINE);
    ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,clrBlack);
    ChartSetInteger(0,CHART_COLOR_FOREGROUND,0,clrBlack);
    
    ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,0,false);
    
    
    ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrWhite);
    ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrBlack);
    ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBlack);
    ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBlack);
    ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrBlack);
    ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrBlack);

    ChartSetInteger(0,CHART_SHOW_BID_LINE,0,false);
    ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,false);
    ChartSetInteger(0,CHART_SHOW_LAST_LINE,0,false);
    ChartSetInteger(0,CHART_COLOR_BID,0,clrBlack);
    ChartSetInteger(0,CHART_SHOW_LAST_LINE,0,clrBlack);
      
    //ChartSetInteger(0,CHART_COLOR_ASK,0,clrRed);
    //ChartSetInteger(0,CHART_COLOR_BID,0,clrBlack);

    ChartSetInteger(0,CHART_COLOR_GRID,clrSilver);
    //ChartSetInteger(0,CHART_VISIBLE_BARS,120); 
    ChartSetInteger(0,CHART_SCALEFIX,0,false);

    ChartSetInteger(0,CHART_SHOW_GRID,0,false);
    //チャート上のバーの太さ
    ChartSetInteger(0,CHART_SCALE,0,4);
    
    //ChartSetInteger(0,CHART_SHIFT,20,false);
    ChartSetInteger(0,CHART_AUTOSCROLL,0,true);
    ChartSetDouble(0,CHART_SHIFT_SIZE,25);
    
    ChartSetDouble(0,CHART_FIXED_POSITION,10);
    /*+-----------------------------------------------------------------------------

    ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
    ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrBlack);
    ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrBlack);
    ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrWhite);
    ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
    ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrLime);
    ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrWhite);
    ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrBlack);
    ChartSetInteger(0,CHART_COLOR_BID,clrWhite);
    ChartSetInteger(0,CHART_COLOR_ASK,clrRed);
    ChartSetInteger(0,CHART_SHOW_GRID,0,false);
    ChartSetInteger(0,CHART_COLOR_GRID,clrSilver);

    ChartSetInteger(0,CHART_VISIBLE_BARS,480); 
    //ChartSetInteger(0,CHART_SCALEFIX,0,true);
    //ChartSetInteger(0,CHART_SHOW_DATE_SCALE,0,true);
    ChartSetInteger(0,CHART_SCALEFIX,0,false);


    ChartSetInteger(0,CHART_SCALE_PT_PER_BAR,0,true); 
    ChartSetDouble(0,CHART_POINTS_PER_BAR,1);

    -------------------------------------------------------------------------------- */

}



//+------------------------------------------------------------------+
