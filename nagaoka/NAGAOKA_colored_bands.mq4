//+------------------------------------------------------------------+
//|                                                        Bands.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Bollinger Bands"
#property strict

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 6

//#property indicator_color1 White
//#property indicator_color2 White //Upper UP
//#property indicator_color3 White //Upper LOW
//#property indicator_color4 White //Lower UP
//#property indicator_color5 White //Lower LOW
//#property indicator_color6 White //Lower LOW
//#property indicator_color7 White //Lower LOW


//#property indicator_width3 3
//#property indicator_width4 1
//#property indicator_width6 1
//#property indicator_width7 3

//--- indicator parameters
input int    InpBandsPeriod=20;      // Bands Period
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=2.0; // Bands Deviations

//--- buffers
double ExtMovingBuffer[];
double ExtUpperBuffer[];
double ExtUpperUpBuffer[];
double ExtLowerBuffer[];
double ExtLowerLowBuffer[];



double ExtStdDevBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- 1 additional buffer used for counting.
   IndicatorBuffers(6);
   IndicatorDigits(Digits);
//--- middle line
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrWhite);
   SetIndexBuffer(0,ExtMovingBuffer);
   SetIndexShift(0,InpBandsShift);
   SetIndexLabel(0,"Bands SMA");

//--- upper band
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrDarkOrange);
   SetIndexBuffer(1,ExtUpperBuffer);
   SetIndexShift(1,InpBandsShift);
   SetIndexLabel(1,"Bands Upper");

//--- upper up band
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,3,clrRoyalBlue);
   SetIndexBuffer(2,ExtUpperUpBuffer);
   SetIndexShift(2,InpBandsShift);
   SetIndexLabel(2,"Bands Upper");
   

//--- lower band
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,clrDarkOrange);
   SetIndexBuffer(3,ExtLowerBuffer);
   SetIndexShift(3,InpBandsShift);
   SetIndexLabel(3,"Bands Lower");


//--- lower low band
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,3,clrRoyalBlue);
   SetIndexBuffer(4,ExtLowerLowBuffer);
   SetIndexShift(4,InpBandsShift);
   SetIndexLabel(4,"Bands Lower");

//--- work buffer
   SetIndexBuffer(5,ExtStdDevBuffer);
//--- check for input parameter
   if(InpBandsPeriod<=0)
     {
      Print("Wrong input parameter Bands Period=",InpBandsPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(1,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(2,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(3,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(4,InpBandsPeriod+InpBandsShift);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
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
   int i,pos;
//---
   if(rates_total<=InpBandsPeriod || InpBandsPeriod<=0)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtMovingBuffer,false);
   ArraySetAsSeries(ExtUpperBuffer,false);
   ArraySetAsSeries(ExtUpperUpBuffer,false);
   ArraySetAsSeries(ExtLowerBuffer,false);
   ArraySetAsSeries(ExtLowerLowBuffer,false);
   ArraySetAsSeries(ExtStdDevBuffer,false);
   ArraySetAsSeries(close,false);


//--- initial zero
   if(prev_calculated<1)
     {
      for(i=0; i<InpBandsPeriod; i++)
        {
         ExtMovingBuffer[i]=EMPTY_VALUE;
         ExtUpperBuffer[i]=EMPTY_VALUE;
         ExtUpperUpBuffer[i]=EMPTY_VALUE;
         ExtLowerBuffer[i]=EMPTY_VALUE;
         ExtLowerLowBuffer[i]=EMPTY_VALUE;
        }
     }
//--- starting calculation
   if(prev_calculated>1)
      pos=prev_calculated-1;
   else
      pos=0;
//--- main cycle

   //printf("rates_total:%d",rates_total);

   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      if(i>=Bars-1) return(rates_total);
      if(i==0) continue;
     
      //--- middle line
      ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,close);
      //--- calculate and write down StdDev
      ExtStdDevBuffer[i]=StdDev_Func(i,close,ExtMovingBuffer,InpBandsPeriod);
      //--- upper line
      ExtUpperBuffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*ExtStdDevBuffer[i];

	 //printf("i:%d",i);

	  if(ExtUpperBuffer[i] > ExtUpperBuffer[i-1])
	  {
          ExtUpperUpBuffer[i]  = ExtUpperBuffer[i];
	  }
	  else
      {
		  ExtUpperUpBuffer[i]  = EMPTY_VALUE;
	  }
	
      //--- lower line
      ExtLowerBuffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*ExtStdDevBuffer[i];
	  if(ExtLowerBuffer[i] <= ExtLowerBuffer[i-1])
	  {
          ExtLowerLowBuffer[i] = ExtLowerBuffer[i];
	  }
	  else
      {
          ExtLowerLowBuffer[i] = EMPTY_VALUE;
	  }


      //---
     }
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }






//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position>=period)
     {
      //--- calcualte StdDev
      for(int i=0; i<period; i++)
         StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
      StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
     }
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
