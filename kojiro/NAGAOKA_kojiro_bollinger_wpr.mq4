//+------------------------------------------------------------------+
//|                                            NAGAOKA_daijunkan.mq4 |
//|                   Copyright 2019-2020, nagaoka. |
//|                                              |

/*
rates_total チャートのバー（ロウソク足）の総数で最初は画面バー総数です。
価格の変化 (Tick) で呼び出さると+1になります。

prev_calculated 計算済みのバー数です。
最初は0
計算を始めて全て計算を終えた時にはrates_totalと同じ
バーが追加されると rates_totalは1つ増えます。

*/
//+------------------------------------------------------------------+
#include <nagaoka.mqh>


#property copyright   "2019-2020, Shunsuke Nagaoka."
#property link        ""
#property description "Nagaoka daijunkan"
#property strict

#property indicator_chart_window
#property indicator_buffers 4

//double EMA_SHORT_BUF[];
//double EMA_MID_BUF[];
//double EMA_LONG_BUF[];

//double LONG_UP[];
//double LONG_DOWN[];

//double MID_UP[];
//double MID_DOWN[];

double UP_BANDS[];
double MD_BANDS[];
double DN_BANDS[];

double WPR[];


//double EMA25[];
//double Buffer1[];


input int PRINT_MODE = 0; //データ出力モード
//input int SHOW_STAGE_NUMBER = 0; //バーの上にStageナンバーを表示
//input int BASE_PERIOD = 1; // 1:1分 5:5分 15:15分 


//確認条件
//input int RSI_UPPER_LIMIT = 70; //RSIの値
//input int RSI_PERIOD = 6;
//input int KOJIRO_SUBSTAGE = 10;
input int HIGHLOW_ENTRY_TIME = 3; //ハイローのエントリ時間
input int BOLLINGER_PERIOD = 20;
input double SIGMA = 3;

input int WPR_PERIOD = 9;
input int WPR_UPPER = -20;
input int WPR_LOWER = -30;


//int SHORT_PERIOD = 1; //1,5,15,30,60,240,1440
//int MID_PERIOD   = 5; //1,5,15,30,60,240,1440
//int LONG_PERIOD  = 15; //1,5,15,30,60,240,1440



//固定値
string CURRENCY = "";
double PIP_BASE = 0.0;
string TIME_FRAME = "";
int CURRENCY_DIGIT = 0;

datetime LAST_SIGNAL_DATETIME = 0.0;

int RESULT_ARRAY[];
#define WIN 1
#define LOSE 0


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{

   IndicatorBuffers(4);
   IndicatorDigits(Digits);

   SetIndexStyle(0,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(0,UP_BANDS);
   SetIndexLabel(0,"Bollinger Bands up");
   SetIndexDrawBegin(0,25);
   
   SetIndexStyle(1,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(1,MD_BANDS);
   SetIndexLabel(1,"Bollinger Bands center");
   SetIndexDrawBegin(1,25);

   SetIndexStyle(2,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(2,DN_BANDS);
   SetIndexLabel(2,"Bollinger Bands down");
   SetIndexDrawBegin(9,25);

   SetIndexStyle(3,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(3,WPR);
   SetIndexLabel(3,"Williams % Range");
   SetIndexDrawBegin(3,14);

   PIP_BASE = getPipPrice();
   CURRENCY_DIGIT = _Digits;
   TIME_FRAME = getTimeFrameString();
   CURRENCY = _Symbol;
  
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  
    Print(reason);
	ObjectDelete(0,"stage_number");  
	//ObjectsDeleteAll(0,"objArrow_");
	ObjectsDeleteAll();
	//return(INIT_SUCCEEDED);
}


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

//--- preliminary calculations

	//Print("start");

	int limit = rates_total - prev_calculated;

	for(int i = limit; i >= 0 ; i--)
	{
		if(i>=Bars-3) continue;

		UP_BANDS[i] = iBands(NULL,PERIOD_CURRENT,BOLLINGER_PERIOD,SIGMA,0,PRICE_CLOSE,MODE_UPPER,i);
		MD_BANDS[i] = iBands(NULL,PERIOD_CURRENT,BOLLINGER_PERIOD,SIGMA,0,PRICE_CLOSE,MODE_MAIN,i);
		DN_BANDS[i] = iBands(NULL,PERIOD_CURRENT,BOLLINGER_PERIOD,SIGMA,0,PRICE_CLOSE,MODE_LOWER,i);

		WPR[i] = iWPR(NULL,PERIOD_CURRENT,WPR_PERIOD,i);
	
		string direction = createSignal(i);

		if(direction == "down" || direction == "UP")
		{
			showArrow(direction,i,clrMagenta);
		}
				
		judge(i,direction);

	}

	showJudge();

	return(rates_total);
}

string createSignal(int i)
{
	string ret = "";

	//if(High[i+1] > UP_BANDS[i+1] ){ ret = "down";} else {return "";}
	//if(WPR[i+1] > WPR_UPPER){ ret = "down";} else {return "";}
	//if(WPR[i] < WPR_LOWER){ ret = "down";} else {return "";}
	//if(Close[i] > MD_BANDS[i]){ ret = "down";} else {return "";}

	//if(High[i] > UP_BANDS[i] ){ ret = "down";} else {return "";}
	//if(WPR[i] > WPR_UPPER){ ret = "down";} else {return "";}
	//if(WPR[i] < WPR_LOWER){ ret = "down";} else {return "";}
	//if(Close[i] > MD_BANDS[i]){ ret = "down";} else {return "";}

	if(MD_BANDS[i+1] > MD_BANDS[i]){ ret = "down";} else {return "";}
	if(WPR[i+1] > WPR_UPPER){ ret = "down";} else {return "";}
	if(WPR[i] < WPR_LOWER){ ret = "down";} else {return "";}
	

	
	if(ret == "up" || ret == "down")
	{
		//Print(TimeToStr(Time[i]) + ":" + ret);
		//printf("%1f:%1f",rsi_p1,rsi);		
	}
	return ret;

}

void showJudge()
{

	int win_count = 0;
	
	for(int i = 0; i < ArraySize(RESULT_ARRAY);i++)
	{
		if(RESULT_ARRAY[i] == 1) { win_count++;}
	}

	Print(ArraySize(RESULT_ARRAY));

	int total = ArraySize(RESULT_ARRAY);
	string percentage;
	if(total == 0.0)
	{
		percentage = 0.0;
	}
	else
	{
		percentage = DoubleToStr((double)win_count / (double)total * 100,1);
	}
	
	//printf("TOTAL:%d win:%d lose:%d",total,win_count,total-win_count);

	Print("");
	Print("");
	Print("");
	Print("=============================================================");
	printf("TOTAL:%d win:%d lose:%d win percentage:%s%%",total,win_count,total-win_count,percentage);
	Print("通貨:" + _Symbol);
	Print("時間枠:" + _Period);
	Print("ボリンジャーバンドシグマ:" + SIGMA);
	Print("ボリンジャーバンド期間:" + BOLLINGER_PERIOD);
	Print("WPR期間:" + WPR_PERIOD);
	Print("ハイローエントリー時間:" + HIGHLOW_ENTRY_TIME);
	Print("=============================================================");
	Print("");
	Print("");
	Print("");



}
void judge(int bar_num,string direction)
{

	//HIGHLOW_ENTRY_TIME

	//現在のバーから勝敗が決まるバーが確定していない場合は、はじく。
	if(bar_num - HIGHLOW_ENTRY_TIME < 0){ return; }
	
	
	int pos;
	
	if(direction == "down")
	{
		ArrayResize(RESULT_ARRAY,ArraySize(RESULT_ARRAY)+1);
		pos = ArraySize(RESULT_ARRAY)-1;

		if(Close[bar_num] > Close[bar_num - HIGHLOW_ENTRY_TIME])
		{
			RESULT_ARRAY[pos] = WIN;
		}
		else
		{
			RESULT_ARRAY[pos] = LOSE;	
		}
	}

	if(direction == "up")
	{
		ArrayResize(RESULT_ARRAY,ArraySize(RESULT_ARRAY));
		pos = ArraySize(RESULT_ARRAY)-1;

		if(Close[bar_num] < Close[bar_num - HIGHLOW_ENTRY_TIME])
		{
			RESULT_ARRAY[pos] = WIN;
		}
		else
		{
			RESULT_ARRAY[pos] = LOSE;	
		}
	}

}





double getPipPrice()
{
	double pip = 0;
	
	if(_Digits == 5)
	{
		pip = 0.0001;
	}
	else if(_Digits == 3)
	{
		pip = 0.01;
	}

	return pip;
}




//+------------------------------------------------------------------+
void showArrow(string direction,int bar_num,int col)
{

	if(PRINT_MODE == 1) return;

	if(IsTesting() == true && IsVisualMode() == false) return;

	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;
	
	if(direction == "up")
	{
		arrow_color = col;
		arrow_type = 217;
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	}
	else if(direction == "down")
	{
		arrow_color = col;
		arrow_type = 234;
		//pos = Low[bar_num];
		//anchor = ANCHOR_LOWER;

		pos = High[bar_num] +  getPipPrice();
		anchor = ANCHOR_UPPER;


	}
	else
	{
		return;
	}

	MqlDateTime mqlDt;
	TimeToStruct(Time[bar_num],mqlDt);
	  
	string objName = 
		"objArrow_" + StringFormat("%4d%02d%02d%02d%02d%02d",mqlDt.year,mqlDt.mon,mqlDt.day,mqlDt.hour,mqlDt.min,mqlDt.sec);

	ObjectCreate(0,objName, OBJ_ARROW,0,Time[bar_num],pos);
	ObjectSetInteger(0,objName, OBJPROP_ARROWCODE,arrow_type);
	ObjectSetInteger(0,objName, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);
    ChartRedraw(0);

}

