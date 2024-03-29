//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |

/*
rates_total チャートのバー（ロウソク足）の総数で最初は画面バー総数です。
価格の変化 (Tick) で呼び出さると+1になります。

prev_calculated 計算済みのバー数です。
最初は0
計算を始めて全て計算を終えた時にはrates_totalと同じ
バーが追加されると rates_totalは1つ増えます。




*/
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Relative Strength Index"
#property strict

//#property indicator_chart_window
#property indicator_separate_window

#property indicator_buffers 8

double EMA_SHORT_BUF[];
double EMA_MID_BUF[];
double EMA_LONG_BUF[];

double LONG_UP[];
double LONG_DOWN[];

double MID_UP[];
double MID_DOWN[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  //ObjectsDeleteAll(0,"objArrow_");
  //ObjectsDeleteAll();
  //Print("OnInit");

   IndicatorBuffers(8);
   IndicatorDigits(Digits);

//--- short line
   SetIndexStyle(0,DRAW_NONE,0,0,clrWhite);
   SetIndexBuffer(0,EMA_SHORT_BUF);
   SetIndexLabel(0,"Bands Short EMA");

//--- short line
   SetIndexStyle(1,DRAW_NONE,0,0,clrRed);
   SetIndexBuffer(1,EMA_MID_BUF);
   SetIndexLabel(1,"Bands Short EMA");

//--- short line
   SetIndexStyle(2,DRAW_NONE,0,0,clrBlue);
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



   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
/*
int OnDeinit()
  {
  
  
  //ObjectsDeleteAll(0,"objArrow_");
  ObjectsDeleteAll();
   return(INIT_SUCCEEDED);
 }
*/





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

	Print("start");

	int limit = rates_total - prev_calculated;


	for(int i = limit; i >= 0 ; i--)
	{
		if(i>=Bars) continue;
		//Print(i);


		EMA_SHORT_BUF[i]	= iMA(NULL,PERIOD_CURRENT,5,0,MODE_EMA,PRICE_CLOSE,i);
		EMA_MID_BUF[i]		= iMA(NULL,PERIOD_CURRENT,20,0,MODE_EMA,PRICE_CLOSE,i);
		EMA_LONG_BUF[i]		= iMA(NULL,PERIOD_CURRENT,40,0,MODE_EMA,PRICE_CLOSE,i);


		if(EMA_MID_BUF[i] > EMA_LONG_BUF[i])
		{
			//LONG_DOWN[i]	= EMA_MID_BUF[i];
			//LONG_UP[i]		= EMA_LONG_BUF[i];
		
			LONG_DOWN[i]	= 200;
			LONG_UP[i]		= 0;
		}
		else
		{
			//MID_DOWN[i]	= EMA_LONG_BUF[i];
			//MID_UP[i]	= EMA_MID_BUF[i];
			MID_DOWN[i]	= 200;
			MID_UP[i]	= 0;
		
		}
		
		showStage(getStage(i));
		
	}
	

	return(rates_total);
}

#define EMA_UP 1
#define EMA_DOWN 2

int getStage(int i)
{

	int stage;
	
	if(EMA_SHORT_BUF[i] > EMA_MID_BUF[i] && EMA_MID_BUF[i] > EMA_LONG_BUF[i])
	{
		stage = 1;
	}
	else if(EMA_MID_BUF[i] > EMA_SHORT_BUF[i] && EMA_SHORT_BUF[i] > EMA_LONG_BUF[i])
	{
		stage = 2;
	}
	else if(EMA_MID_BUF[i] > EMA_LONG_BUF[i] && EMA_LONG_BUF[i] > EMA_SHORT_BUF[i])
	{
		stage = 3;
	}
	else if(EMA_LONG_BUF[i] > EMA_MID_BUF[i] && EMA_MID_BUF[i] > EMA_SHORT_BUF[i])
	{
		stage = 4;
	}
	else if(EMA_LONG_BUF[i] > EMA_SHORT_BUF[i] && EMA_SHORT_BUF[i] > EMA_MID_BUF[i])
	{
		stage = 5;
	}
	else if(EMA_SHORT_BUF[i] > EMA_LONG_BUF[i] && EMA_LONG_BUF[i] > EMA_MID_BUF[i])
	{
		stage = 6;
	}

	return stage;

}




void showStage(int stage){
	
    double x_pos = 10;
    double y_pos = 0;
    string objName = "lot";
    

	string text = "第" + IntegerToString(stage) + "ステージ";

    string rate_font = "MS P ゴシック";

	ObjectDelete(objName);

	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, text, 16, rate_font, clrWhite);
	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);

}












//+------------------------------------------------------------------+
void showArrow(string direction,int bar_num,int col)
{

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

void signallog(string signal_txt)
{

	int filehandle=FileOpen("signal.log",FILE_WRITE); 
	FileWrite(filehandle,signal_txt);
	FileFlush(filehandle);
	FileClose(filehandle); 

}

void showFlag()
{

	string objShort = "short_flg";
	string objMid = "mid_flg";
	string objLong = "long_flg";

	string short_txt,mid_txt,long_txt;
	color col_short,col_mid,col_long;

	ObjectDelete(objShort);
	ObjectDelete(objMid);
	ObjectDelete(objLong);


	short_txt = "短期：下落";
	col_short = clrMagenta;


	
	//ObjectCreate(0,objShort, OBJ_ARROW,0,0,0);
	ObjectCreate(0,objShort,OBJ_LABEL,0,0,0);
	ObjectSetString(0,objShort,OBJPROP_TEXT,short_txt);    // 表示するテキスト
    ObjectSetString(0,objShort,OBJPROP_FONT,"ＭＳ　ゴシック");
    ObjectSetInteger(0,objShort,OBJPROP_FONTSIZE,14);                   // フォントサイズ
    ObjectSetInteger(0,objShort,OBJPROP_COLOR,col_short);                   // フォントサイズ
    ObjectSetInteger(0,objShort,OBJPROP_CORNER,CORNER_RIGHT_UPPER);  // コーナーアンカー設定
    ObjectSetInteger(0,objShort,OBJPROP_XDISTANCE,100);                // X座標
    ObjectSetInteger(0,objShort,OBJPROP_YDISTANCE,20);     


   

}