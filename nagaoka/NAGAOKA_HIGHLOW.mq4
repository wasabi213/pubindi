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
#define UPPER_FLG 1
#define LOWER_FLG 2

#define UPPER 1
#define LOWER 2

int TREND_FLG = LOWER_FLG;


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
	//if(limit == 0) limit = 1;
    if(limit == Bars) limit -= 10;


	for(int i = limit; i >= 0; i--){

		
		
		if(close[i] < LOWEST || low[i] < LOWEST){
			LOWEST = close[i];
			//高値繰り下げ処理
			int highest_bar = searchHighest(i);
			HIGHEST = high[highest_bar];
			showLine(highest_bar,HIGHEST,UPPER);
		}
		
		if(close[i] > HIGHEST || high[i] > HIGHEST){
			HIGHEST = close[i];
			//安値引き上げ処理
			int lowest_bar = searchLowest(i);
			LOWEST = low[lowest_bar];
			showLine(lowest_bar,LOWEST,LOWER);
		}

		

		if(high[i + 2] > high[i + 1] && high[i + 2] > high[i + 3] && high[i + 2] > HIGHEST){

			HIGHEST = high[i + 2];	
			//高値線描画処理
			showLine(i + 2,HIGHEST,UPPER);
	
			//安値引き上げ処理
			int lowest_bar = searchLowest(i + 2);
			LOWEST = low[lowest_bar];
			showLine(lowest_bar,LOWEST,LOWER);

		}


		if(low[i + 2] < low[i + 1] && low[i + 2] < low[i + 3] && low[i + 2] < LOWEST){

			LOWEST = low[i + 2];
			//安値線描画処理
			showLine(i + 2,LOWEST,LOWER);
			
			//高値繰り下げ処理
			int highest_bar = searchHighest(i + 2);
			HIGHEST = high[highest_bar];
			showLine(highest_bar,HIGHEST,UPPER);


	
		}


    }


   
//--- return value of prev_calculated for next call
   return(rates_total);
}
void showLine(int bar_num,double price,int direction){



	long chart_id = 0;
	string bars_txt = IntegerToString(Bars - bar_num);
	string obj_name = "lower_line_" + bars_txt;

	int line_color = clrYellow;
    
    if(direction == UPPER){
    	obj_name = "upper_line_" + bars_txt;
    	line_color = clrAqua;    	
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
int searchLowest(int bar_num){

	for(int i = 0; i < Bars - bar_num - 10;i++){
	
		if(Low[bar_num + i] < Low[bar_num]){
		
			if(Low[bar_num + i + 1] > Low[bar_num + i]){
				return bar_num + i;
			}
		}
	}

	return Bars - 1;

}
int searchHighest(int bar_num){

	for(int i = 0; i < Bars - bar_num - 10;i++){
	
		if(High[bar_num + i] > High[bar_num]){
		
			if(High[bar_num + i + 1] < High[bar_num + i]){
				return bar_num + i;
			}
		}
	}

	return Bars - 1;

}

