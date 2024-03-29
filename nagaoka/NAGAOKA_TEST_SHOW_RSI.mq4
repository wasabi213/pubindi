//+------------------------------------------------------------------+
//|																  |
//|																  |
//|										 Copyright 2019,s.nagaoka |
//|																  |
//+------------------------------------------------------------------+
/*

*/
#property copyright "Copyright 2019,s.nagaoka"
#property link	  "test"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers    1


sinput ENUM_TIMEFRAMES timeframe = PERIOD_H1;
input int InpRSIPeriod = 14;

int InpRSIPeriodBufLength = InpRSIPeriod * 2;

double H1Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function						 |
//+------------------------------------------------------------------+
int OnInit(){


    //IndicatorBuffers(1);
    //SetIndexBuffer(1,H1Buffer);
   


	ObjectsDeleteAll(0,OBJ_TEXT);

	//calcRsi();
	return(INIT_SUCCEEDED);

}
int deinit(){

	ObjectsDeleteAll(0,OBJ_TEXT);
	return(INIT_SUCCEEDED);

}

//+------------------------------------------------------------------+
//| Custom indicator iteration function							  |
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


	/*
	int pos = Bars - prev_calculated;
	
	printf("prev_calculated:%d",prev_calculated);
	printf("pos:%d",pos);
	
	for(int i = pos - 1; i >= 0;i--)
	{
	
		setH1Buffer(i);

		printf("H1Buffer[%d] :%3.3f",i,H1Buffer[i]);
	}

	*/

	double current_rsi;

	for(int i = Bars - 1; i >= 0; i--)
	{
		//double m60_rsi = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,i);
		//printf("m60_rsi:%2.1f",m60_rsi);
	
		current_rsi = getFixedRsi(i);
		showRsi(current_rsi,i);	
		//showRsi(m60_rsi,i);	


	}

	return(rates_total);
}


/**
 * 1時間足の終値の配列を作る。
 */
void setH1Buffer(int bar_num)
{

	ArrayResize(priceArray,InpRSIPeriodBufLength);
	ArrayInitialize(priceArray,0.0);
	
	int h1_bar_num = iBarShift(_Symbol,timeframe,Time[bar_num],false);
	//printf("h1_bar_num:%d",h1_bar_num);
	
	H1Buffer[bar_num] = Close[h1_bar_num];

}



double priceArray[];
void setUpperPriceArray(int bar_num)
{

	ArrayResize(priceArray,InpRSIPeriodBufLength);
	ArrayInitialize(priceArray,0.0);

	int h1_bar_num = iBarShift(_Symbol,timeframe,Time[bar_num],false);
	
	for(int j = InpRSIPeriodBufLength - 1;j >= 0;j--)
	{
		priceArray[j] = iClose(_Symbol,timeframe,h1_bar_num + j);
	}
	priceArray[0] = iClose(_Symbol,PERIOD_CURRENT,bar_num);


	/*
	for(int k = 0;k < ArraySize(priceArray);k++)
	{
		printf("priceArray[%d]:%3.3f",k,priceArray[k]);
	
	}

	*/

}




double getFixedRsi(int bar_num)
{

	double upperTimeFramePrice[];
	double extPosBuffer[];
	double extNegBuffer[];
	double extRSIBuffer[];

	ArrayResize(extPosBuffer,InpRSIPeriodBufLength);
	ArrayResize(extNegBuffer,InpRSIPeriodBufLength);
	ArrayResize(extRSIBuffer,InpRSIPeriodBufLength);

	ArrayInitialize(extPosBuffer,0.0);
	ArrayInitialize(extNegBuffer,0.0);
	ArrayInitialize(extRSIBuffer,0.0);

	setUpperPriceArray(bar_num);

	double posDiff = 0.0;
	double negDiff = 0.0;	
	
	
	
	//for(int i = InpRSIPeriod - 1; i >= 0; i--)
	for(int i = ArraySize(priceArray) - 2; i >= 0; i--)
	{
	
		//printf("priceArray[13]:%3.5f",priceArray[13]);
	
		double 	diff = priceArray[i] - priceArray[i + 1];
		
		if(diff > 0.0)
		{
			posDiff = diff;
		}
		else
		{
			posDiff = 0.0;
		}

		if(diff < 0.0)
		{
			negDiff = -diff;
		}
		else
		{
			negDiff = 0.0;
		}

	
		extPosBuffer[i] = ( extPosBuffer[i + 1] * (InpRSIPeriod - 1) + posDiff) / InpRSIPeriod;
		extNegBuffer[i] = ( extNegBuffer[i + 1] * (InpRSIPeriod - 1) + negDiff) / InpRSIPeriod;

	}

	//printf("extPosBuffer[%d]:%3.8f",i,extPosBuffer[i]);
	//printf("extNegBuffer[%d]:%3.8f",i,extNegBuffer[i]);
	
	/*
	double posRsi = posDiff / InpRSIPeriod;
	double negRsi = negDiff / InpRSIPeriod;

	return 100.0 - 100.0 / (1 +  posRsi / negRsi);

	*/

	for(int i = InpRSIPeriod; i >= 0;i--)
	{	

		//printf("extPosBuffer[%d]:%3.8f",i,extPosBuffer[i]);
		//printf("extNegBuffer[%d]:%3.8f",i,extNegBuffer[i]);

		if(extNegBuffer[i] != 0.0)
		{
			//printf("extPosBuffer:%3.8f",extPosBuffer[i]);
			//printf("extNegBuffer:%3.8f",extNegBuffer[i]);

			extRSIBuffer[i] = 100.0 - 100.0 / (1 + extPosBuffer[i] / extNegBuffer[i]);
            //ExtRSIBuffer[i] = 100.0 - 100.0 / (1 + ExtPosBuffer[i] / ExtNegBuffer[i]);
			//printf("extRSIBuffer:%3.8f",extRSIBuffer[i]);
		}
		else
		{
			if(extPosBuffer[i]!=0.0)
			{
				extRSIBuffer[i]=100.0;
			}
			else
			{
				extRSIBuffer[i]=50.0;
			}
		}


	}
	//printf("extRSIBuffer[%d]:%3.3f",0,extRSIBuffer[0]);
		
	return extRSIBuffer[0];

	

}

void showRsi(double current_rsi,int num)
{

	int wk = current_rsi / 100 * 100;
	
	//string current_rsi_txt = IntegerToString((int)MathFloor(current_rsi),0);
	string current_rsi_txt = IntegerToString(wk);
	string objCurrentRsi = "rsi_" + IntegerToString(num);

	double fix_pos = 2;
	int font_size = 9;	
	int font_color = clrSilver;

	if(num % 2 == 0)
	{
		fix_pos = 3;
		font_color = clrWhite;		
	}

	double pos = 0.0;
	if(current_rsi >= 50)
	{
		pos = High[num] + Point() * 65 * fix_pos;
	}
	else
	{
		pos = Low[num] - Point() * 65 * fix_pos;
	}
	
	if(current_rsi > 60)
	{
		font_color = clrLime;
	}
	else if(current_rsi < 41)
	{
		font_color = clrMagenta;
	}
	else
	{
		font_color = clrSilver;
	}

	ObjectCreate(0,objCurrentRsi, OBJ_TEXT,0,Time[num],pos);
    ObjectSetInteger(0,objCurrentRsi,OBJPROP_COLOR,font_color);
    ObjectSetInteger(0,objCurrentRsi,OBJPROP_FONTSIZE,font_size);
    ObjectSetString(0,objCurrentRsi,OBJPROP_TEXT,current_rsi_txt);
    ObjectSetString(0,objCurrentRsi,OBJPROP_FONT,"Arial");
    ObjectSetInteger(0,objCurrentRsi,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objCurrentRsi,OBJPROP_ANCHOR,ANCHOR_LOWER);
 

}
