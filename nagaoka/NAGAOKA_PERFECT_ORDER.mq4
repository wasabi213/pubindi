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


input int SHORT_TERM = 10; //短期
input int MID_TERM = 25; //中期
input int LONG_TERM = 50; //長期

#define UP_TREND 1
#define DOWN_TREND 2
#define NO_ORDER 3

input int BASE_HEIGHT = 10; //縦位置



#define PERFECT_ORDER_UP 1
#define PERFECT_ORDER_DOWN 2
#define NO_PERFECT_ORDER 0

int PERFECT_ORDER_FLAG = NO_PERFECT_ORDER;


//+------------------------------------------------------------------+
//| Custom indicator initialization function						 |
//+------------------------------------------------------------------+
int OnInit(){

	ObjectDelete("M5_objPerfectOrder");
	ObjectDelete("M15_objPerfectOrder");
	ObjectDelete("H1_objPerfectOrder");
	ObjectsDeleteAll(0,OBJ_ARROW);
	return(INIT_SUCCEEDED);

}
int deinit(){

	ObjectDelete("M5_objPerfectOrder");
	ObjectDelete("M15_objPerfectOrder");
	ObjectDelete("H1_objPerfectOrder");
	ObjectsDeleteAll(0,OBJ_ARROW);
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



	int limit = rates_total - prev_calculated;
	if(limit == 0) limit = 1;
    if(limit == Bars) limit--;

	int current_trend;
	int pos;
	int x_pos = 172;

	for(int i = limit; i >= 0; i--){

		//pos = i + 1;
		pos = i;

		current_trend = getPerfectOrder(PERIOD_CURRENT,pos);
		
		
		if(current_trend == UP_TREND)
		{
			showPerfectOrderArrow("up",PERIOD_CURRENT,pos);
		}
		else if(current_trend == DOWN_TREND)
		{
			showPerfectOrderArrow("down",PERIOD_CURRENT,pos);
		}
		else if(current_trend == NO_ORDER)
		{
			showPerfectOrderArrow("no_direction",PERIOD_CURRENT,pos);
			PERFECT_ORDER_FLAG = NO_PERFECT_ORDER;		
		}
    }

	int m5_trend = getPerfectOrder(PERIOD_M5,1);
	double m5_xpos = x_pos;
	double m5_ypos = 26;
	string m5_ObjName = "m5ObjPo";

	if(m5_trend == UP_TREND)
	{
		showPerfectOrder("up","M5",m5_xpos,m5_ypos);
	}
	else if(m5_trend == DOWN_TREND)
	{
		showPerfectOrder("down","M5",m5_xpos,m5_ypos);
	}
	else
	{
		ObjectDelete("M5_objPerfectOrder");
	}


	int m15_trend = getPerfectOrder(PERIOD_M15,1);
	double m15_xpos = x_pos;
	double m15_ypos = 13;
	string m15_ObjName = "m15ObjPo";

	if(m15_trend == UP_TREND)
	{
		showPerfectOrder("up","M15",m15_xpos,m15_ypos);
	}
	else if(m15_trend == DOWN_TREND)
	{
		showPerfectOrder("down","M15",m15_xpos,m15_ypos);
	}
	else
	{
		ObjectDelete("M15_objPerfectOrder");
	}


	int h1_trend = getPerfectOrder(PERIOD_H1,1);
	double h1_xpos = x_pos;
	double h1_ypos = 0;

	if(h1_trend == UP_TREND)
	{
		showPerfectOrder("up","H1",h1_xpos,h1_ypos);
	}
	else if(h1_trend == DOWN_TREND)
	{
		showPerfectOrder("down","H1",h1_xpos,h1_ypos);
	}
	else
	{
		ObjectDelete("H1_objPerfectOrder");
	}

	return(rates_total);
}


void showPerfectOrder(string direction,string tf,double x_pos,double y_pos){
	
	string direction_txt;

	int font_color;

	if(direction == "up")
	{
		font_color = clrAqua;
		direction_txt = "UP";
	}
	else
	{
		font_color = clrMagenta;
		direction_txt = "DOWN";
	}

	//string text = tf + " PO:" + direction_txt;
	string font = "arial black";

	string objName = tf + "_objPerfectOrder";

	ObjectDelete(objName);

	y_pos += BASE_HEIGHT;

	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, "P", 9, font, font_color);
	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);

}


void showPerfectOrderArrow(string direction,string tf,int bar_num){
	
	string direction_txt;
	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;
	
	if(PERFECT_ORDER_FLAG != PERFECT_ORDER_UP && direction == "up")
	{
		arrow_color = clrAqua;
		PERFECT_ORDER_FLAG = PERFECT_ORDER_UP;
		arrow_type = 233;
		pos = Low[bar_num];
		anchor = ANCHOR_TOP;		
	}
	else if(PERFECT_ORDER_FLAG != PERFECT_ORDER_DOWN && direction == "down")
	{
		arrow_color = clrMagenta;
		PERFECT_ORDER_FLAG = PERFECT_ORDER_DOWN;
		arrow_type = 234;
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	}
	else if(PERFECT_ORDER_FLAG == PERFECT_ORDER_UP && direction == "no_direction")
	{
		arrow_color = clrGray;;
		//PERFECT_ORDER_FLAG = PERFECT_ORDER_DOWN;
		arrow_type = 234;
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	
	}
	else if(PERFECT_ORDER_FLAG == PERFECT_ORDER_DOWN && direction == "no_direction")
	{
		arrow_color = clrGray;
		//PERFECT_ORDER_FLAG = PERFECT_ORDER_UP;
		arrow_type = 233;
		pos = Low[bar_num];
		anchor = ANCHOR_TOP;		

	}
	else
	{
		return;
	}

	string objName = "objPerfectOrderArrow_" + IntegerToString(bar_num);


	ObjectCreate(0,objName, OBJ_ARROW,0,Time[bar_num],pos);
	ObjectSetInteger(0,objName, OBJPROP_ARROWCODE,arrow_type);
	ObjectSetInteger(0,objName, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);
}



int getPerfectOrder(int time_frame ,int bar_number)
{

	double short_term = iMA(NULL,time_frame,SHORT_TERM,0,MODE_EMA,PRICE_CLOSE,bar_number);
	double mid_term   = iMA(NULL,time_frame,MID_TERM,0,MODE_EMA,PRICE_CLOSE,bar_number);
	double long_term  = iMA(NULL,time_frame,LONG_TERM,0,MODE_EMA,PRICE_CLOSE,bar_number);

	if(short_term > mid_term && mid_term > long_term)
	{
		return UP_TREND;
	}
	else if(short_term < mid_term && mid_term < long_term)
	{
		return DOWN_TREND;
	}
	
	return NO_ORDER;

}

