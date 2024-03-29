//+------------------------------------------------------------------+
//|                                            AutoStdDevChannel.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                     https://fxtrading.greeds.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://fxtrading.greeds.net"
#property version   "1.00"
#property strict
#property indicator_chart_window

input int SEARCH_PERIOD1=21;
input int SEARCH_PERIOD2=67;
input double DEVIATION=1.5;
input color UPPER_LINE_COLOR = clrAqua;
input color LOWER_LINE_COLOR = clrLavenderBlush;

//string obj_name;
//string prefix;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
	
	//prefix   = IntegerToString((long)TimeLocal());
	//obj_name = prefix + "_AUTO_STDDEVCHANNEL";
	
	//CreateStdChannel();
	
	return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
	
	//ObjectsDeleteAll(0,prefix,0,OBJ_STDDEVCHANNEL);
	ObjectsDeleteAll(0,OBJ_STDDEVCHANNEL);
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

	CreateStdChannel(SEARCH_PERIOD1);
	CreateStdChannel(SEARCH_PERIOD2);
	return(rates_total);

}


void CreateStdChannel(int term)
{
	int upperIdx=iHighest(NULL,0,MODE_HIGH,term,1);
	int lowerIdx=iLowest (NULL,0,MODE_LOW ,term,1);

	//ObjectDelete(0,obj_name);
	//ObjectsDeleteAll(0,prefix,0,OBJ_STDDEVCHANNEL);
	//ObjectsDeleteAll(0,OBJ_STDDEVCHANNEL);

		
	int idx;
	int line_color;
	
	if(upperIdx > lowerIdx)
	{
		idx = upperIdx;
		line_color = LOWER_LINE_COLOR;
	}
	if(upperIdx < lowerIdx)
	{
		idx = lowerIdx;
		line_color = UPPER_LINE_COLOR;
	}

	int chart_id = 0;
	
	
	//Print(obj_name);
	
	string obj_name = "test" + IntegerToString(term);;

	ObjectDelete(0,obj_name);


	ObjectCreate(chart_id,obj_name,OBJ_STDDEVCHANNEL,0,Time[idx],0,Time[1],0);
	
	//ObjectCreate(chart_id,obj_name,OBJ_STDDEVCHANNEL,0,Time[idx],0,Time[1],0);
	//ObjectMove(obj_name,1,Time[1],0);

	ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,line_color);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_STYLE,STYLE_SOLID);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_WIDTH,1);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_BACK,false);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTABLE,true);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTED,false);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_HIDDEN,true);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_ZORDER,0);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_RAY_LEFT,false);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_RAY_RIGHT,false);
	ObjectSetInteger(chart_id,obj_name,OBJPROP_FILL,false);
	ObjectSetDouble(chart_id,obj_name,OBJPROP_DEVIATION,DEVIATION);

}
/*
bool isNewBar()
{
static datetime time=Time[0];
bool ret=false;
if(Time[0]!=time)
{
time=Time[0];
ret=true;
}
return ret;
}
*/