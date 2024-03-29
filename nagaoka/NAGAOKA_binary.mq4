//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Relative Strength Index"
#property strict

#property indicator_chart_window



//--- input parameters
input int RSI_PERIOD = 5; // RSI Period



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  ObjectsDeleteAll(0,"objArrow_");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
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

//--- preliminary calculations

	double rsi,rsi1,longMa,shortMa,env_up,env_low;

	int num_uncalculated = rates_total - prev_calculated;
	if(num_uncalculated >= Bars) num_uncalculated = num_uncalculated - 1;

	for(int i = num_uncalculated; i >= 0; i--)
	{
		if(i + 1 >= rates_total) break;

		//printf("i:%d",i);

		rsi     = iRSI(NULL,PERIOD_M1,RSI_PERIOD,PRICE_CLOSE,i);
		rsi1    = iRSI(NULL,PERIOD_M1,RSI_PERIOD,PRICE_CLOSE,i + 1);
		env_up	= iEnvelopes(NULL,PERIOD_M1,60,MODE_SMA,0,PRICE_CLOSE,0.03,MODE_UPPER,i);
		env_low = iEnvelopes(NULL,PERIOD_M1,60,MODE_SMA,0,PRICE_CLOSE,0.03,MODE_LOWER,i);
		longMa  = iMA(NULL,PERIOD_M1,60,0,MODE_SMA,PRICE_CLOSE,i);
		shortMa = iMA(NULL,PERIOD_M1,3,0,MODE_SMA,PRICE_CLOSE,i);

		Print(env_up);


		//売りエントリの場合
		if(	isUp(i))
		{
			showArrow("down",i);
		}
		else if(shortMa < longMa && rsi <= 30.0 && Close[i + 1] < shortMa && Close[i + 1] > Open[i + 1])
		{
			//showArrow("up",i);		
		}
		
		
		/*
		if(shortMa > longMa && rsi >= 70.0  && Close[i + 1] > shortMa)
		{
			showArrow("down",i);
		}
		else if(shortMa < longMa && rsi <= 30.0 && Close[i + 1] < shortMa )
		{
			showArrow("up",i);		
		}
		*/
			
		
	}

	return(rates_total);
}
bool isUp(int i)
{
	double rsi,rsi1,env_up,env_low,longMa,shortMa;

	bool ret = false;

	rsi     = iRSI(NULL,PERIOD_M1,RSI_PERIOD,PRICE_CLOSE,i);
	rsi1    = iRSI(NULL,PERIOD_M1,RSI_PERIOD,PRICE_CLOSE,i + 1);
	env_up	= iEnvelopes(NULL,PERIOD_M1,60,MODE_SMA,0,PRICE_CLOSE,0.03,MODE_UPPER,i);
	env_low = iEnvelopes(NULL,PERIOD_M1,60,MODE_SMA,0,PRICE_CLOSE,0.03,MODE_LOWER,i);
	longMa  = iMA(NULL,PERIOD_M1,60,0,MODE_SMA,PRICE_CLOSE,i);
	shortMa = iMA(NULL,PERIOD_M1,3,0,MODE_SMA,PRICE_CLOSE,i);


	if(shortMa > longMa)			{ ret = true; } else{ return false;}
	if(rsi >= 70)       			{ ret = true; } else{ return false;}
	if(Close[i + 1] > shortMa)		{ ret = true; } else{ return false;}
	if(Close[i + 1] < Open[i + 1])	{ ret = true; } else{ return false;}
	if(Close[i + 1] < High[i + 2])	{ ret = true; } else{ return false;}
	if(Close[i + 1] < High[i + 3])	{ ret = true; } else{ return false;}
	if(Close[i + 1] < High[i + 4])	{ ret = true; } else{ return false;}
	if(Close[i + 1] > env_up)		{ ret = true; } else{ return false;}


	return ret;

}


//+------------------------------------------------------------------+
void showArrow(string direction,int bar_num)
{

	//printf("bar_num:%d",bar_num);
	//printf("Bars:%d",Bars);

	if(bar_num >= Bars - 10) return;

	//Print(direction);

	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;
	
	if(direction == "up")
	{
		arrow_color = clrAqua;
		arrow_type = 233;
		pos = Low[bar_num];
		anchor = ANCHOR_LOWER;


	}
	else if(direction == "down")
	{
	
		arrow_color = clrMagenta;
		arrow_type = 234;
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;

	}
	else
	{
		return;
	}

	//datetime dt = TimeCurrent();
	datetime dt = Time[bar_num];
	
	MqlDateTime mqlDt;
	TimeToStruct(dt,mqlDt);
	  
	string signal = 
		StringFormat(	"[BINARY_OPTION] %4d%02d%02d%02d%02d%02d %s %s",
						mqlDt.year,mqlDt.mon,mqlDt.day,mqlDt.hour,mqlDt.min,mqlDt.sec,
						_Symbol,direction
					);
					
	signallog(signal);
	Print(signal);

	string objName = "objArrow_" + IntegerToString(IndicatorCounted());


	ObjectCreate(0,objName, OBJ_ARROW,0,Time[bar_num],pos);
	ObjectSetInteger(0,objName, OBJPROP_ARROWCODE,arrow_type);
	ObjectSetInteger(0,objName, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);
    


}

void signallog(string signal_txt)
{

	int filehandle=FileOpen("signal.log",FILE_WRITE); 
	FileWrite(filehandle,signal_txt);
	FileFlush(filehandle);
	FileClose(filehandle); 

}
