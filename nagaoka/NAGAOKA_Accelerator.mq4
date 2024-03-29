//+------------------------------------------------------------------+
//|                                                  Accelerator.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Accelerator/Decelerator"
#property strict

//#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Black
#property  indicator_color2  Lime
#property  indicator_color3  Red
//--- indicator buffers
double     ExtACBuffer[];
double     ExtUpBuffer[];
double     ExtDnBuffer[];
double     ExtMacdBuffer[];
double     ExtSignalBuffer[];
double     Don[];

//---
#define PERIOD_FAST  5
#define PERIOD_SLOW 34
//--- bars minimum for calculation
#define DATA_LIMIT  38


#define UP 1
#define DOWN 2

int DIRECTION = UP;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
{

	ObjectsDeleteAll(0,0,OBJ_ARROW);

	IndicatorShortName("NAGAOKA_AC");

	//--- 2 additional buffers are used for counting.
	IndicatorBuffers(6);

	//--- drawing settings
	SetIndexStyle(0,DRAW_NONE);
	SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
	SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);

	IndicatorDigits(Digits+2);
	SetIndexDrawBegin(0,DATA_LIMIT);
	SetIndexDrawBegin(1,DATA_LIMIT);
	SetIndexDrawBegin(2,DATA_LIMIT);

	//--- all indicator buffers mapping
	SetIndexBuffer(0,ExtACBuffer);
	SetIndexBuffer(1,ExtUpBuffer);
	SetIndexBuffer(2,ExtDnBuffer);
	SetIndexBuffer(3,ExtMacdBuffer);
	SetIndexBuffer(4,ExtSignalBuffer);
	SetIndexBuffer(5,Don);

	//--- name for DataWindow and indicator subwindow label
	SetIndexLabel(1,NULL);
	SetIndexLabel(2,NULL);
	
	
}
//+------------------------------------------------------------------+
//| Accelerator/Decelerator Oscillator                               |
//+------------------------------------------------------------------+
int OnCalculate (	const int rates_total,
					const int prev_calculated,
					const datetime& time[],
					const double& open[],
					const double& high[],
					const double& low[],
					const double& close[],
					const long& tick_volume[],
					const long& volume[],
					const int& spread[])
{
	int    i,limit;
	double prev=0.0,current;

	//--- check for rates total
	if(rates_total<=DATA_LIMIT)
		return(0);

	//--- last counted bar will be recounted
	limit=rates_total-prev_calculated;

	if(prev_calculated>0)
	{
		limit++;
		prev=ExtMacdBuffer[limit]-ExtSignalBuffer[limit];
	}

	//--- macd counted in the 1-st additional buffer
	for(i=0; i<limit; i++)
	{
		ExtMacdBuffer[i] = iMA(NULL,0,PERIOD_FAST,0,MODE_SMA,PRICE_MEDIAN,i) - iMA(NULL,0,PERIOD_SLOW,0,MODE_SMA,PRICE_MEDIAN,i);
	}
	
	//--- signal line counted in the 2-nd additional buffer
	SimpleMAOnBuffer(rates_total,prev_calculated,0,5,ExtMacdBuffer,ExtSignalBuffer);

	//--- dispatch values between 2 buffers
	bool up=true;
	for(i=limit-1; i>=0;)
	{
	
		current=ExtMacdBuffer[i]-ExtSignalBuffer[i];

		if(current>prev)
			up=true;

		if(current<prev)
			up=false;

		if(!up)//下落時
		{
			ExtUpBuffer[i]=0.0;
			ExtDnBuffer[i]=current;
			Don[i] = current;
		}
		else //上昇時
		{
			ExtUpBuffer[i]=current;
			ExtDnBuffer[i]=0.0;
			Don[i] = current;

		}

		//矢印の表示
		if(i < Bars - 3 )
		{

			if(Don[i+1] < Don[i+2] && Don[i+2] < Don[i+3] && Don[i+3] < Don[i+4])
			{
				if(Don[i+3] < 0.0 && Don[i+4] > 0.0)
				{
					showArrow(i+2,DOWN);
				}
			}

			else if(Don[i+1] > Don[i+2] && Don[i+2] > Don[i+3] && Don[i+3] > Don[i+4])
			{
				if(Don[i+3] > 0.0 && Don[i+4] < 0.0)
				{
					showArrow(i+2,UP);
				}
			}


			
		}


		ExtACBuffer[i]=current;
		i--;
		prev=ExtMacdBuffer[i+1]-ExtSignalBuffer[i+1];
		
	}

	//--- done
	return(rates_total);
}
//+------------------------------------------------------------------+
void showArrow(int bar_num,int direction)
{

	int arrow_color = clrSilver;
	int arrow_type;
	double pos;
	int anchor;
	string objName = "arrow_" + IntegerToString(bar_num);

	if(direction == UP)
	{
		arrow_type = 233;
		pos = Low[bar_num];
		anchor = ANCHOR_TOP;	
	
	}
	else if(direction == DOWN)
	{
		arrow_type = 234;
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	
	}
	else
	{
		return;
	}
	

	ObjectCreate(0,objName, OBJ_ARROW,0,Time[bar_num],pos);
	ObjectSetInteger(0,objName, OBJPROP_ARROWCODE,arrow_type);
	ObjectSetInteger(0,objName, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);


}

int SimpleMAOnBuffer(const int rates_total,const int prev_calculated,const int begin,
                     const int period,const double& price[],double& buffer[])
  {
   int i,limit;
//--- check for data
   if(period<=1 || rates_total-begin<period) return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);
   if(as_series_price)  ArraySetAsSeries(price,false);
   if(as_series_buffer) ArraySetAsSeries(buffer,false);
//--- first calculation or number of bars was changed
   if(prev_calculated==0) // first calculation
     {
      limit=period+begin;
      //--- set empty value for first bars
      for(i=0;i<limit-1;i++) buffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=period;
      buffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total;i++)
      buffer[i]=buffer[i-1]+(price[i]-price[i-period])/period;
//--- restore as_series flags
   if(as_series_price)  ArraySetAsSeries(price,true);
   if(as_series_buffer) ArraySetAsSeries(buffer,true);
//---
    return(rates_total);
  }