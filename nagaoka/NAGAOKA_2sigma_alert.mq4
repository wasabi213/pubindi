//+------------------------------------------------------------------+
//|                       　　　　　　　                             |
//|	遅行スパンアタッカー改                                           |
//|                                         Copyright 2016,s.nagaoka |
//|                                     　　                         |
//+------------------------------------------------------------------+
/*
追加する機能

-エントリ枚数の表示
○エントリ枚数のメール送信



○立ち上げ時にアラートを発生させないようにする。
メール送信できるようにする。
○シグナル発生と同時に２シグマを超えた場合に通知
○シグナルが発生してから２シグマを超えた場合に通知
過去２６本の高値を更新した場合に通知
過去２６本の安値を更新した場合に通知

■上位足の判定
遅行スパンがローソク足の上にある。
１本前の終値が、プラス１シグマを超えている。
１本前の終値が、マイナス１シグマを超えている。


★負けパターンを除外する方法はないか？
*/

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
	int cnt = (int)(LARGE_TIME / SMALL_TIME);
	
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
		
		
		for(int j = 0;j < cnt;j++)
		{
			if(l_pos > Bars - 1)
			{
				break;
			}
			LARGE_Band_Upper_1[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_UPPER,i);
			LARGE_Band_Lower_1[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_LOWER,i);
			LARGE_Band_Upper_2[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_UPPER,i);
			LARGE_Band_Lower_2[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_LOWER,i);
			LARGE_Band_Upper_3[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_3,0,PRICE_CLOSE,MODE_UPPER,i);
			LARGE_Band_Lower_3[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_3,0,PRICE_CLOSE,MODE_LOWER,i);
		
			LARGE_LateSpan[l_pos]     = iMA(NULL,LARGE_TIME,1,0,MODE_SMA,PRICE_CLOSE,i);  
			LARGE_MA[l_pos]           = iMA(NULL,LARGE_TIME,MAPeriod,0,MODE_SMA,PRICE_CLOSE,i); 	
			l_pos++;
		}		
	}

	
/*
	int max = Bars - 1;
	int l_pos = 0;
	for(int k = 0; k <= max; k++){

		for(int l_cnt = 0; l_cnt < (int)(LARGE_TIME / SMALL_TIME); l_cnt++){
		
			LARGE_MA[l_pos]           = iMA(NULL,LARGE_TIME,MAPeriod,0,MODE_SMA,PRICE_CLOSE,k);          
			LARGE_Band_Upper_1[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_UPPER,k);
			LARGE_Band_Lower_1[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_LOWER,k);
			LARGE_Band_Upper_2[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_UPPER,k);
			LARGE_Band_Lower_2[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_LOWER,k);
			LARGE_Band_Upper_3[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_3,0,PRICE_CLOSE,MODE_UPPER,k);
			LARGE_Band_Lower_3[l_pos] = iBands(NULL,LARGE_TIME,BandsPeriod,BandsDeviation_3,0,PRICE_CLOSE,MODE_LOWER,k);
			LARGE_LateSpan[l_pos]     = iMA(NULL,LARGE_TIME,1,0,MODE_SMA,PRICE_CLOSE,k);  
			l_pos++;

		}		

    }
*/

	limit = rates_total - prev_calculated;
	if(limit == 0) limit = 1;	
	for(int i = limit; i > 0 ; i--){

		if(isSatisfiedBuySignal(i,time,close,high)){       
			showUpperArrow(i,time[i],close[i]);		       
		}

		if(isSatisfiedSellSignal(i,time,close,low)){
			showLowerArrow(i,time[i],high[i]);
		}

        twoSigmaCheck(i,time,close);

	}   

	return(rates_total);
}

//+------------------------------------------------------------------+
//
//買いシグナル成立判定
//
//+------------------------------------------------------------------+
bool isSatisfiedBuySignal(int bar_num,const datetime &time[],const double &close[], const double &high[]){

	if(SIGNAL == UPPER_FLAG) return false;

	if( isSatisfiedUpperBandCondition(bar_num,close) == true &&
	    isSatisfiedUpperLateSpan(bar_num,high) == true){

		SIGNAL = UPPER_FLAG;
		//ENTRY_FLAG = true;
        HIGHEST_FLG = false;
 		
		//売り方向の2シグマ下回りフラグをクリアする。
		LOWER_2SIGMA = false;
		
        string message = "";

        bool two_sigma_flg = isOver2Sigma(bar_num,close);

        if(two_sigma_flg == true){
            message = _Symbol + ":" + IntegerToString(Period()) + " Buy signal Over 2sigma.";
        
        }else{
            message = _Symbol + ":" + IntegerToString(Period()) + " Buy signal.";

        }

		//立上がり時はメール・アラートを発生させない。
		if(bar_num <= 1 ){
			alertMessage(bar_num,message);
			string title = buildMailTitle("buy",two_sigma_flg);
			string body  = buildMailBody("buy",close,time,two_sigma_flg);
			sendSignalMail(time,title,body);
		}

  		return true;

//いきなり２シグマを割ったかどうか判定する。

	}
	return false;
}

//+------------------------------------------------------------------+
//
// プラス１シグマの判定
//
//+------------------------------------------------------------------+
bool isSatisfiedUpperBandCondition(int bar_num,const double &close[]){

	if(Bars < 20) return false;
    if(bar_num >= Bars - 1) return false;

	if(close[bar_num] > Band_Upper_1[bar_num]){
		return true;
	}
	return false;
}

//+------------------------------------------------------------------+
//
// 遅行スパンの判定
//
//+------------------------------------------------------------------+
bool isSatisfiedUpperLateSpan(int bar_num,const double &high[]){

	if( Bars < 22) return false;
    if( bar_num >= Bars - 21) return false;

	if(LateSpan[bar_num] > high[bar_num + 20]) return true;

	return false;
}

//+------------------------------------------------------------------+
//
// 売りシグナル成立判定処理
//
//+------------------------------------------------------------------+
bool isSatisfiedSellSignal(int bar_num,const datetime &time[],const double &close[], const double &low[]){

	if(SIGNAL == LOWER_FLAG) return false;

	if( isSatisfiedLowerBandCondition(bar_num,close) == true &&
	    isSatisfiedLowerLateSpan(bar_num,low) == true){
		SIGNAL = LOWER_FLAG;
		//ENTRY_FLAG = true;
        LOWEST_FLG = false;
        
		//買い方向の2シグマ超えフラグをクリアする。
		UPPER_2SIGMA = false;

        string message = "";
        bool two_sigma_flg = isUnder2Sigma(bar_num,close);
            
        if(two_sigma_flg == true){
            message = _Symbol + ":" + IntegerToString(Period()) + " Sell signal Over 2sigma.";           
        }else{
            message = _Symbol + ":" + IntegerToString(Period()) + " Sell signal.";
        }
    
    	//立上がり時はメール・アラートを発生させない。
		alertMessage(bar_num,message);
		string title = buildMailTitle("sell",two_sigma_flg);
		string body  = buildMailBody("sell",close,time,two_sigma_flg);
		sendSignalMail(time,title,body);
  
        return true;

	}

	return false;
}

//+------------------------------------------------------------------+
//
// 下位ボリンジャーバンド条件成立判定処理
//
//+------------------------------------------------------------------+
bool isSatisfiedLowerBandCondition(int bar_num,const double &close[]){

	if(Bars < 22) return false;
    if(bar_num >= Bars - 1) return false;
    
	if(close[bar_num] < Band_Lower_1[bar_num]){

		return true;
	}

	return false;
}

//+------------------------------------------------------------------+
//
// 遅行スパン売り条件成立判定処理
//
//+------------------------------------------------------------------+
bool isSatisfiedLowerLateSpan(int bar_num,const double &low[]){

	if(Bars < 22) return false;
    if( bar_num >= Bars - 21) return false;
    
	if(LateSpan[bar_num] < low[bar_num + 20]) return true;
	
	return false;
}
//+------------------------------------------------------------------+
//
// +2シグマを超えているか
//
//+------------------------------------------------------------------+
bool isOver2Sigma(int bar_num,const double &close[]){
	if(Bars < 22) return false;
    //if( bar_num >= Bars - 21) return false;

	if(close[bar_num] > Band_Upper_2[bar_num]){

	    UPPER_2SIGMA = true;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//
// -2シグマを下回っているか
//
//+------------------------------------------------------------------+
bool isUnder2Sigma(int bar_num,const double &close[]){
	if(Bars < 22) return false;
    //if( bar_num >= Bars - 21) return false;

	if(close[bar_num] < Band_Lower_2[bar_num]){
	
        LOWER_2SIGMA = true;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//
// サイン発生後に２シグマを超えた場合のチェック
//
//+------------------------------------------------------------------+
bool twoSigmaCheck(int bar_num,const datetime &time[],const double &close[]){

	//if(bar_num > 1){ return false; }

    bool two_sigma_flg = false;
    
    if(SIGNAL == UPPER_FLAG && UPPER_2SIGMA == false){

        two_sigma_flg = isOver2Sigma(bar_num,close);
        string message = "";
                
        if(two_sigma_flg == true){
        
            showOver2sigmaArrow(bar_num,time,close);

            message = _Symbol + ":" + IntegerToString(Period()) + " Buy signal Over 2sigma.";           
        	alertMessage(bar_num,message);

        	string title = buildMailTitle("buy",two_sigma_flg);
        	string body  = buildMailBody("buy",close,time,two_sigma_flg);
        	sendSignalMail(time,title,body);
    
            return true;
        }
     
    }else if(SIGNAL == LOWER_FLAG && LOWER_2SIGMA == false){

        two_sigma_flg = isUnder2Sigma(bar_num,close);
        string message = "";

        if(two_sigma_flg == true){
            showUnder2sigmaArrow(bar_num,time,close);
            message = _Symbol + ":" + IntegerToString(Period()) + " Sell signal Under 2sigma.";       
        	alertMessage(bar_num,message);

        	string title = buildMailTitle("sell",two_sigma_flg);
        	string body  = buildMailBody("sell",close,time,two_sigma_flg);
        	sendSignalMail(time,title,body);
            
            return true;
        }
    }
 
    return false;
}

//+------------------------------------------------------------------+
//
// 買いサイン表示処理
//
//+------------------------------------------------------------------+
void showUpperArrow(int bar_num,datetime time,double price){

	int chart_ID = 0;
	//string name = "arrow_up_" + IntegerToString(Bars - 2);
	string name = "arrow_up_" + IntegerToString(Bars);

    double low = iLow(_Symbol,Period(),bar_num + 1);
    //double high = iHigh(_Symbol,Period(),1);

	ObjectCreate(chart_ID,name,OBJ_ARROW_UP,0,time,low);
	ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_TOP);
	ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrAqua);
	ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,5);
	ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
	//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);  
	ChartRedraw();

}

//+------------------------------------------------------------------+
//
// 売りサイン表示処理
//
//+------------------------------------------------------------------+
void showLowerArrow(int bar_num,datetime time,double price){

	int chart_ID = 0;
	string name = "arrow_down_" + IntegerToString(Bars);
    double high = iHigh(_Symbol,Period(),bar_num + 1);
 
	ObjectCreate(chart_ID,name,OBJ_ARROW_DOWN,0,time,high);
	ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
	ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrRed);
	ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,5);
	ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
	//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);  
	ChartRedraw();

}
//+------------------------------------------------------------------+
//
// 2シグマ超えサイン表示処理
//
//+------------------------------------------------------------------+
void showOver2sigmaArrow(int bar_num,const datetime &time[],const double &close[]){

	int chart_ID = 0;
	string name = "two_sigma_buy_" + IntegerToString(Bars);
    double low = iLow(_Symbol,Period(),bar_num );

	ObjectCreate(chart_ID,name,OBJ_ARROW,0,time[bar_num],low);
	ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,225);
	ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_TOP);
	ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrAqua);
	ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,5);
	ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
	//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);  
	ChartRedraw();

}

//+------------------------------------------------------------------+
//
// ２シグマ下回りサイン表示処理
//
//+------------------------------------------------------------------+
void showUnder2sigmaArrow(int bar_num,const datetime &time[],const double &close[]){

	int chart_ID = 0;
	string name = "two_sigma_sell_" + IntegerToString(Bars);
    double high = iHigh(_Symbol,Period(),bar_num);

	ObjectCreate(chart_ID,name,OBJ_ARROW,0,time[bar_num],high);
    ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,226);
	ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
	ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrRed);
	ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,5);
	ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
	//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);  
	ChartRedraw();

}

//+------------------------------------------------------------------+
//
// 最高値更新表示処理
//
//+------------------------------------------------------------------+
void showOverHighestArrow(int bar_num,const datetime &time[],const double &close[]){

	int chart_ID = 0;
	string name = "highest_" + IntegerToString(Bars);

    double low = iLow(_Symbol,Period(),bar_num);

	ObjectCreate(chart_ID,name,OBJ_ARROW,0,0,0,0);
    ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,217);    // 矢印のコードを作成 
    ObjectSetInteger(chart_ID,name,OBJPROP_TIME,time[bar_num]);        // 時間を設定 
    ObjectSetDouble(chart_ID,name,OBJPROP_PRICE,low);// 価格を設定 	
	
	ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_TOP);
	ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrAqua);
	ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,5);
	ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
	//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);  
	ChartRedraw();

}

//+------------------------------------------------------------------+
//
// 最安値下回りサイン表示処理
//
//+------------------------------------------------------------------+
void showUnderLowestArrow(int bar_num,const datetime &time[],const double &close[]){

    //Print("test");
    //Print("bar_num:"+ bar_num);

	int chart_ID = 0;
	string name = "lowest_" + IntegerToString(Bars);

    double high = iHigh(_Symbol,Period(),bar_num);

	ObjectCreate(chart_ID,name,OBJ_ARROW,0,0,0,0);
    ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,218);    // 矢印のコードを作成 
    ObjectSetInteger(chart_ID,name,OBJPROP_TIME,time[bar_num]);        // 時間を設定 
    ObjectSetDouble(chart_ID,name,OBJPROP_PRICE,high);// 価格を設定 	

	ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
	ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrRed);
	ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,5);
	ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
	//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);  
	ChartRedraw();

}


//+------------------------------------------------------------------+
//
// エグジット判定処理
//
//+------------------------------------------------------------------+
bool checkExit(){
	return true;
}

//+------------------------------------------------------------------+
//
// アラート発生処理
//
//+------------------------------------------------------------------+
void alertMessage(int bar_num,string message){

	//立上がり時はアラートを発生させない。
	if(bar_num <= 1){
        Alert(message);
	}
}
//+------------------------------------------------------------------+
//
// メールタイトル作成処理
//
//  【ChikouSpan】売買：通貨:時間足:
//
//
//
//+------------------------------------------------------------------+
string buildMailTitle(string buy_or_sell,bool two_sigma_flg){

	string category = "";
	string two_sigma = "";

	if(buy_or_sell == "buy"){
		category = "Buy Entry";
    	if(two_sigma_flg == true){
            two_sigma = "Over 2Sigma."; 
        }
	}else{
		category = "Sell Entry";
    	if(two_sigma_flg == true){
            two_sigma = "Under 2Sigma."; 
        }
	}
	
	string candleTime = getChartPeriodString();
	string title = "【Chikou Span】" + category + ":" + _Symbol + ":" + candleTime + " " + two_sigma;

	return title;
}

//+------------------------------------------------------------------+
//
// メール本文作成処理
//
//  通貨ペア
//	時間足
//	シグナル方向
//	価格
//	発生時間
//
//	ロット
//	ロスカット価格
//
//
//
//+------------------------------------------------------------------+
string buildMailBody(string buy_or_sell,const double &close[],const datetime &time[],bool two_sigma_flg){

	string category = "";
	double losscut_price = 0.0;

	string body = "";
	string trend = "";

	if(buy_or_sell == "buy"){
		category = "買い方向";
		losscut_price = getMinus1Sigma();
        if(two_sigma_flg == true){
            body += "☆☆☆　Over 2Sigma!　☆☆☆\n\n";
			trend = "trend";
        }else{
            body += "下落方向の可能性が高いです。\n\n";
			trend = "range";
        }

	}else{
		category = "売り方向";
		losscut_price = getPlus1Sigma();
        if(two_sigma_flg == true){
            body += "☆☆☆　 2Sigma!　☆☆☆\n\n";
			trend = "trend";
        }else{
            body += "上昇方向の可能性が高いです。\n\n";
			trend = "range";
        }
	}
	
	string timeLocal = TimeToString(TimeLocal(),TIME_DATE|TIME_MINUTES);
	string timeStr   = TimeToString(time[1],TIME_DATE|TIME_MINUTES);

    body += "通貨ペア:" + _Symbol + "\n";
    body += "シグナル:" + category + "\n";
    body += "現在価格：" + DoubleToStr(NormalizeDouble(close[0],5),5) + "\n";
    body += "現在時刻:" + timeLocal + "\n";
    body += "サーバー時間：" + timeStr + "\n";
    body += "ロット:" + getLotNumber() + "\n";
	body += "利食い価格:" + DoubleToStr(NormalizeDouble(getTargetPrice(buy_or_sell,trend),5),5);
    body += "ロスカット価格" + DoubleToStr(NormalizeDouble(losscut_price,5),5) + "\n\n";
    body += getNotice();

	return body;
}
//注意点メモの作成
string getNotice(){

    string txt = "";
    
    txt +=" \n";
    txt +="■利食い・損切りポイントの判定\n";
    txt +="\n";
    txt +="＜順張りでエントリした場合＞\n";
    txt += "（トレンド相場の場合）\n";
    txt += "\n";
    txt += "◎利食いポイント\n";
    txt += "・大局観把握用の隣接する各シグマライン\n";
    txt += "\n";
    txt += "◎利食いポイントまたは損切りポイント\n";
    txt += "・トレンド終了時点\n";
    txt += "　→終値が＋１シグマの下方に位置する。\n";
    txt += "　→終値が－１シグマの上方に位置する。\n";
    txt += "\n";
    txt += "\n";
    txt += "○ポジションを分割決済するか、\n";
    txt += "トレーリングストップを用いて、\n";
    txt += "損切りレベルを変更するのがベター。\n";
    txt += "\n";
    txt += "＜逆張りでエントリした場合＞\n";
    txt += "（レンジ相場の場合）\n";
    txt += "\n";
    txt += "◎利食いポイント\n";
    txt += "・売買ポイント把握用のボリンジャーバンドの\n";
    txt += "　各シグマラインやセンターライン\n";
    txt += "\n";
    txt += "◎利食いポイントまたは損切りポイント\n";
    txt += "・トレンド発生時\n";
    txt += "　→終値が＋２シグマの上方に位置する。\n";
    txt += "　→終値が－２シグマの下方に位置する。\n";
    txt += "\n";
    txt += "◎利食いポイントまたは損切りポイント\n";
    txt += "・直近の高値ブレイク時\n";
    txt += "・直近の安値ブレイク時\n";

    return txt;
}



//+------------------------------------------------------------------+
//
// メール送信処理
//
//+------------------------------------------------------------------+
int sendSignalMail(const datetime &time[],string title, string body){

    if(LAST_SENDMAIL_TIME >= time[1]) return(0);

    SendMail(title, body);
    Print("Mail was sent.");
    
    LAST_SENDMAIL_TIME = time[0];

    return(1);

}
//*****************************************************************************************
//*****************************************************************************************
//ロスカット価格の算出処理
//*****************************************************************************************
//*****************************************************************************************

//+------------------------------------------------------------------+
//
// ボリンジャーバンドのプラス１シグマを取得する。
//
//+------------------------------------------------------------------+
double getPlus1Sigma(){
	double ret = iBands(NULL,0,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_UPPER,1);

    if(Digits == 3){
        return NormalizeDouble(ret,3);
    }else{
        return NormalizeDouble(ret,5);
    }
}
//+------------------------------------------------------------------+
//
// ボリンジャーバンドのマイナス１シグマを取得する。
//
//+------------------------------------------------------------------+
double getMinus1Sigma(){
	double ret = iBands(NULL,0,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_LOWER,1);

    if(Digits == 3){
        return NormalizeDouble(ret,3);
    }else{
        return NormalizeDouble(ret,5);
    }


}
//+------------------------------------------------------------------+
//
// 最大リスク許容額を算出する。
//
//+------------------------------------------------------------------+
int getRiskPrice(){
	return int(MathFloor(AccountBalance() / 100 * RISK_PERCENTAGE));
}

//+------------------------------------------------------------------+
//
// RiskPipsを算出する。
//
//+------------------------------------------------------------------+
int getRiskPips(){
	
	double plus1,minus1;

	plus1  = getPlus1Sigma();
	minus1 = getMinus1Sigma();

	double wk = 0.0;
	int pips = 0;

	double close = iClose(_Symbol,Period(),1);

	//Buyl
	if(close > plus1){
		wk = close - minus1;
	}
	//Sell
	else if(close < minus1){
		wk = plus1 - close;
	}else{
	    return 0;
	}

	if(Digits == 3){
		pips = int(MathFloor(wk / 0.01));
	}else if(Digits == 5){
		pips = int(MathFloor(wk / 0.0001));
	}else{
		pips = 0;
	}
	return pips;

}

//+------------------------------------------------------------------+
//
// 対象通貨における1pipsあたり円価格
//
//+------------------------------------------------------------------+
double getPipPerCurrencyPrice(){

	double yen = 0.0;
	double pip = 0.0;

	yen = iClose("USDJPY",Period(),1);

	if(	_Symbol == "USDJPY" ||
		_Symbol == "GBPJPY" ||
		_Symbol == "AUDJPY" ||
		_Symbol == "EURJPY"	){

		pip = 0.01;

	}else if(	_Symbol == "EURUSD" ||
				_Symbol == "GBPUSD" ||
				_Symbol == "AUDUSD"){
		pip = 0.0001 * yen;
	}else{
		pip = 0.0001 * yen;
	}

	return pip;
}

//+------------------------------------------------------------------+
//
// エントリ可能ロット数を算出する。
//
//+------------------------------------------------------------------+
//double getLotNumber(){
string getLotNumber(){
	//損失許容額の取得
	//---  10万円 * 2% = 2000円

	int risk_price = getRiskPrice();

    //debug
    //risk_price = 50000;
    
	//1ロットが何万通貨か
	//--- 1ロット = 100,000通貨

	double lot_size = MarketInfo(_Symbol,MODE_LOTSIZE);
	

	//ロスカットまでのpips
	//-- 終値からボリンジャーバンドプラス・マイナス１シグマまで20pips
	int losscut_pips =  getRiskPips();



	//この場合の1pipsあたりの価格
	// 2000円　÷　20pips = 100円

    if(losscut_pips <= 0){
        return "0";
    }
	double pips_per_yen = risk_price / losscut_pips;

	//クロス円
	//ドルストレート
	//1ロットで1pips動いた場合の価格（円価）
	//---- 100,000 / 100 = 1000円　1ロットでは、1pipsあたり1000円動く

	//クロス円の場合は100で割る　1pips = 0.01円
	//ドルストレートの場合は10000で割る　1pips = 0.0001ドル
	double lot_per_pipprice = lot_size * getPipPerCurrencyPrice();

    if(lot_per_pipprice <= 0){
        return "0";
    }

	//--- 1pipで100円動くようにする時のロット数は？
	//---  100 / 1000 = 0.1ロット
	double wk_lot = pips_per_yen / lot_per_pipprice;

	//小数点以下第2桁まで算出
	string lot = DoubleToStr(wk_lot,2);

	return lot;
}
//+------------------------------------------------------------------+
//
// ターゲット価格の取得
//
// ①順張りか逆張りか判定する。
// ②利食い価格を算出する。
//
//+------------------------------------------------------------------+
double getTargetPrice(string buy_or_sell, string trend){

	//時間枠のペアを取得する。
	ENUM_TIMEFRAMES time_frame = getTimeFramePair();
	double take_profit = 0.0;

	//下位でトレンド相場の場合
	if(buy_or_sell == "buy" && trend == "trend"){

		//大局観の隣接するバンドの取得
		take_profit = iBands(NULL,time_frame,MAPeriod,BandsDeviation_1,0,PRICE_CLOSE,1,1);
	}

	//売りでトレンド相場の場合
	else if(buy_or_sell == "sell" && trend == "trend"){
		take_profit = iBands(NULL,time_frame,MAPeriod,BandsDeviation_1,0,PRICE_CLOSE,2,1);
	}

	//買いでレンジ相場の場合
	else if(buy_or_sell == "buy" && trend == "range"){
		take_profit = iBands(NULL,Period(),MAPeriod,BandsDeviation_1,0,PRICE_CLOSE,1,0);
	}

	//売りでレンジ相場の場合
	else if(buy_or_sell == "sell" && trend == "range"){
		take_profit = iBands(NULL,Period(),MAPeriod,BandsDeviation_1,0,PRICE_CLOSE,2,0);
	}

	return take_profit;

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