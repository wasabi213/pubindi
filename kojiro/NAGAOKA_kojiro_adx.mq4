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
#property indicator_buffers 25

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


input int PRINT_MODE			= 0; //データ出力モード
input int SHOW_STAGE_NUMBER		= 1; //バーの上にStageナンバーを表示
input int HIGHLOW_ENTRY_TIME	= 5; //ハイローのエントリ時間

input int SHORT_PERIOD = 5; //1,5,15,30,60,240,1440
input int MID_PERIOD   = 15; //1,5,15,30,60,240,1440
input int LONG_PERIOD  = 60; //1,5,15,30,60,240,1440

input double BOLLINGER_SIGMA = 2;
input int ADX_PERIOD = 14; //ADX算出期間

//固定値
string CURRENCY = "";
double PIP_BASE = 0.0;
string TIME_FRAME = "";
int CURRENCY_DIGIT = 0;

datetime LAST_SIGNAL_DATETIME = 0.0;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit( void )
{
	//ObjectsDeleteAll(0,"objArrow_");
	//ObjectsDeleteAll();
	//Print("OnInit");

	IndicatorBuffers( 25 );
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


	PIP_BASE		= getPipPrice();
	CURRENCY_DIGIT	= _Digits;
	TIME_FRAME		= getTimeFrameString();
	CURRENCY		= _Symbol;


	ArrayInitialize(TIME_WIN,0);
	ArrayInitialize(TIME_LOSE,0);
	


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

	//double second_term_short;
	//double second_term_short_p1;
	//double second_term_mid;
	//double second_term_long;
	//double third_term_short
	//double third_term_short_p1;
	//double third_term_mid;
	//double third_term_long;


	for( int i = limit; i >= 0 ; i-- )
	{
		if( i >= Bars - 3 ) continue;

		EMA_SHORT_BUF[i]    = iMA( NULL, SHORT_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i );
		EMA_MID_BUF[i]      = iMA( NULL, SHORT_PERIOD, 20, 0, MODE_EMA, PRICE_CLOSE, i );
		EMA_LONG_BUF[i]     = iMA( NULL, SHORT_PERIOD, 40, 0, MODE_EMA, PRICE_CLOSE, i );

		//second_term_short		= iMA( NULL, MID_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i );
		//second_term_short_p1	= iMA( NULL, MID_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i + 1 );
		//second_term_mid		= iMA( NULL, MID_PERIOD, 20, 0, MODE_EMA, PRICE_CLOSE, i );
		//second_term_long		= iMA( NULL, MID_PERIOD, 40, 0, MODE_EMA, PRICE_CLOSE, i );

		///third_term_short   = iMA( NULL, LONG_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i );
		//third_term_short_p1 = iMA( NULL, LONG_PERIOD, 5, 0, MODE_EMA, PRICE_CLOSE, i + 1 );
		//third_term_mid      = iMA( NULL, LONG_PERIOD, 20, 0, MODE_EMA, PRICE_CLOSE, i );
		//third_term_long     = iMA( NULL, LONG_PERIOD, 40, 0, MODE_EMA, PRICE_CLOSE, i );

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

		EMA25[i] = iMA( NULL, PERIOD_CURRENT, 25, 0, MODE_SMA, PRICE_CLOSE, i ); //SMAにする。

		ADX_MAIN[i]  = iADX(NULL,PERIOD_CURRENT,ADX_PERIOD,PRICE_CLOSE,MODE_MAIN,i);
		ADX_PLUS[i]  = iADX(NULL,PERIOD_CURRENT,ADX_PERIOD,PRICE_CLOSE,MODE_PLUSDI,i);
		ADX_MINUS[i] = iADX(NULL,PERIOD_CURRENT,ADX_PERIOD,PRICE_CLOSE,MODE_MINUSDI,i);


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
		showStage( short_stage[0], 3, "SHORT_TERM", SHOW_STAGE_NUMBER );
		showStageNumber( i, short_stage[1], 1, SHOW_STAGE_NUMBER );

		//getStage( second_term_short, second_term_short_p1, second_term_mid, second_term_long, mid_stage );
		//showStage( mid_stage[0], 2, "MID_TERM", SHOW_STAGE_NUMBER );
		//showStageNumber(i,mid_stage[1],2,SHOW_STAGE_NUMBER);

		//getStage( third_term_short, third_term_short_p1, third_term_mid, third_term_long, long_stage );
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
		
	}

	calcResult();
	calcPips();
	calcBands();
	calcEmaBands();
	calcStage();
	calcTime();

	return( rates_total );
}


//string createSignal( int i, int short_num, int mid_num, int long_num )

string createSignal( int i )
{
	if(i + 6 > Bars) return "";

	string ret = "";

	//+DIと-DIがクロスして最初の上昇
	if(ADX_MAIN[i+1] < ADX_MAIN[i]){ ret = "up"; }else{return "";}	
	if(ADX_PLUS[i] > ADX_MINUS[i]){ ret = "up"; }else{return "";}
	//if(ADX_PLUS[i+1] < ADX_MINUS[i+1] && ADX_PLUS[i] > ADX_MINUS[i]){ ret = "up"; }else{return "";}	
	if(ADX_PLUS[i+1] < ADX_PLUS[i] && ADX_MINUS[i+1] > ADX_MINUS[i]){ ret = "up"; }else{return "";}
	if(EMA25[i+1] < EMA25[i]){ ret = "up"; }else{return "";}
	//2020.01.25 18:19:07.261	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:444 負け:507 勝率 46.7% 本数:8422 出現確率11.29% 勝ち出現確率5.27%

	//38を超えたらエントリしない。
	if(ADX_MAIN[i] < 38){ ret = "up"; }else{return "";}
	//2020.01.25 18:51:43.232	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:361 負け:384 勝率 48.5% 本数:8422 出現確率8.85% 勝ち出現確率4.29%

	
	////MACD_SHORTのヒストグラムが0以下のときにエントリしない。
	////if(HISTGRAM_SHORT[i] < 0){ return "";}
	////2020.01.25 18:53:14.376	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:293 負け:317 勝率 48.0% 本数:8422 出現確率7.24% 勝ち出現確率3.48%

	
	//ADXが22以下のときにエントリしない
	if(ADX_MAIN[i] < 22){return "";}
	//2020.01.25 18:54:36.228	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:257 負け:254 勝率 50.3% 本数:8422 出現確率6.07% 勝ち出現確率3.05%

		
	////MACD_SHORTが下がっているときにエントリしない。
	////if(MACD_SHORT[i+1] > MACD_SHORT[i]){return "";}
	////2020.01.25 18:56:30.675	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:232 負け:239 勝率 49.3% 本数:8422 出現確率5.59% 勝ち出現確率2.75%

	
	//MACD_SHORTのシグナルラインが下がっているときにエントリしない。
	if(SIGNAL_SHORT[i+1] > SIGNAL_SHORT[i]){ return "";}
	//2020.01.25 18:58:38.110	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:205 負け:200 勝率 50.6% 本数:8422 出現確率4.81% 勝ち出現確率2.43%

	//終値が2シグマを上回っているか。
	if(Close[i] > UP_BANDS[i]){return "";}
	//2020.01.25 20:20:07.265	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:57 負け:33 勝率 63.3% 本数:8422 出現確率1.07% 勝ち出現確率0.68%



	//帯が細いところはエントリしない。
	if(MathAbs(EMA_MID_BUF[i] - EMA_LONG_BUF[i]) / getPipPrice() > 1){ret = "up";}else{return "";}
	//2020.01.25 19:07:09.844	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:85 負け:70 勝率 54.8% 本数:8422 出現確率1.84% 勝ち出現確率1.01%


	//プラスDIが30以上
	if(ADX_PLUS[i] < 30){return "";}


	//MACD_SHORTがMACD_SHORTのシグナルラインを下回っているときにエントリしない。
	if(MACD_SHORT[i] < SIGNAL_SHORT[i]){return "";}
	//2020.01.25 19:00:37.681	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:188 負け:188 勝率 50.0% 本数:8422 出現確率4.46% 勝ち出現確率2.23%

	//MACD_SHORTのヒストグラムが下がっているときにエントリしない。
	if(HISTGRAM_SHORT[i] < 0){ return "";}


	//MACD_SHORTのヒストグラムが下がっているときにエントリしない。
	if(HISTGRAM_SHORT[i+1] > HISTGRAM_SHORT[i]){ return "";}


	
	////MACD_LONGが下がっている。
	////if(MACD_LONG[i+1] > MACD_LONG[i]){return "";}
	////2020.01.25 19:02:44.336	NAGAOKA_kojiro_adx USDJPY,M5: 勝ち:178 負け:188 勝率 48.6% 本数:8422 出現確率4.35% 勝ち出現確率2.11%


	
	//MACD_LONGのシグナル線が下がっている。





	//if(High[i] > UP_BANDS[i]){ ret = "down"; }else{return "";}	
	//if(Close[i] > UP_BANDS[i]){ ret = "down"; }else{return "";}	
	//if(Low[i] > UP_BANDS[i]){ ret = "down"; }else{return "";}	

	//EMAの帯の幅
	//if(MathAbs(EMA_MID_BUF[i] - EMA_LONG_BUF[i]) / getPipPrice() > 2){ret = "down";}else{return "";}

	//if(UP_BANDS[i+1] > UP_BANDS[i]){ ret = "down"; }else{return "";}	

	//stage1のみ表示
	//int short_stage[2];
	//getStage( EMA_SHORT_BUF[i], EMA_SHORT_BUF[i + 1], EMA_MID_BUF[i], EMA_LONG_BUF[i], short_stage );
	//if(short_stage[0] != 1){ret = "down";}else{return "";}
	

	if( ret == "up" || ret == "down" )
	{
		//Print(TimeToStr(Time[i]) + ":" + ret);
		//printf("%d:%d:%d",long_num,mid_num,short_num);

	}
	return ret;

}

#define BOLLINGER_PAST 3
bool isBollingerTouch(int bar_num,string direction)
{

	for(int i = 0; i < BOLLINGER_PAST;i++)
	{
		if(direction == "up")
		{
			if(High[bar_num + i] > UP_BANDS[bar_num + i])
			{
				return true;
			}
		}
		else
		{
			if(Low[bar_num + i] < DN_BANDS[bar_num + i])
			{
				return true;
			}
		}
	}


	return false;

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
		rate = WIN_NUMBER / total;
	}

	printf("win:%d lose:%d even:%d rate:%s",WIN_NUMBER,LOSE_NUMBER,EVEN_NUMBER,DoubleToStr(rate,1));

}

void calcTime()
{


	for(int i=0;i<24;i++)
	{
		double cnt = TIME_WIN[i] + TIME_LOSE[i];
		string rate = "0";
		if(cnt != 0)
		{
			rate = DoubleToStr((TIME_WIN[i] / cnt) * 100,1) + "%";
		}
		
		
		
		printf("%d時 win:%d lose:%d total:%d rate:%s",i,TIME_WIN[i],TIME_LOSE[i],TIME_WIN[i]+TIME_LOSE[i],rate);
	
	}


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
		printf("STAGE%d win:%d lose:%d",stg_count,stage_win_count[stg_count],stage_lose_count[stg_count]);
		sum_win += stage_win_count[stg_count];
		sum_lose += stage_lose_count[stg_count];
	}

	int sub_stg_array[] = {10,11,20,21,30,31,40,41,50,51,60,61};
	
	for(int sub_stg_count = 0;sub_stg_count < ArraySize(sub_stg_array);sub_stg_count++)
	{
		printf("SUB_STAGE%d win:%d lose:%d",
			sub_stg_array[sub_stg_count],
			sub_stage_win_count[sub_stg_array[sub_stg_count]],
			sub_stage_lose_count[sub_stg_array[sub_stg_count]]);
	}
	
	double total = sum_win + sum_lose;
	double rate = sum_win / total;
	//Print(sum_win);
	//Print(sum_lose);
	//Print(rate);
	
	string str_rate = DoubleToString(rate * 100 ,1) + "%";
	string appearance_rate = DoubleToString(total / Bars * 100,2) + "%";
	string appearance_win_rate = DoubleToString((double)sum_win / Bars * 100,2) + "%";
	
	printf("勝ち:%d 負け:%d 勝率 %s 本数:%d 出現確率%s 勝ち出現確率%s",
		sum_win,sum_lose,str_rate,Bars,appearance_rate,appearance_win_rate);	

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
		pips_lose_avg = 0;
	}
	else
	{
		pips_lose_avg = DoubleToStr(sum_lose / ArraySize(PIPS_LOSE),1);
	}
	
	Print("=============================================================");
	printf("0.0-0.5 Win:%d Lose:%d",pip_win_range[5], pip_lose_range[5]);
	printf("0.5-1.0 Win:%d Lose:%d",pip_win_range[10],pip_lose_range[10]);
	printf("1.0-1.5 Win:%d Lose:%d",pip_win_range[15],pip_lose_range[15]);
	printf("1.5-2.0 Win:%d Lose:%d",pip_win_range[20],pip_lose_range[20]);
	printf("2.0-2.5 Win:%d Lose:%d",pip_win_range[25],pip_lose_range[25]);
	printf("2.5-3.0 Win:%d Lose:%d",pip_win_range[30],pip_lose_range[30]);
	printf("3.0-3.5 Win:%d Lose:%d",pip_win_range[35],pip_lose_range[35]);
	printf("3.5-4.0 Win:%d Lose:%d",pip_win_range[40],pip_lose_range[40]);
	printf("4.0 Win:%d Lose:%d",    pip_win_range[45],pip_lose_range[45]);
	printf("勝ち平均pips:%s 負け平均pips:%s",pips_win_avg,pips_lose_avg);
	printf("勝ち:%d回 負け:%d回",win_number,lose_number);

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
	Print("=============================================================");
	printf("0.0-2.0   Win:%d Lose:%d",bands_win_range[2], bands_lose_range[2]);
	printf("2.0-4.0   Win:%d Lose:%d",bands_win_range[4], bands_lose_range[4]);
	printf("4.0-6.0   Win:%d Lose:%d",bands_win_range[6], bands_lose_range[6]);
	printf("6.0-8.0   Win:%d Lose:%d",bands_win_range[8], bands_lose_range[8]);
	printf("8.0-10.0  Win:%d Lose:%d",bands_win_range[10],bands_lose_range[10]);
	printf("10.0-12.0 Win:%d Lose:%d",bands_win_range[12],bands_lose_range[12]);
	printf("12.0-14.0 Win:%d Lose:%d",bands_win_range[14],bands_lose_range[14]);
	printf("14.0-16.0 Win:%d Lose:%d",bands_win_range[16],bands_lose_range[16]);
	printf("16.0      Win:%d Lose:%d",bands_win_range[18],bands_lose_range[18]);
	printf("勝ち平均BAND幅:%s 負け平均BAND幅:%s",bands_win_avg,bands_lose_avg);

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
	printf("0.0-2.0  Win:%d Lose:%d",ema_bands_win_range[2], ema_bands_lose_range[2]);
	printf("2.0-4.0   Win:%d Lose:%d",ema_bands_win_range[4], ema_bands_lose_range[4]);
	printf("4.0-6.0   Win:%d Lose:%d",ema_bands_win_range[6], ema_bands_lose_range[6]);
	printf("6.0-8.0   Win:%d Lose:%d",ema_bands_win_range[8], ema_bands_lose_range[8]);
	printf("8.0-10.0  Win:%d Lose:%d",ema_bands_win_range[10],ema_bands_lose_range[10]);
	printf("10.0-12.0 Win:%d Lose:%d",ema_bands_win_range[12],ema_bands_lose_range[12]);
	printf("12.0-14.0 Win:%d Lose:%d",ema_bands_win_range[14],ema_bands_lose_range[14]);
	printf("14.0-16.0 Win:%d Lose:%d",ema_bands_win_range[16],ema_bands_lose_range[16]);
	printf("16.0      Win:%d Lose:%d",ema_bands_win_range[18],ema_bands_lose_range[18]);
	printf("勝ち平均EMA BAND幅:%s 負け平均EMA BAND幅:%s",ema_bands_win_avg,ema_bands_lose_avg);

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

}

