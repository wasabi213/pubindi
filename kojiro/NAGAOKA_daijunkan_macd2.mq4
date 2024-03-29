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

#property indicator_separate_window
#property indicator_buffers 4


input int MACD_SHORT = 5; //macd短期線
input int MACD_LONG  = 20; //macd長期線



double MACD1[];
double MACD2[];
double MACD3_UP[];
double MACD3_DOWN[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  //ObjectsDeleteAll(0,"objArrow_");
  //ObjectsDeleteAll();
  //Print("OnInit");

   IndicatorBuffers(4);
   IndicatorDigits(Digits);

//--- short line
   SetIndexStyle(0,DRAW_LINE,0,0,clrWhite);
   SetIndexBuffer(0,MACD1);
   SetIndexLabel(0,"Bands Short EMA");

   SetIndexStyle(1,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(1,MACD2);
   SetIndexLabel(1,"Bands Short EMA");

   SetIndexStyle(2,DRAW_HISTOGRAM,0,2,clrSkyBlue);
   SetIndexBuffer(2,MACD3_UP);

   SetIndexStyle(3,DRAW_HISTOGRAM,0,2,clrRed);
   SetIndexBuffer(3,MACD3_DOWN);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
  
  
  //ObjectsDeleteAll(0,"objArrow_");
  //ObjectsDeleteAll();
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
		if(i>=Bars-10) continue;
		//Print(i);


		MACD1[i] = iMACD(NULL,PERIOD_CURRENT,MACD_SHORT,MACD_LONG,9,PRICE_CLOSE,MODE_MAIN,i);
		MACD2[i] = iMACD(NULL,PERIOD_CURRENT,MACD_SHORT,MACD_LONG,9,PRICE_CLOSE,MODE_SIGNAL,i);
		MACD3_UP[i] = MACD1[i] - MACD2[i];
		
		//showMacdDirection("long",getLongMacdDirection(i));
		//showMacdDirection("mid",getMidMacdDirection(i));
		//showMacdDirection("short",getShortMacdDirection(i));
	}
	

	return(rates_total);
}

#define MACD_UP 1
#define MACD_DOWN 2
int getShortMacdDirection(int i)
{
	int direction = MACD_DOWN;
	if(MACD1[i+1] > MACD1[i+2]){ direction = MACD_UP; }
	return direction;
}

int getMidMacdDirection(int i)
{
	int direction = MACD_DOWN;
	if(MACD2[i+1] > MACD2[i+2]){ direction = MACD_UP; }
	return direction;
}
int getLongMacdDirection(int i)
{
	int direction = MACD_DOWN;
	if(MACD3_UP[i+1] > MACD3_UP[i+2]){ direction = MACD_UP; }
	return direction;
}


void showMacdDirection(string term,int direction)
{

    double x_pos = 50;
    double y_pos = 0;
	string text;

	if(term == "long")
	{
		y_pos = 60;
		text = "MACD長期：";		
	}	
	else if(term == "mid")
	{
		y_pos = 40;
		text = "MACD中期：";		
	}	
	else if(term == "short")
	{
		y_pos = 20;
		text = "MACD短期：";		
	}	
	
	
	string dir_text;
	if(direction == MACD_UP)
	{
		dir_text = "上昇";
	}
	else
	{
		dir_text = "下落";
	}
	
	
	string objName = "macd_direction"+ term + "_" + IntegerToString(Bars);
    string rate_font = "MS P ゴシック";

	ObjectsDeleteAll(0,"macd_direction",0);

	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, text+dir_text, 11, rate_font, clrWhite);
	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);

}




//+------------------------------------------------------------------+
/*
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
*/

void signallog(string signal_txt)
{

	int filehandle=FileOpen("signal.log",FILE_WRITE); 
	FileWrite(filehandle,signal_txt);
	FileFlush(filehandle);
	FileClose(filehandle); 

}

/*
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
*/