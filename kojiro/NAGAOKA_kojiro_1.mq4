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
#property copyright   "2019-2020, Shunsuke Nagaoka."
#property link        ""
#property description "Nagaoka daijunkan"
#property strict

#property indicator_chart_window
#property indicator_buffers 13

double EMA_SHORT_BUF[];
double EMA_MID_BUF[];
double EMA_LONG_BUF[];

double LONG_UP[];
double LONG_DOWN[];

double MID_UP[];
double MID_DOWN[];

double UP_BANDS[];
double MD_BANDS[];
double DN_BANDS[];

double EMA25[];

double Buffer1[];


input int PRINT_MODE = 0; //データ出力モード
input int SHOW_STAGE_NUMBER = 0; //バーの上にStageナンバーを表示


input int SHORT_PERIOD = 5; //1,5,15,30,60,240,1440
input int MID_PERIOD   = 15; //1,5,15,30,60,240,1440
input int LONG_PERIOD  = 60; //1,5,15,30,60,240,1440



//固定値
string CURRENCY = "";
double PIP_BASE = 0.0;
string TIME_FRAME = "";
int CURRENCY_DIGIT = 0;

datetime LAST_SIGNAL_DATETIME = 0.0;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  //ObjectsDeleteAll(0,"objArrow_");
  //ObjectsDeleteAll();
  //Print("OnInit");

   IndicatorBuffers(13);
   IndicatorDigits(Digits);

//--- short line
   SetIndexStyle(0,DRAW_LINE,0,0,clrWhite);
   SetIndexBuffer(0,EMA_SHORT_BUF);
   SetIndexLabel(0,"Bands Short EMA");

//--- short line
   SetIndexStyle(1,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(1,EMA_MID_BUF);
   SetIndexLabel(1,"Bands Short EMA");

//--- short line
   SetIndexStyle(2,DRAW_LINE,0,0,clrBlue);
   SetIndexBuffer(2,EMA_LONG_BUF);
   SetIndexLabel(2,"Bands Short EMA");



   /*
   SetIndexStyle(3,DRAW_HISTOGRAM,0,0,clrSkyBlue);
   SetIndexBuffer(3,LONG_DOWN);

   SetIndexStyle(4,DRAW_HISTOGRAM,0,0,clrRed);
   SetIndexBuffer(4,LONG_UP);
   */ 


   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,clrSkyBlue);
   SetIndexBuffer(4,LONG_DOWN);
   SetIndexDrawBegin(4,40);

   SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,2,clrRed);
   SetIndexBuffer(5,LONG_UP);
   SetIndexDrawBegin(5,40);

   SetIndexStyle(6,DRAW_HISTOGRAM,STYLE_SOLID,2,clrViolet);
   SetIndexBuffer(6,MID_DOWN);
   SetIndexDrawBegin(6,40);

   SetIndexStyle(7,DRAW_HISTOGRAM,STYLE_SOLID,2,clrRed);
   SetIndexBuffer(7,MID_UP);
   SetIndexDrawBegin(7,40);



   SetIndexStyle(8,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(8,UP_BANDS);
   SetIndexLabel(8,"Bollinger Bands up");
   SetIndexDrawBegin(8,25);
   
   SetIndexStyle(9,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(9,MD_BANDS);
   SetIndexLabel(9,"Bollinger Bands center");
   SetIndexDrawBegin(9,25);

   SetIndexStyle(10,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(10,DN_BANDS);
   SetIndexLabel(10,"Bollinger Bands down");
   SetIndexDrawBegin(10,25);



   SetIndexStyle(11,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(11,EMA25);
   SetIndexLabel(11,"EMA 25");
   SetIndexDrawBegin(10,26);

   SetIndexStyle(12,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(12,Buffer1);
   SetIndexLabel(12,"Buffer1");
   SetIndexDrawBegin(11,100);


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

	double second_term_short,second_term_short_p1,second_term_mid,second_term_long;
	double third_term_short,third_term_short_p1,third_term_mid,third_term_long;


	for(int i = limit; i >= 0 ; i--)
	{
		if(i>=Bars-3) continue;
		//Print(i);


		EMA_SHORT_BUF[i]	= iMA(NULL,SHORT_PERIOD,5,0,MODE_EMA,PRICE_CLOSE,i);
		EMA_MID_BUF[i]		= iMA(NULL,SHORT_PERIOD,20,0,MODE_EMA,PRICE_CLOSE,i);
		EMA_LONG_BUF[i]		= iMA(NULL,SHORT_PERIOD,40,0,MODE_EMA,PRICE_CLOSE,i);


		second_term_short	= iMA(NULL,MID_PERIOD,5,0,MODE_EMA,PRICE_CLOSE,i);
		second_term_short_p1= iMA(NULL,MID_PERIOD,5,0,MODE_EMA,PRICE_CLOSE,i+1);
		second_term_mid		= iMA(NULL,MID_PERIOD,20,0,MODE_EMA,PRICE_CLOSE,i);
		second_term_long	= iMA(NULL,MID_PERIOD,40,0,MODE_EMA,PRICE_CLOSE,i);

		third_term_short	= iMA(NULL,LONG_PERIOD,5,0,MODE_EMA,PRICE_CLOSE,i);
		third_term_short_p1	= iMA(NULL,LONG_PERIOD,5,0,MODE_EMA,PRICE_CLOSE,i+1);
		third_term_mid		= iMA(NULL,LONG_PERIOD,20,0,MODE_EMA,PRICE_CLOSE,i);
		third_term_long		= iMA(NULL,LONG_PERIOD,40,0,MODE_EMA,PRICE_CLOSE,i);


		//UP_BANDS[i] = iBands(NULL,PERIOD_CURRENT,21,2.0,0,PRICE_CLOSE,MODE_UPPER,i);
		//MD_BANDS[i] = iBands(NULL,PERIOD_CURRENT,21,2.0,0,PRICE_CLOSE,MODE_MAIN,i);
		//DN_BANDS[i] = iBands(NULL,PERIOD_CURRENT,21,2.0,0,PRICE_CLOSE,MODE_LOWER,i);

		EMA25[i]		= iMA(NULL,PERIOD_CURRENT,25,0,MODE_SMA,PRICE_CLOSE,i); //SMAにする。

		if(EMA_MID_BUF[i] > EMA_LONG_BUF[i])
		{
			LONG_DOWN[i]	= EMA_MID_BUF[i];
			LONG_UP[i]		= EMA_LONG_BUF[i];
		
		}
		else
		{
			MID_DOWN[i]	= EMA_LONG_BUF[i];
			MID_UP[i]	= EMA_MID_BUF[i];
		
		}
	

		int short_stage[2],mid_stage[2],long_stage[2];

		getStage(EMA_SHORT_BUF[i],EMA_SHORT_BUF[i+1],EMA_MID_BUF[i],EMA_LONG_BUF[i],short_stage);
		showStage(short_stage[0],3,"SHORT_TERM",SHOW_STAGE_NUMBER);
		showStageNumber(i,short_stage[1],1,SHOW_STAGE_NUMBER);

		getStage(second_term_short,second_term_short_p1,second_term_mid,second_term_long,mid_stage);
		showStage(mid_stage[0],2,"MID_TERM",SHOW_STAGE_NUMBER);
		//showStageNumber(i,mid_stage[1],2,SHOW_STAGE_NUMBER);

		getStage(third_term_short,third_term_short_p1,third_term_mid,third_term_long,long_stage);
		showStage(long_stage[0],1,"LONG_TERM",SHOW_STAGE_NUMBER);
		//showStageNumber(i,long_stage[1],3,SHOW_STAGE_NUMBER);

		string direction = createSignal(i,short_stage[1],mid_stage[1],long_stage[1]);

		showArrow(direction,i-1,clrMagenta);

		if(PRINT_MODE == 1)
		{	
			analyze_log(i,short_stage[0],short_stage[1]);
		}
	}
	

	return(rates_total);
}
/**
 *マルチステージでの検証
 *   H1:サブステージ10 M15サブステージ15 M5サブステージ10
 *   または、
 *   H1:サブステージ11 M15サブステージ11 M5サブステージ11
 */
string createSignal(int i,int short_num,int mid_num,int long_num)
{
	string ret = "";

	//if(long_num == 10 && mid_num == 10 && short_num == 21) { ret = "down"; }
	//else if(long_num == 10 && mid_num == 10 && short_num == 30) { ret = "down"; }
	if(long_num == 10 && mid_num == 11 && short_num == 10) { ret = "up"; }
	else if(long_num == 11 && mid_num == 11 && short_num == 11) { ret = "up"; }
	//else if(long_num == 11 && mid_num == 11 && short_num == 10) { ret = "up"; }
	//else if(long_num == 40 && mid_num == 40 && short_num == 51) { ret = "up"; }
	//else if(long_num == 40 && mid_num == 41 && short_num == 40) { ret = "down"; }
	//else if(long_num == 41 && mid_num == 41 && short_num == 40) { ret = "down"; }
	//else if(long_num == 60 && mid_num == 11 && short_num == 10) { ret = "up"; }
	
	if(ret == "up" || ret == "down")
	{
		Print(TimeToStr(Time[i]) + ":" + ret);
		printf("%d:%d:%d",long_num,mid_num,short_num);	
	
	}
	return ret;

}



void signallog(int index,string direction)
{
	//[BINARY_OPTION] 20190618193500 USDCHF down

	string signal_txt = "[BINARY_OPTION] " + getStrTimeLocal() + " " + _Symbol + " " + IntegerToString(_Period) + " " + getStrTime() + " " + direction;
	string file_name = "signal.log";

	int filehandle = FileOpen(file_name,FILE_READ|FILE_WRITE);

    if(filehandle < 0)
    {
	    Print("Failed to open file.");
	    Print("Error code ",GetLastError());
    }
 

	FileSeek(filehandle,0,SEEK_END);
	FileWrite(filehandle,signal_txt);
	FileFlush(filehandle);
	FileClose(filehandle); 
	
	Print(signal_txt);

	Alert(_Symbol + " " + IntegerToString(_Period) + " " + direction);

}
string getStrTime()
{

	//Print(TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));

	string str_time = TimeToStr(Time[0],TIME_DATE|TIME_MINUTES);
	StringReplace(str_time,".","");
	StringReplace(str_time,":","");
	StringReplace(str_time," ","");

	return str_time;
						
}

string getStrTimeLocal()
{

	string str_time = TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
	StringReplace(str_time,".","");
	StringReplace(str_time,":","");
	StringReplace(str_time," ","");

	return str_time;
						
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



//void getStage(int i,int &ret[])
void getStage(double short_ema,double short_ema_p1,double mid_ema,double long_ema,int &ret[])
{

	int stage = 0;
	int substage = 0;
	
	//double short_ema = EMA_SHORT_BUF[i];
	//double mid_ema   = EMA_MID_BUF[i];
	//double long_ema  = EMA_LONG_BUF[i];
	//double short_ema_p1 = EMA_SHORT_BUF[i + 1];
	
	if(short_ema > mid_ema && mid_ema > long_ema)
	{
		stage = 1;
		if(short_ema_p1 > short_ema)
		{
			substage = 11;
		}
		else
		{
			substage = 10;
		}
	}
	else if(long_ema > mid_ema && mid_ema > short_ema)
	{
		stage = 4;
		if(short_ema_p1 < short_ema)
		{
			substage = 41;
		}
		else
		{
			substage = 40;
		}
	}
	else if(mid_ema > short_ema && short_ema > long_ema)
	{
		stage = 2;
		if(short_ema_p1 <= short_ema)
		{
			substage = 20;
		}
		else
		{
			substage = 21;
		}
	}
	else if(long_ema > short_ema && short_ema > mid_ema)
	{
		stage = 5;
		if(short_ema_p1 >= short_ema)
		{
			substage = 50;
		}
		else
		{
			substage = 51;
		}
	}
	else if(mid_ema > long_ema && long_ema > short_ema)
	{
		stage = 3;
		if(short_ema_p1 >= short_ema)
		{
			substage = 30;
		}
		else
		{
			substage = 31;
		}	
	}
	else if(short_ema > long_ema && long_ema > mid_ema)
	{
		stage = 6;
		if(short_ema_p1 <= short_ema)
		{
			substage = 60;
		}
		else
		{
			substage = 61;
		}
	}
	
	ret[0] = stage;
	ret[1] = substage;
}

void showStage(int stage,int display_pos,string title,int mode)
{
	if(mode != 1){ return; }

	//if(PRINT_MODE == 1) return;

	if(IsTesting() == true && IsVisualMode() == false) return;
	
    double x_pos = 10;
    double y_pos = 15 * display_pos;
    string objName = title; 
    
	string text = title + ":" + IntegerToString(stage) + "ステージ";
    string rate_font = "MS P ゴシック";

	ObjectDelete(objName);

	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, text, 12, rate_font, clrWhite);
	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);

}

void showStageNumber(int i,int stage,int display_pos,int mode)
{

	if(mode != 1) return; //バーの上にステージナンバーを表示するか。

	if(IsTesting() == true && IsVisualMode() == false) return;

    long tm = Time[i];
    string objName = "stage_number" + IntegerToString(tm) + "_" + IntegerToString(display_pos);
	string text = IntegerToString(stage);
    string rate_font = "MS P ゴシック";
	ObjectCreate(objName, OBJ_TEXT,0,Time[i],High[i] + (PIP_BASE * display_pos));
	ObjectSetText(objName, text, 10, rate_font, clrWhite);

}

void setArrow(string direction,string position ,int bar_num,int col)
{

	if(PRINT_MODE == 1) return;

	if(IsTesting() == true && IsVisualMode() == false) return;

	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;

	arrow_color = col;

	
	if(direction == "up")
	{
		arrow_type = 217;
	}
	else if(direction == "down")
	{
		arrow_type = 218;
	}
	else
	{
		return;
	}

	if(position == "up")
	{
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	}
	else if(position == "down")
	{
		pos = Low[bar_num];
		anchor = ANCHOR_LOWER;
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
		arrow_type = 218;
		pos = Low[bar_num];
		anchor = ANCHOR_LOWER;
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

void outputlog(int bar_num,string txt)
{

	//id	datetime	currency	timeframe	open	high	low	close	direction	pips	ema_short	ema_mid	ema_long	mid_long_belt	stage	substage	pip_avg	next_direction	low<ema_short	low<ema_mid	low<ema_long	pre stage

	MqlDateTime mqlDt;
	TimeToStruct(Time[bar_num],mqlDt);
	  
	static string file_name = 
		"analyze_" + _Symbol + "_" + IntegerToString(_Period) + "_" + StringFormat("%4d%02d%02d%02d%02d%02d",mqlDt.year,mqlDt.mon,mqlDt.day,mqlDt.hour,mqlDt.min,mqlDt.sec) + ".log";

	int filehandle = FileOpen(file_name,FILE_READ|FILE_WRITE); 
	FileSeek(filehandle,0,SEEK_END);
	FileWrite(filehandle,txt);
	FileFlush(filehandle);
	FileClose(filehandle); 
	
}

void analyze_log(int num,int stage,int substage)
{
	if(PRINT_MODE != 1) return;

	static string currency = _Symbol;
	
	string bar_category;

	double o = Open[num];
	double h = High[num];
	double l = Low[num];
	double c = Close[num];	

	double short_ema = EMA_SHORT_BUF[num];
	double mid_ema   = EMA_MID_BUF[num];
	double long_ema  = EMA_LONG_BUF[num];

	double up_band = UP_BANDS[num];
	double dn_band = DN_BANDS[num];
	
	double ema25 = EMA25[num];


	//日付、陰線、陽線、ステージナンバー　OK,NG
	if(o > c)
	{
		bar_category = "dn";
	}
	else if(o < c)
	{
		bar_category = "up";
	}
	else
	{
		bar_category = "dj";
	}

	//ローソク足の長さ
	

	string	text =	TimeToStr(Time[num],TIME_DATE|TIME_MINUTES) + "," + 
					CURRENCY + "," + 
					TIME_FRAME + "," +
					bar_category  + "," +
					IntegerToString(stage) + "," +
					IntegerToString(substage) + "," +
					DoubleToStr(o,CURRENCY_DIGIT) + "," +
					DoubleToStr(h,CURRENCY_DIGIT) + "," +
					DoubleToStr(l,CURRENCY_DIGIT) + "," +
					DoubleToStr(c,CURRENCY_DIGIT) + "," +
					getUpDown(num,1)  + "," +
					getUpDown(num,2)  + "," +
					getUpDown(num,3)  + "," +
					getUpDown(num,4)  + "," +
					getUpDown(num,5)  + "," +
					getCandleStickBodyPips(o,h,l,c) + "," +
					getCandleStickAllPips(h,l) + "," +
					getCandleStickUpperPin(o,h,l,c) + "," +
					getCandleStickLowerPin(o,h,l,c) + "," +
					DoubleToStr(short_ema,CURRENCY_DIGIT) + "," +
					DoubleToStr(mid_ema,CURRENCY_DIGIT) + "," +
					DoubleToStr(long_ema,CURRENCY_DIGIT) + "," +
					getEmaBand(mid_ema,long_ema) + "," +
					DoubleToStr(up_band,CURRENCY_DIGIT) + "," +
					DoubleToStr(dn_band,CURRENCY_DIGIT) + "," +
					DoubleToStr(ema25,CURRENCY_DIGIT);

	//string txt = TimeToStr(Time[num]) + "," + bar_category + "," 
	outputlog(num,text);

}
string getUpDown(int i,int pos)
{
	if(i <= 0 ) return "";

	int target = i - pos;
	if(target >= Bars) return "";

	string txt = "dj";

	if(Close[i] < Close[target])
	{
		txt = "up";
	}
	else if(Close[i] > Close[target])
	{
		txt = "dn";
	}

	return txt;

}



string getTimeFrameString()
{
	switch( Period() )
	{
		case PERIOD_M1:  return( "M1" );
		case PERIOD_M5:  return( "M5" );
		case PERIOD_M15: return( "M15" );
		case PERIOD_M30: return( "M30" );
		case PERIOD_H1:  return( "H1" );
		case PERIOD_H4:  return( "H4" );
		case PERIOD_D1:  return( "D1" );
		case PERIOD_W1:  return( "W1" );
		case PERIOD_MN1: return( "MN1" );
		default: return( "Unknown timeframe" );
	}
}

//ローソク足の長さ
string getCandleStickBodyPips(double o, double h, double l, double c)
{
	double ret;
	if(o > c) { ret =  o - c; }
	else if(o < c) { ret = c - o; }
	else { ret = 0.0; }
	
	return DoubleToStr(ret / PIP_BASE,1);

}

string getCandleStickAllPips(double h, double l)
{
	return DoubleToStr((h - l) / PIP_BASE,1);
}
string getCandleStickUpperPin(double o, double h, double l, double c)
{
	double ret;
	if(o > c) { ret =  h - o; }
	else { ret = h - c; }

	return DoubleToStr(ret / PIP_BASE,1);

}
string getCandleStickLowerPin(double o, double h, double l, double c)
{
	double ret;
	if(o < c) { ret =  o - l; }
	else { ret = c - l; }

	return DoubleToStr(ret / PIP_BASE,1);

}
string getEmaBand(double mid_ema, double long_ema)
{
	return DoubleToStr(MathAbs(mid_ema - long_ema) / PIP_BASE,1);
	
}