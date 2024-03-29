//+------------------------------------------------------------------+
//|                                            NAGAOKA_SHOW_PIPS.mq4 |
//|                                          Copyright 2019, NAGAOKA |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, NAGAOKA"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


input double LOSSCUT_PIPS = -1.0; //ロスカットするpips
input double FIRST_PROFIT_PIPS = 3.0;
input double FIRST_EXIT_PIPS = 1.0;
input double SECOND_PROFIT_PIPS = 7.0;
input double SECOND_EXIT_PIPS = 5.0; 



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
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
   showPips();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double MAX_PIPS = 0.0;

void showPips()
{

	bool select_result = false;
	bool history_result = false;
	int  order_history_num;
    
    int order_total = 0;
   	double profit = 0;
	double pips = 0.0;
	double stoploss = 0.0;
	double lots = 0.0;

    order_history_num = OrdersHistoryTotal();  // アカウント履歴の数を取得
	if(order_history_num > 0)
	{
		for(int history_cnt = 0; history_cnt < order_history_num; history_cnt++)
		{
	
			history_result = OrderSelect(history_cnt, SELECT_BY_POS,MODE_HISTORY);
			
			if(OrderSymbol() == _Symbol)
			{

				ObjectsDeleteAll(0,"pips_");
				ObjectsDeleteAll(0,"stoploss_");

				ObjectDelete("exit");
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
				else
				{
					continue;
				}
				
				stoploss = OrderStopLoss();
				lots = OrderLots();

				if(pips > MAX_PIPS)
				{
					MAX_PIPS = pips;
				}

				//printf("stoploss:%f",stoploss);

				//drawLosscut(pips);
				//drawPips(pips);	

				double opne_price = OrderOpenPrice();
				drawPrice(opne_price);
				drawPips2(pips,stoploss,opne_price,lots,order_cnt);

						
			}
		}
	}
			
			
	if(existOrder() == false)
	{
		MAX_PIPS = 0.0;
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
   	ObjectSetText("current_price", Close[0], 12, "Arial", font_color);
   	ObjectSet("current_price", OBJPROP_XDISTANCE, 70);
   	ObjectSet("current_price", OBJPROP_YDISTANCE, 15);
   	ObjectSet("current_price", OBJPROP_CORNER, CORNER_RIGHT_UPPER);  

}
void drawPips2(double pips,double stoploss,double open_price,double lots,int order_count)
{

	
    double x_pos = 10;
    double y_pos = order_count * 25 + 10;
    datetime dt = TimeCurrent();
    //string strDt = TimeToStr(dt);

	//string strDt = IntegerToString((int)TimeCurrent()) + "_" + IntegerToString(order_count);
    string strDt = IntegerToString(order_count);
	//Print(strDt);
    
    string text = DoubleToStr(pips,1);
	string stoploss_txt = DoubleToStr(stoploss,0);

    string pipsObjName = "pips_" + strDt;
    string stoplossObjName = "stoploss_" + strDt;
    
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

	//printf("stoploss:%f",stoploss);
	//printf("open_price:%f",open_price);

	//ロスカットの値段の算出
	double distraction = 0.0;
	if(stoploss > open_price)
	{
		distraction = stoploss - open_price;
	}
	else
	{
		distraction = open_price - stoploss;
	}
	
	double lot_size = MarketInfo(Symbol(),MODE_LOTSIZE);
	//printf("lotsize:%f",lot_size);
	//printf("lotsize:%f",lot_size * distraction * lots);
	
	
	string dist_txt = DoubleToStr(distraction,_Digits);
	
	double losscut_pips = 0.0;
	if(_Digits == 5)
	{
		losscut_pips = distraction * 10000;
	
	}
	else if(_Digits == 3)
	{
		losscut_pips = distraction * 100;
	
	}
	else
	{
		losscut_pips = 0.0;
	}
	double losscut_price = lot_size * lots * losscut_pips;
	
	//クロス円か
	if(StringFind(_Symbol,"JPY") > 0)
	{
		losscut_price = losscut_pips * lots * lot_size / 100;
		Print("test1");
	
	
	}
	else
	{
		int pos = StringFind(_Symbol,"/");
		string pair = StringSubstr(_Symbol,pos+1,3);
		string pair_name = pair + "JPY";
		double bid = MarketInfo(pair_name,MODE_BID); 
		double ask = MarketInfo(pair_name,MODE_ASK);
		
		printf("bid:%3f",bid);
		printf("losscut_pips:%2f",losscut_pips);
		
		losscut_price = losscut_pips * lots * lot_size / 10000 * bid;
	
	}
	
	
	
	//ObjectsDeleteAll(0,"pips_");
	//ObjectDelete("pips");
	ObjectDelete(pipsObjName);

   	ObjectCreate(pipsObjName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(pipsObjName, text, 20, font, font_color);
   	ObjectSet(pipsObjName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(pipsObjName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(pipsObjName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  


	//ObjectsDeleteAll(0,"current_price");

   	//ObjectCreate("current_price", OBJ_LABEL, 0, 0, 0);
   	//ObjectSetText("current_price", Close[0], 12, "Arial", font_color);
   	//ObjectSet("current_price", OBJPROP_XDISTANCE, 70);
   	//ObjectSet("current_price", OBJPROP_YDISTANCE, 15);
   	//ObjectSet("current_price", OBJPROP_CORNER, CORNER_RIGHT_UPPER);  


	double balance = AccountBalance();
	string balance_txt = DoubleToStr(balance,0);
	double proportion = losscut_price / balance * 100;
	string info = DoubleToStr(losscut_price,0) + "/" + balance_txt +":" + DoubleToStr(proportion,1) + "%";
	//ObjectsDeleteAll(0,"stoploss_");
	ObjectDelete(stoplossObjName);

   	ObjectCreate(stoplossObjName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(stoplossObjName, info, 14, "Arial", font_color);
   	ObjectSet(stoplossObjName, OBJPROP_XDISTANCE, x_pos + 100);
   	ObjectSet(stoplossObjName, OBJPROP_YDISTANCE, y_pos + 10);
   	ObjectSet(stoplossObjName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  

}

void drawStoploss(double stoploss)
{






}


void drawLosscut(double pips)
{

    int font_color = clrRed;
    int font_size = 20;
	string exit_text = "";
	string font = "Arial Black";
	
	if(pips <= LOSSCUT_PIPS)
	{
		exit_text = "LOSSCUT EXIT!!";	
	}

    double x_pos = 10;
    double y_pos = 25;
	string objName = "exit";
	ObjectDelete(objName);

   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, exit_text, font_size, font, font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  


}
void drawExit(double pips)
{

    int font_color = clrRed;
    int font_size = 9;
	string pip_level = "";
	string exit_text = "";
	string font = "Arial Black";
	
	if(MAX_PIPS >= FIRST_PROFIT_PIPS && pips <= FIRST_EXIT_PIPS)
	{
		exit_text = "EXIT:1";		
	}
	else if(MAX_PIPS >= SECOND_PROFIT_PIPS && pips <= SECOND_EXIT_PIPS)
	{
		exit_text = "EXIT:5";		
	}

    double x_pos = 5;
    double y_pos = 0;
	string objName = "exit";

	ObjectDelete(objName);
   	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
   	ObjectSetText(objName, pip_level, font_size, font, font_color);
   	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
   	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
   	ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);  


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

bool existOrder(){

	int order_total = OrdersTotal();
	
	if(order_total > 0 )
	{
		for(int order_cnt = 0; order_cnt < order_total;order_cnt++)
		{
			bool select_result = OrderSelect( order_cnt , SELECT_BY_POS , MODE_TRADES);

			if(OrderSymbol() == _Symbol)
			{
				return true;
			}
		}
	}
	
	return false;
}
