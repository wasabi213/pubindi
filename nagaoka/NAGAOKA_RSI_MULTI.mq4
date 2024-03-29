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

input int BASE_HEIGHT = 10; //マルチRSIバーの縦位置

input bool BELL_RING_FLAG = FALSE;  //アラート音
input double BAND_WIDTH_MIN = 5.0;  //最小バンド幅
input double MAX_SPREAD = 2.5;

input bool HLINE = false;

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
}

#define NO_STANDBY 0
#define STANDBY 1

#define NO_ENTRY 0
#define ENTRY 1

int STANDBY_FLG = 0;
int ENTRY_FLG = 0;
/*
void OnTimer()
{
	
	
}
*/
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

		double m5_rsi,m15_rsi,m60_rsi;
		
		if(IsTesting())
		{
			m5_rsi  = iRSI(_Symbol,PERIOD_M5,14,PRICE_CLOSE,1);
			m15_rsi = iRSI(_Symbol,PERIOD_M5,42,PRICE_CLOSE,1);
			m60_rsi = iRSI(_Symbol,PERIOD_M5,168,PRICE_CLOSE,1);
		}
		else
		{
			m5_rsi  = iRSI(_Symbol,PERIOD_M5,14,PRICE_CLOSE,1);
			m15_rsi = iRSI(_Symbol,PERIOD_M15,14,PRICE_CLOSE,1);
			m60_rsi = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,1);
   		}

   		showDirection(m60_rsi,m15_rsi,m5_rsi);
   
   		showRsi(m5_rsi,PERIOD_M5);
   		showRsi(m15_rsi,PERIOD_M15);
   		showRsi(m60_rsi,PERIOD_H1);
   
   		showStandby(m60_rsi,m15_rsi,m5_rsi);
   		//showPips();
  
   
	    createHorizontalLine();
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void showRsi(double rsi,int period){
                      
    double x_pos = 0;
    double y_pos = 0;
   
    double x_bar_pos = 0;
    double y_bar_pos = 0;
    
    double x_rsi_pos = 0;
    double y_rsi_pos = 0;
   
    string objName = "rsi";
	string objBarName = "rsi_bar";
	string objRsiName = "rsi_val";
    string text = "";
    string bar_text = "";

	x_pos = 5;
	x_bar_pos = 29;
	x_rsi_pos = 112;

	if(period == PERIOD_H1)
	{
		text = "H1";
		y_pos = 3;
		y_bar_pos = 3;
		y_rsi_pos = 2;

		objName += "H1";
		objBarName += "H1";
		objRsiName += "H1";
	
	}
	else if(period == PERIOD_M15)
	{
		text = "M15";
		y_pos = 15;
		y_bar_pos = 15;
		y_rsi_pos = 14;

		objName += "M15";
		objBarName += "M15";
		objRsiName += "M15";
	
	}
	else
	{
		text = "M5";
		y_pos = 27;
		y_bar_pos = 27;
		y_rsi_pos = 26;

		objName += "M5";
		objBarName += "M5";
		objRsiName += "M5";
	
	}

	int rsi_font_color = clrGray; 

	if(rsi > 50)
	{
		rsi_font_color = clrLime;
		bar_text = showBar(rsi,UPPER);
 	}
 	else 
 	{
		rsi_font_color = clrRed; 
		bar_text += showBar(rsi,LOWER);	
 	}

	y_pos += BASE_HEIGHT;
	y_bar_pos += BASE_HEIGHT;
	y_rsi_pos += BASE_HEIGHT;


	string font = "MS ゴシック";
	int font_size = 9;
	
	
   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, font_size, font, rsi_font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

   	ObjectCreate(objBarName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objBarName, bar_text, font_size, font, rsi_font_color);
   	ObjectSet(objBarName, OBJPROP_XDISTANCE, x_bar_pos);
   	ObjectSet(objBarName, OBJPROP_YDISTANCE, y_bar_pos);
   	ObjectSet(objBarName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

	string rsi_text = " " + DoubleToString(rsi,1);

   	ObjectCreate(objRsiName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objRsiName, rsi_text, font_size, "Arial Black", rsi_font_color);
   	ObjectSet(objRsiName, OBJPROP_XDISTANCE, x_rsi_pos);
   	ObjectSet(objRsiName, OBJPROP_YDISTANCE, y_rsi_pos);
   	ObjectSet(objRsiName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  


}
void showDirection(double rsi60,double rsi15,double rsi5){
                      
    double x_pos = 4;
    double y_pos = 36;
   
    string objName = "direction";
 
    string text = "";
	int font_color;


	if(rsi60 > 50 && rsi15 > 50 && rsi5 > 50)
	{
		text = "UP";
		font_color = clrLime;		
	}
	else if(rsi60 < 50 && rsi15 < 50 && rsi5 < 50)
	{
		text = "DW";
		font_color = clrRed;

	}
	else
	{
		text = "NG";
		font_color = clrGray;
	}

	string font = "Arial Black";
	y_pos += BASE_HEIGHT;

   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, text, 14, font, font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos); 
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

}

#define OFF 0
#define ON 1
int STANDBY_SIGN = 0;
int ENTRY_SIGN = 0;
bool ALERT_FLAG = false;

void showStandby(double rsi60,double rsi15,double rsi5)
{
    double x_pos = 43;
    double y_pos = 37;
	string objName = "standby";
    string alert_text = "STANDBY";
	int font_color = clrYellow;

	//1本前のRSIを取得する。  
	double rsi_current = iRSI(_Symbol,PERIOD_M5,14,PRICE_CLOSE,0);
	double rsi_past1   = iRSI(_Symbol,PERIOD_M5,14,PRICE_CLOSE,1);
	double rsi_past2   = iRSI(_Symbol,PERIOD_M5,14,PRICE_CLOSE,2);

	double upper  = iBands(_Symbol,PERIOD_M5,20,1.0,0,PRICE_CLOSE,1,0);
	double lower  = iBands(_Symbol,PERIOD_M5,20,1.0,0,PRICE_CLOSE,2,0);
	double center = iBands(_Symbol,PERIOD_M5,20,1.0,0,PRICE_CLOSE,0,0);
	double center_past1 = iBands(_Symbol,PERIOD_M5,20,1.0,0,PRICE_CLOSE,0,1);
	
	double h1_ma1 = iMA(_Symbol,PERIOD_H1,20,0,MODE_SMA,PRICE_CLOSE,1);
	double h1_ma2 = iMA(_Symbol,PERIOD_H1,20,0,MODE_SMA,PRICE_CLOSE,2);

	double m5_ma1 = iMA(_Symbol,PERIOD_H1,20,0,MODE_SMA,PRICE_CLOSE,1);
	double m5_ma2 = iMA(_Symbol,PERIOD_H1,20,0,MODE_SMA,PRICE_CLOSE,2);
	
	double rsi_h1_past1   = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,1);
	double rsi_h1_past2   = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,2);

	//スプレッドを取得する。	
    double spread =  MarketInfo(_Symbol,MODE_SPREAD) / 10;
    
    double width = getBandWidth(PERIOD_M5);
	double pip = Point() * 10;

	bool entry_flg = false;

	//上昇
	//1本前のRSIがすべて50以上が確定
	if( rsi60 >= 50 && rsi15 >= 50 && rsi5 >= 50)
	{
		//1本前のRSIが2本前のRSIより大きい。折り返しが確定していること。
		if(rsi_past1 > rsi_past2 )
		{
			//1時間移動平均線が上昇していること。
			if(h1_ma1 > h1_ma2)
			{
				//5分足移動平均線が上昇していること。
				if(m5_ma1 > m5_ma2)
				{
					//1時間足のRSIが上昇していること。
					if(rsi_h1_past1 > rsi_h1_past2)
					{
						if(rsi_current > 45 && rsi_current < 52)
						{
							font_color = clrAqua;
							alert_text = "RSI ENTRY";
							STANDBY_FLG = STANDBY;
						}	
					}
				}
			}
		}
	}


	//下落
	//1本前のRSIがすべて50未満が確定
	if( rsi60 < 50 && rsi15 < 50 && rsi5 < 50)
	{
		//1本前のRSIが2本前のRSIより小さい。折り返しが確定していること。
		if(rsi_past1 < rsi_past2 )
		{
			//1時間移動平均線が下落していること。
			if(h1_ma1 < h1_ma2)
			{
				//5分足移動平均線が下落していること。
				if(m5_ma1 < m5_ma2)
				{
					//1時間足のRSIが下落していること。
					if(rsi_h1_past1 < rsi_h1_past2)
					{
						if(rsi_current < 55 && rsi_current > 48)
						{
							font_color = clrAqua;
							alert_text = "RSI ENTRY";
							STANDBY_FLG = STANDBY;
						}	
					}
				}
			}
		}
	}
	else
	{
		STANDBY_FLG = NO_STANDBY;
	}

	if(STANDBY_FLG == STANDBY)
	{
		string font = "Arial Black";
		y_pos += BASE_HEIGHT;
	
	   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	   	ObjectSetText(objName, alert_text, 12, font, font_color);
	   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);  
	   	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);  

		STANDBY_SIGN = ON;
		if(ALERT_FLAG == false)
		{
			if(BELL_RING_FLAG)
			{
				Alert("Standby:" + _Symbol);
			}
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

	ChartRedraw();
}

double getBandWidth(int timeframe)
{

	double upper  = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,1,0);
	double lower  = iBands(_Symbol,PERIOD_M5,21,1.0,0,PRICE_CLOSE,2,0);

	double width = (upper - lower) / 2;
	double pips = NormalizeDouble((width / Point()) / 10,1);
	
	return pips;

}


string showBar(double rsi,int direction)
{
	int cnt = getBarCount(rsi,direction);
	string img = barImage(cnt);
	
	return img;

}

int getBarCount(double rsi,int direction)
{

	int bar_count  = 0;

	if(direction == LOWER)
	{
		if(rsi < 50 && rsi >= 47)
		{
			bar_count = 1;
		}
		else if(rsi < 46 && rsi >= 43)
		{
			bar_count = 2;
		
		}
		else if(rsi < 42 && rsi >= 39)
		{
			bar_count = 3;
		
		}
		else if(rsi < 38 && rsi >= 35)
		{
			bar_count = 4;
		
		}
		else if(rsi < 34 && rsi >= 31)
		{
			bar_count = 5;
		
		}
		else if(rsi < 30 && rsi >= 27)
		{
			bar_count = 6;
		
		}
		else if(rsi < 27)
		{
			bar_count = 7;
		
		}	
	}
	else
	{
		if(rsi >= 50 && rsi < 54 )
		{
			bar_count = 1;
		}
		else if(rsi >= 54 && rsi < 58)
		{
			bar_count = 2;	
		}
		else if(rsi >= 58 && rsi < 62)
		{
			bar_count = 3;	
		}
		else if(rsi >= 62 && rsi < 66)
		{
			bar_count = 4;	
		}
		else if(rsi >= 66 && rsi < 70)
		{
			bar_count = 5;	
		}
		else if(rsi >= 70 && rsi < 74)
		{
			bar_count = 6;	
		}
		else if(rsi >= 74)
		{
			bar_count = 7;	
		}
	}
	return bar_count;
}
string barImage(int count)
{
	string bar_image = "";

	switch(count)
	{
		case 1:
			bar_image = "■□□□□□□";
			break;
		case 2:
			bar_image = "■■□□□□□";
			break;
		case 3:
			bar_image = "■■■□□□□";
			break;
		case 4:
			bar_image = "■■■■□□□";
			break;
		case 5:
			bar_image = "■■■■■□□";
			break;
		case 6:
			bar_image = "■■■■■■□";
			break;
		case 7:
			bar_image = "■■■■■■■";
			break;
		default:
			bar_image = "□□□□□□□";
			break;
	}	
	return bar_image;

}
///////////////////////////////////////////////////////////////////////////////
//
// エントリした時のPIPSを表示
//
//
//
///////////////////////////////////////////////////////////////////////////////
void showPips()
{

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
			
			if(OrderSymbol() == _Symbol)
			{	
				ObjectDelete("pips");
				ObjectDelete("entry_price");
				ObjectDelete("current_price");
			}
		}
	}
  
	order_total = OrdersTotal();
	
	if(order_total > 0 )
	{
		for(int order_cnt = 0; order_cnt < order_total;order_cnt++)
		{
			select_result = OrderSelect( order_cnt , SELECT_BY_POS , MODE_TRADES);

			if(OrderSymbol() == _Symbol)
			{
				if(OrderType() == OP_SELL)
				{
					profit = OrderOpenPrice() - Close[0];
					pips = NormalizeDouble((profit / Point()) / 10,1);

				}
				else if(OrderType() == OP_BUY)
				{
              		double spread =  MarketInfo(_Symbol,MODE_SPREAD) / 10;
					profit = Close[0] - OrderOpenPrice();
					pips = NormalizeDouble((profit / Point()) / 10,1) + spread;
					
				}
				drawPips(pips);	
				double last_price = OrderOpenPrice();
				drawPrice(last_price);
						
			}
		}
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
    string objName = "pips";
    
    int font_color = clrYellow;
	string font = "Arial Black";

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
   	ObjectSetText("current_price", DoubleToStr(Close[0],_Digits), 12, "Arial", font_color);
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
    int font_color = clrWhite;
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

void createHorizontalLine()
{
	if(HLINE == false) return;

	//double pips = NormalizeDouble(( Point() * 100 ) ,1);
	double pips = Point() * 150 ;
	ObjectDelete(0,"upper_line");
	ObjectCreate(0, "upper_line", OBJ_HLINE, 0, 0, 0);
    ObjectSetInteger(0, "upper_line", OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, "upper_line", OBJPROP_WIDTH, 2);
	ObjectMove("upper_line", 0, 0, Bid + pips);


	ObjectDelete(0,"lower_line");
	ObjectCreate(0, "lower_line", OBJ_HLINE, 0, 0, 0);
    ObjectSetInteger(0, "lower_line", OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, "lower_line", OBJPROP_WIDTH, 2);
	ObjectMove("lower_line", 0, 0, Bid - pips);




}