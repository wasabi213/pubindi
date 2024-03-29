//+------------------------------------------------------------------+
//|                                           NAGAOKA_PIPS_SCALE.mq4 |
//|                                          Copyright 2019, NAGAOKA |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, NAGAOKA"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
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
   
	showScale();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


void showScale()
{


	double out_upper = Point() * 500;
	double out_lower = Point() * -500;
	double in_upper = Point() * 400;
	double in_lower = Point() * -400;

	string objOutUpper = "obj_out_upper";
	string objOutLower = "obj_out_Lower";
	string objInUpper = "obj_in_upper";
	string objInLower = "obj_in_lower";


	ObjectDelete(objOutUpper);
	ObjectDelete(objOutLower);
	ObjectDelete(objInUpper);
	ObjectDelete(objInLower);

	ObjectCreate(objOutUpper, OBJ_TREND, 0, 0, 0);
	ObjectCreate(objOutUpper, OBJ_TREND, 0, Time[0], Close[0], Time[0], Close[0]);
	ObjectMove(objOutUpper, 0, Time[1], Close[0] + out_upper);
	ObjectMove(objOutUpper, 1, Time[0], Close[0] + out_upper);
	ObjectSet(objOutUpper, OBJPROP_COLOR, clrAqua); // カラー
	ObjectSet(objOutUpper, OBJPROP_STYLE, STYLE_SOLID); // スタイル
	ObjectSet(objOutUpper, OBJPROP_WIDTH, 2); // 幅
	ObjectSet(objOutUpper,OBJPROP_ZORDER,1000);

	ObjectCreate(objOutLower, OBJ_TREND, 0, 0, 0);
	ObjectCreate(objOutLower, OBJ_TREND, 0, Time[0], Close[0], Time[0], Close[0]);
	ObjectMove(objOutLower, 0, Time[1], Close[0] + out_lower);
	ObjectMove(objOutLower, 1, Time[0], Close[0] + out_lower);
	ObjectSet(objOutLower, OBJPROP_COLOR, clrAqua); // カラー
	ObjectSet(objOutLower, OBJPROP_STYLE, STYLE_SOLID); // スタイル
	ObjectSet(objOutLower, OBJPROP_WIDTH, 2); // 幅
	ObjectSet(objOutLower,OBJPROP_ZORDER,1000);


	ObjectCreate(objInUpper, OBJ_TREND, 0, 0, 0);
	ObjectCreate(objInUpper, OBJ_TREND, 0, Time[0], Close[0], Time[0], Close[0]);
	ObjectMove(objInUpper, 0, Time[1], Close[0] + in_upper);
	ObjectMove(objInUpper, 1, Time[0], Close[0] + in_upper);
	ObjectSet(objInUpper, OBJPROP_COLOR, clrYellow); // カラー
	ObjectSet(objInUpper, OBJPROP_STYLE, STYLE_SOLID); // スタイル
	ObjectSet(objInUpper, OBJPROP_WIDTH, 2); // 幅
	ObjectSet(objInUpper,OBJPROP_ZORDER,100);

	ObjectCreate(objInLower, OBJ_TREND, 0, 0, 0);
	ObjectCreate(objInLower, OBJ_TREND, 0, Time[0], Close[0], Time[0], Close[0]);
	ObjectMove(objInLower, 0, Time[1], Close[0] + in_lower);
	ObjectMove(objInLower, 1, Time[0], Close[0] + in_lower);
	ObjectSet(objInLower, OBJPROP_COLOR, clrYellow); // カラー
	ObjectSet(objInLower, OBJPROP_STYLE, STYLE_SOLID); // スタイル
	ObjectSet(objInLower, OBJPROP_WIDTH, 2); // 幅
	ObjectSet(objInLower,OBJPROP_ZORDER,100);

	
	// 終点以降までラインを伸ばすかどうか
	//ObjectSet("obj", OBJPROP_RAY, true); // 伸ばす
	//ObjectSet("obj", OBJPROP_RAY, false); // 伸ばさない
}
void OnDeinit(const int reason){

   ObjectDelete("obj_out_upper");
   ObjectDelete("obj_out_Lower");
   ObjectDelete("obj_in_upper");
   ObjectDelete("obj_in_lower");   

}  