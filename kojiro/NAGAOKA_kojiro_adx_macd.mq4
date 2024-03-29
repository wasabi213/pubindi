//+------------------------------------------------------------------+
//|                                                                  |
//|                                    Copyright 2019-2020, nagaoka. |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright   "2019-2020, Shunsuke Nagaoka."
#property link        ""
#property description "Nagaoka"
#property strict

#property indicator_chart_window
#property indicator_buffers 30

double EMA_SHORT_BUF[];
double EMA_MID_BUF[];
double EMA_LONG_BUF[];

double LONG_UP[];
double LONG_DOWN[];

double MID_UP[];
double MID_DOWN[];

double UP_BANDS[];
double MD_BANDS[];
double DN_BANDS[];

double EMA25[];

double Buffer1[];

//MACD
double MACD_SHORT[];
double SIGNAL_SHORT[];
double HISTGRAM_SHORT[];
double MACD_MID[];
double SIGNAL_MID[];
double HISTGRAM_MID[];
double MACD_LONG[];
double SIGNAL_LONG[];
double HISTGRAM_LONG[];

//ADX
double ADX_MAIN[];
double ADX_PLUS[];
double ADX_MINUS[];


//EMA
double EMA240[];
double EMA60[];

//RSI
double RSI_SHORT_TF[];
double RSI_MID_TF[];
double RSI_LONG_TF[];


int RESULT_ARRAY[1];
#define NO_DATA -1
#define EVEN 0
#define WIN 1
#define LOSE 2

int TIME_WIN[24];
int TIME_LOSE[24];

double PIPS_WIN[];
double PIPS_LOSE[];

double BANDS_WIN[];
double BANDS_LOSE[];

double EMA_BANDS_WIN[];
double EMA_BANDS_LOSE[];

double RSI_WIN[];
double RSI_LOSE[];

int STAGE_WIN[];
int STAGE_LOSE[];
int SUB_STAGE_WIN[];
int SUB_STAGE_LOSE[];


//RSIカウント用
int RSI_SHORT_WIN[101];
int RSI_MID_WIN[101];
int RSI_LONG_WIN[101];

int RSI_SHORT_LOSE[101];
int RSI_MID_LOSE[101];
int RSI_LONG_LOSE[101];

//RSIマルチタイムカウント用
int RSI_MTF_WIN_RESULT[1000];
int RSI_MTF_LOSE_RESULT[1000];

//ステージマルチタイムカウント用
int MTF_STAGE_WIN[1];
int MTF_SUBSTAGE_WIN[1];
int MTF_STAGE_LOSE[1];
int MTF_SUBSTAGE_LOSE[1];

input int PRINT_MODE			= 0; //データ出力モード
input int SHOW_STAGE_NUMBER		= 1; //バーの上にStageナンバーを表示
input int HIGHLOW_ENTRY_TIME	= 5; //ハイローのエントリ時間

input int SHORT_PERIOD = 5; //1,5,15,30,60,240,1440
input int MID_PERIOD   = 15; //1,5,15,30,60,240,1440
input int LONG_PERIOD  = 60; //1,5,15,30,60,240,1440

input double BOLLINGER_SIGMA = 2;
input int ADX_PERIOD = 14; //ADX算出期間

input int RSI_PERIOD = 14;
input int RSI_SHORT_PERIOD	= 5;
input int RSI_MID_PERIOD	= 15;
input int RSI_LONG_PERIOD	= 60;


//固定値
string CURRENCY = "";
double PIP_BASE = 0.0;
string TIME_FRAME = "";
int CURRENCY_DIGIT = 0;

datetime LAST_SIGNAL_DATETIME = 0.0;

//マルチRSI格納用構造体
struct STRUCT_RSI_MULTI
{
	double h1;
	double m15;
	double m5;
	string result;
};

STRUCT_RSI_MULTI RSI_MULTI[1];


//ログファイル名
string LOG_FILE_NAME = "";


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit( void )
{
	//ObjectsDeleteAll(0,"objArrow_");
	//ObjectsDeleteAll();
	//Print("OnInit");

	IndicatorBuffers( 27 );
	IndicatorDigits( Digits );

	//--- short line
	SetIndexStyle( 0, DRAW_LINE, 0, 0, clrWhite );
	SetIndexBuffer( 0, EMA_SHORT_BUF );
	SetIndexLabel( 0, "Bands Short EMA" );

	//--- short line
	SetIndexStyle( 1, DRAW_LINE, 0, 0, clrRed );
	SetIndexBuffer( 1, EMA_MID_BUF );
	SetIndexLabel( 1, "Bands Short EMA" );

	//--- short line
	SetIndexStyle( 2, DRAW_LINE, 0, 0, clrBlue );
	SetIndexBuffer( 2, EMA_LONG_BUF );
	SetIndexLabel( 2, "Bands Short EMA" );

	/*
	SetIndexStyle(3,DRAW_HISTOGRAM,0,0,clrSkyBlue);
	SetIndexBuffer(3,LONG_DOWN);

	SetIndexStyle(4,DRAW_HISTOGRAM,0,0,clrRed);
	SetIndexBuffer(4,LONG_UP);
	*/

	SetIndexStyle( 4, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrSkyBlue );
	SetIndexBuffer( 4, LONG_DOWN );
	SetIndexDrawBegin( 4, 40 );

	SetIndexStyle( 5, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrRed );
	SetIndexBuffer( 5, LONG_UP );
	SetIndexDrawBegin( 5, 40 );

	SetIndexStyle( 6, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrViolet );
	SetIndexBuffer( 6, MID_DOWN );
	SetIndexDrawBegin( 6, 40 );

	SetIndexStyle( 7, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrRed );
	SetIndexBuffer( 7, MID_UP );
	SetIndexDrawBegin( 7, 40 );

	SetIndexStyle( 8, DRAW_LINE, 0, 0, clrGreen );
	SetIndexBuffer( 8, UP_BANDS );
	SetIndexLabel( 8, "Bollinger Bands up" );
	SetIndexDrawBegin( 8, 25 );

	SetIndexStyle( 9, DRAW_LINE, 0, 0, clrGreen );
	SetIndexBuffer( 9, MD_BANDS );
	SetIndexLabel( 9, "Bollinger Bands center" );
	SetIndexDrawBegin( 9, 25 );

	SetIndexStyle( 10, DRAW_LINE, 0, 0, clrGreen );
	SetIndexBuffer( 10, DN_BANDS );
	SetIndexLabel( 10, "Bollinger Bands down" );
	SetIndexDrawBegin( 10, 25 );

	SetIndexStyle( 11, DRAW_LINE, 0, 0, clrRed );
	SetIndexBuffer( 11, EMA25 );
	SetIndexLabel( 11, "EMA 25" );
	SetIndexDrawBegin( 10, 26 );

	SetIndexStyle( 12, DRAW_LINE, 0, 0, clrRed );
	SetIndexBuffer( 12, Buffer1 );
	SetIndexLabel( 12, "Buffer1" );
	SetIndexDrawBegin( 11, 100 );


	SetIndexBuffer( 13, MACD_SHORT );
	SetIndexLabel( 13, "MACD_SHORT" );
	SetIndexDrawBegin( 13, 41 );

	SetIndexBuffer( 14, SIGNAL_SHORT );
	SetIndexLabel( 14, "SIGNAL_SHORT" );
	SetIndexDrawBegin( 14, 41 );

	SetIndexBuffer( 15, MACD_MID );
	SetIndexLabel( 15, "MACD_MID" );
	SetIndexDrawBegin( 15, 41 );

	SetIndexBuffer( 16, SIGNAL_MID );
	SetIndexLabel( 16, "SIGNAL_MID" );
	SetIndexDrawBegin( 16, 41 );

	SetIndexBuffer( 17, MACD_LONG );
	SetIndexLabel( 17, "MACD_LONG" );
	SetIndexDrawBegin( 17, 41 );

	SetIndexBuffer( 18, SIGNAL_LONG );
	SetIndexLabel( 18, "SIGNAL_LONG" );
	SetIndexDrawBegin( 18, 41 );

	SetIndexBuffer( 19, HISTGRAM_SHORT );
	SetIndexLabel( 19, "HISTGRAM_SHORT" );
	SetIndexDrawBegin( 19, 41 );

	SetIndexBuffer( 20, HISTGRAM_MID );
	SetIndexLabel( 20, "HISTGRAM_MID" );
	SetIndexDrawBegin( 20, 41 );

	SetIndexBuffer( 21, HISTGRAM_LONG );
	SetIndexLabel( 21, "HISTGRAM_LONG" );
	SetIndexDrawBegin( 21, 41 );

	SetIndexBuffer( 22, ADX_MAIN );
	SetIndexLabel( 22, "ADX_MAIN" );
	SetIndexDrawBegin( 22, 41 );

	SetIndexBuffer( 23, ADX_PLUS );
	SetIndexLabel( 23, "ADX_PLUS" );
	SetIndexDrawBegin( 23, 41 );

	SetIndexBuffer( 24, ADX_MINUS );
	SetIndexLabel( 24, "ADX_MINUS" );
	SetIndexDrawBegin( 24, 41 );

	SetIndexBuffer( 25, EMA240 );
	SetIndexLabel( 25, "EMA240" );
	SetIndexDrawBegin( 25, 241 );

	SetIndexBuffer( 26, EMA60 );
	SetIndexLabel( 26, "EMA60" );
	SetIndexDrawBegin( 26, 61 );

	SetIndexBuffer( 27, RSI_SHORT_TF );
	SetIndexLabel( 27, "RSI_SHORT_TF" );
	SetIndexDrawBegin( 27, RSI_PERIOD + 1 );

	SetIndexBuffer( 28, RSI_MID_TF );
	SetIndexLabel( 28, "RSI_MID_TF" );
	SetIndexDrawBegin( 28, RSI_PERIOD + 1 );

	SetIndexBuffer( 29, RSI_LONG_TF );
	SetIndexLabel( 29, "RSI_LONG_TF" );
	SetIndexDrawBegin( 29, RSI_PERIOD + 1 );



	PIP_BASE		= getPipPrice();
	CURRENCY_DIGIT	= _Digits;
	TIME_FRAME		= getTimeFrameString();
	CURRENCY		= _Symbol;


	ArrayInitialize(TIME_WIN,0);
	ArrayInitialize(TIME_LOSE,0);
	

	//RSIカウント配列の初期化
	ArrayInitialize(RSI_SHORT_TF,0);
	ArrayInitialize(RSI_MID_TF,0);
	ArrayInitialize(RSI_LONG_TF,0);
	
	ArrayInitialize(RSI_SHORT_WIN,0);
	ArrayInitialize(RSI_MID_WIN,0);
	ArrayInitialize(RSI_LONG_WIN,0);

	ArrayInitialize(RSI_SHORT_LOSE,0);
	ArrayInitialize(RSI_MID_LOSE,0);
	ArrayInitialize(RSI_LONG_LOSE,0);

	ArrayInitialize(RSI_MTF_WIN_RESULT,0);
	ArrayInitialize(RSI_MTF_LOSE_RESULT,0);

	//ステージマルチタイムカウント用配列の初期化
	//ArrayInitialize(MTF_STAGE_WIN,0);
	//ArrayInitialize(MTF_SUBSTAGE_WIN,0);
	//ArrayInitialize(MTF_STAGE_LOSE,0);
	//ArrayInitialize(MTF_SUBSTAGE_LOSE,0);


	LOG_FILE_NAME = getLogFileName();

	return( INIT_SUCCEEDED );
}
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
void OnDeinit( const int reason )
{

	ObjectDelete( 0, "stage_number" );
	//ObjectsDeleteAll(0,"objArrow_");
	ObjectsDeleteAll();
	//return(INIT_SUCCEEDED);
}


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

//--- preliminary calculations

	//Print("start");

	int limit = rates_total - prev_calculated;

	double second_term_short;
	double second_term_short_p1;
	double second_term_mid;
	double second_term_long;
	double third_term_short;
	double third_term_short_p1;
	double third_term_mid;
	double third_term_long;

	
	for( int i = limit; i >= 0 ; i-- )
	{
		if( i >= Bars - 3 ) continue;

		EMA_SHORT_BUF[i]    = iMA( NULL, SHORT_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i );
		EMA_MID_BUF[i]      = iMA( NULL, SHORT_PERIOD, 20, 0, MODE_EMA, PRICE_CLOSE, i );
		EMA_LONG_BUF[i]     = iMA( NULL, SHORT_PERIOD, 40, 0, MODE_EMA, PRICE_CLOSE, i );

		second_term_short		= iMA( NULL, MID_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i );
		second_term_short_p1	= iMA( NULL, MID_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i + 1 );
		second_term_mid		= iMA( NULL, MID_PERIOD, 20, 0, MODE_EMA, PRICE_CLOSE, i );
		second_term_long		= iMA( NULL, MID_PERIOD, 40, 0, MODE_EMA, PRICE_CLOSE, i );

		third_term_short   = iMA( NULL, LONG_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i );
		third_term_short_p1 = iMA( NULL, LONG_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i + 1 );
		third_term_mid      = iMA( NULL, LONG_PERIOD, 20, 0, MODE_EMA, PRICE_CLOSE, i );
		third_term_long     = iMA( NULL, LONG_PERIOD, 40, 0, MODE_EMA, PRICE_CLOSE, i );

		MACD_SHORT[i]   = iMACD( NULL, PERIOD_CURRENT, 5, 20, 9, PRICE_CLOSE, MODE_MAIN, i );
		SIGNAL_SHORT[i] = iMACD( NULL, PERIOD_CURRENT, 5, 20, 9, PRICE_CLOSE, MODE_SIGNAL, i );
		HISTGRAM_SHORT[i] = MACD_SHORT[i] - SIGNAL_SHORT[i];

		MACD_MID[i]     = iMACD( NULL, PERIOD_CURRENT, 5, 40, 9, PRICE_CLOSE, MODE_MAIN, i );
		SIGNAL_MID[i]   = iMACD( NULL, PERIOD_CURRENT, 5, 40, 9, PRICE_CLOSE, MODE_SIGNAL, i );
		HISTGRAM_MID[i] = MACD_MID[i] - SIGNAL_MID[i];

		MACD_LONG[i]    = iMACD( NULL, PERIOD_CURRENT, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, i );
		SIGNAL_LONG[i]  = iMACD( NULL, PERIOD_CURRENT, 20, 40, 9, PRICE_CLOSE, MODE_SIGNAL, i );
		HISTGRAM_LONG[i] = MACD_LONG[i] - SIGNAL_LONG[i];

		UP_BANDS[i] = iBands(NULL,PERIOD_CURRENT,21,BOLLINGER_SIGMA,0,PRICE_CLOSE,MODE_UPPER,i);
		MD_BANDS[i] = iBands(NULL,PERIOD_CURRENT,21,BOLLINGER_SIGMA,0,PRICE_CLOSE,MODE_MAIN,i);
		DN_BANDS[i] = iBands(NULL,PERIOD_CURRENT,21,BOLLINGER_SIGMA,0,PRICE_CLOSE,MODE_LOWER,i);

		EMA25[i]	= iMA( NULL, PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_CLOSE, i ); //SMAにする。
		EMA240[i]	= iMA( NULL, PERIOD_CURRENT,240, 0, MODE_EMA, PRICE_CLOSE, i ); //SMAにする。
		EMA60[i]	= iMA( NULL, PERIOD_CURRENT, 60, 0, MODE_EMA, PRICE_CLOSE, i ); //SMAにする。

		ADX_MAIN[i]  = iADX(NULL,PERIOD_CURRENT,ADX_PERIOD,PRICE_CLOSE,MODE_MAIN,i);
		ADX_PLUS[i]  = iADX(NULL,PERIOD_CURRENT,ADX_PERIOD,PRICE_CLOSE,MODE_PLUSDI,i);
		ADX_MINUS[i] = iADX(NULL,PERIOD_CURRENT,ADX_PERIOD,PRICE_CLOSE,MODE_MINUSDI,i);


		RSI_SHORT_TF[i] = iRSI(NULL,PERIOD_CURRENT, RSI_PERIOD,PRICE_CLOSE,i);
		int mid_pos = iBarShift(NULL,MID_PERIOD,Time[i],false);
		RSI_MID_TF[i]	= iRSI(NULL,RSI_MID_PERIOD, RSI_PERIOD,PRICE_CLOSE,mid_pos);
		int long_pos = iBarShift(NULL,LONG_PERIOD,Time[i],false);
		RSI_LONG_TF[i]  = iRSI(NULL,RSI_LONG_PERIOD,RSI_PERIOD,PRICE_CLOSE,long_pos);



		if( EMA_MID_BUF[i] > EMA_LONG_BUF[i] )
		{
			LONG_DOWN[i]	= EMA_MID_BUF[i];
			LONG_UP[i]		= EMA_LONG_BUF[i];
		}
		else
		{
			MID_DOWN[i]	= EMA_LONG_BUF[i];
			MID_UP[i]	= EMA_MID_BUF[i];
		}


		int short_stage[2], mid_stage[2], long_stage[2];

		getStage( EMA_SHORT_BUF[i], EMA_SHORT_BUF[i + 1], EMA_MID_BUF[i], EMA_LONG_BUF[i], short_stage );
		//showStage( short_stage[0], 3, "SHORT_TERM", SHOW_STAGE_NUMBER );
		//showStageNumber( i, short_stage[0], 1, SHOW_STAGE_NUMBER );

		getStage( second_term_short, second_term_short_p1, second_term_mid, second_term_long, mid_stage );
		//showStage( mid_stage[0], 2, "MID_TERM", SHOW_STAGE_NUMBER );
		//showStageNumber(i,mid_stage[1],2,SHOW_STAGE_NUMBER);

		getStage( third_term_short, third_term_short_p1, third_term_mid, third_term_long, long_stage );
		//showStage( long_stage[0], 1, "LONG_TERM", SHOW_STAGE_NUMBER );
		//showStageNumber(i,long_stage[1],3,SHOW_STAGE_NUMBER);

		//string direction = createSignal( i, short_stage[1], mid_stage[1], long_stage[1] );
		string direction = createSignal( i );
		showArrow( direction, i, clrMagenta );

		//ヒストグラムの状態を保持する。
		setHistgramStatus(i);

		countResult(i,direction);
		countPips(i,direction);
		countBands(i,direction);
		countEmaBands(i,direction);
		countStage(i,direction,short_stage);
		
		countMultiStage(i,direction,short_stage,mid_stage,long_stage);	

		countRsi(i,direction);
		countRsiMulti2(i,direction,RSI_LONG_TF[i],RSI_MID_TF[i],RSI_SHORT_TF[i]);

	}


	calcResult();
	calcPips();
	calcBands();
	calcEmaBands();
	calcStage();
	calcRsi();
	calcTime();

	calcMultiRsi();
	calcMultiStage();

	calcRsiMulti2();

	return( rates_total );
}


//string createSignal( int i, int short_num, int mid_num, int long_num )

string createSignal( int i )
{
	if(i + 6 > Bars) return "";

	string ret = "";


	if(ADX_MAIN[i] < 22){ ret = "up"; }else{return "";}
	if(ADX_MAIN[i+1] < ADX_MAIN[i]){ ret = "up"; }else{return "";}
	if(EMA_SHORT_BUF[i+1] < EMA_SHORT_BUF[i]){ ret = "up"; }else{return "";}

	//ステージ１でSIGNAL_SHORTが下落しているときは除く
	int short_stage[2];
	getStage( EMA_SHORT_BUF[i], EMA_SHORT_BUF[i + 1], EMA_MID_BUF[i], EMA_LONG_BUF[i], short_stage );
	if(short_stage[0] == 1 && SIGNAL_SHORT[i+1] > SIGNAL_SHORT[i]){return "";}


	
	//if(ADX_MAIN[i+1] < ADX_MAIN[i]){ ret = "up"; }else{return "";}
	//if(ADX_PLUS[i+1] < ADX_PLUS[i]){ ret = "up"; }else{return "";}
	//if(ADX_MINUS[i+1] > ADX_MINUS[i]){ ret = "up"; }else{return "";}

	//if(MACD_SHORT[i+1] < MACD_SHORT[i]){ ret = "up"; }else{return "";}
	//if(SIGNAL_SHORT[i+1] < SIGNAL_SHORT[i]){ ret = "up"; }else{return "";}
	//if(HISTGRAM_SHORT[i+1] < HISTGRAM_SHORT[i]){ ret = "up"; }else{return "";}


	//if(EMA240[i+1] < EMA240[i]){ ret = "up"; }else{return "";}
	//if(EMA60[i+1] < EMA60[i]){ ret = "up"; }else{return "";}
	
	//if(EMA_MID_BUF[i+1] < EMA_MID_BUF[i]){ ret = "up"; }else{return "";}
	//if(EMA_LONG_BUF[i+1] < EMA_LONG_BUF[i]){ ret = "up"; }else{return "";}

	//if(EMA_SHORT_BUF[i] > EMA_MID_BUF[i]){ ret = "up"; }else{return "";}

	//if(High[i] < UP_BANDS[i]){ ret = "up"; }else{return "";}

	//if((UP_BANDS[i] - DN_BANDS[i]) / getPipPrice() >= 6){ ret = "up"; }else{return "";}



	//if(UP_BANDS[i+1] < UP_BANDS[i]){ ret = "up"; }else{return "";}	


	//if(Close[i] < UP_BANDS[i]){ ret = "up"; }else{return "";}

	//if(ADX_MAIN[i] <= 22){ ret = "up"; }else{return "";}


	////MACD_SHORTが上昇しているタイミングを外す。
	////if(MACD_SHORT[i+1] < MACD_SHORT[i]){ ret = "down"; }else{return "";}


	//if(ADX_MAIN[i+1] < ADX_MAIN[i]){ ret = "down"; }else{return "";}


	//-DIが下落しているタイミングを外す。
	//if(ADX_MINUS[i+1] > ADX_MINUS[i]){ ret = "down"; }else{return "";}

	//ヒストグラムが上昇しているタイミングを外す。
	//if(HISTGRAM_SHORT[i+1] > HISTGRAM_SHORT[i]){ ret = "down"; }else{return "";}

	//if(EMA_LONG_BUF[i+1] > EMA_LONG_BUF[i]){ ret = "down"; }else{return "";}
	//if(EMA_SHORT_BUF[i+1] > EMA_SHORT_BUF[i]){ ret = "down"; }else{return "";}


	//+DIと-DIがクロスして最初の上昇
	//if(ADX_MAIN[i+2] < ADX_MAIN[i+1]){ ret = "up"; }else{return "";}	
	//if(ADX_PLUS[i] > ADX_MINUS[i]){ ret = "up"; }else{return "";}
	//if(ADX_PLUS[i+1] <= ADX_MINUS[i+1] && ADX_PLUS[i] > ADX_MINUS[i]){ ret = "up"; }else{return "";}	
	//if(ADX_PLUS[i+1] < ADX_PLUS[i] && ADX_MINUS[i+1] > ADX_MINUS[i]){ ret = "up"; }else{return "";}

	//if(EMA25[i+1] < EMA25[i]){ ret = "up"; }else{return "";}
	//2020.01.25 18:19:07.261	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:444 負け:507 勝率 46.7% 本数:8422 出現確率11.29% 勝ち出現確率5.27%


	//EMAの帯の幅
	//if(MathAbs(EMA_MID_BUF[i] - EMA_LONG_BUF[i]) / getPipPrice() > 2){ret = "up";}else{return "";}

	//if(UP_BANDS[i+1] > UP_BANDS[i]){ ret = "down"; }else{return "";}	

	//stage1のみ表示
	//int short_stage[2];
	//getStage( EMA_SHORT_BUF[i], EMA_SHORT_BUF[i + 1], EMA_MID_BUF[i], EMA_LONG_BUF[i], short_stage );
	//if(short_stage[0] != 1){ret = "down";}else{return "";}
	

	if( ret == "up" || ret == "down" )
	{
		//Print(TimeToStr(Time[i]) + ":" + ret);
		//logout(StringFormat("%d:%d:%d",long_num,mid_num,short_num));

	}
	return ret;

}

void countRsiMulti2(int bar_num,string direction,double long_term,double mid_term,double short_term)
{
	
	if(direction == "") return;

	//現在のBarから勝敗が決まるBarが確定していない場合、はじく。
	if( bar_num - HIGHLOW_ENTRY_TIME < 0 ) return;

	int result = getResult(bar_num,direction);

	if(result == WIN)
	{
		ArrayResize(RSI_MULTI,ArraySize(RSI_MULTI) + 1);
		
		
		RSI_MULTI[ArraySize(RSI_MULTI)-1].h1		= long_term;
		RSI_MULTI[ArraySize(RSI_MULTI)-1].m15		= mid_term;
		RSI_MULTI[ArraySize(RSI_MULTI)-1].m5		= short_term;
		RSI_MULTI[ArraySize(RSI_MULTI)-1].result	= "win";

	}

	if(result == LOSE)
	{
		ArrayResize(RSI_MULTI,ArraySize(RSI_MULTI) + 1);

		RSI_MULTI[ArraySize(RSI_MULTI)-1].h1		= long_term;
		RSI_MULTI[ArraySize(RSI_MULTI)-1].m15		= mid_term;
		RSI_MULTI[ArraySize(RSI_MULTI)-1].m5		= short_term;
		RSI_MULTI[ArraySize(RSI_MULTI)-1].result	= "lose";

	}

}

void calcRsiMulti2()
{
	int long_mid_win[100][100];
	int long_short_win[100][100];
	int mid_short_win[100][100];
	int long_mid_lose[100][100];
	int long_short_lose[100][100];
	int mid_short_lose[100][100];

	ArrayInitialize(long_mid_win,0);
	ArrayInitialize(long_short_win,0);
	ArrayInitialize(mid_short_win,0);
	ArrayInitialize(long_mid_lose,0);
	ArrayInitialize(long_short_lose,0);
	ArrayInitialize(mid_short_lose,0);


	int long_val,mid_val,short_val;

	//LONG-MIDDLE
	for(int i=0;i<ArraySize(RSI_MULTI);i++)
	{
	
		if(RSI_MULTI[i].result == "win")
		{
			long_val  = (int)MathFloor(RSI_MULTI[i].h1 / 10) * 10;
			mid_val   = (int)MathFloor(RSI_MULTI[i].m15 / 10) * 10;
			short_val = (int)MathFloor(RSI_MULTI[i].m5 / 10) * 10;

			long_mid_win[long_val][mid_val]++;
			long_short_win[long_val][short_val]++;
			mid_short_win[mid_val][short_val]++;
		
		}
	
		else if(RSI_MULTI[i].result == "lose")
		{
			long_val  = (int)MathFloor(RSI_MULTI[i].h1 / 10) * 10;
			mid_val   = (int)MathFloor(RSI_MULTI[i].m15 / 10) * 10;
			short_val = (int)MathFloor(RSI_MULTI[i].m5 / 10) * 10;

			long_mid_lose[long_val][mid_val]++;
			long_short_lose[long_val][short_val]++;
			mid_short_lose[mid_val][short_val]++;
		
		}
	}


	logout("======================================================================");
	logout("RSI LONG_MIDDLE");
	for(int j=0;j<100;j++)
	{
		for(int k=0;k<100;k++)
		{
			int total = long_mid_win[j][k] + long_mid_lose[j][k];
		
			if(total == 0){ continue; }

			double rate =  (double)long_mid_win[j][k] / (double)(total) * 100;
			logout(StringFormat("RSI LONG-MIDDLE,long:%d,mid:%d,win:%d,lose:%d,total:%d,rate:%.1f%%",
				j,k,long_mid_win[j][k],long_mid_lose[j][k],total,rate));
	
		}
	}

	logout("----------------------------------------------------------------------");
	logout("RSI LONG_SHORT");
	for(int j=0;j<100;j++)
	{
		for(int k=0;k<100;k++)
		{
			int total = long_short_win[j][k] + long_short_lose[j][k];
		
			if(total == 0){ continue; }

			double rate =  (double)long_short_win[j][k] / (double)(total) * 100;
			logout(StringFormat("RSI LONG-SHORT,long:%d,short:%d,win:%d,lose:%d,total:%d,rate:%.1f%%",
				j,k,long_short_win[j][k],long_short_lose[j][k],total,rate));
	
		}
	}

	logout("----------------------------------------------------------------------");
	logout("RSI MID_SHORT");
	for(int j=0;j<100;j++)
	{
		for(int k=0;k<100;k++)
		{
			int total = mid_short_win[j][k] + mid_short_lose[j][k];
		
			if(total == 0){ continue; }

			double rate =  (double)mid_short_win[j][k] / (double)(total) * 100;
			logout(StringFormat("RSI MID-SHORT,mid:%d,short:%d,win:%d,lose:%d,total:%d,rate:%.1f%%",
				j,k,mid_short_win[j][k],mid_short_lose[j][k],total,rate));
	
		}
	}





}


void countMultiStage(int bar_num,string direction,int &short_stage[], int &mid_stage[],int &long_stage[])
{

	if(direction == "") return;

	//現在のBarから勝敗が決まるBarが確定していない場合、はじく。
	if( bar_num - HIGHLOW_ENTRY_TIME < 0 ) return;

	int result = getResult(bar_num,direction);
	if(result == WIN)
	{
	
		ArrayResize(MTF_STAGE_WIN,ArraySize(MTF_STAGE_WIN)+1);
		MTF_STAGE_WIN[ArraySize(MTF_STAGE_WIN)-1] = StrToInteger( 
			IntegerToString(long_stage[0]) + IntegerToString(mid_stage[0]) + IntegerToString(short_stage[0]));
						
	}
	else if(result == LOSE)
	{
		ArrayResize(MTF_STAGE_LOSE,ArraySize(MTF_STAGE_LOSE)+1);
		MTF_STAGE_LOSE[ArraySize(MTF_STAGE_LOSE)-1] = StrToInteger(
			IntegerToString(long_stage[0]) + IntegerToString(mid_stage[0]) + IntegerToString(short_stage[0]));
	}
	else
	{
		return;
	}


}

/**
 *　マルチステージの出力
 */
void calcMultiStage()
{

	int win_array[1000];
	int lose_array[1000];
	ArrayInitialize(win_array,0);
	ArrayInitialize(lose_array,0);

	for(int k=0;k<ArraySize(MTF_STAGE_WIN);k++)
	{
		win_array[MTF_STAGE_WIN[k]]++;
	}

	for(int j=0;j<ArraySize(MTF_STAGE_LOSE);j++)
	{
		lose_array[MTF_STAGE_LOSE[j]]++;
	}

	int win_count,lose_count;
	string long_stage  = "0";
	string mid_stage   = "0";
	string short_stage = "0";
	
	for(int i=0;i<1000;i++)
	{
		if(i >= 100)
		{	
			long_stage  = StringSubstr(IntegerToString(i+1),0,1);
			mid_stage   = StringSubstr(IntegerToString(i+1),1,1);
			short_stage = StringSubstr(IntegerToString(i+1),2,1);
		}
		else if(i >= 10)
		{
			long_stage  = "1";
			mid_stage   = StringSubstr(IntegerToString(i+1),0,1);
			short_stage = StringSubstr(IntegerToString(i+1),1,1);
		}
		else
		{
			long_stage  = "1";
			mid_stage   = "1";
			short_stage = StringSubstr(IntegerToString(i+1),0,1);
		}
		
		win_count  = win_array[i];
		lose_count = lose_array[i];

		int total = win_count + lose_count;
		if(total == 0){ continue; }
		
				
		double result =  (double)win_count / (double)(total) * 100;
		string rate = DoubleToStr(result,1) + "%";
		logout(StringFormat("STAGE,long:%s,mid:%s,short:%s,win:%d,lose:%d,total:%d,rate:%s",
			long_stage,mid_stage,short_stage,win_count,lose_count,total,rate));
	
	}	
	
	
}

/**
 * RSIをカウントする。
 */

void countRsi(int bar_num, string direction)
{

	if(direction == "") return;

	//現在のBarから勝敗が決まるBarが確定していない場合、はじく。
	if( bar_num - HIGHLOW_ENTRY_TIME < 0 ) return;

	int result = getResult(bar_num,direction);

	double rsi_short = RSI_SHORT_TF[bar_num];
	double rsi_mid   = RSI_MID_TF[bar_num];
	double rsi_long  = RSI_LONG_TF[bar_num];


	int min = 0;
	int max = 0;

	int short_pos = 0;
	int mid_pos = 0;
	int long_pos = 0;

	if(result == WIN)
	{

		//RSI60 RSI15 RSI5の組み合わせが表示できるようにする。
		for(int i=0;i<10;i++)
		{
			min = i * 10;
			max = min + 10;

			if(rsi_short >= min && rsi_short < max)
			{
				RSI_SHORT_WIN[min]++;
				short_pos = i;
			}
			if(rsi_mid   >= min && rsi_mid   < max)
			{
				RSI_MID_WIN[min]++;
				mid_pos = i;
			}
			if(rsi_long  >= min && rsi_long  < max)
			{
				RSI_LONG_WIN[min]++;
				long_pos = i;
			}

		}
		
		int index = long_pos * 100 + mid_pos * 10 + short_pos;
		
		RSI_MTF_WIN_RESULT[index]++;
		
	}

	if(result == LOSE)
	{
		for(int i=0;i<10;i++)
		{
			min = i * 10;
			max = min + 10;
		
			if(rsi_short >= min && rsi_short < max)
			{
				RSI_SHORT_LOSE[min]++;
				short_pos = i;
			}
			if(rsi_mid   >= min && rsi_mid   < max)
			{
				RSI_MID_LOSE[min]++;
				mid_pos = i;
			}
			if(rsi_long  >= min && rsi_long  < max)
			{
				RSI_LONG_LOSE[min]++;
				long_pos = i;
			}
		}

		int index = long_pos * 100 + mid_pos * 10 + short_pos;
		
		RSI_MTF_LOSE_RESULT[index]++;

	}

	//組み合わせパターンをどうやって表現するか。




}
void calcRsi()
{

	int cnt = 0;
	int min = 0;
	int max = 0;
	int win = 0;
	int lose = 0;
	int total = 0;
	double result = 0.0;
	string rate = "0";

	logout("RSI");

	//Print("-----------------------------------------------------------------------");
	for(int i=0;i<ArraySize(RSI_SHORT_WIN);i++)
	{
		min = i;
		max = min + 10;
		win  = RSI_SHORT_WIN[min];
		lose = RSI_SHORT_LOSE[min];
		total = win + lose;
		if(total != 0)
		{
	
			result =  (double)win / (double)total * 100;
			rate = DoubleToStr(result,1) + "%";
			logout(StringFormat("RSI(%d):%d-%d win:%d lose:%d total:%d rate:%s",PERIOD_CURRENT,min,max,win,lose,total,rate));
		}
	}

	Print("-----------------------------------------------------------------------");
	logout("-----------------------------------------------------------------------");
	for(int i=0;i<ArraySize(RSI_MID_WIN);i++)
	{
		min = i;
		max = min + 10;
		win  = RSI_MID_WIN[min];
		lose = RSI_MID_LOSE[min];
		
		//Print(RSI_MID_WIN[min]," min:" + min);
		
		
		total = win + lose;
		if(total != 0)
		{
			result =  (double)win / (double)total * 100;
			rate = DoubleToStr(result,1) + "%";
			logout(StringFormat("RSI(%d):%d-%d win:%d lose:%d total:%d rate:%s",RSI_MID_PERIOD,min,max,win,lose,total,rate));
		}
	}

	Print("-----------------------------------------------------------------------");
	logout("-----------------------------------------------------------------------");
	for(int i=0;i<ArraySize(RSI_LONG_WIN);i++)
	{
		min = i;
		max = min + 10;
		win  = RSI_LONG_WIN[min];
		lose = RSI_LONG_LOSE[min];
		total = win + lose;
		if(total != 0)
		{
			result =  (double)win / (double)total * 100;
			rate = DoubleToStr(result,1) + "%";
			logout(StringFormat("RSI(%d):%d-%d win:%d lose:%d total:%d rate:%s",RSI_LONG_PERIOD,min,max,win,lose,total,rate));
		}
	}
	Print("-----------------------------------------------------------------------");
	logout("======================================================================");
	logout("");
}

/**
 * RSIのマルチタイムフレームの集計
 */
void calcMultiRsi()
{
	string short_val = "0";
	string mid_val   = "0";
	string long_val  = "0";


	logout("RSI マルチタイム");
	logout("LONG-MIDDLE-SHORT");

	for(int i=0;i<1000;i++)
	{

		if( i < 10)
		{
			short_val = IntegerToString(i);
			mid_val   = IntegerToString(0);
			long_val  = IntegerToString(0);
		}
		else if( i < 100)
		{
			string wk = IntegerToString(i);
			long_val  = IntegerToString(0);
			mid_val   = StringSubstr(IntegerToString(i),0,1);
			short_val = StringSubstr(IntegerToString(i),1,1);
		}	
		else
		{
			string wk = IntegerToString(i);
			long_val  = StringSubstr(IntegerToString(i),0,1);
			mid_val   = StringSubstr(IntegerToString(i),1,1);
			short_val = StringSubstr(IntegerToString(i),2,1);
		}	

		int win = RSI_MTF_WIN_RESULT[i];
		int lose = RSI_MTF_LOSE_RESULT[i];
		int total = win + lose;
		string rate = "0%";

		if(total != 0)
		{
			rate = DoubleToStr((double)win / (double)total * 100,1) + "%";

			logout(StringFormat("long:%s0 mid:%s0 short:%s0 win:%d\tlose:%d\ttotal:%d\trate:%s",
				long_val,mid_val,short_val,win,lose,total,rate));

		}
	}

	logout("----------------------------------------------------------------------");


}

#define HISTGRAM_UP 1
#define HISTGRAM_DOWN 2
#define NO_HISTGRAM 0

int HISTGRAM_STAUS = NO_HISTGRAM;
double HISTGRAM_MAX = 0.0;
double HISTGRAM_MIN = 0.0;

void setHistgramStatus(int bar_num)
{

	double previous	= HISTGRAM_MID[bar_num+1];
	double current	= HISTGRAM_MID[bar_num];

	//ヒストグラムのステータスを設定する。
	if(previous <= 0.0 && current > 0.0)
	{
		HISTGRAM_STAUS = HISTGRAM_UP;
		HISTGRAM_MAX = current;
		HISTGRAM_MIN = 0.0;
	}
	else if(previous >= 0.0 && current < 0.0)
	{
		HISTGRAM_STAUS = HISTGRAM_DOWN;
		HISTGRAM_MAX = 0.0;
		HISTGRAM_MIN = current;
	}


	//ヒストグラムの最大値を設定する。
	if(HISTGRAM_STAUS == HISTGRAM_UP && current > HISTGRAM_MAX)
	{
		HISTGRAM_MAX = current;
	}
	else if(HISTGRAM_STAUS == HISTGRAM_DOWN &&current < HISTGRAM_MIN)
	{
		HISTGRAM_MIN = current;
	}
}
/**
 * 勝敗をカウントする。
 */
int WIN_NUMBER  = 0;
int LOSE_NUMBER = 0;
int EVEN_NUMBER = 0;
void countResult(int bar_num, string direction)
{

	if(direction == "") return;

	//現在のBarから勝敗が決まるBarが確定していない場合、はじく。
	if( bar_num - HIGHLOW_ENTRY_TIME < 0 ) return;

	int result = getResult(bar_num,direction);

	if(result == WIN)
	{
		WIN_NUMBER++;
		showWinLoseMark( direction, bar_num, "W", clrAqua );
		TIME_WIN[TimeHour( Time[bar_num] )]++;
	}
	else if(result == LOSE)
	{
		LOSE_NUMBER++;
		showWinLoseMark( direction, bar_num, "L", clrRed );
		TIME_LOSE[TimeHour( Time[bar_num] )]++;

	}
	else if( result == EVEN)
	{
		EVEN_NUMBER++;
	}
}

/**
 * calcResult
 */
void calcResult()
{
	int total = WIN_NUMBER + LOSE_NUMBER + EVEN_NUMBER;

	double rate = 0.0;
	if(total != 0)
	{
		rate = (double)WIN_NUMBER / (double)total * 100;
	}

	logout("##########################################################################################");
	logout("");
	logout(StringFormat("win:%d lose:%d even:%d rate:%.1f%%",WIN_NUMBER,LOSE_NUMBER,EVEN_NUMBER,rate));
	logout(StringFormat("通貨:%s",_Symbol));
	logout(StringFormat("バーの本数:%d本",Bars));
	logout(StringFormat("期間 開始:%s 終了:%s",TimeToString(Time[Bars-1], TIME_DATE),TimeToString(Time[0], TIME_DATE)));
	logout(StringFormat("時間枠:%d",_Period));
	logout("");
	logout("##########################################################################################");
	logout("");

}

void calcTime()
{

	logout("時間帯別");

	for(int i=0;i<24;i++)
	{
		double cnt = TIME_WIN[i] + TIME_LOSE[i];
		string rate = "0";
		if(cnt != 0)
		{
			rate = DoubleToStr((TIME_WIN[i] / cnt) * 100,1) + "%";
		}
		logout(StringFormat("%2d時 win:%d lose:%d total:%d rate:%s",i,TIME_WIN[i],TIME_LOSE[i],TIME_WIN[i]+TIME_LOSE[i],rate));
	}

	logout("========================================================================");
	logout("");

}

/**
 * getResult
 */
int getResult(int bar_num,string direction)
{

	if(bar_num - HIGHLOW_ENTRY_TIME < 0) return NO_DATA;

	double target  = Close[bar_num - HIGHLOW_ENTRY_TIME];
	double current = Close[bar_num];

	if(direction == "up")
	{
		if(target > current){ return WIN; }
		else if(target < current){ return LOSE; }
		else if(target == current){ return EVEN; }
	}
	else if(direction == "down")
	{
		if(target < current){ return WIN; }
		else if(target > current){ return LOSE; }
		else if(target == current){ return EVEN; }
	}

	return NO_DATA;
}

void countStage(int bar_num,string direction,int &ret[])
{
	//現在のBarから勝敗が決まるBarが確定していない場合、はじく。
	if( bar_num - HIGHLOW_ENTRY_TIME < 0 ) return;

	int result = getResult(bar_num,direction);

	if(result == WIN)
	{
		ArrayResize(STAGE_WIN,ArraySize(STAGE_WIN)+1);
		int stage_pos = ArraySize(STAGE_WIN)-1;
		STAGE_WIN[stage_pos] = ret[0];

		ArrayResize(SUB_STAGE_WIN,ArraySize(SUB_STAGE_WIN)+1);
		int sub_stage_pos = ArraySize(SUB_STAGE_WIN)-1;
		SUB_STAGE_WIN[sub_stage_pos] = ret[1];

	}
	else if(result == LOSE)
	{
		ArrayResize(STAGE_LOSE,ArraySize(STAGE_LOSE)+1);
		int pip_pos = ArraySize(STAGE_LOSE)-1;
		STAGE_LOSE[pip_pos] = ret[0];

		ArrayResize(SUB_STAGE_LOSE,ArraySize(SUB_STAGE_LOSE)+1);
		int sub_stage_pos = ArraySize(SUB_STAGE_LOSE)-1;
		SUB_STAGE_LOSE[sub_stage_pos] = ret[1];

	}
}

void calcStage()
{

	int stage_win_count[7];
	ArrayInitialize(stage_win_count,0);

	for(int i=0;i<ArraySize(STAGE_WIN);i++)
	{
		switch(STAGE_WIN[i])
		{
			case 1:
				stage_win_count[1]++;
				break;
			case 2:
				stage_win_count[2]++;
				break;
			case 3:
				stage_win_count[3]++;
				break;
			case 4:
				stage_win_count[4]++;
				break;
			case 5:
				stage_win_count[5]++;
				break;
			case 6:
				stage_win_count[6]++;
				break;
			default:
				break;
		}

	}

	int stage_lose_count[7];
	ArrayInitialize(stage_lose_count,0);

	for(int i=0;i<ArraySize(STAGE_LOSE);i++)
	{
		switch(STAGE_LOSE[i])
		{
			case 1:
				stage_lose_count[1]++;
				break;
			case 2:
				stage_lose_count[2]++;
				break;
			case 3:
				stage_lose_count[3]++;
				break;
			case 4:
				stage_lose_count[4]++;
				break;
			case 5:
				stage_lose_count[5]++;
				break;
			case 6:
				stage_lose_count[6]++;
				break;
			default:
				break;
		}
	}

	int sub_stage_win_count[100];
	ArrayInitialize(sub_stage_win_count,0);

	for(int i=0;i<ArraySize(SUB_STAGE_WIN);i++)
	{
		switch(SUB_STAGE_WIN[i])
		{
			case 10:
				sub_stage_win_count[10]++;
				break;
			case 11:
				sub_stage_win_count[11]++;
				break;
			case 20:
				sub_stage_win_count[20]++;
				break;
			case 21:
				sub_stage_win_count[21]++;
				break;
			case 30:
				sub_stage_win_count[30]++;
				break;
			case 31:
				sub_stage_win_count[31]++;
				break;
			case 40:
				sub_stage_win_count[40]++;
				break;
			case 41:
				sub_stage_win_count[41]++;
				break;
			case 50:
				sub_stage_win_count[50]++;
				break;
			case 51:
				sub_stage_win_count[51]++;
				break;
			case 60:
				sub_stage_win_count[60]++;
				break;
			case 61:
				sub_stage_win_count[61]++;
				break;
			default:
				break;
		}

	}

	int sub_stage_lose_count[100];
	ArrayInitialize(sub_stage_lose_count,0);

	for(int i=0;i<ArraySize(SUB_STAGE_LOSE);i++)
	{
		switch(SUB_STAGE_LOSE[i])
		{
			case 10:
				sub_stage_lose_count[10]++;
				break;
			case 11:
				sub_stage_lose_count[11]++;
				break;
			case 20:
				sub_stage_lose_count[20]++;
				break;
			case 21:
				sub_stage_lose_count[21]++;
				break;
			case 30:
				sub_stage_lose_count[30]++;
				break;
			case 31:
				sub_stage_lose_count[31]++;
				break;
			case 40:
				sub_stage_lose_count[40]++;
				break;
			case 41:
				sub_stage_lose_count[41]++;
				break;
			case 50:
				sub_stage_lose_count[50]++;
				break;
			case 51:
				sub_stage_lose_count[51]++;
				break;
			case 60:
				sub_stage_lose_count[60]++;
				break;
			case 61:
				sub_stage_lose_count[61]++;
				break;
			default:
				break;
		}
	}

	Print("=============================================================");

	int sum_win = 0;
	int sum_lose = 0;


	for(int stg_count = 1;stg_count <= 6; stg_count++)
	{
		sum_win += stage_win_count[stg_count];
		sum_lose += stage_lose_count[stg_count];
	}


	double total = sum_win + sum_lose;
	double rate = 0.0;
	if(total != 0) rate = sum_win / total;
	
	string str_rate = DoubleToString(rate * 100 ,1) + "%";
	string appearance_rate = DoubleToString(total / Bars * 100,2) + "%";
	string appearance_win_rate = DoubleToString((double)sum_win / Bars * 100,2) + "%";
	
	logout(StringFormat("STAGE 勝ち:%d 負け:%d 勝率 %s 本数:%d 出現確率%s 勝ち出現確率%s",
		sum_win,sum_lose,str_rate,Bars,appearance_rate,appearance_win_rate));	


	for(int stg_count = 1;stg_count <= 6; stg_count++)
	{

		int stage_count_total = stage_win_count[stg_count] + stage_lose_count[stg_count];
		double stage_rate = (double)stage_win_count[stg_count] / (double)stage_count_total * 100;
		logout(StringFormat("STAGE%d win:%d lose:%d total:%d rate:%.1f%%",stg_count,stage_win_count[stg_count],stage_lose_count[stg_count],stage_count_total,stage_rate));
		//sum_win += stage_win_count[stg_count];
		//sum_lose += stage_lose_count[stg_count];
	}
	
	
	
	logout("======================================================================");
	logout("SUBSTAGE");

	int sub_stg_array[] = {10,11,20,21,30,31,40,41,50,51,60,61};
	
	for(int sub_stg_count = 0;sub_stg_count < ArraySize(sub_stg_array);sub_stg_count++)
	{
		int substage_count_total = sub_stage_win_count[sub_stg_array[sub_stg_count]] + sub_stage_lose_count[sub_stg_array[sub_stg_count]];
		
		double substage_rate = 0.0;
		if(substage_count_total != 0){
			substage_rate = (double)sub_stage_win_count[sub_stg_array[sub_stg_count]] / (double)substage_count_total * 100;
		}
		logout(StringFormat("SUB_STAGE%d win:%d lose:%d total:%d rate:%.1f%%",
			sub_stg_array[sub_stg_count],
			sub_stage_win_count[sub_stg_array[sub_stg_count]],
			sub_stage_lose_count[sub_stg_array[sub_stg_count]],substage_count_total,substage_rate));
	}
	
	logout("======================================================================");
	logout("");
}

void countPips(int bar_num,string direction)
{

	int result = getResult(bar_num,direction);

	if(result == WIN)
	{
		ArrayResize(PIPS_WIN,ArraySize(PIPS_WIN)+1);
		int pip_pos = ArraySize(PIPS_WIN)-1;
		PIPS_WIN[pip_pos] = (High[bar_num] - Low[bar_num]) / getPipPrice();
	}
	else if(result == LOSE)
	{
		ArrayResize(PIPS_LOSE,ArraySize(PIPS_LOSE)+1);
		int pip_pos = ArraySize(PIPS_LOSE)-1;
		PIPS_LOSE[pip_pos] = (High[bar_num] - Low[bar_num]) / getPipPrice();
	}
	
}

/**
 *　PIPSの出力
 */

void calcPips()
{

	double sum_win = 0.0;
	int pip_win_range[51];
	ArrayInitialize(pip_win_range,0);
	int win_number = ArraySize(PIPS_WIN);

	for(int j=0;j<win_number;j++)
	{
		sum_win += PIPS_WIN[j];

		if(PIPS_WIN[j] < 0.5)
		{
			pip_win_range[5]++;
		}
		else if(PIPS_WIN[j] > 0.5 && PIPS_WIN[j] <= 1.0)
		{
			pip_win_range[10]++;
		}
		else if(PIPS_WIN[j] > 1.0 && PIPS_WIN[j] <= 1.5)
		{
			pip_win_range[15]++;
		}
		else if(PIPS_WIN[j] > 1.5 && PIPS_WIN[j] <= 2.0)
		{
			pip_win_range[20]++;
		}
		else if(PIPS_WIN[j] > 2.0 && PIPS_WIN[j] <= 2.5)
		{
			pip_win_range[25]++;
		}
		else if(PIPS_WIN[j] > 2.5 && PIPS_WIN[j] <= 3.0)
		{
			pip_win_range[30]++;
		}
		else if(PIPS_WIN[j] > 3.0 && PIPS_WIN[j] <= 3.5)
		{
			pip_win_range[35]++;
		}
		else if(PIPS_WIN[j] > 3.5 && PIPS_WIN[j] <= 4.0)
		{
			pip_win_range[40]++;
		}
		else if(PIPS_WIN[j] > 4.0)
		{
			pip_win_range[45]++;
		}

	}
	
	string pips_win_avg;
	if(ArraySize(PIPS_WIN) == 0)
	{
		pips_win_avg = "0";
	}
	else
	{
		pips_win_avg = DoubleToStr(sum_win / ArraySize(PIPS_WIN),1);
	}
	
	double sum_lose = 0.0;
	int pip_lose_range[51];
	ArrayInitialize(pip_lose_range,0);

	int lose_number = ArraySize(PIPS_LOSE);

	for(int k=0;k<lose_number;k++)
	{
		sum_lose += PIPS_LOSE[k];

		if(PIPS_LOSE[k] < 0.5)
		{
			pip_lose_range[5]++;
		}
		else if(PIPS_LOSE[k] > 0.5 && PIPS_LOSE[k] <= 1.0)
		{
			pip_lose_range[10]++;
		}
		else if(PIPS_LOSE[k] > 1.0 && PIPS_LOSE[k] <= 1.5)
		{
			pip_lose_range[15]++;
		}
		else if(PIPS_LOSE[k] > 1.5 && PIPS_LOSE[k] <= 2.0)
		{
			pip_lose_range[20]++;
		}
		else if(PIPS_LOSE[k] > 2.0 && PIPS_LOSE[k] <= 2.5)
		{
			pip_lose_range[25]++;
		}
		else if(PIPS_LOSE[k] > 2.5 && PIPS_LOSE[k] <= 3.0)
		{
			pip_lose_range[30]++;
		}
		else if(PIPS_LOSE[k] > 3.0 && PIPS_LOSE[k] <= 3.5)
		{
			pip_lose_range[35]++;
		}
		else if(PIPS_LOSE[k] > 3.5 && PIPS_LOSE[k] <= 4.0)
		{
			pip_lose_range[40]++;
		}
		else if(PIPS_LOSE[k] > 4.0)
		{
			pip_lose_range[45]++;
		}
	}
	
	
	string pips_lose_avg;
	if(ArraySize(PIPS_LOSE) == 0)
	{
		pips_lose_avg = "0";
	}
	else
	{
		pips_lose_avg = DoubleToStr(sum_lose / ArraySize(PIPS_LOSE),1);
	}
	
	logout(StringFormat("PIPS 勝ち平均pips:%s 負け平均pips:%s",pips_win_avg,pips_lose_avg));
	
	for(int i=1; i<10;i++)
	{
		int idx = i * 5;
		double from = (double)i * 0.5;
		double to  = (double)i * 1.0;
		logout(StringFormat("%.1f-%.1fpips Win:%d Lose:%d rate:%.1f%%",
			from,to,pip_win_range[idx],pip_lose_range[idx],(double)pip_win_range[idx]/((double)pip_win_range[idx]+(double)pip_lose_range[idx])*100));

	}
	logout("======================================================================");
	logout("");
	
}
void countBands(int bar_num,string direction)
{
	int result = getResult(bar_num,direction);

	if(result == WIN)
	{
		ArrayResize(BANDS_WIN,ArraySize(BANDS_WIN)+1);
		int bands_pos = ArraySize(BANDS_WIN)-1;
		BANDS_WIN[bands_pos] = (UP_BANDS[bar_num] - DN_BANDS[bar_num]) / getPipPrice();
	}
	else if(result == LOSE)
	{
		ArrayResize(BANDS_LOSE,ArraySize(BANDS_LOSE)+1);
		int bands_pos = ArraySize(BANDS_LOSE)-1;
		BANDS_LOSE[bands_pos] = (UP_BANDS[bar_num] - DN_BANDS[bar_num]) / getPipPrice();
	}
}
void calcBands()
{
	double sum_win = 0.0;
	int bands_win_range[51];
	ArrayInitialize(bands_win_range,0);
	for(int j=0;j<ArraySize(BANDS_WIN);j++)
	{
		sum_win += BANDS_WIN[j];

		if(BANDS_WIN[j] < 2)
		{
			bands_win_range[2]++;
		}
		else if(BANDS_WIN[j] > 2 && BANDS_WIN[j] <= 4)
		{
			bands_win_range[4]++;
		}
		else if(BANDS_WIN[j] > 4 && BANDS_WIN[j] <= 6)
		{
			bands_win_range[6]++;
		}
		else if(BANDS_WIN[j] > 6 && BANDS_WIN[j] <= 8)
		{
			bands_win_range[8]++;
		}
		else if(BANDS_WIN[j] > 8 && BANDS_WIN[j] <= 10)
		{
			bands_win_range[10]++;
		}
		else if(BANDS_WIN[j] > 10 && BANDS_WIN[j] <= 12)
		{
			bands_win_range[12]++;
		}
		else if(BANDS_WIN[j] > 12 && BANDS_WIN[j] <= 14)
		{
			bands_win_range[14]++;
		}
		else if(BANDS_WIN[j] > 14 && BANDS_WIN[j] <= 16)
		{
			bands_win_range[16]++;
		}
		else if(BANDS_WIN[j] > 16)
		{
			bands_win_range[18]++;
		}

	}
	
	string bands_win_avg = DoubleToStr(sum_win / ArraySize(BANDS_WIN),1);
		
	double sum_lose = 0.0;
	int bands_lose_range[51];
	ArrayInitialize(bands_lose_range,0);

	for(int k=0;k<ArraySize(BANDS_LOSE);k++)
	{
		sum_lose += BANDS_LOSE[k];

		if(BANDS_LOSE[k] < 2)
		{
			bands_lose_range[2]++;
		}
		else if(BANDS_LOSE[k] > 2 && BANDS_LOSE[k] <= 4)
		{
			bands_lose_range[4]++;
		}
		else if(BANDS_LOSE[k] > 4 && BANDS_LOSE[k] <= 6)
		{
			bands_lose_range[6]++;
		}
		else if(BANDS_LOSE[k] > 6 && BANDS_LOSE[k] <= 8)
		{
			bands_lose_range[8]++;
		}
		else if(BANDS_LOSE[k] > 8 && BANDS_LOSE[k] <= 10)
		{
			bands_lose_range[10]++;
		}
		else if(BANDS_LOSE[k] > 10 && BANDS_LOSE[k] <= 12)
		{
			bands_lose_range[12]++;
		}
		else if(BANDS_LOSE[k] > 12 && BANDS_LOSE[k] <= 14)
		{
			bands_lose_range[14]++;
		}
		else if(BANDS_LOSE[k] > 14 && BANDS_LOSE[k] <= 16)
		{
			bands_lose_range[16]++;
		}
		else if(BANDS_LOSE[k] > 16)
		{
			bands_lose_range[18]++;
		}
	}

	string bands_lose_avg;
	int lose_count = ArraySize(BANDS_LOSE);
	if(	lose_count != 0)
	{
		bands_lose_avg = DoubleToStr(sum_lose / lose_count,1);
	}
	else
	{
		bands_lose_avg = "0.0";
	}

	logout(StringFormat("BOLLINGER BAND 勝ち平均BAND幅:%s 負け平均BAND幅:%s",bands_win_avg,bands_lose_avg));

	for(int i=1;i<10;i++)
	{
		int idx = i * 2;
		double from = (double)idx - 2;
		double to = (double)idx;
		int total = bands_win_range[idx] + bands_lose_range[idx];
		double rate = (double)bands_win_range[idx] / (double)total * 100;
		logout(StringFormat("%.1f-%.1fpips Win:%d Lose:%d total:%d rate:%.1f%%",from,to,bands_win_range[idx], bands_lose_range[idx],total,rate));

	}
	logout("======================================================================");
	logout("");


}


void countEmaBands(int bar_num,string direction)
{
	int result = getResult(bar_num,direction);

	if(result == WIN)
	{
		ArrayResize(EMA_BANDS_WIN,ArraySize(EMA_BANDS_WIN)+1);
		int ema_bands_pos = ArraySize(EMA_BANDS_WIN)-1;
		EMA_BANDS_WIN[ema_bands_pos] = MathAbs((EMA_MID_BUF[bar_num] - EMA_LONG_BUF[bar_num])) / getPipPrice();
	}
	else if(result == LOSE)
	{
		ArrayResize(EMA_BANDS_LOSE,ArraySize(EMA_BANDS_LOSE)+1);
		int ema_bands_pos = ArraySize(EMA_BANDS_LOSE)-1;
		EMA_BANDS_LOSE[ema_bands_pos] = MathAbs((EMA_MID_BUF[bar_num] - EMA_LONG_BUF[bar_num])) / getPipPrice();
	}
}

void calcEmaBands()
{
	double sum_win = 0.0;
	int ema_bands_win_range[51];
	ArrayInitialize(ema_bands_win_range,0);
	for(int j=0;j<ArraySize(EMA_BANDS_WIN);j++)
	{
		sum_win += EMA_BANDS_WIN[j];

		if(EMA_BANDS_WIN[j] < 2)
		{
			ema_bands_win_range[2]++;
		}
		else if(EMA_BANDS_WIN[j] > 2 && EMA_BANDS_WIN[j] <= 4)
		{
			ema_bands_win_range[4]++;
		}
		else if(EMA_BANDS_WIN[j] > 4 && EMA_BANDS_WIN[j] <= 6)
		{
			ema_bands_win_range[6]++;
		}
		else if(EMA_BANDS_WIN[j] > 6 && EMA_BANDS_WIN[j] <= 8)
		{
			ema_bands_win_range[8]++;
		}
		else if(EMA_BANDS_WIN[j] > 8 && EMA_BANDS_WIN[j] <= 10)
		{
			ema_bands_win_range[10]++;
		}
		else if(EMA_BANDS_WIN[j] > 10 && EMA_BANDS_WIN[j] <= 12)
		{
			ema_bands_win_range[12]++;
		}
		else if(EMA_BANDS_WIN[j] > 12 && EMA_BANDS_WIN[j] <= 14)
		{
			ema_bands_win_range[14]++;
		}
		else if(EMA_BANDS_WIN[j] > 14 && EMA_BANDS_WIN[j] <= 16)
		{
			ema_bands_win_range[16]++;
		}
		else if(EMA_BANDS_WIN[j] > 16)
		{
			ema_bands_win_range[18]++;
		}

	}
	
	string ema_bands_win_avg = DoubleToStr(sum_win / ArraySize(EMA_BANDS_WIN),1);
		
	double sum_lose = 0.0;
	int ema_bands_lose_range[51];
	ArrayInitialize(ema_bands_lose_range,0);
	for(int k=0;k<ArraySize(EMA_BANDS_LOSE);k++)
	{
		sum_lose += EMA_BANDS_LOSE[k];

		if(EMA_BANDS_LOSE[k] < 2)
		{
			ema_bands_lose_range[2]++;
		}
		else if(EMA_BANDS_LOSE[k] > 2 && EMA_BANDS_LOSE[k] <= 4)
		{
			ema_bands_lose_range[4]++;
		}
		else if(EMA_BANDS_LOSE[k] > 4 && EMA_BANDS_LOSE[k] <= 6)
		{
			ema_bands_lose_range[6]++;
		}
		else if(EMA_BANDS_LOSE[k] > 6 && EMA_BANDS_LOSE[k] <= 8)
		{
			ema_bands_lose_range[8]++;
		}
		else if(EMA_BANDS_LOSE[k] > 8 && EMA_BANDS_LOSE[k] <= 10)
		{
			ema_bands_lose_range[10]++;
		}
		else if(EMA_BANDS_LOSE[k] > 10 && EMA_BANDS_LOSE[k] <= 12)
		{
			ema_bands_lose_range[12]++;
		}
		else if(EMA_BANDS_LOSE[k] > 12 && EMA_BANDS_LOSE[k] <= 14)
		{
			ema_bands_lose_range[14]++;
		}
		else if(EMA_BANDS_LOSE[k] > 14 && EMA_BANDS_LOSE[k] <= 16)
		{
			ema_bands_lose_range[16]++;
		}
		else if(EMA_BANDS_LOSE[k] > 16)
		{
			ema_bands_lose_range[18]++;
		}
	}

	int ema_lose_count = ArraySize(EMA_BANDS_LOSE);
		
	string ema_bands_lose_avg;
	if(ema_lose_count != 0)
	{
		ema_bands_lose_avg = DoubleToStr(sum_lose / ema_lose_count,1);
	}
	else
	{
		ema_lose_count = 0;
	}
	Print("=============================================================");
	
	logout(StringFormat("EMAバンド幅 勝ち平均EMAバンド幅:%s 負け平均EMAバンド幅:%s",ema_bands_win_avg,ema_bands_lose_avg));
	for(int i=1;i<10;i++)
	{
		int idx = i * 2;
		double from = (double)idx - 2;
		double to = (double)idx;
		int total = ema_bands_win_range[idx] + ema_bands_lose_range[idx];
		double rate = (double)ema_bands_win_range[idx] / (double)total * 100;
		logout(StringFormat("%.1f-%.1fpips Win:%d Lose:%d total:%d rate:%.1f%%",from,to,ema_bands_win_range[idx],ema_bands_lose_range[idx],total,rate));

	}
	logout("======================================================================");
	logout("");

}

double getPipPrice()
{
	double pip = 0;

	if( _Digits == 5 )
	{
		pip = 0.0001;
	}
	else if( _Digits == 3 )
	{
		pip = 0.01;
	}

	return pip;
}


void getStage( double short_ema, double short_ema_p1, double mid_ema, double long_ema, int &ret[] )
{

	int stage = 0;
	int substage = 0;

	if( short_ema > mid_ema && mid_ema > long_ema )
	{
		stage = 1;
		if( short_ema_p1 > short_ema )
		{
			substage = 11;
		}
		else
		{
			substage = 10;
		}
	}
	else if( long_ema > mid_ema && mid_ema > short_ema )
	{
		stage = 4;
		if( short_ema_p1 < short_ema )
		{
			substage = 41;
		}
		else
		{
			substage = 40;
		}
	}
	else if( mid_ema > short_ema && short_ema > long_ema )
	{
		stage = 2;
		if( short_ema_p1 <= short_ema )
		{
			substage = 20;
		}
		else
		{
			substage = 21;
		}
	}
	else if( long_ema > short_ema && short_ema > mid_ema )
	{
		stage = 5;
		if( short_ema_p1 >= short_ema )
		{
			substage = 50;
		}
		else
		{
			substage = 51;
		}
	}
	else if( mid_ema > long_ema && long_ema > short_ema )
	{
		stage = 3;
		if( short_ema_p1 >= short_ema )
		{
			substage = 30;
		}
		else
		{
			substage = 31;
		}
	}
	else if( short_ema > long_ema && long_ema > mid_ema )
	{
		stage = 6;
		if( short_ema_p1 <= short_ema )
		{
			substage = 60;
		}
		else
		{
			substage = 61;
		}
	}

	ret[0] = stage;
	ret[1] = substage;
}


/**
 * 右上にStageを表示
 */
void showStage( int stage, int display_pos, string title, int mode )
{
	if( mode != 1 )
	{
		return;
	}

	if( IsTesting() == true && IsVisualMode() == false ) return;

	double x_pos = 10;
	double y_pos = 15 * display_pos;
	string objName = title;

	string text = title + ":" + IntegerToString( stage ) + "ステージ";
	string rate_font = "MS P ゴシック";

	ObjectDelete( objName );

	ObjectCreate( objName, OBJ_LABEL, 0, 0, 0 );
	ObjectSetText( objName, text, 12, rate_font, clrWhite );
	ObjectSet( objName, OBJPROP_XDISTANCE, x_pos );
	ObjectSet( objName, OBJPROP_YDISTANCE, y_pos );
	ObjectSet( objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER );

}

/**
 * Barの上にStageNumberを表示する。
 *
 * 1:show 0:no show
 *
 */
void showStageNumber( int i, int stage, int display_pos, int mode )
{

	if( mode != 1 ) return; //バーの上にステージナンバーを表示するか。

	if( IsTesting() == true && IsVisualMode() == false ) return;

	long tm = Time[i];
	string objName = "stage_number" + IntegerToString( tm ) + "_" + IntegerToString( display_pos );
	string text = IntegerToString( stage );
	string rate_font = "MS P ゴシック";

	ObjectCreate( objName, OBJ_TEXT, 0, Time[i], High[i] + ( PIP_BASE * display_pos ) );
	ObjectSetText( objName, text, 10, rate_font, clrWhite );

}

//+------------------------------------------------------------------+
void showArrow( string direction, int bar_num, int col )
{

	if( PRINT_MODE == 1 ) return;

	if( IsTesting() == true && IsVisualMode() == false ) return;

	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;

	if( direction == "up" )
	{
		arrow_color = col;
		//arrow_type = 217;
		arrow_type = 233;
		pos = Low[bar_num] - getPipPrice() * 1;
		//anchor = ANCHOR_BOTTOM;
		anchor = ANCHOR_LOWER;
	}
	else if( direction == "down" )
	{
		arrow_color = col;
		arrow_type = 234;
		pos = High[bar_num] + getPipPrice() * 3;
		anchor = ANCHOR_UPPER;
	}
	else
	{
		return;
	}

	MqlDateTime mqlDt;
	TimeToStruct( Time[bar_num], mqlDt );

	string objName =
	    "objArrow_" + StringFormat( "%4d%02d%02d%02d%02d%02d", mqlDt.year, mqlDt.mon, mqlDt.day, mqlDt.hour, mqlDt.min, mqlDt.sec );

	ObjectCreate( 0, objName, OBJ_ARROW, 0, Time[bar_num], pos );
	ObjectSetInteger( 0, objName, OBJPROP_ARROWCODE, arrow_type );
	ObjectSetInteger( 0, objName, OBJPROP_COLOR, arrow_color );
	ObjectSetInteger( 0, objName, OBJPROP_WIDTH, 2 );
	ObjectSetInteger( 0, objName, OBJPROP_ANCHOR, anchor );
	ChartRedraw( 0 );

}

string getUpDown( int i, int pos )
{
	if( i <= 0 ) return "";

	int target = i - pos;
	if( target >= Bars ) return "";

	string txt = "dj";

	if( Close[i] < Close[target] )
	{
		txt = "up";
	}
	else if( Close[i] > Close[target] )
	{
		txt = "dn";
	}

	return txt;

}



string getTimeFrameString()
{
	switch( Period() )
	{
	case PERIOD_M1:
		return( "M1" );
	case PERIOD_M5:
		return( "M5" );
	case PERIOD_M15:
		return( "M15" );
	case PERIOD_M30:
		return( "M30" );
	case PERIOD_H1:
		return( "H1" );
	case PERIOD_H4:
		return( "H4" );
	case PERIOD_D1:
		return( "D1" );
	case PERIOD_W1:
		return( "W1" );
	case PERIOD_MN1:
		return( "MN1" );
	default:
		return( "Unknown timeframe" );
	}
}

//ローソク足の長さ
string getCandleStickBodyPips( double o, double h, double l, double c )
{
	double ret;
	if( o > c )
	{
		ret =  o - c;
	}
	else if( o < c )
	{
		ret = c - o;
	}
	else
	{
		ret = 0.0;
	}

	return DoubleToStr( ret / PIP_BASE, 1 );

}

string getCandleStickAllPips( double h, double l )
{
	return DoubleToStr( ( h - l ) / PIP_BASE, 1 );
}
string getCandleStickUpperPin( double o, double h, double l, double c )
{
	double ret;
	if( o > c )
	{
		ret =  h - o;
	}
	else
	{
		ret = h - c;
	}

	return DoubleToStr( ret / PIP_BASE, 1 );

}
string getCandleStickLowerPin( double o, double h, double l, double c )
{
	double ret;
	if( o < c )
	{
		ret =  o - l;
	}
	else
	{
		ret = c - l;
	}

	return DoubleToStr( ret / PIP_BASE, 1 );

}
string getEmaBand( double mid_ema, double long_ema )
{
	return DoubleToStr( MathAbs( mid_ema - long_ema ) / PIP_BASE, 1 );

}

void showWinLoseMark( string direction, int bar_num, string result, int col )
{

	if( PRINT_MODE == 1 ) return;

	if( IsTesting() == true && IsVisualMode() == false ) return;

	double pos;
	string text;
	int anchor;

	if( direction == "up" )
	{
		pos = Low[bar_num] - getPipPrice() * 6;
		//anchor = ANCHOR_BOTTOM;
		anchor = ANCHOR_LOWER;
	}
	else if( direction == "down" )
	{
		pos = High[bar_num] +  getPipPrice() * 6;
		anchor = ANCHOR_UPPER;
	}
	else
	{
		return;
	}

	MqlDateTime mqlDt;
	TimeToStruct( Time[bar_num], mqlDt );

	string objName =
		"objText_" + StringFormat( "%4d%02d%02d%02d%02d%02d", mqlDt.year, mqlDt.mon, mqlDt.day, mqlDt.hour, mqlDt.min, mqlDt.sec );

	ObjectCreate( 0, objName, OBJ_TEXT, 0, Time[bar_num], pos );
	ObjectSetString( 0, objName, OBJPROP_TEXT, result );
	ObjectSetString( 0, objName, OBJPROP_FONT, "Arial Bold" );
	ObjectSetInteger( 0, objName, OBJPROP_FONTSIZE, 20 );
	ObjectSetInteger( 0, objName, OBJPROP_COLOR, col );
	ObjectSetInteger( 0, objName, OBJPROP_WIDTH, 2 );
	ObjectSetInteger( 0, objName, OBJPROP_ANCHOR, anchor );
	ChartRedraw( 0 );
	
	int short_stage[2];
	getStage( EMA_SHORT_BUF[bar_num], EMA_SHORT_BUF[bar_num + 1], EMA_MID_BUF[bar_num], EMA_LONG_BUF[bar_num], short_stage );
	showStage( short_stage[0], 3, "SHORT_TERM", SHOW_STAGE_NUMBER );
	showStageNumber( bar_num, short_stage[0], 1, SHOW_STAGE_NUMBER );
	

}

void logout(string txt)
{

	//Print(txt);
	//string signal_txt = getStrTimeLocal() + " " + _Symbol + " " + IntegerToString(_Period) + " " + getStrTime() + " ";
	//string file_name = "signal.log";

	//static string file_name = _Symbol + "_" + getStrTimeLocal() + ".log";
	//string file_name = _Symbol + "_" + getStrTime() + ".log";


	int filehandle = FileOpen(LOG_FILE_NAME,FILE_READ|FILE_WRITE);

    if(filehandle < 0)
    {
	    Print("Failed to open file.");
	    Print("Error code ",GetLastError());
    }
 

	FileSeek(filehandle,0,SEEK_END);
	FileWrite(filehandle,txt);
	FileFlush(filehandle);
	FileClose(filehandle); 
	
	Print(txt);

	//Alert(_Symbol + " " + IntegerToString(_Period) + " " + direction);

}
/**
 * ログファイル名を作成する。
 * ・mq4ファイル名
 * ・日付
 * ・HighLowエントリ時間
 * ・拡張子をcsvにする。（後で）
 * ・通貨名
 * ・時間枠
 */
string getLogFileName()
{
	string source_file_name[];
	StringSplit(__FILE__,'.',source_file_name);
	
	string log_file_name = 
			source_file_name[0] + "_" + _Symbol + "_" + IntegerToString(_Period) + "_" + "high_low_" + IntegerToString(HIGHLOW_ENTRY_TIME) + "_" + getStrTimeLocal() + ".log"; 

	return log_file_name;
}


string getStrTimeLocal()
{

	//ローカルの時間にしないと宇和が枯れてしまう。

	string str_time = TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
	StringReplace(str_time,".","");
	StringReplace(str_time,":","");
	StringReplace(str_time," ","");

	return str_time;
						
}
string getStrTime()
{

	//Print(TimeToStr(Time[0],TIME_DATE|TIME_MINUTES));

	string str_time = TimeToStr(Time[0],TIME_DATE|TIME_MINUTES);
	StringReplace(str_time,".","");
	StringReplace(str_time,":","");
	StringReplace(str_time," ","");

	return str_time;
						
}
