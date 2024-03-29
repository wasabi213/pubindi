//+------------------------------------------------------------------+
//|                                                           |
//|                    |
//|                                             |
//+------------------------------------------------------------------+
#property copyright   ""
#property link        ""
#property description "Biary Option"
#property strict

#property indicator_chart_window



//--- input parameters
input int RSI_PERIOD = 5; // RSI Period

int last_minute = 0;

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


    //Print(Time[0]);
    
    
    MqlDateTime mdt;
    TimeToStruct(Time[0],mdt);
    //Print(mdt.min);
    
    
    if(last_minute >= mdt.min)
    {
   		//return(rates_total);
	}
	last_minute = mdt.min;    

	//Print("test");

		//売りエントリの場合
	if(	isUp() == true)
	{
		showArrow("down");
	}
	//else if(shortMa < longMa && rsi <= 30.0 && Close[i + 1] < shortMa && Close[i + 1] > Open[i + 1])
	//{
		//showArrow("up",i);		
	//}
		

	return(rates_total);
}
bool isUp()
{
	//Print("test");

	double rsi,rsi1,env_up,env_low,longMa,shortMa;

	bool ret = false;
	
	double pip = 0;
	
	if(_Digits == 5)
	{
		pip = 0.0001;
	}
	else if(_Digits == 3)
	{
		pip = 0.01;
	}
	

	rsi     = iRSI(NULL,PERIOD_M1,RSI_PERIOD,PRICE_CLOSE,1);
	rsi1    = iRSI(NULL,PERIOD_M1,RSI_PERIOD,PRICE_CLOSE,2);
	env_up	= iEnvelopes(NULL,PERIOD_M1,60,MODE_SMA,0,PRICE_CLOSE,0.03,MODE_UPPER,1);
	env_low = iEnvelopes(NULL,PERIOD_M1,60,MODE_SMA,0,PRICE_CLOSE,0.03,MODE_LOWER,1);
	longMa  = iMA(NULL,PERIOD_M1,60,0,MODE_SMA,PRICE_CLOSE,1);
	shortMa = iMA(NULL,PERIOD_M1,3,0,MODE_SMA,PRICE_CLOSE,1);

	/*
	ここは基本
	if(shortMa > longMa)	{ ret = true; } else{ return false;}
	if(rsi >= 70)       	{ ret = true; } else{ return false;}
	if(Close[1] > shortMa)	{ ret = true; } else{ return false;}
	if(Open[1]  > Close[1])	{ ret = true; } else{ return false;}	//陰線
	*/
	//if(Close[1] > High[2])	{ ret = true; } else{ return false;}
	//if(Close[1] > High[3])	{ ret = true; } else{ return false;}
	//if(Close[1] > High[4])	{ ret = true; } else{ return false;}
	//if(Close[1] > env_up)	{ ret = true; } else{ return false;}

	if(shortMa > longMa)	{ ret = true; } else{ return false;}
	if(rsi1 >= 70)       	{ ret = true; } else{ return false;}
	if(Close[1] > shortMa)	{ ret = true; } else{ return false;}
	if(Open[1]  > Close[1])	{ ret = true; } else{ return false;}	//陰線
	if(Low[1] > shortMa + pip * 1)	{ ret = true; } else{ return false;}	//陰線

	

	return ret;

}


//+------------------------------------------------------------------+
void showArrow(string direction)
{
	Alert("signal");

	//printf("bar_num:%d",bar_num);
	//printf("Bars:%d",Bars);

	//if(bar_num >= Bars - 10) return;

	//Print(direction);

	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;
	
	if(direction == "up")
	{
		arrow_color = clrAqua;
		arrow_type = 233;
		pos = Low[0];
		anchor = ANCHOR_LOWER;


	}
	else if(direction == "down")
	{
	
		arrow_color = clrMagenta;
		arrow_type = 234;
		pos = High[0];
		anchor = ANCHOR_BOTTOM;

	}
	else
	{
		return;
	}

	//datetime dt = TimeCurrent();
	datetime dt = Time[1];
	
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


	ObjectCreate(0,objName, OBJ_ARROW,0,Time[0],pos);
	//ObjectCreate(0,objName, OBJ_ARROW,0,Time[0],pos);
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
