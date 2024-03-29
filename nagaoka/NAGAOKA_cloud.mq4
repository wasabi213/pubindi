//+------------------------------------------------------------------+
//|                                               chikouspan_kai.mq4 |
//|                                         Copyright 2015,s.nagaoka |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015,s.nagaoka"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

//#property indicator_buffers 1
#property indicator_color1 White
#property indicator_color2 White
#property indicator_color3 White
#property indicator_color4 White
#property indicator_color5 White
#property indicator_color6 White
#property indicator_color7 White
#property indicator_color8 White
//#property indicator_color9 White


//--- input parameters
//input int MAPeriod = 65;

double MaBuf[];
double ShortMABuf[];
double LongMABuf[];

double WkBuf[];
double Wk2Buf[];
double Wk3Buf[];
double Wk4Buf[];
double Wk5Buf[];
//double Wk6Buf[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(8);
   IndicatorDigits(Digits);

//--- middle line
   SetIndexStyle(0, DRAW_LINE , STYLE_SOLID , 1 , clrAqua);
   SetIndexBuffer(0,MaBuf);
   SetIndexLabel(0,"Bands SMA");

   SetIndexStyle(1, DRAW_LINE , STYLE_SOLID , 1 , clrLime);
   SetIndexBuffer(1,ShortMABuf);
   SetIndexLabel(1,"Bands SMA");

   SetIndexStyle(2, DRAW_LINE , STYLE_SOLID , 1 , clrBlack);
   SetIndexBuffer(2,LongMABuf);
   SetIndexLabel(2,"Bands SMA");


   SetIndexStyle(3, DRAW_LINE , STYLE_SOLID , 1 , clrBlack);
   SetIndexBuffer(3,WkBuf);
   SetIndexLabel(3,"Bands SMA");

   SetIndexStyle(4, DRAW_LINE , STYLE_SOLID , 1 , clrWhite);
   SetIndexBuffer(4,Wk2Buf);
   SetIndexLabel(4,"Bands SMA");

   SetIndexStyle(5, DRAW_LINE , STYLE_SOLID , 1 , clrGreen);
   SetIndexBuffer(5,Wk3Buf);
   SetIndexLabel(5,"Bands SMA");

   SetIndexStyle(6, DRAW_LINE , STYLE_SOLID , 1 , clrBlack);
   SetIndexBuffer(6,Wk4Buf);
   SetIndexLabel(6,"Bands SMA");

   SetIndexStyle(7, DRAW_LINE , STYLE_SOLID , 1 , clrRed);
   SetIndexBuffer(7,Wk5Buf);
   SetIndexLabel(7,"Bands SMA");

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

	//int MAPeriod      = 75; //変更しない
	//int ShortMAPeriod = 10;
	//int LongMAPeriod  = 200; 

	int MAPeriod      = 75; 
	int ShortMAPeriod = 14;
	int LongMAPeriod  = 100; //変更しない
	//int LongMAPeriod  = 75; //変更しない



	int limit = rates_total - prev_calculated;
	
	 
	for(int i = 0; i < limit; i++)
	{

		if( i > Bars - 100) break; 

	 
		MaBuf[i]      = iMA(_Symbol, 0 , MAPeriod,      0, MODE_EMA, PRICE_CLOSE, i); //Aqua
		ShortMABuf[i] = iMA(_Symbol, 0 , ShortMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i); //Yellow
		LongMABuf[i]  = iMA(_Symbol, 0 , LongMAPeriod,  0, MODE_EMA, PRICE_CLOSE, i); //Blue
	 

	 
	}

	int avg_val = 10;

	for(int i = 0; i < limit; i++)
	{

		if( i > Bars - 100) break; 
		double calcWk = 0.0;
		
		for(int j = i; j < i + avg_val; j++)
		{
			//Print(Bars +":"+j);
			calcWk += ShortMABuf[j];	
		
		}

		
		Wk4Buf[i] = calcWk / avg_val;  //短期の平均 Lime
	}

	//avg_val = 50;
	for(int i = 0; i < limit; i++)
	{

		if( i > Bars - 100) break; 
		double calcWk = 0.0;
		
		for(int j = i; j < i + avg_val; j++)
		{
			//Print(Bars +":"+j);
			calcWk +=MaBuf[j];	
		
		}

		
		//Wk5Buf[i] = calcWk / avg_val;  //中期の平均 Lime
	}






/*
	for(int i = 0; i < limit; i++)
	{

		if( i > Bars - 100) break; 
		//double calcWk = 0.0;
		
		for(int j = i; j < i + avg_val; j++)
		{
			//Print(Bars+":"+j);
			Wk5Buf[j] = MaBuf[j] + (Wk2Buf[j] - Wk4Buf[j]);	 //短期の平均　‐　長期の平均 赤い線
			//Print(Wk5Buf[j]);
		}

		
	}
*/







   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double calcAvg(int start_count,int num)
{

	double wk = 0.0;
	
	for(int i = start_count;i <= start_count + num; i++)
	{
		wk += WkBuf[i];
		
		Print(WkBuf[i]);
	}

	//Print(wk);

	return wk / num;
}


