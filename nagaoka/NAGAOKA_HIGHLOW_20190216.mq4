//+------------------------------------------------------------------+
//|                                              NAGAOKA_HIGHLOW.mq4 |
//|                                          Copyright 2017, Nagaoka |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Nagaoka"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

double LOWEST = 10000000.00;
double HIGHEST = 0.00;


int OnInit()
  {
//--- indicator buffers mapping
    
    ObjectsDeleteAll();


	LOWEST = Low[Bars - 1];
	HIGHEST = High[Bars - 1];

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

#define NO_FLG 0
#define UPPER 1
#define LOWER 2

int TREND_FLG = UPPER;

string UPPER_CURRENT_OBJECT = "";
string LOWER_CURRENT_OBJECT = "";


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

	int limit = rates_total - prev_calculated;
    if(limit == Bars) limit -= 10;

	for(int i = limit; i >= 0; i--)
	{
		if(high[i] > HIGHEST)
		{
		
			HIGHEST = high[i];
			LOWEST = low[searchLowest(i)];

			showLine(i,LOWEST,LOWER);
			if(TREND_FLG == UPPER)
			{
				moveUpperLine(i);
			}
			else
			{
				showLine(i,HIGHEST,UPPER);
			}

			TREND_FLG = UPPER;

		}
		if(low[i] < LOWEST)
		{
			LOWEST = low[i];
			HIGHEST = high[searchHighest(i)];
			showLine(i,HIGHEST,UPPER);

			if(TREND_FLG == LOWER)
			{
				moveLowerLine(i);
			}
			else
			{
				showLine(i,LOWEST,LOWER);
			}

			TREND_FLG = LOWER;
		}
	}



   
//--- return value of prev_calculated for next call
   return(rates_total);
}

//ObjectMove("myHLineStop",0,Time[0],Close[0]);

int searchHighest(int bar_num){

	for(int i = bar_num + 1; i < Bars; i++){
		
		if(High[i+1]  > High[i] && High[i+1] > High[i+2])
		{
			return i+1;
		} 
	}
	
	return bar_num;
	
}

int searchLowest(int bar_num){

	for(int i = bar_num + 1; i < Bars; i++){
		if(Low[i+1]  < Low[i] && Low[i+1] < Low[i+2])
		{
			return i+1;
		} 
	}
	
	return bar_num;
	
}

void showLine(int bar_num,double price,int direction){

	long chart_id = 0;
	string bars_txt = IntegerToString(Bars - bar_num);
	string obj_name = "";
	int line_color = 0;
    
    if(direction == UPPER)
    {
    	obj_name = "upper_line_" + bars_txt;
    	line_color = clrAqua;    	
		UPPER_CURRENT_OBJECT = obj_name;
	}
	else
	{
    	obj_name = "lower_line_" + bars_txt;
    	line_color = clrYellow;    	
		LOWER_CURRENT_OBJECT = obj_name;		
	}

	int len = 5;
    if(Bars - bar_num < 5){
    	len = Bars - bar_num - 1;
    	Print(len);
    }
    	
    ObjectCreate(chart_id,obj_name,                                     // オブジェクト作成
                 OBJ_TREND,                                             // オブジェクトタイプ
                 0,                                                       // サブウインドウ番号
                 Time[bar_num + len],                                               // 1番目の時間のアンカーポイント
                 price,                                              // 1番目の価格のアンカーポイント
                 Time[bar_num],                                               // 2番目の時間のアンカーポイント
                 price                                               // 2番目の価格のアンカーポイント
                 );  
    
    ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,line_color);    // ラインの色設定
    ObjectSetInteger(chart_id,obj_name,OBJPROP_STYLE,STYLE_SOLID);  // ラインのスタイル設定
    ObjectSetInteger(chart_id,obj_name,OBJPROP_WIDTH,2);              // ラインの幅設定
    ObjectSetInteger(chart_id,obj_name,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
    ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
    ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTED,false);       // オブジェクトの選択状態
    ObjectSetInteger(chart_id,obj_name,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定

	// 終点以降までラインを伸ばすかどうか
	//ObjectSet("obj", OBJPROP_RAY, true); // 伸ばす
	ObjectSet(obj_name, OBJPROP_RAY, false); // 伸ばさない
    //ObjectSetInteger(chart_id,obj_name,OBJPROP_ZORDER,0);            // オブジェクトのチャートクリックイベント優先順位

    //ObjectSetInteger(chart_id,obj_name,OBJPROP_RAY_LEFT,false);      // ラインの延長線(左)
    //ObjectSetInteger(chart_id,obj_name,OBJPROP_RAY_RIGHT,true);      // ラインの延長線(右)

	//ObjectMove(obj_name, 0, Time[bar_num + 5], low_price);
	//ObjectMove(obj_name, 1, Time[bar_num], low_price);



}
void moveUpperLine(int bar_num)
{
	Print("upper");
	ObjectMove(0,UPPER_CURRENT_OBJECT,0,Time[bar_num -5],High[bar_num]);
	ObjectMove(0,UPPER_CURRENT_OBJECT,1,Time[bar_num],High[bar_num]);
}

void moveLowerLine(int bar_num)
{
	Print("lower");
	ObjectMove(0,LOWER_CURRENT_OBJECT,0,Time[bar_num -5],Low[bar_num]);
	ObjectMove(0,LOWER_CURRENT_OBJECT,1,Time[bar_num],Low[bar_num]);
}
