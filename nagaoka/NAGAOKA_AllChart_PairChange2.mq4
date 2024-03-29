//+------------------------------------------------------------------+
//|                                         AllChart_PairChange2.mq4 |
//|                                                            Rondo |
//|                                  http://fx-dollaryen.seesaa.net/ |
//+------------------------------------------------------------------+
#property copyright "Rondo"
#property link      "http://fx-dollaryen.seesaa.net/"
#property version   "2.1"
#property strict
#property indicator_separate_window

#include <Arrays\Array.mqh>
#include <Arrays\ArrayString.mqh>

input bool COLOR_BLACK_MODE = true; //カラーモード：黒系／白系

input string PairA1 = "USDJPY.";  //通貨ペア A1
input string PairA2 = "USDCHF.";  //通貨ペア A2
input string PairA3 = "USDCAD.";  //通貨ペア A3
input string PairA4 = "EURJPY.";  //通貨ペア A4
input string PairA5 = "EURUSD.";  //通貨ペア A5
input string PairA6 = "EURCHF.";  //通貨ペア A6
input string PairA7 = "EURGBP.";  //通貨ペア A7
input string PairA8 = "EURAUD.";  //通貨ペア A8
input string PairA9 = "EURCAD.";  //通貨ペア A9
input string PairA10 = "EURNZD.";  //通貨ペア A10


input string PairB1 = "CHFJPY.";  //通貨ペア B1
input string PairB2 = "GBPJPY.";  //通貨ペア B2
input string PairB3 = "GBPUSD.";  //通貨ペア B3
input string PairB4 = "GBPCHF.";  //通貨ペア B4
input string PairB5 = "GBPAUD.";  //通貨ペア B5
input string PairB6 = "GBPCAD.";  //通貨ペア B6
input string PairB7 = "GBPNZD.";  //通貨ペア B7
input string PairB8 = "AUDJPY.";  //通貨ペア B8
input string PairB9 = "AUDUSD.";  //通貨ペア B9
input string PairB10 = "AUDCHF.";  //通貨ペア B10


input string PairC1 = "AUDCAD.";  //通貨ペア C1
input string PairC2 = "AUDNZD.";  //通貨ペア C2
input string PairC3 = "CADJPY.";  //通貨ペア C3
input string PairC4 = "NZDJPY.";  //通貨ペア C4
input string PairC5 = "NZDUSD.";  //通貨ペア C5
input string PairC6 = "";  //通貨ペア C6
input string PairC7 = "";  //通貨ペア C7
input string PairC8 = "";  //通貨ペア C8
input string PairC9 = "";  //通貨ペア C9
input string PairC10 = "";  //通貨ペア C10


//input color font_colorA = clrWhite; //表示色 A
//input color font_colorB = clrWhite;  //表示色 B
//input color font_colorC = clrLightSteelBlue; //表示色 C

color font_colorA = clrWhite; //表示色 A
color font_colorB = clrWhite;  //表示色 B
color font_colorC = clrLightSteelBlue; //表示色 C




input int font_size = 12;  //文字の大きさ

string indiName = "AC_PC2";
int totalA, totalB, totalC;
int window;

CArrayString *arrayA = new CArrayString;
CArrayString *arrayB = new CArrayString;
CArrayString *arrayC = new CArrayString;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   if(SymbolSelect(PairA1, true)) arrayA.Add(PairA1);
   if(SymbolSelect(PairA2, true)) arrayA.Add(PairA2);
   if(SymbolSelect(PairA3, true)) arrayA.Add(PairA3);
   if(SymbolSelect(PairA4, true)) arrayA.Add(PairA4);
   if(SymbolSelect(PairA5, true)) arrayA.Add(PairA5);
   if(SymbolSelect(PairA6, true)) arrayA.Add(PairA6);
   if(SymbolSelect(PairA7, true)) arrayA.Add(PairA7);
   if(SymbolSelect(PairA8, true)) arrayA.Add(PairA8);
   if(SymbolSelect(PairA9, true)) arrayA.Add(PairA9);
   if(SymbolSelect(PairA10, true)) arrayA.Add(PairA10);
   
   if(SymbolSelect(PairB1, true)) arrayB.Add(PairB1);
   if(SymbolSelect(PairB2, true)) arrayB.Add(PairB2);
   if(SymbolSelect(PairB3, true)) arrayB.Add(PairB3);
   if(SymbolSelect(PairB4, true)) arrayB.Add(PairB4);
   if(SymbolSelect(PairB5, true)) arrayB.Add(PairB5);
   if(SymbolSelect(PairB6, true)) arrayB.Add(PairB6);
   if(SymbolSelect(PairB7, true)) arrayB.Add(PairB7);
   if(SymbolSelect(PairB8, true)) arrayB.Add(PairB8);
   if(SymbolSelect(PairB9, true)) arrayB.Add(PairB9);
   if(SymbolSelect(PairB10, true)) arrayB.Add(PairB10);

   if(SymbolSelect(PairC1, true)) arrayC.Add(PairC1);
   if(SymbolSelect(PairC2, true)) arrayC.Add(PairC2);
   if(SymbolSelect(PairC3, true)) arrayC.Add(PairC3);
   if(SymbolSelect(PairC4, true)) arrayC.Add(PairC4);
   if(SymbolSelect(PairC5, true)) arrayC.Add(PairC5);
   if(SymbolSelect(PairC6, true)) arrayC.Add(PairC6);
   if(SymbolSelect(PairC7, true)) arrayC.Add(PairC7);
   if(SymbolSelect(PairC8, true)) arrayC.Add(PairC8);
   if(SymbolSelect(PairC9, true)) arrayC.Add(PairC9);
   if(SymbolSelect(PairC10, true)) arrayC.Add(PairC10);
   
   IndicatorShortName(indiName);
   window = WindowFind(indiName);
   
   Label();


   //ChartSetInteger(ChartNext(0), CHART_COLOR_BACKGROUND, BG_COLOR);
   
   IndicatorShortName("");
   
//---_
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   objDelete(indiName);
   
   delete arrayA;
   delete arrayB;
   delete arrayC;

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
   Label();
           
//--- return value of prev_calculated for next call
   return(rates_total);
  }


//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){

   if(id == CHARTEVENT_CHART_CHANGE){
   
      Label();
   }

   if(id == CHARTEVENT_OBJECT_CLICK){
   
      for(int a=0; a<totalA; a++){
      
         if(sparam == indiName+"A"+arrayA.At(a)) ChartChange(arrayA.At(a));
      }

      for(int b=0; b<totalB; b++){
      
         if(sparam == indiName+"B"+arrayB.At(b)) ChartChange(arrayB.At(b));
      }

      for(int c=0; c<totalC; c++){
      
         if(sparam == indiName+"C"+arrayC.At(c)) ChartChange(arrayC.At(c));
      }

   }
}


void ChartChange(string Pair){

   long currChart, prevChart=ChartFirst();
   int i=0, limit=100;
   
   while(i<limit){
      ChartSetSymbolPeriod(prevChart, Pair, ChartPeriod(prevChart));
      currChart = ChartNext(prevChart);
      if(currChart<0) break;
      prevChart = currChart;
      i++;
   }
}

//+------------------------------------------------------------------+

void Label(){

   int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   
   totalA = arrayA.Total();
   totalB = arrayB.Total();
   totalC = arrayC.Total();
   
   //配列の個数（一番大きいもの）
   int totalMax = MathMax(MathMax(totalA, totalB), totalC);
   
   double row_space = 1.1;
   double col_space = 2;
   double x_start_pos = 0.1;
   
   for(int a=0; a<totalA; a++){
   
      //LabelCreate(indiName+"A"+arrayA.At(a), arrayA.At(a), width*row_space/(totalMax+1)*(a+1), font_size*col_space*0.5, font_size, font_colorA);
      LabelCreate(indiName+"A"+arrayA.At(a), arrayA.At(a), width*row_space/(totalMax+1)*(a+x_start_pos), font_size*col_space*0.5, font_size, font_colorA);
   }
   
   for(int b=0; b<totalB; b++){
   
      LabelCreate(indiName+"B"+arrayB.At(b), arrayB.At(b), width*row_space/(totalMax+1)*(b+x_start_pos), font_size*col_space*1.5, font_size, font_colorB);
   }

   for(int c=0; c<totalC; c++){
   
      LabelCreate(indiName+"C"+arrayC.At(c), arrayC.At(c), width*row_space/(totalMax+1)*(c+x_start_pos), font_size*col_space*2.5, font_size, font_colorC);
   }
}


void LabelCreate(string name, string text, int x, int y, int f_size, color LabelColor){

	double rsi5  = iRSI(text,PERIOD_M5 ,14,PRICE_CLOSE,1);
	double rsi15 = iRSI(text,PERIOD_M15,14,PRICE_CLOSE,1);
	double rsi60 = iRSI(text,PERIOD_H1 ,14,PRICE_CLOSE,1);
	
	text += DoubleToStr(rsi60,0);



	//LabelColor = getAbsRsiColor(val);
	LabelColor = getRsiColor(rsi5,rsi15,rsi60);

   if(ObjectFind(0, name) != 0){
   
      ObjectCreate(0, name, OBJ_LABEL, window, 0, 0);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_COLOR, LabelColor);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, f_size);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else{
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   }
   
   ChartRedraw(0);
   
}
int getAbsRsiColor(double rsi)
{
	if(rsi >= 60)
	{
		return clrLime;
	}
	else if(rsi <= 40)
	{
		return clrMagenta;
	}
	else if(rsi <= 55 && rsi >= 45)
	{
		return clrGray;
	}
	else
	{
		return clrWhite;
	}

}

int getRsiColor(double m5,double m15,double m60)
{

	if(COLOR_BLACK_MODE == false)
	{
		return clrBlack;
	}


	if(m5 >= 50 && m15 >= 50 && m60 >= 60)
	{
		return clrLime;
	}
	else if(m5 < 50 && m15 < 50 && m60 <= 40)
	{
		return clrMagenta;
	}
	else if(m5 >= 50 && m15 >= 50 && m60 >= 50)
	{
		return clrWhite;
	}
	else if(m5 < 50 && m15 < 50 && m60 < 50)
	{
		return clrWhite;
	}

	return clrGray;

}

void objDelete(string basicName){

   for(int i=ObjectsTotal(); i>=0; i--){
   
      string ObjName = ObjectName(i);
      if(StringFind(ObjName, basicName) >=0) ObjectDelete(ObjName);
   }
}