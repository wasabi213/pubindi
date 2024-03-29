//+------------------------------------------------------------------+
//|                                            NAGAOKA_daijunkan.mq4 |
//|                   Copyright 2019-2020, nagaoka. |
//|                                              |

/*
rates_total チャートのバー（ロウソク足）の総数で最初は画面バー総数です。
価格の変化 (Tick) で呼び出さると+1になります。

prev_calculated 計算済みのバー数です。
最初は0
計算を始めて全て計算を終えた時にはrates_totalと同じ
バーが追加されると rates_totalは1つ増えます。

*/
//+------------------------------------------------------------------+
#include <nagaoka.mqh>


#property copyright   "2019-2020, Shunsuke Nagaoka."
#property link        ""
#property description "Nagaoka daijunkan"
#property strict

#property indicator_chart_window
#property indicator_buffers 15

double UP_BANDS[];
double MD_BANDS[];
double DN_BANDS[];

double WPR[];

double STO_K[];
double STO_D[];

double RSI[];

input int PRINT_MODE = 0; //データ出力モード
//input int SHOW_STAGE_NUMBER = 0; //バーの上にStageナンバーを表示
//input int BASE_PERIOD = 1; // 1:1分 5:5分 15:15分 


input int HIGHLOW_ENTRY_TIME = 1; //ハイローのエントリ時間
input int BOLLINGER_PERIOD = 20;
input double SIGMA = 3;

input int WPR_PERIOD = 9;
input int WPR_UPPER = -20;
input int WPR_LOWER = -30;

input int PERCENT_K = 28;
input int PERCENT_D = 3;
input int SLOWING = 3;

input int RSI_PERIOD = 14;


//固定値
string CURRENCY = "";
double PIP_BASE = 0.0;
string TIME_FRAME = "";
int CURRENCY_DIGIT = 0;

datetime LAST_SIGNAL_DATETIME = 0.0;

int RESULT_ARRAY[];
#define WIN 1
#define LOSE 0
int TIME_WIN[24];
int TIME_LOSE[24];
double PIPS_WIN[];
double PIPS_LOSE[];

double BANDS_WIN[];
double BANDS_LOSE[];

double RSI_WIN[];
double RSI_LOSE[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{

   IndicatorBuffers(4);
   IndicatorDigits(Digits);

   SetIndexStyle(0,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(0,UP_BANDS);
   SetIndexLabel(0,"Bollinger Bands up");
   SetIndexDrawBegin(0,25);
   
   SetIndexStyle(1,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(1,MD_BANDS);
   SetIndexLabel(1,"Bollinger Bands center");
   SetIndexDrawBegin(1,25);

   SetIndexStyle(2,DRAW_LINE,0,0,clrGreen);
   SetIndexBuffer(2,DN_BANDS);
   SetIndexLabel(2,"Bollinger Bands down");
   SetIndexDrawBegin(9,25);

   SetIndexStyle(3,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(3,STO_K);
   SetIndexLabel(3,"STO_K");
   SetIndexDrawBegin(3,28);

   SetIndexStyle(4,DRAW_LINE,0,0,clrRed);
   SetIndexBuffer(4,RSI);
   SetIndexLabel(4,"RSI");
   SetIndexDrawBegin(4,28);



   PIP_BASE = getPipPrice();
   CURRENCY_DIGIT = _Digits;
   TIME_FRAME = getTimeFrameString();
   CURRENCY = _Symbol;
  
  
   ArrayInitialize(TIME_WIN,0);
   ArrayInitialize(TIME_LOSE,0);
  
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  
    Print(reason);
	ObjectDelete(0,"stage_number");  
	//ObjectsDeleteAll(0,"objArrow_");
	ObjectsDeleteAll();
	//return(INIT_SUCCEEDED);
}


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

//--- preliminary calculations

	//Print("start");

	int limit = rates_total - prev_calculated;

	for(int i = limit; i >= 0 ; i--)
	{
		if(i>=Bars-3) continue;

		UP_BANDS[i] = iBands(NULL,PERIOD_CURRENT,BOLLINGER_PERIOD,SIGMA,0,PRICE_CLOSE,MODE_UPPER,i);
		MD_BANDS[i] = iBands(NULL,PERIOD_CURRENT,BOLLINGER_PERIOD,SIGMA,0,PRICE_CLOSE,MODE_MAIN,i);
		DN_BANDS[i] = iBands(NULL,PERIOD_CURRENT,BOLLINGER_PERIOD,SIGMA,0,PRICE_CLOSE,MODE_LOWER,i);

		//WPR[i] = iWPR(NULL,PERIOD_CURRENT,WPR_PERIOD,i);
	
		//Print(i);
		STO_K[i] = iStochastic(NULL,PERIOD_CURRENT,PERCENT_K,PERCENT_D,SLOWING,MODE_SMA,0,0,i);
	
		RSI[i] = iRSI(NULL,PERIOD_CURRENT,RSI_PERIOD,PRICE_CLOSE,i);
	
		string direction = createSignal(i);

		if(direction == "down" || direction == "UP")
		{
			showArrow(direction,i,clrMagenta);
		}
				
		judge(i,direction);

	}
	showRSI();
	showBands();
	showPips();
	showJudge();

	return(rates_total);
}

string createSignal(int i)
{
	string ret = "";

	//if(MD_BANDS[i+1] > MD_BANDS[i]){ ret = "down";} else {return "";}
	//if(WPR[i+1] > WPR_UPPER){ ret = "down";} else {return "";}
	//if(WPR[i] < WPR_LOWER){ ret = "down";} else {return "";}
	
	//if(STO_K[i+1] > 80){ ret = "down";} else {return "";}
	//if(STO_K[i]   < 80){ ret = "down";} else {return "";}

	//if(High[i+2] < MD_BANDS[i+2]){ ret = "down";} else {return "";}
	if(MD_BANDS[i+2] > MD_BANDS[i+1]){ ret = "down";} else {return "";}
	if(MD_BANDS[i+1] > MD_BANDS[i]){ ret = "down";} else {return "";}
	
	if(Open[i+2] > Close[i+2]){ ret = "down";} else {return "";}
	if(Open[i+1] > Close[i+1]){ ret = "down";} else {return "";}
	if(Open[i]   > Close[i]  ){ ret = "down";} else {return "";}
	
	if(Close[i+2] >= Open[i+1]){ ret = "down";} else {return "";}
	if(Close[i+1] >= Open[i]){ ret = "down";} else {return "";}
	

	//ヒゲの長さ
	if(High[i+2] - Open[i+2] < Open[i+2] - Close[i+2]){ ret = "down";} else {return "";}
	if(Close[i+2] - Low[i+2] < Open[i+2] - Close[i+2]){ ret = "down";} else {return "";}

	if(High[i+1] - Open[i+1] < Open[i+1] - Close[i+1]){ ret = "down";} else {return "";}
	if(Close[i+1] - Low[i+1] < Open[i+1] - Close[i+1]){ ret = "down";} else {return "";}

	if(High[i] - Open[i] < Open[i] - Close[i]){ ret = "down";} else {return "";}
	if(Close[i] - Low[i] < Open[i] - Close[i]){ ret = "down";} else {return "";}


	
	if(ret == "up" || ret == "down")
	{
		//Print(TimeToStr(Time[i]) + ":" + ret);
		//printf("%1f:%1f",rsi_p1,rsi);		
	}
	return ret;

}

void showJudge()
{

	int win_count = 0;
	
	for(int i = 0; i < ArraySize(RESULT_ARRAY);i++)
	{
		if(RESULT_ARRAY[i] == 1) { win_count++;}
	}

	Print(ArraySize(RESULT_ARRAY));

	int total = ArraySize(RESULT_ARRAY);
	string percentage;
	if(total == 0.0)
	{
		percentage = 0.0;
	}
	else
	{
		percentage = DoubleToStr((double)win_count / (double)total * 100,1);
	}
	

	for(int i=0;i<24;i++)
	{
		printf("%d時 WIN:%d LOSE:%d",i,TIME_WIN[i],TIME_LOSE[i]);
	}
	Print("通貨:" + _Symbol);
	Print("時間枠:" + _Period);
	Print("ボリンジャーバンドシグマ:" + SIGMA);
	Print("ボリンジャーバンド期間:" + BOLLINGER_PERIOD);
	Print("WPR期間:" + WPR_PERIOD);
	Print("ハイローエントリー時間:" + HIGHLOW_ENTRY_TIME);
	printf("TOTAL:%d win:%d lose:%d win percentage:%s%%",total,win_count,total-win_count,percentage);
	Print("=============================================================");
	Print("");
	Print("");
	Print("");



}
void showPips()
{

	double sum_win = 0.0;
	int pip_win_range[51];
	ArrayInitialize(pip_win_range,0);
	for(int j=0;j<ArraySize(PIPS_WIN);j++)
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
	
	string pips_win_avg = DoubleToStr(sum_win / ArraySize(PIPS_WIN),1);
		
	double sum_lose = 0.0;
	int pip_lose_range[51];
	ArrayInitialize(pip_lose_range,0);
	for(int k=0;k<ArraySize(PIPS_LOSE);k++)
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
	
	string pips_lose_avg = DoubleToStr(sum_lose / ArraySize(PIPS_LOSE),1);

	Print("");
	Print("");
	Print("");
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

}

void showBands()
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
	
	string bands_lose_avg = DoubleToStr(sum_lose / ArraySize(BANDS_LOSE),1);

	Print("");
	Print("");
	Print("");
	Print("=============================================================");

	printf("2.0       Win:%d Lose:%d",bands_win_range[2], bands_lose_range[2]);
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

void showRSI()
{

	double sum_win = 0.0;
	int rsi_win_range[101];
	ArrayInitialize(rsi_win_range,0);
	for(int j=0;j<ArraySize(RSI_WIN);j++)
	{
		sum_win += RSI_WIN[j];

		if(RSI_WIN[j] <= 10)
		{
			rsi_win_range[0]++;
		}
		else if(RSI_WIN[j] > 10 && RSI_WIN[j] <= 20)
		{
			rsi_win_range[10]++;
		}
		else if(RSI_WIN[j] > 20 && RSI_WIN[j] <= 30)
		{
			rsi_win_range[20]++;
		}
		else if(RSI_WIN[j] > 30 && RSI_WIN[j] <= 40)
		{
			rsi_win_range[30]++;
		}
		else if(RSI_WIN[j] > 40 && RSI_WIN[j] <= 50)
		{
			rsi_win_range[40]++;
		}
		else if(RSI_WIN[j] > 50 && RSI_WIN[j] <= 60)
		{
			rsi_win_range[50]++;
		}
		else if(RSI_WIN[j] > 60 && RSI_WIN[j] <= 70)
		{
			rsi_win_range[60]++;
		}
		else if(RSI_WIN[j] > 70 && RSI_WIN[j] <= 80)
		{
			rsi_win_range[70]++;
		}
		else if(RSI_WIN[j] > 80 && RSI_WIN[j] <= 90)
		{
			rsi_win_range[80]++;
		}
		else if(RSI_WIN[j] > 90 )
		{
			rsi_win_range[90]++;
		}

	}
	
	string rsi_win_avg = DoubleToStr(sum_win / ArraySize(RSI_WIN),1);
		
	double sum_lose = 0.0;
	int rsi_lose_range[101];
	ArrayInitialize(rsi_lose_range,0);
	for(int k=0;k<ArraySize(RSI_LOSE);k++)
	{
		sum_lose += RSI_LOSE[k];

		if(RSI_LOSE[k] <= 10)
		{
			rsi_lose_range[0]++;
		}
		else if(RSI_LOSE[k] > 10 && RSI_LOSE[k] <= 20)
		{
			rsi_lose_range[10]++;
		}
		else if(RSI_LOSE[k] > 20 && RSI_LOSE[k] <= 30)
		{
			rsi_lose_range[20]++;
		}
		else if(RSI_LOSE[k] > 30 && RSI_LOSE[k] <= 40)
		{
			rsi_lose_range[30]++;
		}
		else if(RSI_LOSE[k] > 40 && RSI_LOSE[k] <= 50)
		{
			rsi_lose_range[40]++;
		}
		else if(RSI_LOSE[k] > 50 && RSI_LOSE[k] <= 60)
		{
			rsi_lose_range[50]++;
		}
		else if(RSI_LOSE[k] > 60 && RSI_LOSE[k] <= 70)
		{
			rsi_lose_range[60]++;
		}
		else if(RSI_LOSE[k] > 70 && RSI_LOSE[k] <= 80)
		{
			rsi_lose_range[70]++;
		}
		else if(RSI_LOSE[k] > 80 && RSI_LOSE[k] <= 90)
		{
			rsi_lose_range[80]++;
		}
		else if(RSI_LOSE[k] > 90 )
		{
			rsi_lose_range[90]++;
		}


	}
	
	string rsi_lose_avg = DoubleToStr(sum_lose / ArraySize(RSI_LOSE),1);

	Print("=============================================================");

	printf("0-10  Win:%d Lose:%d",rsi_win_range[0],rsi_lose_range[0]);
	printf("10-20 Win:%d Lose:%d",rsi_win_range[10],rsi_lose_range[10]);
	printf("20-30 Win:%d Lose:%d",rsi_win_range[20],rsi_lose_range[20]);
	printf("30-40 Win:%d Lose:%d",rsi_win_range[30],rsi_lose_range[30]);
	printf("40-50 Win:%d Lose:%d",rsi_win_range[40],rsi_lose_range[40]);
	printf("50-60 Win:%d Lose:%d",rsi_win_range[50],rsi_lose_range[50]);
	printf("60-70 Win:%d Lose:%d",rsi_win_range[60],rsi_lose_range[60]);
	printf("70-80 Win:%d Lose:%d",rsi_win_range[70],rsi_lose_range[70]);
	printf("80-90 Win:%d Lose:%d",rsi_win_range[80],rsi_lose_range[80]);
	printf("90-100 Win:%d Lose:%d",rsi_win_range[90],rsi_lose_range[90]);
	printf("勝ち平均RSI:%s 負け平均RSI:%s",rsi_win_avg,rsi_lose_avg);

}

void judge(int bar_num,string direction)
{

	//HIGHLOW_ENTRY_TIME

	//現在のバーから勝敗が決まるバーが確定していない場合は、はじく。
	if(bar_num - HIGHLOW_ENTRY_TIME < 0){ return; }
	
	
	int pos;
	int h;
	
	if(direction == "down")
	{
		ArrayResize(RESULT_ARRAY,ArraySize(RESULT_ARRAY)+1);
		pos = ArraySize(RESULT_ARRAY)-1;

		if(Close[bar_num] > Close[bar_num - HIGHLOW_ENTRY_TIME])
		{
			RESULT_ARRAY[pos] = WIN;
			showWinLoseMark(direction,bar_num,"W",clrAqua);
			TIME_WIN[TimeHour(Time[bar_num])]++;


			//勝った時のpipsを算出する。
			ArrayResize(PIPS_WIN,ArraySize(PIPS_WIN)+1);
			int pip_pos = ArraySize(PIPS_WIN)-1;
			PIPS_WIN[pip_pos] = (High[bar_num] - Low[bar_num]) / getPipPrice();

			//勝った時のボリンジャーバンドの幅を算出する。
			ArrayResize(BANDS_WIN,ArraySize(BANDS_WIN)+1);
			int bands_pos = ArraySize(BANDS_WIN)-1;
			BANDS_WIN[bands_pos] = (UP_BANDS[bar_num] - DN_BANDS[bar_num]) / getPipPrice();
			
			//勝った時のRSIを算出する。
			ArrayResize(RSI_WIN,ArraySize(RSI_WIN)+1);
			int rsi_pos = ArraySize(RSI_WIN)-1;
			RSI_WIN[rsi_pos] = RSI[bar_num];


		}
		else
		{
			RESULT_ARRAY[pos] = LOSE;	
			showWinLoseMark(direction,bar_num,"L",clrRed);
			TIME_LOSE[TimeHour(Time[bar_num])]++;

			//負けた時のpipsを算出する。
			ArrayResize(PIPS_LOSE,ArraySize(PIPS_LOSE)+1);
			int pip_pos = ArraySize(PIPS_LOSE)-1;
			PIPS_LOSE[pip_pos] = (High[bar_num] - Low[bar_num]) / getPipPrice();

			//負けたときのボリンジャーバンドの幅を算出する。
			ArrayResize(BANDS_LOSE,ArraySize(BANDS_LOSE)+1);
			int bands_pos = ArraySize(BANDS_LOSE)-1;
			BANDS_LOSE[bands_pos] = (UP_BANDS[bar_num] - DN_BANDS[bar_num]) / getPipPrice();
				
			//負けた時のRSIを算出する。
			ArrayResize(RSI_LOSE,ArraySize(RSI_LOSE)+1);
			int rsi_pos = ArraySize(RSI_LOSE)-1;
			RSI_LOSE[rsi_pos] = RSI[bar_num];
			
			

		}
	}

	if(direction == "up")
	{
		ArrayResize(RESULT_ARRAY,ArraySize(RESULT_ARRAY));
		pos = ArraySize(RESULT_ARRAY)-1;

		if(Close[bar_num] < Close[bar_num - HIGHLOW_ENTRY_TIME])
		{
			RESULT_ARRAY[pos] = WIN;
			showWinLoseMark(direction,bar_num,"W",clrAqua);
			TIME_WIN[TimeHour(Time[bar_num])]++;

			//勝った時のpipsを算出する。
			ArrayResize(PIPS_WIN,ArraySize(PIPS_WIN)+1);
			int pip_pos = ArraySize(PIPS_WIN)-1;
			PIPS_WIN[pip_pos] = (High[bar_num] - Low[bar_num]) / getPipPrice();
			
			//勝った時のボリンジャーバンドの幅を算出する。
			ArrayResize(BANDS_WIN,ArraySize(BANDS_WIN)+1);
			int bands_pos = ArraySize(BANDS_WIN)-1;
			BANDS_WIN[bands_pos] = (UP_BANDS[bar_num] - DN_BANDS[bar_num]) / getPipPrice();

			//勝った時のRSIを算出する。
			ArrayResize(RSI_WIN,ArraySize(RSI_WIN)+1);
			int rsi_pos = ArraySize(RSI_WIN)-1;
			RSI_WIN[rsi_pos] = RSI[bar_num];
			
			
			

		}
		else
		{
			RESULT_ARRAY[pos] = LOSE;	
			showWinLoseMark(direction,bar_num,"L",clrRed);
			TIME_LOSE[TimeHour(Time[bar_num])]++;

			//負けた時のpipsを算出する。
			ArrayResize(PIPS_LOSE,ArraySize(PIPS_LOSE)+1);
			int pip_pos = ArraySize(PIPS_LOSE)-1;
			PIPS_LOSE[pip_pos] = (High[bar_num] - Low[bar_num]) / getPipPrice();

			//負けたときのボリンジャーバンドの幅を算出する。
			ArrayResize(BANDS_LOSE,ArraySize(BANDS_LOSE)+1);
			int bands_pos = ArraySize(BANDS_LOSE)-1;
			BANDS_LOSE[bands_pos] = (UP_BANDS[bar_num] - DN_BANDS[bar_num]) / getPipPrice();

			//負けた時のRSIを算出する。
			ArrayResize(RSI_LOSE,ArraySize(RSI_LOSE)+1);
			int rsi_pos = ArraySize(RSI_LOSE)-1;
			RSI_LOSE[rsi_pos] = RSI[bar_num];

		}
	}



}





double getPipPrice()
{
	double pip = 0;
	
	if(_Digits == 5)
	{
		pip = 0.0001;
	}
	else if(_Digits == 3)
	{
		pip = 0.01;
	}

	return pip;
}




//+------------------------------------------------------------------+
void showArrow(string direction,int bar_num,int col)
{

	if(PRINT_MODE == 1) return;

	if(IsTesting() == true && IsVisualMode() == false) return;

	double pos;
	int arrow_color;
	int arrow_type;
	int anchor;
	
	if(direction == "up")
	{
		arrow_color = col;
		arrow_type = 217;
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	}
	else if(direction == "down")
	{
		arrow_color = col;
		arrow_type = 234;
		//pos = Low[bar_num];
		//anchor = ANCHOR_LOWER;

		pos = High[bar_num] +  getPipPrice();
		anchor = ANCHOR_UPPER;


	}
	else
	{
		return;
	}

	MqlDateTime mqlDt;
	TimeToStruct(Time[bar_num],mqlDt);
	  
	string objName = 
		"objArrow_" + StringFormat("%4d%02d%02d%02d%02d%02d",mqlDt.year,mqlDt.mon,mqlDt.day,mqlDt.hour,mqlDt.min,mqlDt.sec);

	ObjectCreate(0,objName, OBJ_ARROW,0,Time[bar_num],pos);
	ObjectSetInteger(0,objName, OBJPROP_ARROWCODE,arrow_type);
	ObjectSetInteger(0,objName, OBJPROP_COLOR, arrow_color);
    ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);
    ChartRedraw(0);

}

//+------------------------------------------------------------------+
void showWinLoseMark(string direction,int bar_num,string result,int col)
{

	if(PRINT_MODE == 1) return;

	if(IsTesting() == true && IsVisualMode() == false) return;

	double pos;
	string text;
	int anchor;
	
	if(direction == "up")
	{
		pos = High[bar_num];
		anchor = ANCHOR_BOTTOM;
	}
	else if(direction == "down")
	{
		pos = High[bar_num] +  getPipPrice() * 2;
		anchor = ANCHOR_UPPER;
	}
	else
	{
		return;
	}

	MqlDateTime mqlDt;
	TimeToStruct(Time[bar_num],mqlDt);
	  
	string objName = 
		"objText_" + StringFormat("%4d%02d%02d%02d%02d%02d",mqlDt.year,mqlDt.mon,mqlDt.day,mqlDt.hour,mqlDt.min,mqlDt.sec);

	//ObjectCreate(0,objName, OBJ_ARROW,0,Time[bar_num],pos);
	ObjectCreate(0,objName, OBJ_TEXT,0,Time[bar_num],pos);
	ObjectSetString(0,objName,OBJPROP_TEXT,result);
	ObjectSetString(0,objName,OBJPROP_FONT,"ＭＳ　ゴシック");
	ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,12); 
	//ObjectSetInteger(0,objName, OBJPROP_ARROWCODE,arrow_type);
	ObjectSetInteger(0,objName, OBJPROP_COLOR, col);
    ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);
    ChartRedraw(0);

}

