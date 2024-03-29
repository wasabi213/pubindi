//+------------------------------------------------------------------+
//|                       　　　　　　　                             |
//|	2シグマ越え通知インジケーター                                    |
//|                                         Copyright 2019,s.nagaoka |
//|                                     　　                         |
//+------------------------------------------------------------------+

#include <mql4_modules\Assert\Assert.mqh>
#include <mql4_modules\Web\Web.mqh>
#include <mql4_modules\Slack\Slack.mqh>


#property copyright "Copyright 2016,s.nagaoka"
#property link      "test"
#property version   "1.00"
#property strict


#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   16
/*
//MA
#property indicator_chart_window
#property indicator_type1   DRAW_LINE
#property indicator_color1 clrAqua

//Bolinger Band Plus1
#property indicator_chart_window
#property indicator_type2   DRAW_LINE
#property indicator_color2 clrWhite

//Bolinger Band Plus2
#property indicator_chart_window
#property indicator_type3   DRAW_LINE
#property indicator_color3 clrWhite

//Bolinger Band Plus3
#property indicator_chart_window
#property indicator_type4   DRAW_LINE
#property indicator_color4 clrRed


//Bolinger Band Minus1
#property indicator_chart_window
#property indicator_type5   DRAW_LINE
#property indicator_color5 clrRed

//Bolinger Band Minus2
#property indicator_chart_window
#property indicator_type6   DRAW_LINE
#property indicator_color6 clrAqua

//Bolinger Band Minus3
#property indicator_chart_window
#property indicator_type7   DRAW_LINE
#property indicator_color7 clrAqua

//LateSPAN
#property indicator_chart_window
#property indicator_type8   DRAW_LINE
#property indicator_color8 clrMagenta
#property indicator_width8 2
//#property indicator_style8 STYLE_DOT
*/







//MA
input int MAPeriod = 21;
int hMA;

//BolingerBands
int hBands_1,hBands_2,hBands_3;
input int BandsPeriod = 21;
input double BandsDeviation_1 = 1.0; 
input double BandsDeviation_2 = 2.0; 
input double BandsDeviation_3 = 3.0; 

//Late SPAN
input int Shift = -20;
int hLateSpan;

input int CHART_WIDTH = 800; //画像の幅
input int CHART_HEIGHT = 400; //画像の高さ
input bool ANSWER_FLAG = true; //回答スクリーンショットを撮るか？
input int ANSWER_SHOT_SHIFT = 35; //回答のスクリーンショット　

input ENUM_TIMEFRAMES LARGE_TIME = PERIOD_H1; //時間軸（大）
input ENUM_TIMEFRAMES SMALL_TIME = PERIOD_M5; //時間軸（小）


//--- indicator buffers
double MA[];
double Band_Upper_1[];
double Band_Lower_1[];
double Band_Upper_2[];
double Band_Lower_2[];
double Band_Upper_3[];
double Band_Lower_3[];
double LateSpan[];


double LARGE_MA[];
double LARGE_Band_Upper_1[];
double LARGE_Band_Lower_1[];
double LARGE_Band_Upper_2[];
double LARGE_Band_Lower_2[];
double LARGE_Band_Upper_3[];
double LARGE_Band_Lower_3[];
double LARGE_LateSpan[];




bool CHART_START_FLAG = true;

#define NO_FLAG 0
#define UPPER_FLAG 1
#define LOWER_FLAG 2


int SIGNAL = NO_FLAG;

//エントリ状態
bool ENTRY_FLAG = false; 

//2シグマオーバーフラグ
bool UPPER_2SIGMA = false;
bool LOWER_2SIGMA = false;

//最高値・最安値フラグ
bool HIGHEST_FLG = false;
bool LOWEST_FLG = false;

//回答スクリーンショット日付
string ANSWER_FILE_NAME = "";
datetime ANSWER_TIME = 0;


//チャートシリアルナンバー
int CHART_NUMBER = 0;

//インジケーター開始時刻
datetime START_TIME = 0;

//メール最終送信時刻
datetime LAST_SENDMAIL_TIME = 0;

//リスクリワード率
int RISK_PERCENTAGE = 2;

//シグナル点灯後経過本数
int UPPER_COUNT = 0;
int LOWER_COUNT = 0;

//シグナル点灯後経過本数最終カウント時刻
datetime CANDLESTICK_LAST_COUNT_TIME = 0;

//サイン発生ローソク足ブレイク確認本数
int CANDLESTICK_BREAK_COUNT = 5;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

	ObjectsDeleteAll(0);
	ObjectsDeleteAll(0,OBJ_LABEL);

	SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrWhite);
	SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrBlack);
	SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,clrBlack);
	SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,clrRed);
	SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1,clrRed);
	SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1,clrBlack);
	SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1,clrBlack);
	//SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,2,clrAqua);
	SetIndexStyle(8,DRAW_LINE,STYLE_SOLID,1,clrWhite);
	SetIndexStyle(9,DRAW_LINE,STYLE_SOLID,1,clrMagenta);
	SetIndexStyle(10,DRAW_LINE,STYLE_SOLID,1,clrMagenta);
	SetIndexStyle(11,DRAW_LINE,STYLE_SOLID,2,clrBlack);
	SetIndexStyle(12,DRAW_LINE,STYLE_SOLID,2,clrBlack);
	SetIndexStyle(13,DRAW_LINE,STYLE_SOLID,1,clrBlack);
	SetIndexStyle(14,DRAW_LINE,STYLE_SOLID,1,clrBlack);
	//SetIndexStyle(15,DRAW_LINE,STYLE_SOLID,2,clrAqua);
	//SetIndexStyle(16,DRAW_LINE,STYLE_SOLID,2,clrAqua);








	//--- indicator buffers mapping
	SetIndexBuffer(0,MA);
	SetIndexBuffer(1,Band_Upper_1,INDICATOR_DATA);
	SetIndexBuffer(2,Band_Lower_1,INDICATOR_DATA);
	SetIndexBuffer(3,Band_Upper_2,INDICATOR_DATA);
	SetIndexBuffer(4,Band_Lower_2,INDICATOR_DATA);
	SetIndexBuffer(5,Band_Upper_3,INDICATOR_DATA);
	SetIndexBuffer(6,Band_Lower_3,INDICATOR_DATA);
	SetIndexBuffer(7,LateSpan,INDICATOR_DATA);


	SetIndexBuffer(8,LARGE_MA);
	SetIndexBuffer(9,LARGE_Band_Upper_1,INDICATOR_DATA);
	SetIndexBuffer(10,LARGE_Band_Lower_1,INDICATOR_DATA);
	SetIndexBuffer(11,LARGE_Band_Upper_2,INDICATOR_DATA);
	SetIndexBuffer(12,LARGE_Band_Lower_2,INDICATOR_DATA);
	SetIndexBuffer(13,LARGE_Band_Upper_3,INDICATOR_DATA);
	SetIndexBuffer(14,LARGE_Band_Lower_3,INDICATOR_DATA);
	SetIndexBuffer(15,LARGE_LateSpan,INDICATOR_DATA);



	SetIndexShift(7,Shift); //遅行スパンの設定
    ArraySetAsSeries(MA,true);
    ArraySetAsSeries(Band_Upper_1,true);
    ArraySetAsSeries(Band_Upper_1,true);
    ArraySetAsSeries(Band_Upper_2,true);
    ArraySetAsSeries(Band_Upper_2,true);
    ArraySetAsSeries(Band_Upper_3,true);
    ArraySetAsSeries(Band_Upper_3,true);
    ArraySetAsSeries(LateSpan,true);


	SetIndexShift(15,Shift); //遅行スパンの設定
    ArraySetAsSeries(LARGE_MA,true);
    ArraySetAsSeries(LARGE_Band_Upper_1,true);
    ArraySetAsSeries(LARGE_Band_Upper_1,true);
    ArraySetAsSeries(LARGE_Band_Upper_2,true);
    ArraySetAsSeries(LARGE_Band_Upper_2,true);
    ArraySetAsSeries(LARGE_Band_Upper_3,true);
    ArraySetAsSeries(LARGE_Band_Upper_3,true);
    ArraySetAsSeries(LARGE_LateSpan,true);



    
	SIGNAL = NO_FLAG;

    START_TIME = TimeLocal();

    ChartSetInteger(0,CHART_MODE,CHART_CANDLES);

	return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

bool SLACK_SEND_FLG = False;
int BARS_TOTAL = 0;
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

	int limit = rates_total - prev_calculated;
	if(limit == 0) limit = 1;
    if(limit == Bars) limit--;

	int l_pos = 0;
	
	for(int i = 0; i <= limit; i++)
	{
		//Print(TimeMinute(time[i]));

		MA[i]           = iMA(NULL,SMALL_TIME,MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);          
		Band_Upper_1[i] = iBands(NULL,SMALL_TIME,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_UPPER,i);
		Band_Lower_1[i] = iBands(NULL,SMALL_TIME,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_LOWER,i);
		Band_Upper_2[i] = iBands(NULL,SMALL_TIME,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_UPPER,i);
		Band_Lower_2[i] = iBands(NULL,SMALL_TIME,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_LOWER,i);
		Band_Upper_3[i] = iBands(NULL,SMALL_TIME,BandsPeriod,BandsDeviation_3,0,PRICE_CLOSE,MODE_UPPER,i);
		Band_Lower_3[i] = iBands(NULL,SMALL_TIME,BandsPeriod,BandsDeviation_3,0,PRICE_CLOSE,MODE_LOWER,i);
		LateSpan[i]     = iMA(NULL,SMALL_TIME,1,0,MODE_SMA,PRICE_CLOSE,i);
		
		if(Bars != BARS_TOTAL){
			
			if(Close[i] >= Band_Upper_2[i])
			{
				//slackSend();
		
			}
			if(Close[i] <= Band_Lower_2[i])
			{
			
			}
	
			slackSend();
			Print("test");

			BARS_TOTAL = Bars;
		
		}
	}

	return(rates_total);
}

int slackSend()
{


   Slack::setAPIKey("ZhxOfDOUyBOwKa97Tx8zI5cw");
   if(!Slack::send("Slack module.", "general"))
   {
      Print("sendSlack method failed.");
      return(INIT_FAILED);
   }
   
	return(0);
}





//+------------------------------------------------------------------+
// タイムフレームのペアを取得する。
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES getTimeFramePair(){

	ENUM_TIMEFRAMES ret;

	switch (Period()){

		case PERIOD_M1:
			ret = PERIOD_M15;
			break;

		case PERIOD_M5:
			ret = PERIOD_H1;
			break;

		case PERIOD_M15:
			ret = PERIOD_H4;
			break;

		case PERIOD_M30:
			ret = PERIOD_D1;
			break;

		case PERIOD_H1:
			ret = PERIOD_D1;
			break;

		case PERIOD_H4:
			ret = PERIOD_W1;
			break;

		case PERIOD_D1:
			ret = PERIOD_MN1;
			break;

		case PERIOD_W1:
			ret = PERIOD_MN1;
			break;

        default:
            ret = PERIOD_CURRENT;
            break;



	}
	return ret;

}
//+------------------------------------------------------------------+
//
// 時間足文字列の取得
//
//+------------------------------------------------------------------+
string getChartPeriodString(){

    string ret = "";

    switch (ChartPeriod(0)){
        case   PERIOD_M1:
            ret = "M1";
            break;

        case   PERIOD_M5:
            ret = "M5";
            break;

        case   PERIOD_M15:
            ret = "M15";
            break;

        case   PERIOD_M30:
            ret = "M30";
            break;

        case   PERIOD_H1:
            ret = "H1";
            break;

        case   PERIOD_H4:
            ret = "H4";
            break;

        case   PERIOD_H12:
            ret = "H12";
            break;

        case   PERIOD_D1:
            ret = "D1";
            break;

        case   PERIOD_W1:
            ret = "W1";
            break;

        case   PERIOD_MN1:
            ret = "MN1";
            break;

        default:
            ret = "XXX";
            break;

    }

    return ret;

}