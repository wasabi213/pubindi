//+------------------------------------------------------------------+
//|                                                                  |
//| spanmodel_special_screenshot.mq4                                 |
//|                                                                  |
//| スパンモデルスペシャルを１時間足ごとにキャプチャする。           |
//|                                                                  |
//| ・テスター上で駆動しながらキャプチャを行う。                     |
//|                                                                  |
//|  ※表示内容                                                 　　 |
//|    -スパンモデル                                                 |
//|    -遅行スパン                                               　  |
//|    -ボリンジャーバンドプライマイナス1シグマ        　　　　　　　|
//|    -ボリンジャーバンドプライマイナス2シグマ        　　　　　　　|
//|                                                    　　　　　　　|
//+------------------------------------------------------------------+

#include <WinUser32.mqh>
#include <Charts\Chart.mqh>

#include <Nagaoka\Util.mqh>
#include <Nagaoka\span_auto_model.mqh>

#import "user32.dll"
   int    MessageBoxA(int hWnd, string lpText, string lpCaption, int uType);
#import

input int CHART_SPEED = 0; //チャートスピード


#property copyright   ""
#property link        ""
#property description "spanmodel special"
#property strict

#property indicator_chart_window

#property indicator_buffers 20
#property indicator_color1 CLR_NONE          // Tenkan-sen
#property indicator_color2 CLR_NONE         // Kijun-sen
#property indicator_color3 RoyalBlue   // Up Kumo
#property indicator_color4 PaleVioletRed     // Down Kumo
#property indicator_color5 Magenta         // Chikou Span
#property indicator_color6 Blue   // Up Kumo bounding line
#property indicator_color7 Crimson      // Down Kumo bounding line

//ボリンジャーバンド
//Bolinger Band Plus1
#property indicator_chart_window
#property indicator_type8  DRAW_LINE
#property indicator_color8 clrBlack

//Bolinger Band Plus2
#property indicator_chart_window
#property indicator_type9  DRAW_LINE
#property indicator_color9 clrBlack

//Bolinger Band Minus1
#property indicator_chart_window
#property indicator_type10  DRAW_LINE
#property indicator_color10 clrOrange
#property indicator_width10 2

//Bolinger Band Minus2
#property indicator_chart_window
#property indicator_type11 DRAW_LINE
#property indicator_color11 clrOrange
#property indicator_width11 2

//Bolinger Band MA
#property indicator_chart_window
#property indicator_type12 DRAW_LINE
#property indicator_color12 clrLimeGreen





//--- input parameters
input int InpTenkan=9;   // Tenkan-sen
input int InpKijun=26;   // Kijun-sen
input int InpSenkou=52;  // Senkou Span B
input int SENDMAIL_FLAG = true; //スパンモデルメール

input int CHART_WIDTH = 1350; //画像の幅
input int CHART_HEIGHT = 450; //画像の高さ
input bool ANSWER_FLAG = true; //回答スクリーンショットを撮るか？
input int ANSWER_SHOT_SHIFT = 35; //回答のスクリーンショット　

input string CHART_TYPE = "spanmodel"; //チャートタイプ



//ボリンジャーバンド初期設定
//MA
input int MAPeriod = 21;
//int hMA;

//BolingerBands
//int hBands_1,hBands_2,hBands_3;
input int BandsPeriod = 21;
input double BandsDeviation_1 = 1.0; 
input double BandsDeviation_2 = 2.0; 
//input double BandsDeviation_3 = 3.0; 





//--- buffers
double ExtTenkanBuffer[];
double ExtKijunBuffer[];
double ExtSpanA_Buffer[];
double ExtSpanB_Buffer[];
double ExtChikouBuffer[];
double ExtSpanA2_Buffer[];
double ExtSpanB2_Buffer[];


//ボリンジャーバンド用バッファ
double Band_Upper_1[];
double Band_Lower_1[];
double Band_Upper_2[];
double Band_Lower_2[];
double MA[];


//---






int    ExtBegin;

datetime LAST_SENDMAIL_TIME;
datetime ANSWER_TIME = 0;


bool CHART_START_FLAG = true;


//チャートシリアルナンバー
int CHART_NUMBER = 0;

int OBJ_COUNTER = 0;




/*-------------------------------------------------------------------*/
// スパンオートシグナル
/*-------------------------------------------------------------------*/


#define SPAN_MODEL_UP 1
#define SPAN_MODEL_DOWN 2
#define SPAN_MODEL_NO_CHANGE 0
int SPAN_MODEL_FLAG = SPAN_MODEL_NO_CHANGE;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
   ObjectsDeleteAll();
   IndicatorDigits(Digits);

   ChartSetInteger(0,CHART_BRING_TO_TOP,0,true);
   ChartSetInteger(0,CHART_FOREGROUND,0,true);

//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtTenkanBuffer);
   SetIndexDrawBegin(0,InpTenkan-1);
   SetIndexLabel(0,"Tenkan Sen");
//---
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtKijunBuffer);
   SetIndexDrawBegin(1,InpKijun-1);
   SetIndexLabel(1,"Kijun Sen");
//---
   ExtBegin=InpKijun;
   if(ExtBegin<InpTenkan)
      ExtBegin=InpTenkan;
//---
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DASH,1);
   SetIndexBuffer(2,ExtSpanA_Buffer);
   SetIndexDrawBegin(2,InpKijun+ExtBegin-1);
   //SetIndexShift(2,InpKijun);
   SetIndexLabel(2,NULL);
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT,2);
   SetIndexBuffer(5,ExtSpanA2_Buffer);
   SetIndexDrawBegin(5,InpKijun+ExtBegin-1);
   //SetIndexShift(5,InpKijun);
   SetIndexLabel(5,"Senkou Span A");
//---
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_DASH,1);
   SetIndexBuffer(3,ExtSpanB_Buffer);
   SetIndexDrawBegin(3,InpKijun+InpSenkou-1);
   //SetIndexShift(3,InpKijun);
   SetIndexLabel(3,NULL);
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT,2);
   SetIndexBuffer(6,ExtSpanB2_Buffer);
   SetIndexDrawBegin(6,InpKijun+InpSenkou-1);
   //SetIndexShift(6,InpKijun);
   SetIndexLabel(6,"Senkou Span B");
//---
   SetIndexStyle(4,DRAW_LINE,1,3);
   SetIndexBuffer(4,ExtChikouBuffer);

   //始値でキャプチャすると遅行スパンの最後の線が平行に移動するため
   //勢いがわかりづらくなるので、１本前までの表示とする。
   //SetIndexShift(4,-InpKijun);
   SetIndexShift(4,-25);
   SetIndexLabel(4,"Chikou Span");
//--- initialization done


//---
//ボリンジャーバンドの設定
    SetIndexBuffer(7,Band_Upper_1);
    SetIndexBuffer(8,Band_Lower_1);
    SetIndexBuffer(9,Band_Upper_2);
    SetIndexBuffer(10,Band_Lower_2);
    SetIndexBuffer(11,MA);


//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtTenkanBuffer,false);
   ArraySetAsSeries(ExtKijunBuffer,false);
   ArraySetAsSeries(ExtSpanA_Buffer,false);
   ArraySetAsSeries(ExtSpanB_Buffer,false);
   ArraySetAsSeries(ExtChikouBuffer,false);
   ArraySetAsSeries(ExtSpanA2_Buffer,false);
   ArraySetAsSeries(ExtSpanB2_Buffer,false);
   
   //ボリンジャーバンドの設定
   ArraySetAsSeries(Band_Upper_1,true);
   ArraySetAsSeries(Band_Lower_1,true);
   ArraySetAsSeries(Band_Upper_2,true);
   ArraySetAsSeries(Band_Lower_2,true);
   ArraySetAsSeries(MA,true);



   
   ApplyTemplate();

 
  }
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo                                               |
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
    ArraySetAsSeries(open,false);
    ArraySetAsSeries(high,false);
    ArraySetAsSeries(low,false);
    ArraySetAsSeries(close,false);
    ArraySetAsSeries(time,false);

    //Print("Working directory is ",TerminalPath());
    //Print(TerminalInfoString(TERMINAL_DATA_PATH));

   int    i,k,pos;
   double high_value,low_value;
  
   double blue_span,previous_blue_span,red_span,previous_red_span;




   //showPrice(open[0],high[0],low[0],close[0]);   


 
   //---
   if(rates_total<=InpTenkan || rates_total<=InpKijun || rates_total<=InpSenkou)
      return(0);
   
   
   
   //ボリンジャーバンド描画
	int limit = rates_total - prev_calculated;
	if(limit == 0) limit = 1;
    if(limit == Bars) limit--;

	for(int i = 0; i <= limit; i++){
        
       Band_Upper_2[i] = iBands(NULL,0,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_UPPER,i);
       Band_Lower_2[i] = iBands(NULL,0,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_LOWER,i); 
   }

  

//--- initial zero

/*
   if(prev_calculated<1)
     {
      for(i=0; i<InpTenkan; i++)
         ExtTenkanBuffer[i]=0.0;
      for(i=0; i<InpKijun; i++)
         ExtKijunBuffer[i]=0.0;
      for(i=0; i<ExtBegin; i++)
        {
         ExtSpanA_Buffer[i]=0.0;
         ExtSpanA2_Buffer[i]=0.0;
        }
      for(i=0; i<InpSenkou; i++)
        {
         ExtSpanB_Buffer[i]=0.0;
         ExtSpanB2_Buffer[i]=0.0;
        }
     }
*/

//--- Tenkan Sen

   pos=InpTenkan-1;
   if(prev_calculated>InpTenkan)
      pos=prev_calculated-1;
   for(i=pos; i<rates_total; i++)
     {
      high_value=high[i];
      low_value=low[i];
      k=i+1-InpTenkan;
      while(k<=i)
        {
         if(high_value<high[k])
            high_value=high[k];
         if(low_value>low[k])
            low_value=low[k];
         k++;
        }
      ExtTenkanBuffer[i]=(high_value+low_value)/2;
     }


//--- Kijun Sen

   pos=InpKijun-1;
   if(prev_calculated>InpKijun)
      pos=prev_calculated-1;
   for(i=pos; i<rates_total; i++)
     {
      high_value=high[i];
      low_value=low[i];
      k=i+1-InpKijun;
      while(k<=i)
        {
         if(high_value<high[k])
            high_value=high[k];
         if(low_value>low[k])
            low_value=low[k];
         k++;
        }
      ExtKijunBuffer[i]=(high_value+low_value)/2;
     }
     
   
     
//--- Senkou Span A 青い線
   pos=ExtBegin-1;
   if(prev_calculated>ExtBegin)
      pos=prev_calculated-1;
   for(i=pos; i<rates_total; i++)
     {
      ExtSpanA_Buffer[i]=(ExtKijunBuffer[i]+ExtTenkanBuffer[i])/2;
      ExtSpanA2_Buffer[i]=ExtSpanA_Buffer[i];

      //Print("先行スパンA:" + ExtSpanA2_Buffer[i]);

     }

      //Print("先行スパンA:" + ExtSpanA2_Buffer[rates_total-1]);
      //Print("先行スパンA-10:" + ExtSpanA2_Buffer[rates_total-10]);

    blue_span = ExtSpanA2_Buffer[rates_total-2];
    previous_blue_span = ExtSpanA2_Buffer[rates_total-3];


//--- Senkou Span B 赤い線
   pos=InpSenkou-1;
   if(prev_calculated>InpSenkou)
      pos=prev_calculated-1;
   for(i=pos; i<rates_total; i++)
     {
      high_value=high[i];
      low_value=low[i];
      k=i+1-InpSenkou;
      while(k<=i)
        {
         if(high_value<high[k])
            high_value=high[k];
         if(low_value>low[k])
            low_value=low[k];
         k++;
        }
      ExtSpanB_Buffer[i]=(high_value+low_value)/2;
      ExtSpanB2_Buffer[i]=ExtSpanB_Buffer[i];
     }

      //Print("先行スパンB:" + ExtSpanB2_Buffer[rates_total-1]);
      //Print("先行スパンB-10:" + ExtSpanB2_Buffer[rates_total-10]);

    red_span = ExtSpanB2_Buffer[rates_total-2];
    previous_red_span = ExtSpanB2_Buffer[rates_total-3];


//--- Chikou Span
//   pos = 0;
//   if(prev_calculated > 1){
//       pos=prev_calculated - 1;
//   }
//
//   for(i=pos; i<rates_total; i++){
//      ExtChikouBuffer[i]=close[i];
//   }

   //始値が表示された時点でキャプチャしているため、最後の遅行スパンが平行になり見にくいので
   //最新の遅行スパンを表示しないようにした。
   pos = 0;
   if(prev_calculated > 1){
       pos=prev_calculated - 1;
   }

   for(i=pos; i<rates_total; i++){
      if(i <= 1) continue;
   
      //ExtChikouBuffer[i - 1] = close[i - 1];
      ExtChikouBuffer[i] = close[i];
   }


//---


    showTime(i,time,high,low,rates_total);
    
    
    //Print("time[rates_total-1]:" + time[rates_total-1]);
    
    
    if(rates_total > 22){

      if(time[rates_total-1] > ANSWER_TIME){
        
            //ChartStop();
            //takeScreenShot(time[rates_total-1]);
            //ChartStart();

            ANSWER_TIME = time[rates_total-1];
      }


    }

    //Print("test");

    int ret = isSpanModelChange(ExtSpanA2_Buffer,ExtSpanB2_Buffer);
    showRectangle(ret);

    return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// スパンモデルが転換したかの判定
//+------------------------------------------------------------------+


int isSpanModelChange(const double &blue_span[],const double &red_span[]){

    //Print("isSpanModelChange");
    int idx2 = Bars - 2; //２本前のインデックス
    int idx1 = Bars - 1; //１本前のインデックス

    //スパンモデルフラグが上昇に転換したかどうかの判定
    if(SPAN_MODEL_FLAG != SPAN_MODEL_UP && blue_span[idx2] < red_span[idx2] && blue_span[idx1] >= red_span[idx1]){
        
        SPAN_MODEL_FLAG = SPAN_MODEL_UP;
        Print("SPAN BLUE ON");

        return SPAN_MODEL_UP;
    
    }
    else if(SPAN_MODEL_FLAG != SPAN_MODEL_DOWN && blue_span[idx2] > red_span[idx2] && blue_span[idx1] <= red_span[idx1]){
        SPAN_MODEL_FLAG = SPAN_MODEL_DOWN;
 
        Print("SPAN RED ON");
        return SPAN_MODEL_DOWN;
    
    }
    
    //SPAN_MODEL_FLAG = SPAN_MODEL_NO_CHANGE;
    
    //スパンモデルフラグに変更がない場合は現在の状態を返す。
    return SPAN_MODEL_NO_CHANGE;
    
    

}
//+------------------------------------------------------------------+
// スパンモデルシグナル矩形の表示
//+------------------------------------------------------------------+

int RECTANGLE_LIMIT = 7;
int START_BAR_COUNT = 0;

//表示中フラグ
#define BLUE_RECTANGLE 1
#define RED_RECTANGLE  2
#define NO_RECTANGLE   0
int RECTANGLE_FLAG = NO_RECTANGLE;

string CURRENT_OBJECT_NAME = "";

void showRectangle(int status){

    string objName = "";

    //スパンモデルフラグがUPに転換した場合
    if(status == SPAN_MODEL_UP){
    
        //矩形の本数カウントを0にする。
        RECTANGLE_FLAG = BLUE_RECTANGLE;
        //START_TIME = Time[0];
        //最初の矩形オブジェクトを作成する。
        CURRENT_OBJECT_NAME = createFirstRectangle();
        
        START_BAR_COUNT = Bars;
        
        return;
    }
    //スパンモデルフラグがDOWNに転換した場合
    else if(status == SPAN_MODEL_DOWN){



        //矩形の本数カウントを0にする。
        RECTANGLE_FLAG = RED_RECTANGLE;
        //START_TIME = Time[0];
        //最初の矩形オブジェクトを作成する。
        CURRENT_OBJECT_NAME = createFirstRectangle();
        //RECTANGLE_COUNT++;

        Print("SPAN_MODEL_DOWN");

        START_BAR_COUNT = Bars;
        
        return;
    
    }
    

    //if(START_TIME == Time[0]){
    //    return;
    //}

    //START_TIME = Time[0];

    int pass_count = Bars - START_BAR_COUNT;

    if(pass_count > RECTANGLE_LIMIT){
        RECTANGLE_FLAG = NO_RECTANGLE;
        //RECTANGLE_COUNT = 0;
    }

    if(RECTANGLE_FLAG == BLUE_RECTANGLE){
    

    
        //Print("RECTANGLE_COUNT:" + RECTANGLE_COUNT);
    
        //転換スタートからの高値を取得する
        int highest = getHighest(pass_count + 1);
        //転換スタートからの安値を取得する。
        int lowest = getLowest(pass_count + 1);

        ObjectMove(CURRENT_OBJECT_NAME, 0, Time[pass_count], High[highest]);
        ObjectMove(CURRENT_OBJECT_NAME, 1, Time[0], Low[lowest]);
        ChartRedraw(0);
 
     
    }else if(RECTANGLE_FLAG == RED_RECTANGLE){
    
        //Print("RECTANGLE_COUNT:" + RECTANGLE_COUNT);
    
        //転換スタートからの高値を取得する
        int highest = getHighest(pass_count + 1);
        //転換スタートからの安値を取得する。
        int lowest = getLowest(pass_count + 1);

        ObjectMove(CURRENT_OBJECT_NAME, 0, Time[pass_count], High[highest]);
        ObjectMove(CURRENT_OBJECT_NAME, 1, Time[0], Low[lowest]);
        ChartRedraw(0);

    }

 

}
//+------------------------------------------------------------------+
// 下値抵抗線の表示
//+------------------------------------------------------------------+

int getHighest(int count){

    int wk = 0;
    for(int i = 0 ; i < count; i++){
        if(High[i] > High[wk]){
            wk = i;
        }
    }
    return wk;
}
int getLowest(int count){

    int wk = 0;
    for(int i = 0 ; i < count; i++){
        if(Low[i] < Low[wk]){
            wk = i;
        }
    }
    return wk;
}

//+------------------------------------------------------------------+
// 最初の矩形オブジェクトを作成する。
//+------------------------------------------------------------------+
string createFirstRectangle(){

    Print("createFirstRectangle");

    string objName = "obj" + IntegerToString(Bars);
    if(ObjectFind(objName) < 0){
    
        Print("createFirstRectangle:"+objName);
        
        double h = MathMax(High[1],High[0]);
        double l = MathMin(Low[1],Low[0]);
        
        ObjectCreate(objName, OBJ_RECTANGLE,0,Time[1],h,Time[0],l); 
        ObjectSetInteger(0,objName,OBJPROP_COLOR,clrLime);
    }

    return objName;
}

//+------------------------------------------------------------------+
// 赤色スパンが向きを変えたかの判定
//+------------------------------------------------------------------+
#define RED_SPAN_UP 1
#define RED_SPAN_DOWN 2
#define RED_SPAN_NO_CHANGE 0
int RED_SPAN_FLAG = RED_SPAN_NO_CHANGE;

int isRedSpanDirectionChange(const double &red_span[]){

    //赤色スパンが下向きに転換した場合
    if(RED_SPAN_FLAG != RED_SPAN_DOWN && red_span[2] > red_span[1]){
        RED_SPAN_FLAG = RED_SPAN_DOWN;
        return RED_SPAN_DOWN;
    }
    //赤色スパンが上向きに転換した場合
    else if(RED_SPAN_FLAG != RED_SPAN_UP && red_span[2] < red_span[1]){
        RED_SPAN_FLAG = RED_SPAN_UP;
        return RED_SPAN_UP;
    }

    return RED_SPAN_NO_CHANGE;

}


//+------------------------------------------------------------------+
// スパンモデル転換
// 縦の破線を表示
// 
//+------------------------------------------------------------------+
void createBuleVerticalLine(){

    string objName = "bule_vline_" + IntegerToString(Bars);
    ObjectCreate(0,objName,OBJ_VLINE,0,Time[1],0);
    ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlue);
    ObjectSetInteger(0,objName,OBJPROP_STYLE,STYLE_DASHDOT);


}
//+------------------------------------------------------------------+
// スパンモデル転換
// 背景色変更
// 
//+------------------------------------------------------------------+
void createBlueBackGround(){

    string objName = "blue_background_" + IntegerToString(Bars);

    if(ObjectFind(objName) < 0){
        ObjectCreate(0,objName,OBJ_RECTANGLE,0,Time[1],WindowPriceMax(0),Time[0],WindowPriceMin(0));
    }
    ObjectSet(objName, OBJPROP_COLOR, LimeGreen);
    ObjectSet(objName, OBJPROP_PRICE1, WindowPriceMax(0));
    ObjectSet(objName, OBJPROP_PRICE2, WindowPriceMin(0));
    //ObjectSet(objName, OBJPROP_TIME1, left);
    ObjectSet(objName, OBJPROP_TIME2, Time[0]);
}
//+------------------------------------------------------------------+
// 赤色スパン転換
// ・背景色変更
// ・縦の破線を表示
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// 上値抵抗線の表示
//+------------------------------------------------------------------+
void createHorizontalLine(datetime t,double price){

    string objName = "hline_" + IntegerToString(Bars);

    if(ObjectFind(objName) <0){
        ObjectCreate(0,objName,OBJ_HLINE,0,Time[1],High[1]);
    }
    
    ObjectSet(objName, OBJPROP_COLOR, LimeGreen);
    ObjectSet(objName, OBJPROP_PRICE1, WindowPriceMax(0));
    ObjectSet(objName, OBJPROP_PRICE2, WindowPriceMin(0));
    //ObjectSet(objName, OBJPROP_TIME1, left);
    ObjectSet(objName, OBJPROP_TIME2, Time[0]);
    
    

}


//+------------------------------------------------------------------+







bool checkTime(datetime prev_time,datetime current_time){

    MqlDateTime prev,current;

    //現在時刻が前回時刻より前であればリターン
    if(current_time <= prev_time) return false;
    
    TimeToStruct(prev_time,prev);
    TimeToStruct(current_time,current);

    return false;
}


void showTime(int cnt,const datetime &tm[], const double &high[], const double &low[],  int rates_total){

    MqlDateTime t1,t2; 

    TimeToStruct(tm[rates_total - 2],t1);
    TimeToStruct(tm[rates_total - 3],t2);  

    //Print("t1.min:"+t1.min);
    //Print("t1.hour:"+t1.hour);

  
    if(t1.min == 0 )                makeDisplayTimeString( t1.hour,tm[rates_total - 2],high[rates_total - 2],clrBlack);
    if(t1.hour == 0 && t1.min == 0) makeDisplayDayString(  t1.day, tm[rates_total - 2],high[rates_total - 2],clrRed);
    if(t1.mon != t2.mon)            makeDisplayMonthString(t1.mon, tm[rates_total - 2],low[rates_total  - 2],clrBlue);

}
/**
 * チャート左上に価格を表示する。
 *
 */
void showPrice(double o, double h, double l, double c){

    int x_dst = 10;
    int y_dst = 0;
    
 
    double wk_close = 0;
    int int_close = 0;
    double result_close = 0;
        
    string txt_close = "";   
        
    if( c < 10 ){
        wk_close = MathFloor(c * 10000);
        result_close = NormalizeDouble(wk_close / 10000,5);
        txt_close = DoubleToStr(result_close,4);

    }else{
        wk_close = MathFloor(c * 100);
        result_close = NormalizeDouble(wk_close / 100,3);
        txt_close = DoubleToStr(result_close,2);

    }
    
        
    ObjectDelete("price");
    ObjectCreate("price", OBJ_LABEL, 0, 0, 0);
    ObjectSet("price", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSet("price", OBJPROP_XDISTANCE, x_dst); // 左から30ピクセル
    ObjectSet("price", OBJPROP_YDISTANCE, y_dst); // 上から40ピクセル
    //ObjectSetText("price",txt_close,9,"HGPｺﾞｼｯｸE",clrBlack);
    ObjectSetText("price","CLOSE:" + txt_close,20,"HGS創英角ｺﾞｼｯｸUB",clrBlue);
    ChartRedraw(0);

}


void makeDisplayTimeString(int time,datetime p_tm,double p_high,int p_color){


    if(getChartPeriodString() != "H1") return;

    //string objName   = "hour_" + IntegerToString(Bars);
    string objName   = "hour_" + IntegerToString(Bars);
    string time_text = IntegerToString(time);

    string font   = "Arial";
    int font_size = 11;
    int chart_ID  = 0;    

    ObjectDelete(objName);
    ObjectCreate(objName, OBJ_TEXT,0,p_tm,p_high);
    ObjectSetString(chart_ID,objName,OBJPROP_TEXT,time_text);
    ObjectSetString(chart_ID,objName,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,objName,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,objName,OBJPROP_COLOR,p_color);
    ObjectSetInteger(chart_ID,objName,OBJPROP_ANCHOR,ANCHOR_LOWER);
    ObjectSetDouble(chart_ID,objName,OBJPROP_ANGLE,0.0);  
    ChartRedraw(0);

}
void makeDisplayDayString(int time,datetime p_tm,double p_high,int p_color){



    string objName = "Day_" + IntegerToString(Bars);
    //string objName = "Day_" + IntegerToString(++OBJ_COUNTER);
    string time_text = IntegerToString(time) + "日";

    string font = "HGS創英角ｺﾞｼｯｸUB";

    int font_size = 12;

    if(getChartPeriodString() == "D1"){
        //time_text = IntegerToString(time); 
        font = "Arial";
        font_size = 10;
        p_color = clrBlack;
    
    }

    int chart_ID = 0;    

    ObjectDelete(objName);
    ObjectCreate(objName, OBJ_TEXT,0,p_tm,p_high + _Point*10);
    ObjectCreate(objName, OBJ_TEXT,0,p_tm,p_high);
    ObjectSetString(chart_ID,objName,OBJPROP_TEXT,time_text);
    ObjectSetString(chart_ID,objName,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,objName,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,objName,OBJPROP_COLOR,p_color);
    ObjectSetInteger(chart_ID,objName,OBJPROP_ANCHOR,ANCHOR_LOWER);
    ObjectSetDouble(chart_ID,objName,OBJPROP_ANGLE,0.0);  
    //ChartRedraw(0);

    //Print("makeDisplayDayString end");

}

void makeDisplayMonthString(int mon, datetime time ,double low,int p_color){


    //Alert("makeDisplayMonthString start");
    
    string objName = "Month_" + IntegerToString(Bars);
    string time_text = IntegerToString(mon) + "月";
    
    string font = "HGS創英角ｺﾞｼｯｸUB";
    
    int font_size = 15;
    int chart_ID = 0;    
    
    //Print("_Point:" + _Point);
    
    ObjectDelete(objName);

    ObjectCreate(objName, OBJ_TEXT,0,time,low - _Point*10);
    ObjectSetString(chart_ID,objName,OBJPROP_TEXT,time_text);
    ObjectSetString(chart_ID,objName,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,objName,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,objName,OBJPROP_COLOR,p_color);
    ObjectSetInteger(chart_ID,objName,OBJPROP_ANCHOR,ANCHOR_LOWER);
    ObjectSetDouble(chart_ID,objName,OBJPROP_ANGLE,0.0);  
    ChartRedraw(0);
    
    Alert("makeDisplayMonthString end");
    

}
//+------------------------------------------------------------------+
//---
// スクリーンショット取得
//
void takeScreenShot(datetime tm){

    string nm_front =   "spanmodel" + "\\" + _Symbol + "\\" + getChartPeriodString() + "\\";

    string chart_start_time = TimeToString(tm);
    setChartTitle(chart_start_time);

    StringReplace(chart_start_time,".","");
    StringReplace(chart_start_time," ","");     
    StringReplace(chart_start_time,":","");     

    //string title = nm_front + chart_start_time;
    string nm = nm_front + chart_start_time + ".gif";

    showSerialNumber();
    shot(nm);

}

void showTitle(string title){

    int x_dst = 400;
    int y_dst = 0;
        
    ObjectDelete("title");
    ObjectCreate("title", OBJ_LABEL, 0, 0, 0);
    ObjectSet("title", OBJPROP_XDISTANCE, x_dst); // 左から30ピクセル
    ObjectSet("title", OBJPROP_YDISTANCE, y_dst); // 上から40ピクセル
    ObjectSetText("title",title,20,"HGPｺﾞｼｯｸE",clrBlack);
    ChartRedraw(0);

}

void showSerialNumber(){

    int x_dst = 230;
    int y_dst = 0;
        
    ObjectDelete("serial_number");
    ObjectCreate("serial_number", OBJ_LABEL, 0, 0, 0);
    ObjectSet("serial_number", OBJPROP_XDISTANCE, x_dst); // 左から30ピクセル
    ObjectSet("serial_number", OBJPROP_YDISTANCE, y_dst); // 上から40ピクセル
    ObjectSetText("serial_number","No." + ++CHART_NUMBER,20,"HGPｺﾞｼｯｸE",clrBlack);
    ChartRedraw(0);

}

void setChartTitle(string title_date){

    int x_dst = 450;
    int y_dst = 0;
        
    ObjectDelete("start_date");
    ObjectCreate("start_date", OBJ_LABEL, 0, 0, 0);
    ObjectSet("start_date", OBJPROP_XDISTANCE, x_dst); // 左から30ピクセル
    ObjectSet("start_date", OBJPROP_YDISTANCE, y_dst); // 上から40ピクセル
    ObjectSetText("start_date",title_date,20,"HGPｺﾞｼｯｸE",clrBlack);
    ChartRedraw(0);

}


void shot(string filename){



    bool ret = ChartScreenShot(0,filename,CHART_WIDTH,CHART_HEIGHT,ALIGN_LEFT);        

    if(ret == false) Print("ScreenShot error");

    //ChartStart();

}


void ChartStop(){

    if(CHART_START_FLAG == false) return;

    int hwnd = WindowHandle(_Symbol,_Period);
    PostMessageA(hwnd, WM_KEYDOWN, 19, 0);//19=Pause
    PostMessageA(hwnd, WM_KEYUP, 19, 0);
    CHART_START_FLAG = false;  
      
}

void ChartStart(){

    if(CHART_START_FLAG == true) return;
    int hwnd = WindowHandle(_Symbol,_Period);
    PostMessageA(hwnd, WM_KEYDOWN, 19, 0);//19=Pause
    PostMessageA(hwnd, WM_KEYUP, 19, 0);
    CHART_START_FLAG = true;  

}


  

