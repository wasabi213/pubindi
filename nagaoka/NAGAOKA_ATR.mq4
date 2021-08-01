//+------------------------------------------------------------------+
//|                                                          ATR.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Average True Range"
#property strict

//--- indicator settings
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_color3  Orange
#property indicator_color4  Lime
#property indicator_color5  Aqua
#property indicator_color6  Green
#property indicator_color7  White
#property indicator_color8  Magenta

//--- input parameter
input int InpAtrPeriod=14; // ATR Period
//--- buffers
double ExtATRBuffer[];
double ExtTRBuffer[];
double ExtHighTRBuffer[];
double ExtLowTRBuffer[];
double ExtHighATRBuffer[];
double ExtLowATRBuffer[];
double ExtTRHistgramBuffer[];
double MA[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 1 additional buffer used for counting.
   IndicatorBuffers(8);
   IndicatorDigits(Digits);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(0,ExtATRBuffer);
   SetIndexBuffer(1,ExtTRBuffer);
   SetIndexBuffer(2,ExtHighTRBuffer);
   SetIndexBuffer(3,ExtLowTRBuffer);
   SetIndexBuffer(4,ExtHighATRBuffer);
   SetIndexBuffer(5,ExtLowATRBuffer);
   SetIndexBuffer(6,ExtTRHistgramBuffer);
   SetIndexBuffer(7,MA);


//--- name for DataWindow and indicator subwindow label
   short_name="ATR("+IntegerToString(InpAtrPeriod)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//--- check for input parameter
   if(InpAtrPeriod<=0)
     {
      Print("Wrong input parameter ATR Period=",InpAtrPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpAtrPeriod);
   SetIndexDrawBegin(1,InpAtrPeriod);
   SetIndexDrawBegin(2,InpAtrPeriod);
   SetIndexDrawBegin(3,InpAtrPeriod);
   SetIndexDrawBegin(4,InpAtrPeriod);
   SetIndexDrawBegin(5,InpAtrPeriod);
   SetIndexDrawBegin(6,InpAtrPeriod);
   SetIndexDrawBegin(7,InpAtrPeriod);
   SetIndexDrawBegin(8,InpAtrPeriod);
  //SetIndexDrawBegin(5,InpAtrPeriod);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
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
   int i,limit;
//--- check for bars count and input parameter
   if(rates_total<=InpAtrPeriod || InpAtrPeriod<=0)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtATRBuffer,false);
   ArraySetAsSeries(ExtTRBuffer,false);
   ArraySetAsSeries(ExtHighTRBuffer,false);
   ArraySetAsSeries(ExtLowTRBuffer,false);
   ArraySetAsSeries(ExtHighATRBuffer,false);
   ArraySetAsSeries(ExtLowATRBuffer,false);
   ArraySetAsSeries(ExtTRHistgramBuffer,false);
   ArraySetAsSeries(MA,false);

   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      ExtHighTRBuffer[0]=0.0;
      ExtLowTRBuffer[0]=0.0;
      ExtHighATRBuffer[0]=0.0;
      ExtLowTRBuffer[0]=0.0;
      ExtLowATRBuffer[0]=0.0;
      ExtTRHistgramBuffer[0]=0.0;
      MA[0]=0.0;


      //--- filling out the array of True Range values for each period
      for(i=1; i<rates_total; i++)

          //Print(i);
          //Print(close[i-1]);
		  ExtTRBuffer[i]     = MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);




      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1; i<=InpAtrPeriod; i++)
        {
         ExtATRBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=InpAtrPeriod;
      ExtATRBuffer[InpAtrPeriod]=firstValue;
      limit=InpAtrPeriod+1;
     }
   else
      limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit; i<rates_total; i++)
     {
      ExtTRBuffer[i] = MathMax(high[i],close[i-1]) - MathMin(low[i],close[i-1]);
      //ExtHighTRBuffer[i] = MathMax(high[i],close[i-1]);
	  //ExtLowTRBuffer[i]  = MathMin(low[i],close[i-1]);
      
      ExtATRBuffer[i] = ExtATRBuffer[i-1] + (ExtTRBuffer[i] - ExtTRBuffer[i - InpAtrPeriod]) / InpAtrPeriod;
      //MA[i] = 
      //ExtHighATRBuffer[i] = MA[i] + ExtATRBuffer[i];
      //ExtLowATRBuffer[i]  = MA[i] - ExtATRBuffer[i];

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
