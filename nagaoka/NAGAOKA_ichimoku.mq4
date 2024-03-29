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

#property indicator_buffers 30

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


//ichimoku
//#property indicator_chart_window
//#property indicator_type13 DRAW_LINE
//#property indicator_color13 clrBlue
//#property indicator_width13 2

//#property indicator_chart_window
//#property indicator_type14 DRAW_LINE
//#property indicator_color14 clrRed
//#property indicator_width14 2

#property indicator_chart_window
#property indicator_type15 DRAW_LINE
#property indicator_color15 clrDodgerBlue
 
#property indicator_width15 3

#property indicator_chart_window
#property indicator_type16 DRAW_LINE
#property indicator_color16 clrRed
#property indicator_width16 3



#property indicator_chart_window
#property indicator_type17 DRAW_LINE
#property indicator_color17 clrMagenta
#property indicator_width17 3



#property indicator_chart_window
#property indicator_type18 DRAW_HISTOGRAM
//#property indicator_color17 clrMagenta
//#property indicator_width17 2
#property indicator_chart_window
#property indicator_type19 DRAW_HISTOGRAM





input int  SENDMAIL_FLAG = true; //スパンモデルメール

input int  CHART_WIDTH = 1350; //画像の幅
input int  CHART_HEIGHT = 450; //画像の高さ
input bool ANSWER_FLAG = true; //回答スクリーンショットを撮るか？
input int  ANSWER_SHOT_SHIFT = 35; //回答のスクリーンショット　

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







double Tenkansen[];
double Kijunsen[];
double SenkouSpanA[];
double SenkouSpanB[];
double Chikouspan[];

double ExtSpanA_Buffer[]; //雲
double ExtSpanB_Buffer[]; //雲

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

//スパンモデルが転換したか
#define SPAN_MODEL_UP 1 //スパンモデルが上昇に転換
#define SPAN_MODEL_DOWN 2 //スパンモデルが下落に転換
#define SPAN_MODEL_NO_CHANGE 0 //スパンモデルに変更なし
int SPAN_MODEL_FLAG = SPAN_MODEL_NO_CHANGE;

//現在のスパンモデルの状態
#define SPAN_STATUS_UP 1
#define SPAN_STATUS_DOWN 2
#define SPAN_STATUS_NOCHANGE 0
int SPAN_STATUS = SPAN_STATUS_NOCHANGE;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
   ObjectsDeleteAll();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   IndicatorDigits(Digits);

   ChartSetInteger(0,CHART_BRING_TO_TOP,0,true);
   ChartSetInteger(0,CHART_FOREGROUND,0,true);


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
    //SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DASH,1);


//ichimoku

    SetIndexBuffer(12,Tenkansen);
    SetIndexBuffer(13,Kijunsen);
    SetIndexBuffer(14,SenkouSpanA);
    SetIndexBuffer(15,SenkouSpanB);
    SetIndexBuffer(16,Chikouspan);
 
 
 //////////////////////////////////////////////////////////////////   
    

   SetIndexBuffer(18,ExtSpanA_Buffer);
   SetIndexStyle(18,DRAW_HISTOGRAM,STYLE_DOT,1,clrBlue);   //SetIndexDrawBegin(18,InpKijun+ExtBegin-1);
 
  
   SetIndexBuffer(19,ExtSpanB_Buffer);
   SetIndexStyle(19,DRAW_HISTOGRAM,STYLE_DOT,1,clrRed); 
 //////////////////////////////////////////////////////////////////   
   
   //ボリンジャーバンドの設定
   ArraySetAsSeries(Band_Upper_1,true);
   ArraySetAsSeries(Band_Lower_1,true);
   ArraySetAsSeries(Band_Upper_2,true);
   ArraySetAsSeries(Band_Lower_2,true);
   ArraySetAsSeries(MA,true);

   ArraySetAsSeries(Tenkansen,true);
   ArraySetAsSeries(Kijunsen,true);
   ArraySetAsSeries(SenkouSpanA,true);
   ArraySetAsSeries(SenkouSpanB,true);
   ArraySetAsSeries(Chikouspan,true);

    ArraySetAsSeries(ExtSpanA_Buffer,true);
    ArraySetAsSeries(ExtSpanB_Buffer,true);
	
	//遅行スパンの最後に不要な線が描画されないようにする。
	SetIndexShift(16,-25);
   
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

    int i,k,pos;
    int span_status;
    double high_value,low_value;
  
    double blue_span,previous_blue_span,red_span,previous_red_span;
      
    //ボリンジャーバンド描画
	int limit = rates_total - prev_calculated;
    if(limit == Bars) limit--;
    
	for(int i = limit; i >= 0; i--){

        Band_Upper_2[i] = iBands(NULL,0,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_UPPER,i);
        Band_Lower_2[i] = iBands(NULL,0,BandsPeriod,BandsDeviation_2,0,PRICE_CLOSE,MODE_LOWER,i); 


        // 転換線
        //Tenkansen[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_TENKANSEN, i);
        // 基準線
        //Kijunsen[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_KIJUNSEN, i);
        // 先行スパンA 青い線
        SenkouSpanA[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_SENKOUSPANA, i - 25);
        // 先行スパンB
        SenkouSpanB[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_SENKOUSPANB, i - 25);
        
        //Print(i);
        //Print(ArraySize(ExtSpanA_Buffer));
        //Print(ArraySize(ExtSpanB_Buffer));
        ExtSpanA_Buffer[i] = SenkouSpanA[i];
        ExtSpanB_Buffer[i] = SenkouSpanB[i];
        
        // 遅行線
        //Chikouspan[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_CHIKOUSPAN, i);
        Chikouspan[i] = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, i);
        
        //スパンモデルの状態を設定する。
        setSpanmodelStatus(SenkouSpanA[i],SenkouSpanB[i]);
        
        span_status = isSpanModelChange(i,SenkouSpanA,SenkouSpanB);
        showRectangle(i,span_status);
   

        int redspan_status = isRedSpanDirectionChange(i,SenkouSpanB);
        createVerticalRedspanChangeLine(i,redspan_status);
        //Print("i:" + i);
        setBackGroundColor(i,redspan_status);

   }
   
    showPrice(open[0],high[0],low[0],close[0]);

    //showTime(i,time,high,low,rates_total);
    showTime(0,time,high,low,rates_total);
    
    showChartInfo();
    
    //ChartStop();
    takeScreenShot(span_status);
    //ChartStart();

    return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// スパンモデルが転換したかの判定
//+------------------------------------------------------------------+
int isSpanModelChange(int bar_num,const double &blue_span[],const double &red_span[]){

    if(bar_num >= Bars - 2){
        return SPAN_MODEL_NO_CHANGE;
    }

    //Print("isSpanModelChange");
    int idx2 = bar_num + 2; //２本前のインデックス
    int idx1 = bar_num + 1; //１本前のインデックス

    int ret = SPAN_MODEL_NO_CHANGE;

    //スパンモデルフラグが上昇に転換したかどうかの判定
    if(SPAN_MODEL_FLAG != SPAN_MODEL_UP && blue_span[idx2] < red_span[idx2] && blue_span[idx1] >= red_span[idx1]){
        
        SPAN_MODEL_FLAG = SPAN_MODEL_UP;
        Print("SPAN BLUE ON");

        ret = SPAN_MODEL_UP;
    
    }
    else if(SPAN_MODEL_FLAG != SPAN_MODEL_DOWN && blue_span[idx2] > red_span[idx2] && blue_span[idx1] <= red_span[idx1]){
        SPAN_MODEL_FLAG = SPAN_MODEL_DOWN;
 
        Print("SPAN RED ON");
        ret = SPAN_MODEL_DOWN;
    
    }
 
    return ret;
}
//+------------------------------------------------------------------+
// スパンモデルの状態を設定する。
// spanA:青い線
// spanB:赤い線
//+------------------------------------------------------------------+
void setSpanmodelStatus(double spanA,double spanB){

    if(spanA > spanB){
        SPAN_STATUS = SPAN_STATUS_UP;
    }else if(spanA < spanB){
        SPAN_STATUS = SPAN_STATUS_DOWN;
    } 
    

}
//+------------------------------------------------------------------+
// スパンモデルシグナル矩形の表示
//+------------------------------------------------------------------+

int RECTANGLE_LIMIT = 8;
int START_BAR_COUNT = 0;

//表示中フラグ
#define BLUE_RECTANGLE 1
#define RED_RECTANGLE  2
#define NO_RECTANGLE   0
int RECTANGLE_FLAG = NO_RECTANGLE;

string CURRENT_OBJECT_NAME = "";

int PASS_COUNT = 0;
datetime START_BAR_TIME = 0;

double LIMIT_HIGHEST = 0;
double LIMIT_LOWEST  = 0;
int START_SPAN_STATUS = 0;

datetime LIMIT_LINE_START_TIME = 0;
void showRectangle(int bar_num,int status){

    if(bar_num > Bars - 3){
        return;
     }

    string objName = "";

    //スパンモデルフラグがUPに転換した場合
    if(status == SPAN_MODEL_UP){
    
        RECTANGLE_FLAG = BLUE_RECTANGLE;

        //最初の矩形オブジェクトを作成する。
        CURRENT_OBJECT_NAME = createFirstRectangle(bar_num);
        
        START_BAR_TIME = Time[bar_num + 1];
        
        PASS_COUNT = 0;
        
        return;
    }
    //スパンモデルフラグがDOWNに転換した場合
    else if(status == SPAN_MODEL_DOWN){

        //矩形の本数カウントを0にする。
        RECTANGLE_FLAG = RED_RECTANGLE;
        //START_TIME = Time[0];
        //最初の矩形オブジェクトを作成する。
        CURRENT_OBJECT_NAME = createFirstRectangle(bar_num);
        START_BAR_TIME = Time[bar_num + 1];
        PASS_COUNT = 0;
        
        return;
    
    }
    
    PASS_COUNT = getBarShift(START_BAR_TIME,bar_num);

    double line_width = (WindowPriceMax(0) - WindowPriceMin(0)) / 200; 
  
    if(PASS_COUNT > RECTANGLE_LIMIT){
        
        RECTANGLE_FLAG = NO_RECTANGLE;
        PASS_COUNT = 0;
        //LIMIT_LINE_START_TIME = Time[bar_num];
    
        //Print(__LINE__ + ":PASS_COUNT:" + PASS_COUNT);
        //Print(__LINE__ + ":RECTANGLE_LIMIT:" + RECTANGLE_LIMIT);
    
        //Print(LIMIT_LINE_START_TIME);        
        //return;
    }
    
    if(RECTANGLE_FLAG == NO_RECTANGLE){

        if(ObjectFind(LIMIT_LINE_OBJ) < 0){ 
            LIMIT_LINE_OBJ = "limit" + objName;
            LIMIT_LINE_START_TIME = Time[bar_num + 1];  
            double line_pos;
            int rect_color = clrWhite;
            if(SPAN_STATUS == SPAN_STATUS_UP){
                line_pos = LIMIT_HIGHEST ;
                rect_color = clrPowderBlue;
            }
            else if(SPAN_STATUS == SPAN_STATUS_DOWN){
                line_pos = LIMIT_LOWEST;
                rect_color = clrMoccasin;
            }
            
            //Print(LIMIT_LINE_START_TIME);
            
            ObjectCreate(LIMIT_LINE_OBJ, OBJ_RECTANGLE,0,LIMIT_LINE_START_TIME,line_pos,Time[bar_num],line_pos); 
            ObjectSetInteger(0,LIMIT_LINE_OBJ,OBJPROP_COLOR,rect_color);
        }
    }

    if(RECTANGLE_FLAG == BLUE_RECTANGLE && PASS_COUNT <= RECTANGLE_LIMIT){
    
        int highest = iHighest(NULL,0,MODE_HIGH,PASS_COUNT ,bar_num);
        int lowest = iLowest(NULL,0,MODE_LOW,PASS_COUNT ,bar_num);
        //Print("PASS_COUNT:"+ PASS_COUNT);

        ObjectMove(LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, High[highest]);
        //ObjectMove(LIMIT_LINE_OBJ, 0, START_BAR_TIME, High[highest]);
        ObjectMove(LIMIT_LINE_OBJ, 1, Time[bar_num], High[highest] - line_width);

        //ObjectMove(CURRENT_OBJECT_NAME, 0, Time[bar_num + PASS_COUNT], High[highest]);
        //ObjectMove(CURRENT_OBJECT_NAME, 1, Time[bar_num], Low[lowest]);
        ObjectMove(CURRENT_OBJECT_NAME, 0, START_BAR_TIME, High[highest]);
        ObjectMove(CURRENT_OBJECT_NAME, 1, Time[bar_num], Low[lowest]);

        ChartRedraw(0);

        LIMIT_HIGHEST = High[highest];
        LIMIT_LOWEST  = Low[lowest];
        
        //矩形を作成した時点のスパンモデルの状態を保持する。
        START_SPAN_STATUS = SPAN_STATUS;
                
        
    }else if(RECTANGLE_FLAG == RED_RECTANGLE && PASS_COUNT <= RECTANGLE_LIMIT){
        int highest = iHighest(NULL,0,MODE_HIGH,PASS_COUNT ,bar_num);
        int lowest = iLowest(NULL,0,MODE_LOW,PASS_COUNT ,bar_num);
    
        //Print("lowest:" + Low[lowest]);
        //Print("Low   :" + Low[bar_num]);
    
        ObjectMove(LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, Low[lowest]);
        ObjectMove(LIMIT_LINE_OBJ, 1, Time[bar_num], Low[lowest] + line_width);     
    
        //ObjectMove(CURRENT_OBJECT_NAME, 0, Time[bar_num + PASS_COUNT], High[highest]);
        //ObjectMove(CURRENT_OBJECT_NAME, 1, Time[bar_num], Low[lowest]);
        
        ObjectMove(CURRENT_OBJECT_NAME, 0, START_BAR_TIME, High[highest]);
        ObjectMove(CURRENT_OBJECT_NAME, 1, Time[bar_num], Low[lowest]);
        
        ChartRedraw(0);

        LIMIT_HIGHEST = High[highest];
        LIMIT_LOWEST  = Low[lowest];

        //矩形を作成した時点のスパンモデルの状態を保持する。
        START_SPAN_STATUS = SPAN_STATUS;

    }


    if(START_SPAN_STATUS == SPAN_STATUS_UP){
        ObjectMove(LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, LIMIT_HIGHEST);
        ObjectMove(LIMIT_LINE_OBJ, 1, Time[bar_num], LIMIT_HIGHEST - line_width);
        ObjectSetInteger(0,LIMIT_LINE_OBJ,OBJPROP_COLOR,clrPowderBlue);
    }
    
    else if(START_SPAN_STATUS == SPAN_STATUS_DOWN){
        ObjectMove(LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, LIMIT_LOWEST);
        ObjectMove(LIMIT_LINE_OBJ, 1, Time[bar_num], LIMIT_LOWEST + line_width);
        ObjectSetInteger(0,LIMIT_LINE_OBJ,OBJPROP_COLOR,clrMoccasin);
    }

    //スパンモデルステータスが転換したらLIMIT_LINEオブジェクトを削除する。
    
}

int getBarShift(datetime t,int bar_num){

    int count = 0;

    if(bar_num >= Bars - 100){
        return 0;
    }
    for(int i = Bars; i >= 0; i--){
        if(bar_num >= Bars){
            return 0;
        }

        if(t > Time[bar_num++]){
            break;
        }
        count++;

    }
    return count;
}
//+------------------------------------------------------------------+ 
// 最初の矩形オブジェクトを作成する。
//+------------------------------------------------------------------+
string LIMIT_LINE_OBJ = "";

string createFirstRectangle(int bar_num){

    string objName = "obj" + IntegerToString(Bars - bar_num);
    if(ObjectFind(objName) > 0){
        return objName; 
    }

    int rect_color = 0;
    int line_color = 0;
    if(RECTANGLE_FLAG == BLUE_RECTANGLE){
        rect_color = clrPaleTurquoise;
        line_color = clrBlue;
        //ObjectDelete(0,LIMIT_LINE_OBJ);
        //ChartRedraw(0);
    }
    else if(RECTANGLE_FLAG == RED_RECTANGLE){
        rect_color = clrNavajoWhite;
        line_color = clrRed;
        //ObjectDelete(0,LIMIT_LINE_OBJ);
        //ChartRedraw(0);

    }else{
        return objName;
    }
   
    double h = MathMax(High[bar_num + 1],High[bar_num]);
    double l = MathMin(Low[bar_num + 1],Low[bar_num]);
    
    //矩形の新規作成
    ObjectCreate(objName, OBJ_RECTANGLE,0,Time[bar_num + 1],h,Time[bar_num],l); 
    ObjectSetInteger(0,objName,OBJPROP_COLOR,rect_color);

    //LIMIT_LINEの新規作成
    
    LIMIT_LINE_OBJ = "limit" + objName;
    
    double line_pos;
    if(SPAN_STATUS == SPAN_STATUS_UP){
        line_pos = h;
    }
    else if(SPAN_STATUS == SPAN_STATUS_DOWN){
        line_pos = l;
    }
    
    //ObjectCreate(LIMIT_LINE_OBJ, OBJ_RECTANGLE,0,Time[bar_num + 1],line_pos,Time[bar_num],line_pos + 0.01); 
    //ObjectSetInteger(0,LIMIT_LINE_OBJ,OBJPROP_COLOR,rect_color);




    string objVlineName = "blue_vline_" + IntegerToString(Bars - bar_num);
    ObjectCreate(0,objVlineName,OBJ_VLINE,0,Time[bar_num + 1],0);
    ObjectSetInteger(0,objVlineName,OBJPROP_COLOR,line_color);
    ObjectSetInteger(0,objVlineName,OBJPROP_STYLE,STYLE_DASHDOT);
    ChartRedraw(0);

    

    return objName;
}


//+------------------------------------------------------------------+
// 下値抵抗線の表示
//+------------------------------------------------------------------+

int getHighest(int bar,int pass_cnt){

    //Print(bar);

    int wk = bar;
    for(int i = 0 ; i < pass_cnt; i++){
        if(High[bar + i] > High[wk]){
            wk = bar + i;
        }
    }
    return wk;
}
int getLowest(int bar,int pass_cnt){

    int wk = bar;
    for(int i = 0 ; i < pass_cnt; i++){
        if(Low[bar + i] < Low[wk]){
            wk = i;
        }
    }
    return wk;
}


//+------------------------------------------------------------------+
// 赤色スパンが向きを変えたかの判定
//+------------------------------------------------------------------+
#define RED_SPAN_UP 1
#define RED_SPAN_DOWN 2
#define RED_SPAN_NO_CHANGE 0
int RED_SPAN_FLAG = RED_SPAN_NO_CHANGE;

int isRedSpanDirectionChange(int bar_num,const double &red_span[]){

    if(bar_num + 3 > Bars){
        return RED_SPAN_NO_CHANGE;
    }

    //赤色スパンが下向きに転換した場合
    if(RED_SPAN_FLAG != RED_SPAN_DOWN && red_span[bar_num + 2] > red_span[bar_num + 1]){
        //Print("RED_SPAN_DOWN");
    
        RED_SPAN_FLAG = RED_SPAN_DOWN;
        return RED_SPAN_DOWN;
    }
    //赤色スパンが上向きに転換した場合
    else if(RED_SPAN_FLAG != RED_SPAN_UP && red_span[bar_num + 2] < red_span[bar_num + 1]){
        //Print("RED_SPAN_UP");
        RED_SPAN_FLAG = RED_SPAN_UP;
        return RED_SPAN_UP;
    }

    return RED_SPAN_NO_CHANGE;

}

//+------------------------------------------------------------------+
// 赤色スパンの転換
// 縦の破線を表示
// 
//+------------------------------------------------------------------+
void createVerticalRedspanChangeLine(int bar_num,int redspan_status){

    //Print("bar_num:" + bar_num);
    //Print("Time:" + ArraySize(Time));
    if(bar_num + 3 > Bars){
        return;
    }

    int line_color = clrWhite;
    if(redspan_status == RED_SPAN_UP){
        line_color = clrRed;
        
    }
    else if(redspan_status == RED_SPAN_DOWN){
        line_color = clrBlue;

    }else{
        return;
    }

    string objName = "red_vline_" + IntegerToString(Bars - bar_num);
    ObjectCreate(0,objName,OBJ_VLINE,0,Time[bar_num + 1],0);
    ObjectSetInteger(0,objName,OBJPROP_COLOR,line_color);
    ObjectSetInteger(0,objName,OBJPROP_STYLE,STYLE_DOT);
    ChartRedraw(0);

    return;

}
//+------------------------------------------------------------------+
// 赤色スパンの転換
// 縦の破線を表示
// 
//+------------------------------------------------------------------+
void createVerticalBlueChangeLine(int bar_num,int bluespan_status){

    //Print("bar_num:" + bar_num);
    //Print("Time:" + ArraySize(Time));
    if(bar_num + 3 > Bars){
        return;
    }

    int line_color = clrWhite;
    if(bluespan_status == RED_SPAN_UP){
        line_color = clrBlue;
        
    }
    else if(bluespan_status == RED_SPAN_DOWN){
        line_color = clrRed;

    }else{
        return;
    }

    string objName = "red_vline_" + IntegerToString(Bars - bar_num);
    ObjectCreate(0,objName,OBJ_VLINE,0,Time[bar_num + 1],0);
    ObjectSetInteger(0,objName,OBJPROP_COLOR,line_color);
    ObjectSetInteger(0,objName,OBJPROP_STYLE,STYLE_DOT);
    ChartRedraw(0);

    return;

}

//+------------------------------------------------------------------+
// スパンモデル転換
// 背景色変更
// 
//+------------------------------------------------------------------+
int BACKGROUND_COLOR = clrWhite;
int BACKGROUND_CHANGE_TIME = 0;
string BACKGROUND_RECTANGLE_OBJECT = "";
datetime BACKGROUND_LAST_CHANGE_TIME = 0;

datetime BACKGROUND_START_TIME = 0;

void setBackGroundColor(int bar_num,int redspan_status){

    if(bar_num > Bars - 3){
        return;
    }

    if(Time[bar_num] > BACKGROUND_LAST_CHANGE_TIME){
    
    }else{
        return;
    }

    if(redspan_status == RED_SPAN_UP){
        BACKGROUND_COLOR = clrLightCyan;
        BACKGROUND_RECTANGLE_OBJECT = "bgcolor_" + IntegerToString(Bars - bar_num);
        

    }else if(redspan_status == RED_SPAN_DOWN){
        
        BACKGROUND_COLOR = clrOldLace;
        BACKGROUND_RECTANGLE_OBJECT = "bgcolor_" + IntegerToString(Bars - bar_num);

    }

    //string objName = "bgcolor_" + IntegerToString(Bars - bar_num);


    if(ObjectFind(BACKGROUND_RECTANGLE_OBJECT) < 0){

        //Print(BACKGROUND_RECTANGLE_OBJECT);    
        BACKGROUND_START_TIME = Time[bar_num + 1];
        ObjectCreate(0,BACKGROUND_RECTANGLE_OBJECT,OBJ_RECTANGLE,0,BACKGROUND_START_TIME,WindowPriceMax(0),Time[bar_num],0);
        ObjectSet(BACKGROUND_RECTANGLE_OBJECT, OBJPROP_COLOR, BACKGROUND_COLOR);
        BACKGROUND_CHANGE_TIME = bar_num + 1;


    }else{
        
        
        //Print(__LINE__ + ":" + BACKGROUND_CHANGE_TIME);
        
        ObjectMove(BACKGROUND_RECTANGLE_OBJECT, 0, BACKGROUND_START_TIME, WindowPriceMax(0) * 5);
        ObjectMove(BACKGROUND_RECTANGLE_OBJECT, 1, Time[bar_num], 0);  
        ObjectSet(BACKGROUND_RECTANGLE_OBJECT, OBJPROP_COLOR, BACKGROUND_COLOR);
        ChartRedraw(0);
        
        //BACKGROUND_CHANGE_TIME++;
    }

    BACKGROUND_LAST_CHANGE_TIME = Time[bar_num];

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




void showTime(int cnt,const datetime &tm[], const double &high[], const double &low[],  int rates_total){

    MqlDateTime t1,t2; 

    //TimeToStruct(tm[rates_total - 2],t1);
    //TimeToStruct(tm[rates_total - 3],t2);  
    TimeToStruct(Time[0],t1);

    //Print("t1.min:"+t1.min);
    //Print("t1.hour:"+t1.hour);
    int m = t1.min % 5;
  
    if(m == 0 && t1.min != 0) makeDisplayTimeString( t1.min,tm[0],high[0],clrBlack);
    if(t1.min == 0) makeDisplayHourString( t1.min,tm[0],low[0],clrRed);
    //if(m == 0) makeDisplayTimeString( t1.min,tm[rates_total - 2],high[rates_total - 2],clrBlack);
    //if(m == 0) makeDisplayTimeString( t1.hour,tm[rates_total - 2],high[rates_total - 2],clrBlack);
    //if(t1.hour == 0 && t1.min == 0) makeDisplayDayString(  t1.day, tm[rates_total - 2],high[rates_total - 2],clrRed);
    //if(t1.hour == 0 && t1.min == 0) makeDisplayDayString(  t1.day, tm[rates_total - 2],high[rates_total - 2],clrRed);
    //if(t1.mon != t2.mon)            makeDisplayMonthString(t1.mon, tm[rates_total - 2],low[rates_total  - 2],clrBlue);

    //if(t1.min == 0 )                makeDisplayTimeString( t1.hour,tm[rates_total - 2],high[rates_total - 2],clrBlack);
    //if(t1.hour == 0 && t1.min == 0) makeDisplayDayString(  t1.day, tm[rates_total - 2],high[rates_total - 2],clrRed);
    //if(t1.mon != t2.mon)            makeDisplayMonthString(t1.mon, tm[rates_total - 2],low[rates_total  - 2],clrBlue);

}

//void makeDisplayTimeString(int time,datetime p_tm,double p_high,int p_color,int pos){
void makeDisplayTimeString(int time,datetime p_tm,double p_high,int p_color){

    MqlDateTime mdt;
    TimeToStruct(Time[0],mdt);

    string t_name    = TimeToString(p_tm);
    string min_text = IntegerToString(mdt.min);
    string objName   = "min_" + t_name;

    string font   = "Arial";
    int font_size = 11;
    int chart_ID  = 0;    

    ObjectDelete(objName);
    ObjectCreate(objName, OBJ_TEXT,0,p_tm,p_high);
    ObjectSetString(chart_ID,objName,OBJPROP_TEXT,min_text);
    ObjectSetString(chart_ID,objName,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,objName,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,objName,OBJPROP_COLOR,p_color);
    ObjectSetInteger(chart_ID,objName,OBJPROP_ANCHOR,ANCHOR_LOWER);
    ObjectSetDouble(chart_ID,objName,OBJPROP_ANGLE,0.0);  
    ChartRedraw(0);
}

void makeDisplayHourString(int time,datetime p_tm,double p_low,int p_color){

    MqlDateTime mdt;
    TimeToStruct(Time[0],mdt);

    string t_name    = TimeToString(p_tm);
    string min_text = IntegerToString(mdt.hour);
    string objName   = "hour_" + t_name;

    string font   = "Arial";
    int font_size = 12;
    int chart_ID  = 0;    
    string font_style = "BOLD";

    ObjectDelete(objName);
    ObjectCreate(objName, OBJ_TEXT,0,p_tm,p_low);
    ObjectSetString(chart_ID,objName,OBJPROP_TEXT,min_text);
    ObjectSetString(chart_ID,objName,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,objName,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,objName,OBJPROP_STYLE,font_style);
    ObjectSetInteger(chart_ID,objName,OBJPROP_COLOR,p_color);
    ObjectSetInteger(chart_ID,objName,OBJPROP_ANCHOR,ANCHOR_UPPER);
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
//bool FIRST_SHOT_FLAG = true;
int  SHOT_COUNTER = 0;
int  SHOT_UPPER_LIMIT = 30;
datetime CURRENT_SHOT_TIME = 0;
string CURRENT_SHOT_DIR = "";
void takeScreenShot(int span_status){

    //Print(span_status);
    Print(TimeToString(Time[0],TIME_DATE|TIME_MINUTES));
    //スパンモデルフラグが成立したか、スクリーンショット取得中の場合
    if(span_status != SPAN_MODEL_NO_CHANGE || SHOT_COUNTER > 0){
    
    
    }else{
        return;
    }

    if(CURRENT_SHOT_TIME == Time[0]){
        return;
    }    

    string output_file = "";
    string output_dir  = "";


    ZeroSuppressDatetime zdt;
    getZeroSupressDatetime(Time[0],zdt);    

    string datetime_str = zdt.year+ zdt.month + zdt.day + zdt.hour + zdt.minute;

    //スクリーンショットの１回目か、２回め以降か
    if(SHOT_COUNTER == 0){

        string indicator_name = "SPAN_AUTO_SIGNAL";
        string symbol_name = _Symbol;
        string time_frame = getChartPeriodString();
        string separator = "\\";
        
        output_dir =    indicator_name + 
                        separator + 
                        symbol_name + 
                        separator + 
                        time_frame + 
                        separator + 
                        datetime_str + 
                        separator;

        CURRENT_SHOT_DIR = output_dir;
        //FIRST_SHOT_FLAG = false;

    }else{
        output_dir = CURRENT_SHOT_DIR;
    
    }

    
    string file_name = datetime_str + "_" + "span_auto_signal.png";
    output_file = output_dir + file_name;

    shot(output_file,CHART_WIDTH,CHART_HEIGHT);
    CURRENT_SHOT_TIME = Time[0];
    //スクリーンショット取得枚数をカウントアップする。
    SHOT_COUNTER++;
    
    if(SHOT_COUNTER > SHOT_UPPER_LIMIT){
        //FIRST_SHOT_FLAG = true;
        SHOT_COUNTER = 0;
    }
    
    
}

void showChartInfo(){
    
    //showTitle(Time[0]);
    showSerialNumber();
    showChartTime();
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

void showChartTime(){

    ZeroSuppressDatetime zdt;
    getZeroSupressDatetime(Time[0],zdt);    
    string time_text = zdt.year + "/" + zdt.month + "/" + zdt.day + " " + zdt.hour + ":" + zdt.minute;

    int x_dst = 450;
    int y_dst = 0;
        
    ObjectDelete("start_date");
    ObjectCreate("start_date", OBJ_LABEL, 0, 0, 0);
    ObjectSet("start_date", OBJPROP_XDISTANCE, x_dst); // 左から30ピクセル
    ObjectSet("start_date", OBJPROP_YDISTANCE, y_dst); // 上から40ピクセル
    ObjectSetText("start_date",time_text,20,"HGPｺﾞｼｯｸE",clrBlack);
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


  

