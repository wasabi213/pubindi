//+------------------------------------------------------------------+
//|                                                 NAGAOKA_ATR2.mq4 |
//|                                          Copyright 2017, Nagaoka |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Nagaoka"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

//#property indicator_separate_window
#property indicator_buffers 8
//--- input parameter
input int ATR_PERIOD = 40; // ATR Period
input int MA_PERIOD = 40; // MA Period

//--- buffers

double HighATR[];
double LowATR[];
double ExtHighTRBuffer[];
double ExtLowTRBuffer[];
double MA[];



double ExtATRBuffer[];
double ExtTRBuffer[];
double ExtHighATRBuffer[];
double ExtLowATRBuffer[];
double ExtTRHistgramBuffer[];
double AtrMA[];








//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  	ObjectsDeleteAll();

  
//--- indicator buffers mapping
   //--- 1 additional buffer used for counting.
   IndicatorBuffers(4);
   IndicatorDigits(Digits);
//--- indicator line

   SetIndexStyle(0,DRAW_LINE,0,1,clrRed);
   SetIndexBuffer(0,ExtHighTRBuffer);

   SetIndexStyle(1,DRAW_LINE,0,1,clrAliceBlue);
   SetIndexBuffer(1,ExtLowTRBuffer);

   //SetIndexStyle(2,DRAW_LINE,0,1,clrViolet);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,5,clrViolet);
   SetIndexBuffer(2,HighATR);

   //SetIndexStyle(3,DRAW_LINE,0,1,clrAliceBlue);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,5,clrViolet);
   SetIndexBuffer(3,LowATR);

   SetIndexEmptyValue(0,0);              
   SetIndexEmptyValue(1,0);              
   SetIndexEmptyValue(2,0);              
   SetIndexEmptyValue(3,0);              
   SetIndexEmptyValue(4,0);              


   //SetIndexStyle(4,DRAW_LINE,0,0,clrMagenta);
   //SetIndexBuffer(4,MA);

/*
   SetIndexStyle(0,DRAW_LINE,0,0,clrMagenta);
   //SetIndexStyle(1,DRAW_LINE,0,2,clrAqua);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,5,clrViolet);
   SetIndexStyle(2,DRAW_LINE,0,2,clrOrange);
   //SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,5,clrViolet);
   SetIndexStyle(3,DRAW_LINE,0,2,clrMagenta);
   SetIndexStyle(4,DRAW_LINE,0,2,clrMagenta);
   SetIndexStyle(5,DRAW_LINE,0,2,clrMagenta);
   SetIndexStyle(6,DRAW_LINE,0,2,clrMagenta);
   SetIndexStyle(7,DRAW_LINE,0,2,clrMagenta);
   SetIndexBuffer(0,AtrMA);
   SetIndexBuffer(1,ExtHighATRBuffer);
   SetIndexBuffer(2,ExtLowATRBuffer);
   SetIndexBuffer(3,MA);
   SetIndexBuffer(4,ExtHighTRBuffer);
   SetIndexBuffer(5,ExtLowTRBuffer);
*/



   //SetIndexBuffer(7,ExtATRBuffer);
   //SetIndexBuffer(1,ExtTRBuffer);
   //SetIndexBuffer(3,ExtLowTRBuffer);
   //SetIndexBuffer(5,ExtLowATRBuffer);
   //SetIndexBuffer(6,ExtTRHistgramBuffer);

   ChartRedraw(0);
   //---
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
//---
   
	int limit = rates_total - prev_calculated;
	if( limit == Bars )limit--;

	for( int i = limit; i >= 0; i-- )
	{
		//MA[i] =iMA( NULL, 0, MA_PERIOD, 0, MODE_SMA, PRICE_CLOSE, i );
		//AtrMA[i] =iMA( NULL, 0, ATR_PERIOD, 0, MODE_SMA, PRICE_CLOSE, i );
		//ExtHighATRBuffer[i] = AtrMA[i] + iATR(NULL,0,ATR_PERIOD,i);
		//ExtLowATRBuffer[i]  = AtrMA[i] - iATR(NULL,0,ATR_PERIOD,i);
		if(i > 0){
	        ExtHighTRBuffer[i]  = MathMax(high[i],close[i-1]);
	        ExtLowTRBuffer[i]   = MathMin(low[i],close[i-1]);
		}else
		{
	        ExtHighTRBuffer[i]  = high[i];
	        ExtLowTRBuffer[i]   = low[i];
		
		}


		HighATR[i] = HighAverage(ATR_PERIOD,i,ExtHighTRBuffer);
		LowATR[i] = LowAverage(ATR_PERIOD,i,ExtLowTRBuffer);

		//HighATR[i] = HighAverage(ATR_PERIOD,i);
		//LowATR[i] = LowAverage(ATR_PERIOD,i);
		
		//HighATR[i] = high[i];
		//LowATR[i] = low[i];
		
		//Print(HighATR[i]);
	}
//--- return value of prev_calculated for next call

   ChartRedraw(0);

   return(rates_total);
  }
//+------------------------------------------------------------------+
double HighAverage(int count,int index, double &buf[])
{

	if(Bars < count){
		return 0.0;
	}

	if(index + count >= Bars){
		return 0.0;
	}
	//Print(index);
	//Print(count);

	double wk = 0.0;

		
	for(int i = 0; i < count; i++,index++)
	{
		wk += buf[index];
	}
	//Print("index:" + index);
	//Print(wk/count);
	return wk / count; 

}
double LowAverage(int count,int index,double &buf[])
{

	if(Bars < count){
		return 0.0;
	}

	if(index + count >= Bars){
		return 0.0;
	}
	//Print(index);
	//Print(count);

	double wk = 0.0;

		
	for(int i = 0; i < count; i++,index++)
	{
		wk = wk + buf[index];
	}
	//Print("index:" + index);
	//Print(wk/count);
	return wk / count; 

}