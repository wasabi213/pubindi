//+------------------------------------------------------------------+
//|                                                                  |
//| NAGAOKA_SPAN_AUTO_SIGNAL.mq4                                     |
//|                                                                  |
//|                                                                  |
//|  ※表示内容                                                 　　 |
//|    -スパンモデル                                                 |
//|    -遅行スパン                                               　  |
//|    -ボリンジャーバンドプライマイナス1シグマ        　　　　　　　|
//|    -ボリンジャーバンドプライマイナス2シグマ        　　　　　　　|
//|    -センターライン                                               |
//|                                                    　　　　　　　|
//+------------------------------------------------------------------+

#include <WinUser32.mqh>
#include <Charts\Chart.mqh>

#include <Nagaoka\Util.mqh>
#include <Nagaoka\span_auto_model.mqh>


#property copyright   ""
#property link        ""
#property description "spanmodel special"
#property strict

#property indicator_buffers 20

//ボリンジャーバンド
//Bolinger Band Plus1
#property indicator_chart_window
#property indicator_type8  DRAW_LINE
#property indicator_color8 clrLightSeaGreen
#property indicator_width8 2


//Bolinger Band Plus2
#property indicator_chart_window
#property indicator_type9  DRAW_LINE
#property indicator_color9 clrLightSeaGreen
#property indicator_width9 2

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
#property indicator_color12 clrBlue
#property indicator_width12 2


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

#property indicator_chart_window
#property indicator_type19 DRAW_HISTOGRAM


/***************************************************************************/
/* INPUT 項目 **************************************************************/
/***************************************************************************/
input bool BANDS_1_FLAG = true; //プラスマイナス１シグマラインを表示するか？
input bool MA_FLAG = true; //センターラインを表示するかどうか？
input int BandsPeriod = 21; //移動平均日数
input double BandsDeviation_1 = 1.0; //偏差１
input double BandsDeviation_2 = 2.0; //偏差２
input double BandsDeviation_3 = 3.0; //偏差３

input int SPAN_COUNT_M1 = 8;
input int SPAN_COUNT_M5 = 8;
input int SPAN_COUNT_M15 = 7;
input int SPAN_COUNT_M30 = 6;
input int SPAN_COUNT_H1 = 5;
input int SPAN_COUNT_H4 = 5;
input int SPAN_COUNT_D1 = 5;
input int SPAN_COUNT_W1 = 5;
input int SPAN_COUNT_MN = 5;


/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

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

/*-------------------------------------------------------------------*/
// スパンオートシグナル
/*-------------------------------------------------------------------*/

//矩形の表示本数
int RECTANGLE_LIMIT = 8;


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
void OnInit( void )
{
	ObjectsDeleteAll();
	ObjectsDeleteAll( 0, OBJ_RECTANGLE );
	IndicatorDigits( Digits );

	ChartSetInteger( 0, CHART_BRING_TO_TOP, 0, true );
	ChartSetInteger( 0, CHART_FOREGROUND, 0, true );

//始値でキャプチャすると遅行スパンの最後の線が平行に移動するため
//勢いがわかりづらくなるので、１本前までの表示とする。
//SetIndexShift(4,-InpKijun);
	SetIndexShift( 4, -25 );
	SetIndexLabel( 4, "Chikou Span" );
//--- initialization done

//---
//ボリンジャーバンドの設定
	SetIndexBuffer( 7, Band_Upper_1 );
	SetIndexBuffer( 8, Band_Lower_1 );
	SetIndexBuffer( 9, Band_Upper_2 );
	SetIndexBuffer( 10, Band_Lower_2 );
	SetIndexBuffer( 11, MA );
//SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DASH,1);

//ichimoku

	SetIndexBuffer( 12, Tenkansen );
	SetIndexBuffer( 13, Kijunsen );
	SetIndexBuffer( 14, SenkouSpanA );
	SetIndexBuffer( 15, SenkouSpanB );
	SetIndexBuffer( 16, Chikouspan );

//////////////////////////////////////////////////////////////////

	SetIndexBuffer( 18, ExtSpanA_Buffer );
	SetIndexStyle( 18, DRAW_HISTOGRAM, STYLE_DOT, 1, clrBlue );

	SetIndexBuffer( 19, ExtSpanB_Buffer );
	SetIndexStyle( 19, DRAW_HISTOGRAM, STYLE_DOT, 1, clrRed );
//////////////////////////////////////////////////////////////////

//ボリンジャーバンドの設定
	ArraySetAsSeries( Band_Upper_1, true );
	ArraySetAsSeries( Band_Lower_1, true );
	ArraySetAsSeries( Band_Upper_2, true );
	ArraySetAsSeries( Band_Lower_2, true );
	ArraySetAsSeries( MA, true );

	ArraySetAsSeries( Tenkansen, true );
	ArraySetAsSeries( Kijunsen, true );
	ArraySetAsSeries( SenkouSpanA, true );
	ArraySetAsSeries( SenkouSpanB, true );
	ArraySetAsSeries( Chikouspan, true );

	ArraySetAsSeries( ExtSpanA_Buffer, true );
	ArraySetAsSeries( ExtSpanB_Buffer, true );

//遅行スパンの最後に不要な線が描画されないようにする。
	SetIndexShift( 16, -25 );

	ApplyTemplate();
	
	switch(_Period){
	   case PERIOD_M1:
   	   RECTANGLE_LIMIT = SPAN_COUNT_M1;
         break;
      
	   case PERIOD_M5:
   	   RECTANGLE_LIMIT = SPAN_COUNT_M5;
         break;

	   case PERIOD_M15:
   	   RECTANGLE_LIMIT = SPAN_COUNT_M15;
         break;

	   case PERIOD_M30:
   	   RECTANGLE_LIMIT = SPAN_COUNT_M30;
         break;

	   case PERIOD_H1:
   	   RECTANGLE_LIMIT = SPAN_COUNT_H1;
         break;

	   case PERIOD_H4:
   	   RECTANGLE_LIMIT = SPAN_COUNT_H4;
         break;

	   case PERIOD_D1:
   	   RECTANGLE_LIMIT = SPAN_COUNT_D1;
         break;

	   case PERIOD_W1:
   	   RECTANGLE_LIMIT = SPAN_COUNT_W1;
         break;

	   case PERIOD_MN1:
   	   RECTANGLE_LIMIT = SPAN_COUNT_MN;
         break;

      default:
         RECTANGLE_LIMIT = SPAN_COUNT_M1;
         break;
   }

}
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo                                               |
//+------------------------------------------------------------------+
int OnCalculate( const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[] )
{

	//Print( "time:" + time[0] );

	int i;
	int span_status;

//ボリンジャーバンド描画
	int limit = rates_total - prev_calculated;
	if( limit == Bars ) limit--;

	for( i = limit; i >= 0; i-- )
	{

		Band_Upper_2[i] = iBands( NULL, 0, BandsPeriod, BandsDeviation_2, 0, PRICE_CLOSE, MODE_UPPER, i );
		Band_Lower_2[i] = iBands( NULL, 0, BandsPeriod, BandsDeviation_2, 0, PRICE_CLOSE, MODE_LOWER, i );

		//１シグマ
		if( BANDS_1_FLAG == true )
		{
			Band_Upper_1[i] = iBands( NULL, 0, BandsPeriod, BandsDeviation_1, 0, PRICE_CLOSE, MODE_UPPER, i );
			Band_Lower_1[i] = iBands( NULL, 0, BandsPeriod, BandsDeviation_1, 0, PRICE_CLOSE, MODE_LOWER, i );
		}
		//センターライン
		if( MA_FLAG == true )
		{
			MA[i] = iMA( NULL, 0, BandsPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
		}

		// 転換線
		//Tenkansen[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_TENKANSEN, i);
		// 基準線
		//Kijunsen[i] = iIchimoku(NULL, 0, 9, 25, 52, MODE_KIJUNSEN, i);
		// 先行スパンA 青い線
		SenkouSpanA[i] = iIchimoku( NULL, 0, 9, 25, 52, MODE_SENKOUSPANA, i - 25 );
		// 先行スパンB
		SenkouSpanB[i] = iIchimoku( NULL, 0, 9, 25, 52, MODE_SENKOUSPANB, i - 25 );

		ExtSpanA_Buffer[i] = SenkouSpanA[i];
		ExtSpanB_Buffer[i] = SenkouSpanB[i];

		// 遅行線
		Chikouspan[i] = iMA( NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, i );

		//スパンモデルの状態を設定する。
		setSpanmodelStatus( SenkouSpanA[i], SenkouSpanB[i] );
		span_status = isSpanModelChange( i, SenkouSpanA, SenkouSpanB );

		//スパンオートシグナルサインを出す。
		showRectangle( i, span_status );

		int redspan_status = isRedSpanDirectionChange( i, SenkouSpanB );
		createVerticalRedspanChangeLine( i, redspan_status );
		//setBackGroundColor( i, redspan_status );
		setBackGroundColor2( i, SenkouSpanB );

	}

	return( rates_total );
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// スパンモデルが転換したかの判定
//+------------------------------------------------------------------+
int isSpanModelChange( int bar_num, const double &blue_span[], const double &red_span[] )
{

	if( bar_num >= Bars - 2 )
	{
		return SPAN_MODEL_NO_CHANGE;
	}

	int idx2 = bar_num + 2; //２本前のインデックス
	int idx1 = bar_num + 1; //１本前のインデックス

	int ret = SPAN_MODEL_NO_CHANGE;

//スパンモデルフラグが上昇に転換したかどうかの判定
	if( SPAN_MODEL_FLAG != SPAN_MODEL_UP && blue_span[idx2] < red_span[idx2] && blue_span[idx1] >= red_span[idx1] )
	{

		SPAN_MODEL_FLAG = SPAN_MODEL_UP;
		//Print( "SPAN BLUE ON" );

		ret = SPAN_MODEL_UP;

	}
	else if( SPAN_MODEL_FLAG != SPAN_MODEL_DOWN && blue_span[idx2] > red_span[idx2] && blue_span[idx1] <= red_span[idx1] )
	{
		SPAN_MODEL_FLAG = SPAN_MODEL_DOWN;

		//Print( "SPAN RED ON" );
		ret = SPAN_MODEL_DOWN;

	}

	return ret;
}
//+------------------------------------------------------------------+
// スパンモデルの状態を設定する。
// spanA:青い線
// spanB:赤い線
//+------------------------------------------------------------------+
void setSpanmodelStatus( double spanA, double spanB )
{

	if( spanA > spanB )
	{
		SPAN_STATUS = SPAN_STATUS_UP;
	}
	else if( spanA < spanB )
	{
		SPAN_STATUS = SPAN_STATUS_DOWN;
	}

}
//+------------------------------------------------------------------+
// スパンモデルシグナル矩形の表示
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showRectangle( int bar_num, int status )
{

	if( bar_num > Bars - 3 )
	{
		return;
	}

	string objName = "";

//スパンモデルフラグがUPに転換した場合
	if( status == SPAN_MODEL_UP )
	{

		RECTANGLE_FLAG = BLUE_RECTANGLE;

		//最初の矩形オブジェクトを作成する。
		CURRENT_OBJECT_NAME = createFirstRectangle( bar_num );

		START_BAR_TIME = Time[bar_num + 1];

		PASS_COUNT = 0;

		return;
	}
//スパンモデルフラグがDOWNに転換した場合
	else if( status == SPAN_MODEL_DOWN )
	{

		//矩形の本数カウントを0にする。
		RECTANGLE_FLAG = RED_RECTANGLE;
		//START_TIME = Time[0];
		//最初の矩形オブジェクトを作成する。
		CURRENT_OBJECT_NAME = createFirstRectangle( bar_num );
		START_BAR_TIME = Time[bar_num + 1];
		PASS_COUNT = 0;

		return;

	}

	PASS_COUNT = getBarShift( START_BAR_TIME, bar_num );

	double line_width = ( WindowPriceMax( 0 ) - WindowPriceMin( 0 ) ) / 200;

	if( PASS_COUNT > RECTANGLE_LIMIT )
	{

		RECTANGLE_FLAG = NO_RECTANGLE;
		PASS_COUNT = 0;

	}

	if( RECTANGLE_FLAG == NO_RECTANGLE )
	{

		if( ObjectFind( LIMIT_LINE_OBJ ) < 0 )
		{
			LIMIT_LINE_OBJ = "limit" + objName;
			LIMIT_LINE_START_TIME = Time[bar_num + 1];
			double line_pos;
			int rect_color = clrWhite;
			if( SPAN_STATUS == SPAN_STATUS_UP )
			{
				line_pos = LIMIT_HIGHEST;
				rect_color = clrPowderBlue;
			}
			else if( SPAN_STATUS == SPAN_STATUS_DOWN )
			{
				line_pos = LIMIT_LOWEST;
				rect_color = clrMoccasin;
			}

			ObjectCreate( LIMIT_LINE_OBJ, OBJ_RECTANGLE, 0, LIMIT_LINE_START_TIME, line_pos, Time[bar_num], line_pos );
			ObjectSetInteger( 0, LIMIT_LINE_OBJ, OBJPROP_COLOR, rect_color );
		}
	}

	if( RECTANGLE_FLAG == BLUE_RECTANGLE && PASS_COUNT <= RECTANGLE_LIMIT )
	{

		int highest = iHighest( NULL, 0, MODE_HIGH, PASS_COUNT, bar_num );
		int lowest = iLowest( NULL, 0, MODE_LOW, PASS_COUNT, bar_num );


		ObjectMove( LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, High[highest] );
		ObjectMove( LIMIT_LINE_OBJ, 1, Time[bar_num], High[highest] - line_width );
		ObjectMove( CURRENT_OBJECT_NAME, 0, START_BAR_TIME, High[highest] );
		ObjectMove( CURRENT_OBJECT_NAME, 1, Time[bar_num], Low[lowest] );

		ChartRedraw( 0 );

		LIMIT_HIGHEST = High[highest];
		LIMIT_LOWEST  = Low[lowest];

		//矩形を作成した時点のスパンモデルの状態を保持する。
		START_SPAN_STATUS = SPAN_STATUS;

	}
	else if( RECTANGLE_FLAG == RED_RECTANGLE && PASS_COUNT <= RECTANGLE_LIMIT )
	{
		int highest = iHighest( NULL, 0, MODE_HIGH, PASS_COUNT, bar_num );
		int lowest = iLowest( NULL, 0, MODE_LOW, PASS_COUNT, bar_num );

		ObjectMove( LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, Low[lowest] );
		ObjectMove( LIMIT_LINE_OBJ, 1, Time[bar_num], Low[lowest] + line_width );
		ObjectMove( CURRENT_OBJECT_NAME, 0, START_BAR_TIME, High[highest] );
		ObjectMove( CURRENT_OBJECT_NAME, 1, Time[bar_num], Low[lowest] );

		ChartRedraw( 0 );

		LIMIT_HIGHEST = High[highest];
		LIMIT_LOWEST  = Low[lowest];

		//矩形を作成した時点のスパンモデルの状態を保持する。
		START_SPAN_STATUS = SPAN_STATUS;

	}

	if( START_SPAN_STATUS == SPAN_STATUS_UP )
	{
		ObjectMove( LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, LIMIT_HIGHEST );
		ObjectMove( LIMIT_LINE_OBJ, 1, Time[bar_num], LIMIT_HIGHEST - line_width );
		ObjectSetInteger( 0, LIMIT_LINE_OBJ, OBJPROP_COLOR, clrPowderBlue );
	}

	else if( START_SPAN_STATUS == SPAN_STATUS_DOWN )
	{
		ObjectMove( LIMIT_LINE_OBJ, 0, LIMIT_LINE_START_TIME, LIMIT_LOWEST );
		ObjectMove( LIMIT_LINE_OBJ, 1, Time[bar_num], LIMIT_LOWEST + line_width );
		ObjectSetInteger( 0, LIMIT_LINE_OBJ, OBJPROP_COLOR, clrMoccasin );
	}

//スパンモデルステータスが転換したらLIMIT_LINEオブジェクトを削除する。

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getBarShift( datetime t, int bar_num )
{

	int count = 0;

	if( bar_num >= Bars - 100 )
	{
		return 0;
	}
	for( int i = Bars; i >= 0; i-- )
	{
		if( bar_num >= Bars )
		{
			return 0;
		}

		if( t > Time[bar_num++] )
		{
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createFirstRectangle( int bar_num )
{

	string objName = "obj" + IntegerToString( Bars - bar_num );
	if( ObjectFind( objName ) > 0 )
	{
		return objName;
	}

	int rect_color = 0;
	int line_color = 0;
	if( RECTANGLE_FLAG == BLUE_RECTANGLE )
	{
		rect_color = clrPaleTurquoise;
		line_color = clrBlue;
	}
	else if( RECTANGLE_FLAG == RED_RECTANGLE )
	{
		rect_color = clrNavajoWhite;
		line_color = clrRed;
	}
	else
	{
		return objName;
	}

	double h = MathMax( High[bar_num + 1], High[bar_num] );
	double l = MathMin( Low[bar_num + 1], Low[bar_num] );

//矩形の新規作成
	ObjectCreate( objName, OBJ_RECTANGLE, 0, Time[bar_num + 1], h, Time[bar_num], l );
	ObjectSetInteger( 0, objName, OBJPROP_COLOR, rect_color );

//LIMIT_LINEの新規作成

	LIMIT_LINE_OBJ = "limit" + objName;

	double line_pos;
	if( SPAN_STATUS == SPAN_STATUS_UP )
	{
		line_pos = h;
	}
	else if( SPAN_STATUS == SPAN_STATUS_DOWN )
	{
		line_pos = l;
	}

	string objVlineName = "blue_vline_" + IntegerToString( Bars - bar_num );
	ObjectCreate( 0, objVlineName, OBJ_VLINE, 0, Time[bar_num + 1], 0 );
	ObjectSetInteger( 0, objVlineName, OBJPROP_COLOR, line_color );
	ObjectSetInteger( 0, objVlineName, OBJPROP_STYLE, STYLE_DASHDOT );
	ChartRedraw( 0 );

	return objName;
}
//+------------------------------------------------------------------+
// 下値抵抗線の表示
//+------------------------------------------------------------------+

int getHighest( int bar, int pass_cnt )
{

	int wk = bar;
	for( int i = 0; i < pass_cnt; i++ )
	{
		if( High[bar + i] > High[wk] )
		{
			wk = bar + i;
		}
	}
	return wk;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getLowest( int bar, int pass_cnt )
{

	int wk = bar;
	for( int i = 0; i < pass_cnt; i++ )
	{
		if( Low[bar + i] < Low[wk] )
		{
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int isRedSpanDirectionChange( int bar_num, const double &red_span[] )
{

	if( bar_num + 3 > Bars )
	{
		return RED_SPAN_NO_CHANGE;
	}

//赤色スパンが下向きに転換した場合
	if( RED_SPAN_FLAG != RED_SPAN_DOWN && red_span[bar_num + 2] > red_span[bar_num + 1] )
	{

		RED_SPAN_FLAG = RED_SPAN_DOWN;
		return RED_SPAN_DOWN;
	}
//赤色スパンが上向きに転換した場合
	else if( RED_SPAN_FLAG != RED_SPAN_UP && red_span[bar_num + 2] < red_span[bar_num + 1] )
	{
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
void createVerticalRedspanChangeLine( int bar_num, int redspan_status )
{

	if( bar_num + 3 > Bars )
	{
		return;
	}

	int line_color = clrWhite;
	if( redspan_status == RED_SPAN_UP )
	{
		line_color = clrBlue;

	}
	else if( redspan_status == RED_SPAN_DOWN )
	{
		line_color = clrRed;

	}
	else
	{
		return;
	}

	string objName = "red_vline_" + IntegerToString( Bars - bar_num );
	ObjectCreate( 0, objName, OBJ_VLINE, 0, Time[bar_num + 1], 0 );
	ObjectSetInteger( 0, objName, OBJPROP_COLOR, line_color );
	ObjectSetInteger( 0, objName, OBJPROP_STYLE, STYLE_DOT );
	ChartRedraw( 0 );

	return;

}
//+------------------------------------------------------------------+
// 赤色スパンの転換
// 縦の破線を表示
//
//+------------------------------------------------------------------+
void createVerticalBlueChangeLine( int bar_num, int bluespan_status )
{

	if( bar_num + 3 > Bars )
	{
		return;
	}

	int line_color = clrWhite;
	if( bluespan_status == RED_SPAN_UP )
	{
		line_color = clrBlue;

	}
	else if( bluespan_status == RED_SPAN_DOWN )
	{
		line_color = clrRed;

	}
	else
	{
		return;
	}

	string objName = "red_vline_" + IntegerToString( Bars - bar_num );
	ObjectCreate( 0, objName, OBJ_VLINE, 0, Time[bar_num + 1], 0 );
	ObjectSetInteger( 0, objName, OBJPROP_COLOR, line_color );
	ObjectSetInteger( 0, objName, OBJPROP_STYLE, STYLE_DOT );
	ChartRedraw( 0 );

	return;

}

//+------------------------------------------------------------------+
// スパンモデル転換
// 背景色変更
//
//+------------------------------------------------------------------+
#define BACKGROUND_NO_STATUS 0
#define BACKGROUND_STATUS_BLUE 1
#define BACKGROUND_STATUS_RED 2

int BACKGROUND_STATUS = BACKGROUND_NO_STATUS;
int BACKGROUND_COLOR = clrWhite;
datetime BACKGROUND_START_TIME;

string BACKGROUND_RECTANGLE_OBJECT = "no_object";

void setBackGroundColor2( int bar_num, double &SenkouSpanB[]){

	if( Bars - bar_num < 3){
		return;
	}

	//バックグラウンドカラーが決まる前の処理
	if(BACKGROUND_STATUS == BACKGROUND_NO_STATUS){
		double wk_senkouspanb = SenkouSpanB[bar_num];
		for(int i = bar_num + 1;i < bar_num; i++){
			if(wk_senkouspanb > SenkouSpanB[i]){
				BACKGROUND_COLOR = clrOldLace;
				break;
			}else if(wk_senkouspanb < SenkouSpanB[i]){
				BACKGROUND_COLOR = clrLightCyan;
				break;			
			}
		}
	}

	//赤色スパンが上昇したか
	

	
	if( BACKGROUND_STATUS != BACKGROUND_STATUS_BLUE && SenkouSpanB[ bar_num + 2] < SenkouSpanB[bar_num + 1]){

		BACKGROUND_STATUS = BACKGROUND_STATUS_BLUE;
		BACKGROUND_COLOR = clrOldLace;
		BACKGROUND_RECTANGLE_OBJECT = "background_" + IntegerToString(Bars - bar_num);
		BACKGROUND_START_TIME = Time[bar_num + 1];

		ObjectCreate( 0, BACKGROUND_RECTANGLE_OBJECT, OBJ_RECTANGLE, 0, BACKGROUND_START_TIME, WindowPriceMax( 0 ), Time[bar_num], 0 );
		ObjectSet( BACKGROUND_RECTANGLE_OBJECT, OBJPROP_COLOR, BACKGROUND_COLOR );

	}else if( BACKGROUND_STATUS != BACKGROUND_STATUS_RED && SenkouSpanB[ bar_num + 2] > SenkouSpanB[bar_num + 1]){

		BACKGROUND_STATUS = BACKGROUND_STATUS_RED;
		BACKGROUND_COLOR = clrLightCyan;
		BACKGROUND_RECTANGLE_OBJECT = "background_" + IntegerToString(Bars - bar_num);
		BACKGROUND_START_TIME = Time[bar_num + 1];

		ObjectCreate( 0, BACKGROUND_RECTANGLE_OBJECT, OBJ_RECTANGLE, 0, BACKGROUND_START_TIME, WindowPriceMax( 0 ), Time[bar_num], 0 );
		ObjectSet( BACKGROUND_RECTANGLE_OBJECT, OBJPROP_COLOR, BACKGROUND_COLOR );

	}else{
	
		if( ObjectFind( BACKGROUND_RECTANGLE_OBJECT ) == 0 ){
		
			ObjectMove( BACKGROUND_RECTANGLE_OBJECT, 0, BACKGROUND_START_TIME, WindowPriceMax( 0 ) * 5 );
			ObjectMove( BACKGROUND_RECTANGLE_OBJECT, 1, Time[bar_num], 0 );
			ObjectSet( BACKGROUND_RECTANGLE_OBJECT, OBJPROP_COLOR, BACKGROUND_COLOR );
			ChartRedraw( 0 );
	
		}
	}
}


//+------------------------------------------------------------------+
// 赤色スパン転換
// ・背景色変更
// ・縦の破線を表示
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// 上値抵抗線の表示
//+------------------------------------------------------------------+
void createHorizontalLine( datetime t, double price )
{

	string objName = "hline_" + IntegerToString( Bars );

	if( ObjectFind( objName ) < 0 )
	{
		ObjectCreate( 0, objName, OBJ_HLINE, 0, Time[1], High[1] );
	}

	ObjectSet( objName, OBJPROP_COLOR, LimeGreen );
	ObjectSet( objName, OBJPROP_PRICE1, WindowPriceMax( 0 ) );
	ObjectSet( objName, OBJPROP_PRICE2, WindowPriceMin( 0 ) );
	ObjectSet( objName, OBJPROP_TIME2, Time[0] );

}

//+------------------------------------------------------------------+
