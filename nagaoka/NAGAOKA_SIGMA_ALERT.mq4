//+------------------------------------------------------------------+
//|																  |
//|																  |
//|										 Copyright 2016,s.nagaoka |
//|																  |
//+------------------------------------------------------------------+
/*

*/
#property copyright "Copyright 2016,s.nagaoka"
#property link	  "test"
#property version   "1.00"
#property strict


input int BANDS_PERIOD = 20; //ボリンジャーバンド期間

#define STDEV1 1.0
#define STDEV2 2.0

#define SIGMA1 1
#define SIGMA2 2
#define MINUS_SIGMA1 -1
#define MINUS_SIGMA2 -2
#define NO_SIGMA 0

input int BASE_HEIGHT = 10; //縦位置

//+------------------------------------------------------------------+
//| Custom indicator initialization function						 |
//+------------------------------------------------------------------+
int OnInit(){

	ObjectDelete("OBJ_M5");
	ObjectDelete("OBJ_M15");
	ObjectDelete("OBJ_H1");
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

	int m5_sigma  = getBands(PERIOD_M5);
	int m15_sigma = getBands(PERIOD_M15);
	int h1_sigma  = getBands(PERIOD_H1);
	
	
	ObjectDelete("OBJ_M5");
	ObjectDelete("OBJ_M15");
	ObjectDelete("OBJ_H1");
	
	showBandsPos(m5_sigma,PERIOD_M5);
	showBandsPos(m15_sigma,PERIOD_M15);
	showBandsPos(h1_sigma,PERIOD_H1);

	return(rates_total);
}

void showBandsPos(int pos,int period)
{

	string objName;

	if(period == PERIOD_M5)
	{
		objName = "OBJ_M5";
	}
	else if(period == PERIOD_M15)
	{
		objName = "OBJ_M15";
	}
	else if(period == PERIOD_H1)
	{
		objName = "OBJ_H1";
	}
	else
	{
		return;
	}

	ObjectDelete(objName);

	int font_color;
	string text;
	
	if(pos == SIGMA1)
	{
		font_color = clrLime;
		text = "+1";
	}
	else if(pos == SIGMA2)
	{
		font_color = clrLime;
		text = "+2";
	}
	else if(pos == MINUS_SIGMA1)
	{
		font_color = clrRed;
		text = "-1";
	}
	else if(pos == MINUS_SIGMA2)
	{
		font_color == clrRed;
		text = "-2";
	}
	else
	{
		return;
	}
	
	int x_pos = 150;
	int y_pos;

	if(period == PERIOD_M5)
	{
		y_pos = 28;
	}
	else if(period == PERIOD_M15)
	{
		y_pos = 15;
	}
	else if(period == PERIOD_H1)
	{
		y_pos = 2;
	}
	else
	{
		return;
	}

	string font = "Arial Black";

	y_pos += BASE_HEIGHT;

	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, text, 9, font, font_color);
	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);


	return;
}


int getBands(int time_frame)
{
	int ret;
	int dev1 = 1.0;
	int dev2 = 2.0;

	double sigma1 = iBands(NULL,time_frame,BANDS_PERIOD,dev1,0,PRICE_CLOSE,MODE_UPPER,0);
	double sigma2 = iBands(NULL,time_frame,BANDS_PERIOD,dev2,0,PRICE_CLOSE,MODE_UPPER,0);
	double minus_sigma1 = iBands(NULL,time_frame,BANDS_PERIOD,dev1,0,PRICE_CLOSE,MODE_LOWER,0);
	double minus_sigma2 = iBands(NULL,time_frame,BANDS_PERIOD,dev2,0,PRICE_CLOSE,MODE_LOWER,0);

	if(Close[0] >= sigma2)
	{
		ret = SIGMA2;
	}
	else if(Close[0] >= sigma1)
	{
		ret = SIGMA1;
	}
	else if(Close[0] <= minus_sigma2)
	{
		ret = MINUS_SIGMA2;
	}
	else if(Close[0] <= minus_sigma1)
	{
		ret = MINUS_SIGMA1;
	}
	else
	{
		ret = NO_SIGMA;
	}

	
	return ret;
}