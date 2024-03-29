//+------------------------------------------------------------------+
//|                                           risk_reward_1sigma.mq4 |
//|                                         Copyright 2016,s.nagaoka |
//|                                                                  |
//| 反対方向に1シグマ進んだ場合をリスクとして、ロット数を計算する。  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015,s.nagaoka"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- input parameters
input double   LIMIT_AT_1TRADE = 2.0;
input double   LIMIT_AT_1DAY = 5.0;

//+------------------------------------------------------------------+
//スタンダード口座：
//
//1 ロット = 100,000
//最小取引サイズ= 0.01
//最大取引サイズ= 50
//ロット数増加ステップ= 0.01
//
//マイクロ口座：
//
//1 ロット = 1,000
//最小取引サイズ= 0.01
//最大取引サイズ= 100
//ロット数増加ステップ = 0.01
//+------------------------------------------------------------------+

input int   LOT_PER_UNIT = 10000;	//通貨単位
input int	RISK_PERCENTAGE = 2;	//許容損失率(%)
input int	REVERAGE = 800;			//レバレッジ



//BolingerBands
int hBands_1,hBands_2,hBands_3;
input int BandsPeriod = 21;
double BandsDeviation_1 = 1.0; 
//double BandsDeviation_2 = 2.0; 
//double BandsDeviation_3 = 3.0; 

//--- indicator buffers
double Band_Upper_1[];
double Band_Lower_1[];
//double Band_Upper_2[];
//double Band_Lower_2[];
//double Band_Upper_3[];
//double Band_Lower_3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
 
ObjectsDeleteAll(); 
ObjectDelete("trade_limit_price");
ObjectDelete("ten_pips");
ObjectDelete("lot_number");


    SetIndexBuffer(1,Band_Upper_1);
    SetIndexBuffer(2,Band_Lower_1);
    //SetIndexBuffer(3,Band_Upper_2);
    //SetIndexBuffer(4,Band_Lower_2);
    //SetIndexBuffer(5,Band_Upper_3);
    //SetIndexBuffer(6,Band_Lower_3);


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
//int x_pos = WindowFirstVisibleBar();
int x_dst = 80;
int font_size = 10;

ObjectDelete("trade_limit_price");
ObjectCreate("trade_limit_price", OBJ_LABEL, 0, 0, 0);
ObjectSetInteger(0,"trade_limit_price",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
ObjectSet("trade_limit_price", OBJPROP_XDISTANCE, 110); // 左から30ピクセル
ObjectSet("trade_limit_price", OBJPROP_YDISTANCE, 15); // 上から40ピクセル
ObjectSetText("trade_limit_price","余剰証拠金2%：" + getTradeLimitPrice() + "円",font_size,"ＭＳ　ゴシック",White);
ChartRedraw(0);

string lotObj = "lot_number";

ObjectDelete(lotObj);
ObjectCreate(lotObj, OBJ_LABEL, 0, 0, 0);
ObjectSetInteger(0,lotObj,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
ObjectSet(lotObj, OBJPROP_XDISTANCE, x_dst); // 左から30ピクセル
ObjectSet(lotObj, OBJPROP_YDISTANCE, 30); // 上から40ピクセル
ObjectSetText(lotObj,"ロット: " +getLotNumber() ,font_size,"ＭＳ　ゴシック",White);
ChartRedraw(0);


//スプレッドを表示する。
ObjectDelete("spread");
ObjectCreate("spread", OBJ_LABEL, 0, 0, 0);
ObjectSetInteger(0,"spread",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
ObjectSet("spread", OBJPROP_XDISTANCE, x_dst -10); // 左から30ピクセル
ObjectSet("spread", OBJPROP_YDISTANCE, 50); // 上から40ピクセル
ObjectSetText("spread","Spread " + getSpread() ,font_size,"ＭＳ　ゴシック",White);
ChartRedraw(0);


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
// ボリンジャーバンドのプラス１シグマを取得する。
//
//+------------------------------------------------------------------+
double getPlus1Sigma(){
	double ret = iBands(NULL,0,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_UPPER,1);

    if(Digits == 3){
        return DoubleToStr(ret,3);
    }else{
        return DoubleToStr(ret,5);
    }
}
//+------------------------------------------------------------------+
//
// ボリンジャーバンドのマイナス１シグマを取得する。
//
//+------------------------------------------------------------------+
double getMinus1Sigma(){
	double ret = iBands(NULL,0,BandsPeriod,BandsDeviation_1,0,PRICE_CLOSE,MODE_LOWER,1);

    if(Digits == 3){
        return DoubleToStr(ret,3);
    }else{
        return DoubleToStr(ret,5);
    }


}
//+------------------------------------------------------------------+
//
// 最大リスク許容額を算出する。
//
//+------------------------------------------------------------------+
int getRiskPrice(){
	return int(MathFloor(AccountBalance() / 100 * RISK_PERCENTAGE));
}

//+------------------------------------------------------------------+
//
// RiskPipsを算出する。
//
//+------------------------------------------------------------------+
int getRiskPips(){
	
	double plus1,minus1;

	plus1  = getPlus1Sigma();
	minus1 = getMinus1Sigma();

	double wk = 0.0;
	int pips = 0;

	double close = iClose(_Symbol,Period(),1);

	//Buyl
	if(close > plus1){
		wk = close - minus1;
	}
	//Sell
	else if(close < minus1){
		wk = plus1 - close;
	}else{
	    return 0;
	}

	if(Digits == 3){
		pips = int(MathFloor(wk / 0.01));
	}else if(Digits == 5){
		pips = int(MathFloor(wk / 0.0001));
	}else{
		pips = 0;
	}

    //Print("Plus1:" + plus1);
    //Print("Minus1:" + minus1);
    //Print("close:" + close);
    //Print("Digits:" + Digits);
    //Print("pips:" + pips);

	return pips;

}

//+------------------------------------------------------------------+
//
// 対象通貨における1pipsあたり円価格
//
//+------------------------------------------------------------------+
double getPipPerCurrencyPrice(){

	double yen = 0.0;
	double pip = 0.0;

	yen = iClose("USDJPY",Period(),1);

	if(	_Symbol == "USDJPY" ||
		_Symbol == "GBPJPY" ||
		_Symbol == "AUDJPY" ||
		_Symbol == "EURJPY"	){

		pip = 0.01;

	}else if(	_Symbol == "EURUSD" ||
				_Symbol == "GBPUSD" ||
				_Symbol == "AUDUSD"){
		pip = 0.0001 * yen;
	}else{
		pip = 0.0001 * yen;
	}

	return pip;
}

//+------------------------------------------------------------------+
//
// エントリ可能ロット数を算出する。
//
//+------------------------------------------------------------------+
//double getLotNumber(){
string getLotNumber(){
	//損失許容額の取得
	//---  10万円 * 2% = 2000円

	int risk_price = getRiskPrice();

    //debug
    //risk_price = 50000;
    
	//1ロットが何万通貨か
	//--- 1ロット = 100,000通貨

	int lot_size = MarketInfo(_Symbol,MODE_LOTSIZE);
	

	//ロスカットまでのpips
	//-- 終値からボリンジャーバンドプラス・マイナス１シグマまで20pips
	int losscut_pips =  getRiskPips();



	//この場合の1pipsあたりの価格
	// 2000円　÷　20pips = 100円

    if(losscut_pips <= 0){
        return 0;
    }
	double pips_per_yen = risk_price / losscut_pips;

	//クロス円
	//ドルストレート
	//1ロットで1pips動いた場合の価格（円価）
	//---- 100,000 / 100 = 1000円　1ロットでは、1pipsあたり1000円動く

	//クロス円の場合は100で割る　1pips = 0.01円
	//ドルストレートの場合は10000で割る　1pips = 0.0001ドル
	double lot_per_pipprice = lot_size * getPipPerCurrencyPrice();

	//--- 1pipで100円動くようにする時のロット数は？
	//---  100 / 1000 = 0.1ロット
	double wk_lot = pips_per_yen / lot_per_pipprice;

	//小数点以下第2桁まで算出
	string lot = DoubleToStr(wk_lot,2);
    
    //Print("risk_price:" + risk_price);
    //Print("lot_size:" + lot_size);
    //Print("losscut_pips:" + losscut_pips);
    //Print("pips_per_yen:" + pips_per_yen);
    //Print("lot_per_pipprice:" + lot_per_pipprice);
    //Print("wk_lot:" + wk_lot);
    //Print("lot:" + lot);

	return lot;
}

double getSpread(){
   return MarketInfo(_Symbol,MODE_SPREAD) / 10;
}

double getUpperLosscutPrice(int pip){
   return  _Point * 10 * pip + Close[0];
}

double getDownerLosscutPrice(int pip){
   return  Close[0] - _Point * 10 * pip;
}


double getTradeLimitPrice(){
   //int account_balance = AccountBalance();
   int account_free_margin = AccountFreeMargin();
 
   double trade_limit_percent =  LIMIT_AT_1TRADE / 100;
   double day_limit_percent   =  LIMIT_AT_1DAY   / 100;

   int trade_limit_price = account_free_margin * trade_limit_percent;
   int day_limit_price = account_free_margin * day_limit_percent;

   //Print("account_free_margin = ",account_free_margin);     
   //Print("trade_limit_percent = ",trade_limit_percent);
   //Print("day_limit_percent = ",day_limit_percent);
   //Print("trade_limit_price = ",trade_limit_price);
   //Print("day_limit_price = ",day_limit_price);

   return trade_limit_price;

}


//ロット数の計算
double getPossibleTradeLot(int pips){

   //ロスカット10pips、20pips、30pipsのときのロット数
   //1 ロット = 100,000unit
   //1ロットで１円下がるとマイナス１０万円
   //1pipsは、0.01円
   //1ロット：1pips　1000円
   //0.1ロット：1pips　100円
   //0.01ロット：1pips　10円
   
   //通貨ごとの１pipsあたり円価格
   double pip_price = getPipPrice();
   
   //Print("pip_price:" + pip_price);
   
   //ロスカット10pipsの場合
   //ロット数 = 2%の金額　／　(ロスカットのpips * 1pipsの金額)
   double lot = getTradeLimitPrice() / (pips * pip_price);
   
   //Print("lot = "+ lot);
      
   //10pips

   if(lot < 0.01){
      return 0;
   }
   
   double ret = NormalizeDouble(lot,2);
      
   return ret; 
}
double getPipPrice(){

   if(StringFind(_Symbol,"JPY",0) != -1){

      return pipToYen();
    
   }else if(StringFind(_Symbol,"USD",0) != -1){

      return pipToDoller() * iClose("USDJPY",PERIOD_M1,0); //ドル円

   }else if(StringFind(_Symbol,"EUR",0) != -1){
   
      return pipToDoller() * iClose("EURUSD",PERIOD_M1,0) * iClose("USDJPY",PERIOD_M1,0);
      
   }else if(StringFind(_Symbol,"GBP",0) != -1){

      return pipToDoller() * iClose("GBPUSD",PERIOD_M1,0) * iClose("USDJPY",PERIOD_M1,0);

   }else if(StringFind(_Symbol,"AUD",0) != -1){

      return pipToDoller() * iClose("AUDUSD",PERIOD_M1,0) * iClose("USDJPY",PERIOD_M1,0);
   
   }else if(StringFind(_Symbol,"NZD",0) != -1){

      return pipToDoller() * iClose("NZDUSD",PERIOD_M1,0) * iClose("USDJPY",PERIOD_M1,0);
   
   }else if(StringFind(_Symbol,"CHF",0) != -1){
   
      return pipToDoller() * iClose("USDCHF",PERIOD_M1,0) * iClose("USDJPY",PERIOD_M1,0);
   
   }else if(StringFind(_Symbol,"CAD",0) != -1){

      return pipToDoller() * iClose("USDCAD",PERIOD_M1,0) * iClose("USDJPY",PERIOD_M1,0);
   
   }else{
   
      return -1;
   }   


}


double pipToYen(){
   return LOT_PER_UNIT * 0.01;
}

double pipToDoller(){
   return LOT_PER_UNIT * 0.0001;
}


//使用中の証拠金を取得する。
/*
double getMarginRate(){

   double wk = AccountMargin() / AccountBalance();

   wk = wk * 100;
   return NormalizeDouble(wk,2);

}
*/

//日本語表記 英語表記 取得方法 
//残高 Balance AccountBalance() 
//有効証拠金 Equity AccountEquity() 
//必要証拠金 Margin AccountFreeMargin() 
//余剰証拠金 Free margin AccountFreeMargin() 
//証拠金維持率 Margin level AccountEquity()/AccountMargin()*100 

//その口座のレバレッジ設定値 AccountLeverage() 
//その口座のロスカットレベル AccountStopoutLevel() 
//1ロット買うのに必要な証拠金 MarketInfo(Symbol(),MODE_MARGINREQUIRED) 
//所有可能な最大ロット数 AccountFreeMargin()/MarketInfo(Symbol(),MODE_MARGINREQUIRED) 
//1注文当たりの最大ロット数 MarketInfo(Symbol(),MODE_MAXLOT) 
//1注文当たりの最小ロット数 MarketInfo(Symbol(),MODE_MINLOT) 
//ロットを数える最小単位 MarketInfo(Symbol(),MODE_LOTSTEP) 
//1ロットが何万通貨か？ MarketInfo(Symbol(),MODE_LOTSIZE) 
