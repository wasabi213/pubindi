//+------------------------------------------------------------------+
//|                                              NAGAOKA_SUPPORT.mq4 |
//|                                  Copyright2017, Shunsuke Nagaoka |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Nagaoka\Util.mqh>

#property copyright "Copyright2017, Shunsuke Nagaoka"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//ロット数
input double RISK_PERCENTAGE = 4.0;  //リスク許容度（％）
input int LOSSCUT_PIPS = 10;    //ロスカットpips
input double DIVIDE_ENTRY = 1.0; 	//分割エントリ数

input color lot_color = clrWhite;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
	ObjectDelete("lot");

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


   showLot();

   
//--- return value of prev_calculated for next call
   return(rates_total);
  }






//使用中の証拠金の割合を取得する。
double getMarginRate(){

   double wk = AccountMargin() / AccountBalance();

   wk = wk * 100;
   return NormalizeDouble(wk,2);

}

//エントリする際のロットを表示する。

void showLot(){
	
    double x_pos = 450;
    double y_pos = 0;
    string objName = "lot";
    
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double lot_test = calcLotSizeRiskPercent(balance, _Symbol,LOSSCUT_PIPS,RISK_PERCENTAGE); 
    string text = "LOT:" + DoubleToString(lot_test,2); 
    string rate_font = "Arial Black";

	ObjectDelete(objName);

	ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(objName, text, 11, rate_font, lot_color);
	ObjectSet(objName, OBJPROP_XDISTANCE, x_pos);
	ObjectSet(objName, OBJPROP_YDISTANCE, y_pos);
	ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);

}



double calcLotSizeRiskPercent(double aFunds, string aSymbol, double aStopLossPips, double aRiskPercent)
{
  // 取引対象の通貨を1ロット売買した時の1ポイント（pipsではない！）当たりの変動額
  double tickValue = MarketInfo(aSymbol, MODE_TICKVALUE);
 
  // tickValueは最小価格単位で計算されるため、3/5桁業者の場合、10倍しないと1pipsにならない
  if(MarketInfo(aSymbol, MODE_DIGITS) == 3 || MarketInfo(aSymbol, MODE_DIGITS) == 5){
    tickValue *= 10.0;
  }
 
  double riskAmount = aFunds * (aRiskPercent / 100.0);
  double spread =  MarketInfo(_Symbol,MODE_SPREAD) / 10;
  double lotSize = riskAmount / ((aStopLossPips + spread) * tickValue); 
  double lotStep = MarketInfo(aSymbol, MODE_LOTSTEP);

  //Print("aFunds:" + aFunds);
  //Print("aRiskPercent:" + aRiskPercent);

  //Print("riskAmount:" + riskAmount);
  //Print("lotSize:" + lotSize);
  //Print("lotStep:" + lotStep);

 
  // ロットステップ単位未満は切り捨て
  // 0.123⇒0.12（lotStep=0.01の場合）
  // 0.123⇒0.1 （lotStep=0.1の場合）
  lotSize = MathFloor(lotSize / lotStep) * lotStep;
 
  // 証拠金ベースの制限
  double margin = MarketInfo(aSymbol, MODE_MARGINREQUIRED);
  
  if(margin > 0.0){
    double accountMax = aFunds / margin;
 
    accountMax = MathFloor(accountMax / lotStep) * lotStep;
 
    if(lotSize > accountMax){
      lotSize = accountMax;
    }
  }
 
  // 最大ロット数、最小ロット数対応
  double minLots = MarketInfo(aSymbol, MODE_MINLOT);
  double maxLots = MarketInfo(aSymbol, MODE_MAXLOT);
  
  if(lotSize < minLots){
    // 仕掛けようとするロット数が最小単位に満たない場合、
    // そのまま仕掛けると過剰リスクになるため、エラーに
    lotSize = -1.0;
	return 0;

  }else if(lotSize > maxLots){
    lotSize = maxLots;
  }
 
 
  return(lotSize / DIVIDE_ENTRY);

}

