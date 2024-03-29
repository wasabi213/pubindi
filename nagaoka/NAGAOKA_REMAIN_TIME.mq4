//+------------------------------------------------------------------+
//|                                          NAGAOKA_REMAIN_TIME.mq4 |
//|                                  Copyright2017, Shunsuke Nagaoka |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Nagaoka\Util.mqh>

#property copyright "Copyright2017, Shunsuke Nagaoka"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color TIME_COLOR = clrWhite; //時刻の色

input int Y_POS = 0; //縦位置
input int X_POS = 220; //横位置 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
	EventSetTimer(1); // 1秒ごとに起動。カッコ内の数値を変えることで起動間隔を変えられる。
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
 	showRemainTime(); 
 	
 	//Print("t");
 	
  }
//+------------------------------------------------------------------+

void showRemainTime(){

	MqlDateTime mdt;
	TimeLocal(mdt);
	string time_text = "";
	
	if(_Period == PERIOD_M1){
	
		time_text = IntegerToStringWithZero(PERIOD_M1 * 60 - 1 - mdt.sec);
	
	}else if(_Period == PERIOD_M5 ||
			 _Period == PERIOD_M15 ||
			 _Period == PERIOD_M30 ||
			 _Period == PERIOD_H1){

		//Print("_Period " + _Period);
		//Print(mdt.min);
		//Print("mod " + mdt.min % _Period);

		time_text = IntegerToStringWithZero(_Period - 1 - mdt.min % _Period) +":" +
					IntegerToStringWithZero(60 - 1 - mdt.sec);
				
	}else if(_Period == PERIOD_H4 ||
			 _Period == PERIOD_D1){

		time_text = IntegerToStringWithZero( (_Period / 60)   - 1 -  mdt.hour %  (_Period  / 60) ) +":" +
					IntegerToStringWithZero(60 - 1 - mdt.min) +":" +
					IntegerToStringWithZero(60 - 1 - mdt.sec);
				
	}else{
		time_text = "";
	
	}
								
    string objName = "remain_time";
 
 	//double x_pos = 120;
 	//double y_pos = 0;
 
	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, time_text, 12, "Arial Black", TIME_COLOR);
	ObjectSet(objName, OBJPROP_XDISTANCE, X_POS);
	ObjectSet(objName, OBJPROP_YDISTANCE, Y_POS);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);


}

string IntegerToStringWithZero(int t){

	string ret = IntegerToString(t);
	if(t == 0){
		return "00";
	}else if(t < 10){
		return "0" + ret;
	}
	return  ret;

}
