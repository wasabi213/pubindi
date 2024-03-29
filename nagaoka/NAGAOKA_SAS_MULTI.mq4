//+------------------------------------------------------------------+
//|                                            NAGAOKA_RCI_MULTI.mq4 |
//|                                          Copyright 2019, Nagaoka |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Nagaoka"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window


#define  UPPER 1
#define  LOWER 2


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
	ObjectDelete("rsi_barH1");
	ObjectDelete("rsi_barM15");
	ObjectDelete("rsi_barM5");

	ObjectDelete("rsiH1");
	ObjectDelete("rsiM15");
	ObjectDelete("rsiM5");

	ObjectDelete("direction");
	ObjectDelete("standby");

	ObjectDelete("entry_price");
	ObjectDelete("pips");
	ObjectDelete("current_price");

	ObjectsDeleteAll(0,0,OBJ_LABEL);

	//EventSetTimer(2);

//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
{
	//EventKillTimer();
	ObjectsDeleteAll(0,"pips_");
	ObjectDelete("entry_price");
	ObjectDelete("current_price");
}

#define NO_STANDBY 0
#define STANDBY 1

#define NO_ENTRY 0
#define ENTRY 1

int STANDBY_FLG = 0;
int ENTRY_FLG = 0;

double M5_UP_C = 0.0;
double M5_UP_1 = 0.0;
double M5_UP_2 = 0.0;
double M5_UP_3 = 0.0;
double M5_LOW_1 = 0.0;
double M5_LOW_2 = 0.0;
double M5_LOW_3 = 0.0;

double H1_UP_C = 0.0;
double H1_UP_1 = 0.0;
double H1_UP_2 = 0.0;
double H1_UP_3 = 0.0;
double H1_LOW_1 = 0.0;
double H1_LOW_2 = 0.0;
double H1_LOW_3 = 0.0;

double D1_UP_C = 0.0;
double D1_UP_1 = 0.0;
double D1_UP_2 = 0.0;
double D1_UP_3 = 0.0;
double D1_LOW_1 = 0.0;
double D1_LOW_2 = 0.0;
double D1_LOW_3 = 0.0;

struct band_info
{
	int pos;
	string direction;
};

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

  		showPips();

		
		//確定したローソク足のボリンジャーバンドの位置を確認する。
		M5_UP_C  = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,MODE_MAIN,1);
		M5_UP_1  = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,MODE_UPPER,1);
		M5_UP_2  = iBands(_Symbol,PERIOD_M5,21,2.0,0,PRICE_CLOSE,MODE_UPPER,1);
		M5_UP_3  = iBands(_Symbol,PERIOD_M5,21,3.0,0,PRICE_CLOSE,MODE_UPPER,1);
		M5_LOW_1 = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,MODE_LOWER,1);
		M5_LOW_2 = iBands(_Symbol,PERIOD_M5,21,2.0,0,PRICE_CLOSE,MODE_LOWER,1);
		M5_LOW_3 = iBands(_Symbol,PERIOD_M5,21,3.0,0,PRICE_CLOSE,MODE_LOWER,1);

		H1_UP_C  = iBands(_Symbol,PERIOD_H1,21,1.0,0,PRICE_CLOSE,MODE_MAIN,1);
		H1_UP_1  = iBands(_Symbol,PERIOD_H1,21,1.0,0,PRICE_CLOSE,MODE_UPPER,1);
		H1_UP_2  = iBands(_Symbol,PERIOD_H1,21,2.0,0,PRICE_CLOSE,MODE_UPPER,1);
		H1_UP_3  = iBands(_Symbol,PERIOD_H1,21,3.0,0,PRICE_CLOSE,MODE_UPPER,1);
		H1_LOW_1 = iBands(_Symbol,PERIOD_H1,21,1.0,0,PRICE_CLOSE,MODE_LOWER,1);
		H1_LOW_2 = iBands(_Symbol,PERIOD_H1,21,2.0,0,PRICE_CLOSE,MODE_LOWER,1);
		H1_LOW_3 = iBands(_Symbol,PERIOD_H1,21,3.0,0,PRICE_CLOSE,MODE_LOWER,1);

		D1_UP_C  = iBands(_Symbol,PERIOD_D1,21,1.0,0,PRICE_CLOSE,MODE_MAIN,1);
		D1_UP_1  = iBands(_Symbol,PERIOD_D1,21,1.0,0,PRICE_CLOSE,MODE_UPPER,1);
		D1_UP_2  = iBands(_Symbol,PERIOD_D1,21,2.0,0,PRICE_CLOSE,MODE_UPPER,1);
		D1_UP_3  = iBands(_Symbol,PERIOD_D1,21,3.0,0,PRICE_CLOSE,MODE_UPPER,1);
		D1_LOW_1 = iBands(_Symbol,PERIOD_D1,21,1.0,0,PRICE_CLOSE,MODE_LOWER,1);
		D1_LOW_2 = iBands(_Symbol,PERIOD_D1,21,2.0,0,PRICE_CLOSE,MODE_LOWER,1);
		D1_LOW_3 = iBands(_Symbol,PERIOD_D1,21,3.0,0,PRICE_CLOSE,MODE_LOWER,1);

   		showBand(PERIOD_M5);
   		showBand(PERIOD_H1);
   		showBand(PERIOD_D1);
   
		showStandby();  
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void showBand(int period){
                      
    double x_pos = 0;
    double y_pos = 0;
   
    double x_bar_pos = 0;
    double y_bar_pos = 0;
    
    double x_band_pos = 0;
    double y_band_pos = 0;
   

    string objName = "band";
	string objBarName = "band_bar";
	string objBandName = "band_val";
    string text = "";
    string bar_text = "";

	x_pos = 5;
	x_bar_pos = 35;
	x_band_pos = 137;

	if(period == PERIOD_M5)
	{
		text = "M5";
		y_pos = 37;
		y_bar_pos = 37;
		y_band_pos = 34;

		objName += "M5";
		objBarName += "M5";
		objBandName += "M5";

	}
	else if(period == PERIOD_H1)
	{
		text = "H1";
		y_pos = 20;
		y_bar_pos = 20;
		y_band_pos = 17;

		objName += "H1";
		objBarName += "H1";
		objBandName += "H1";
	
	}
	else if(period == PERIOD_D1)
	{
		text = "D1";
		y_pos = 3;
		y_bar_pos = 3;
		y_band_pos = 0;

		objName += "D1";
		objBarName += "D1";
		objBandName += "D1";
	
	}

	int band_font_color = clrGray; 
	band_info info = getBarInfo(period);
	if(info.direction == "up")
	{
		band_font_color = clrBlue;
	}
	else if(info.direction == "down")
	{
		band_font_color = clrRed;
	}

	bar_text = barImage(info.pos);
	string font = "Arial Black";
	
	ObjectDelete(objName);
	
   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, 11, font, band_font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

	ObjectDelete(objBarName);

	string bar_font = "MS ゴシック";

   	ObjectCreate(objBarName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objBarName, bar_text, 11, bar_font, band_font_color);
   	ObjectSet(objBarName, OBJPROP_XDISTANCE, x_bar_pos);
   	ObjectSet(objBarName, OBJPROP_YDISTANCE, y_bar_pos);
   	ObjectSet(objBarName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

}

#define OFF 0
#define ON 1
int STANDBY_SIGN = 0;
int ENTRY_SIGN = 0;
bool ALERT_FLAG = false;

void showStandby()
{
    double x_pos = 70;
    double y_pos = 47;
	string objName = "standby";
    string text = "STANDBY";
    int font_color = clrYellow;

	double upper  = iBands(_Symbol,PERIOD_CURRENT,21,2.0,0,PRICE_CLOSE,1,0);
	double lower  = iBands(_Symbol,PERIOD_CURRENT,21,2.0,0,PRICE_CLOSE,2,0);
	
	if(Close[0] >= upper)
	{
		STANDBY_FLG = STANDBY;
		font_color = clrBlue;
	}
	else if(Close[0] <= lower)
	{
		STANDBY_FLG = STANDBY;
		font_color = clrRed;
	}
	else
	{
		STANDBY_FLG = NO_STANDBY;
	}
    
	if(STANDBY_FLG == STANDBY)
	{

		string font = "Arial Black";

		ObjectDelete(0,objName);	
	   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	   	ObjectSetText(objName, text, 14, font, font_color);
	   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);  
	   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

		STANDBY_SIGN = ON;
		if(ALERT_FLAG == false)
		{
			//Alert("Standby:" + _Symbol);
			ALERT_FLAG = true;
		}
	}
	else
	{
		ObjectDelete(0,objName);
		STANDBY_SIGN = OFF;
		if(ALERT_FLAG == true)
		{
			ALERT_FLAG = false;
		}


	}
}

band_info getBarInfo(int period)
{

	band_info info;
	info.pos = 0;
	info.direction = "ng";

	if(period == PERIOD_M5)
	{
		if(Close[1] > M5_UP_3)
		{
			info.pos = 3;
			info.direction = "up";
		}
		else if(Close[1] > M5_UP_2)
		{
			info.pos = 2;
			info.direction = "up";
		}
		else if(Close[1] > M5_UP_1)
		{
			info.pos = 1;
			info.direction = "up";
		}
		else if(Close[1] > M5_UP_C)
		{
			info.pos = 0;
			info.direction = "up";
		}
		else if(Close[1] < M5_LOW_3)
		{
			info.pos = 3;
			info.direction = "down";	
		}
		else if(Close[1] < M5_LOW_2)
		{
			info.pos = 2;
			info.direction = "down";	
		}
		else if(Close[1] < M5_LOW_1)
		{
			info.pos = 1;
			info.direction = "down";	
		}
		else if(Close[1] < M5_UP_C)
		{
			info.pos = 0;
			info.direction = "down";
		}
	}
	else if(period == PERIOD_H1)
	{
		if(Close[1] > H1_UP_3)
		{
			info.pos = 3;
			info.direction = "up";
		}
		else if(Close[1] > H1_UP_2)
		{
			info.pos = 2;
			info.direction = "up";
		}
		else if(Close[1] > H1_UP_1)
		{
			info.pos = 1;
			info.direction = "up";
		}
		else if(Close[1] > H1_UP_C)
		{
			info.pos = 0;
			info.direction = "up";
		}
		else if(Close[1] < H1_LOW_3)
		{
			info.pos = 3;
			info.direction = "down";	
		}
		else if(Close[1] < H1_LOW_2)
		{
			info.pos = 2;
			info.direction = "down";	
		}
		else if(Close[1] < H1_LOW_1)
		{
			info.pos = 1;
			info.direction = "down";	
		}
		else if(Close[1] < H1_UP_C)
		{
			info.pos = 0;
			info.direction = "down";
		}

	}
	else if(period == PERIOD_D1)
	{
		if(Close[1] > D1_UP_3)
		{
			info.pos = 3;
			info.direction = "up";
		}
		else if(Close[1] > D1_UP_2)
		{
			info.pos = 2;
			info.direction = "up";
		}
		else if(Close[1] > D1_UP_1)
		{
			info.pos = 1;
			info.direction = "up";
		}
		else if(Close[1] > D1_UP_C)
		{
			info.pos = 0;
			info.direction = "up";
		}
		else if(Close[1] < D1_LOW_3)
		{
			info.pos = 3;
			info.direction = "down";	
		}
		else if(Close[1] < D1_LOW_2)
		{
			info.pos = 2;
			info.direction = "down";	
		}
		else if(Close[1] < D1_LOW_1)
		{
			info.pos = 1;
			info.direction = "down";	
		}
		else if(Close[1] < D1_UP_C)
		{
			info.pos = 0;
			info.direction = "down";
		}

	}

	return info;
}
string barImage(int count)
{
	string bar_image = "";

	switch(count)
	{
		case 1:
			bar_image = "■□□";
			break;
		case 2:
			bar_image = "■■□";
			break;
		case 3:
			bar_image = "■■■";
			break;
		default:
			bar_image = "□□□";
			break;
	}	
	return bar_image;

}


void showPips()
{
//---

	bool select_result = false;
	bool history_result = false;
	int  order_history_num;
    
    int order_total = 0;
   	double profit = 0;
	double pips = 0.0;

    order_history_num = OrdersHistoryTotal();  // アカウント履歴の数を取得
	if(order_history_num > 0)
	{
		for(int history_cnt = 0; history_cnt < order_history_num; history_cnt++)
		{
	
			history_result = OrderSelect(history_cnt, SELECT_BY_POS,MODE_HISTORY);
			//Print(history_result);
			
			if(OrderSymbol() == _Symbol)
			{	
				//Print("delete pips:" + objName);
				//ObjectDelete(objName);
				ObjectsDeleteAll(0,"pips_");
				ObjectsDeleteAll(0,"entry_price");
				ObjectDelete("current_price");

			}
		}
	}


    
    //orderhistory_num = OrdersHistoryTotal();  // アカウント履歴の数を取得
	order_total = OrdersTotal();


	//Print(order_total);
	double pipsArray[]; 
	int pipsIndex = 0;
	if(order_total > 0 )
	{
		//Print("showPips1");
		for(int order_cnt = 0; order_cnt < order_total;order_cnt++)
		{
			select_result = OrderSelect( order_cnt , SELECT_BY_POS , MODE_TRADES);

			if(OrderSymbol() == _Symbol)
			{

          		double spread =  MarketInfo(_Symbol,MODE_SPREAD) / 10;

				if(OrderType() == OP_SELL)
				{
					profit = OrderOpenPrice() - Close[0];
					pips = NormalizeDouble((profit / Point()) / 10,1) - spread;

					ArrayResize(pipsArray,pipsIndex + 1);
					pipsArray[pipsIndex] = pips;
					pipsIndex++;

				}
				else if(OrderType() == OP_BUY)
				{
					profit = Close[0] - OrderOpenPrice();
					//pips = NormalizeDouble((profit / Point()) / 10,1) + spread;
					pips = NormalizeDouble((profit / Point()) / 10,1);
					
					ArrayResize(pipsArray,pipsIndex + 1);
					pipsArray[pipsIndex] = pips;
					pipsIndex++;

				}
				//drawPips(pips);	
				
			double last_price = OrderOpenPrice();
			drawPrice(last_price);
						
			}
		}

		drawPips2(pipsArray);
	}
	
		
	
	
	return;
	
		
}

void drawPips(double pips)
{

    double x_pos = 10;
    double y_pos = 0;
    datetime dt = TimeCurrent();
    string strDt = TimeToStr(dt);
    string text = DoubleToStr(pips,1);

	//objName = createPipsObjname();
   
    string objName = "pips";
    
    int font_color = clrYellow;
	string font = "Arial Black";
	//string font = "MS ゴシック";


	if(pips < 0)
	{
		font_color = clrRed;
	}
	else if(pips == 0.0)
	{
		font_color = clrYellow;
	}
	else
	{
		font_color = clrLime;
	}

	ObjectDelete("pips");

   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, 20, font, font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  


	ObjectDelete("current_price");

   	ObjectCreate("current_price", OBJ_LABEL, 0, 0, 0);
   	ObjectSetText("current_price", DoubleToStr(Close[0],Digits), 12, "Arial", font_color);
   	ObjectSet("current_price", OBJPROP_XDISTANCE, 70);
   	ObjectSet("current_price", OBJPROP_YDISTANCE, 15);
   	ObjectSet("current_price", OBJPROP_CORNER, CORNER_RIGHT_UPPER);  

}
void drawPrice(double price)
{

    double x_pos = 70;
    double y_pos = 0;
    string text = DoubleToStr(price,Digits);

    string objName = "entry_price";
   
    int font_color = clrBlack;
	string font = "Arial";

	ObjectDelete("entry_price");

   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, 12, font, font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  

}
string createPipsObjname()
{
	MqlDateTime mdt;
	TimeCurrent(mdt);

	string dtStr =	"pips_" + _Symbol + 
					IntegerToString(mdt.year) + 
					IntegerToString(mdt.mon) + 
					IntegerToString(mdt.day) + 
					IntegerToString(mdt.hour) + 
					IntegerToString(mdt.min) + 
					IntegerToString(mdt.sec); 
	
	return dtStr;
}
void drawPips2(const double& pips[])
{

    double x_pos = 5;
    double y_pos = 0;
    datetime dt = TimeCurrent();
    string strDt = TimeToStr(dt);

	//objName = createPipsObjname();

    int font_color = clrYellow;
	string font = "Arial Black";
	//string font = "MS ゴシック";

	for(int i = 0;i < ArraySize(pips);i++)
	{
	   
	    string objName = "pips_" + IntegerToString(i);
	    string text = DoubleToStr(pips[i],1);
	    
		if(pips[i] < 0)
		{
			font_color = clrRed;
		}
		else if(pips[i] == 0.0)
		{
			font_color = clrYellow;
		}
		else
		{
			font_color = clrLime;
		}
	
		ObjectDelete(objName);
	
	   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	   	ObjectSetText(objName, text, 18, font, font_color);
	   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos + (i * 20));
	   	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  

	}


	ObjectDelete("current_price");

   	ObjectCreate("current_price", OBJ_LABEL, 0, 0, 0);
   	ObjectSetText("current_price", DoubleToStr(Close[0],Digits), 12, "Arial", font_color);
   	ObjectSet("current_price", OBJPROP_XDISTANCE, 70);
   	ObjectSet("current_price", OBJPROP_YDISTANCE, 15);
   	ObjectSet("current_price", OBJPROP_CORNER, CORNER_RIGHT_UPPER);  

}