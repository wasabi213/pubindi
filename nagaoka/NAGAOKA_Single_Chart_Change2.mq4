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

input string PairA1 = "USDJPY.";  //通貨ペア A1
input string PairA2 = "USDCHF.";  //通貨ペア A2
input string PairA3 = "USDCAD.";  //通貨ペア A3
input string PairA4 = "EURUSD.";  //通貨ペア A4
input string PairA5 = "EURJPY.";  //通貨ペア A5
input string PairA6 = "EURCHF.";  //通貨ペア A6

input string PairA7 = "";  //通貨ペア A7
input string PairA8 = "";  //通貨ペア A8
input string PairA9 = "";  //通貨ペア A9
input string PairA10 = "";  //通貨ペア A10


input string PairB1 = "EURCAD.";  //通貨ペア B1
input string PairB2 = "EURGBP.";  //通貨ペア B2
input string PairB3 = "GBPCAD.";  //通貨ペア B3
input string PairB4 = "GBPJPY.";  //通貨ペア B4
input string PairB5 = "GBPUSD.";  //通貨ペア B5
input string PairB6 = "GBPCHF.";  //通貨ペア B6

input string PairB7 = "";  //通貨ペア B7
input string PairB8 = "";  //通貨ペア B8
input string PairB9 = "";  //通貨ペア B9
input string PairB10 = "";  //通貨ペア B10


input string PairC1 = "GBPAUD.";  //通貨ペア C1
input string PairC2 = "AUDJPY.";  //通貨ペア C2
input string PairC3 = "AUDUSD.";  //通貨ペア C3
input string PairC4 = "AUDCHF.";  //通貨ペア C4
input string PairC5 = "CHFJPY.";  //通貨ペア C5
input string PairC6 = "CADJPY.";  //通貨ペア C6

input string PairC7 = "";  //通貨ペア C7
input string PairC8 = "";  //通貨ペア C8
input string PairC9 = "";  //通貨ペア C9
input string PairC10 = "";  //通貨ペア C10

input string PairD1 = "AUDCAD.";  //通貨ペア C1
input string PairD2 = "EURAUD.";  //通貨ペア C2
input string PairD3 = "NZDUSD.";  //通貨ペア C3
input string PairD4 = "GBPNZD.";  //通貨ペア C4
input string PairD5 = "AUDNZD.";  //通貨ペア C5
input string PairD6 = "NZDJPY.";  //通貨ペア C6
input string PairD7 = "EURNZD.";  //通貨ペア C7

input string PairD8 = "";  //通貨ペア C8
input string PairD9 = "";  //通貨ペア C9
input string PairD10 = "";  //通貨ペア C10

//input color font_colorA = clrWhite; //表示色 A
//input color font_colorB = clrWhite;  //表示色 B
//input color font_colorC = clrLightSteelBlue; //表示色 C

color font_colorA = clrWhite; //表示色 A
color font_colorB = clrWhite;  //表示色 B
color font_colorC = clrLightSteelBlue; //表示色 C
color font_colorD = clrLightSteelBlue; //表示色 C


input int font_size = 9;  //文字の大きさ

input bool Show_RSI = false; //RSI表示

string indiName = "AC_PC2";
int totalA, totalB, totalC, totalD;
int window;

CArrayString *arrayA = new CArrayString;
CArrayString *arrayB = new CArrayString;
CArrayString *arrayC = new CArrayString;
CArrayString *arrayD = new CArrayString;



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
   
   if(SymbolSelect(PairD1, true)) arrayD.Add(PairD1);
   if(SymbolSelect(PairD2, true)) arrayD.Add(PairD2);
   if(SymbolSelect(PairD3, true)) arrayD.Add(PairD3);
   if(SymbolSelect(PairD4, true)) arrayD.Add(PairD4);
   if(SymbolSelect(PairD5, true)) arrayD.Add(PairD5);
   if(SymbolSelect(PairD6, true)) arrayD.Add(PairD6);
   if(SymbolSelect(PairD7, true)) arrayD.Add(PairD7);
   if(SymbolSelect(PairD8, true)) arrayD.Add(PairD8);
   if(SymbolSelect(PairD9, true)) arrayD.Add(PairD9);
   if(SymbolSelect(PairD10, true)) arrayD.Add(PairD10);
   
   
   
   IndicatorShortName(indiName);
   window = WindowFind(indiName);
   
   Label();
   
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
   delete arrayD;

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

      for(int d=0; d<totalD; d++){
      
         if(sparam == indiName+"D"+arrayD.At(d)) ChartChange(arrayD.At(d));
      }


   }
}


void ChartChange(string Pair){

   //long currChart, prevChart=ChartFirst();
   long currChart, prevChart=ChartID();
   int i=0, limit=100;
   
   ChartSetSymbolPeriod(prevChart, Pair, ChartPeriod(prevChart));
   currChart = ChartNext(prevChart);
}

//+------------------------------------------------------------------+

void Label(){

   int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   
   totalA = arrayA.Total();
   totalB = arrayB.Total();
   totalC = arrayC.Total();
   totalD = arrayD.Total();
   
   //配列の個数（一番大きいもの）
   int totalMax = MathMax(MathMax(MathMax(totalA, totalB), totalC),totalD);
   
   double row_space = 1.1;
   double col_space = 2;
   double x_start_pos = 0.1;
   
   for(int a=0; a<totalA; a++){
   
      //LabelCreate(indiName+"A"+arrayA.At(a), arrayA.At(a), width*row_space/(totalMax+1)*(a+1), font_size*col_space*0.5, font_size, font_colorA);
      LabelCreate(indiName+"A"+arrayA.At(a), arrayA.At(a), width*row_space/(totalMax+1)*(a+x_start_pos), font_size*col_space*0.5, font_size, font_colorA);
   }
   
   for(int b=0; b<totalB; b++){
   
      LabelCreate(indiName+"B"+arrayB.At(b), arrayB.At(b), width*row_space/(totalMax+1)*(b+x_start_pos), font_size*col_space*2, font_size, font_colorB);
   }

   for(int c=0; c<totalC; c++){
   
      LabelCreate(indiName+"C"+arrayC.At(c), arrayC.At(c), width*row_space/(totalMax+1)*(c+x_start_pos), font_size*col_space*3.5, font_size, font_colorC);
   }

   for(int d=0; d<totalD; d++){
   
      LabelCreate(indiName+"D"+arrayD.At(d), arrayD.At(d), width*row_space/(totalMax+1)*(d+x_start_pos), font_size*col_space*5.0, font_size, font_colorD);
   }
}


void LabelCreate(string name, string text, int x, int y, int f_size, color LabelColor){

	double val = iRSI(text,PERIOD_H1,14,PRICE_CLOSE,1);

	if(Show_RSI == true)
	{
		text += DoubleToStr(val,0);
	}
	
	LabelColor = getAbsRsiColor(val);

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

void objDelete(string basicName){

   for(int i=ObjectsTotal(); i>=0; i--){
   
      string ObjName = ObjectName(i);
      if(StringFind(ObjName, basicName) >=0) ObjectDelete(ObjName);
   }
}