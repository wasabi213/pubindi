//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |

/*
rates_total チャートのバー（ロウソク足）の総数で最初は画面バー総数です。
価格の変化 (Tick) で呼び出さると+1になります。

prev_calculated 計算済みのバー数です。
最初は0
計算を始めて全て計算を終えた時にはrates_totalと同じ
バーが追加されると rates_totalは1つ増えます。




*/
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Relative Strength Index"
#property strict

#property indicator_chart_window


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  //ObjectsDeleteAll(0,"objArrow_");
  //ObjectsDeleteAll();
  Print("OnInit");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+

int OnDeinit()
  {
  ObjectsDeleteAll(0,"objArrow_");
  //ObjectsDeleteAll();
   return(INIT_SUCCEEDED);
 }





int short_term[];
int middle_term[];
int up_short_term[];
int up_middle_term[];

bool short_term_flag = false;
bool mid_term_flag = false;
bool long_term_flag = false;

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



	int limit = rates_total - prev_calculated;


	for(int i = limit; i >= 0 ; i--)
	{
		//Print("test");
		if(i > rates_total-4)continue;

		/*
		//つつみ足を除外
		if(High[i-3] < High[i-2] && Low[i-3] > Low[i-2])
		{
			continue;
		}
		if(High[i-1] > High[i-2] && Low[i-1] < Low[i-2])
		{
			continue;
		}
		
		
		//はらみ足を除外
		if(High[i-3] > High[i-2] && Low[i-3] < Low[i-2])
		{
			continue;
		}   

		if(High[i-1] < High[i-2] && Low[i-1] > Low[i-2])
		{
			continue;
		}   
		*/


		//下向き矢印の判定
		if(Low[i+3] >= Low[i+2] && Low[i+2] < Low[i+1])
		{
			//短期矢印の表示
			showArrow("down",i+2,clrMagenta);
			
			short_term_flag = false;
			
			//短期安値を配列に追加
			ArrayResize(short_term,ArraySize(short_term)+1);
			short_term[ArraySize(short_term)-1] = i+2;


			if(ArraySize(short_term) > 3)
			{
			
				//短期安値の末尾のインデックスを取得する。
				int last_short_idx = ArraySize(short_term)-1;
			
			
				//短期安値と短期安値の間の中期安値が形成されているか判定する。
				if(	Low[short_term[last_short_idx-2]] > Low[short_term[last_short_idx-1]] &&
					Low[short_term[last_short_idx-1]] <  Low[short_term[last_short_idx]] )
				{
					//中期安値の矢印表示
					showArrow("down",short_term[last_short_idx-1],clrBlue);
	
					mid_term_flag = false;
	
					//中期の安値を配列に追加する。
					ArrayResize(middle_term,ArraySize(middle_term)+1);			
					middle_term[ArraySize(middle_term)-1] = short_term[last_short_idx-1];
					
					if(ArraySize(middle_term) > 3)
					{

						//中期安値の末尾のインデックスを取得する。
						int last_mid_idx = ArraySize(middle_term)-1;

						//中期安値と中期安値の間に長期安値が形成されているか判定する。
						if(	Low[middle_term[last_mid_idx-2]] > Low[middle_term[last_mid_idx-1]] &&
							Low[middle_term[last_mid_idx-1]] < Low[middle_term[last_mid_idx]])
						{
							//長期安値の矢印表示
							showArrow("down",middle_term[last_mid_idx-1],clrLime);

							long_term_flag = false;

						}
					}
				}
			}
		}// 下向き矢印の処理


		//上向き矢印の判定
		if(High[i+3] <= High[i+2] && High[i+2] > High[i+1])
		{
			//短期矢印の表示
			showArrow("up",i+2,clrMagenta);
			
			short_term_flag = true;
			
			//短期安値を配列に追加
			ArrayResize(up_short_term,ArraySize(up_short_term)+1);
			up_short_term[ArraySize(up_short_term)-1] = i+2;

			if(ArraySize(up_short_term) > 3)
			{
			
				//短期安値の末尾のインデックスを取得する。
				int last_short_idx = ArraySize(up_short_term)-1;
			
			
				//短期安値と短期安値の間の中期安値が形成されているか判定する。
				if(	High[up_short_term[last_short_idx-2]] < High[up_short_term[last_short_idx-1]] &&
					High[up_short_term[last_short_idx-1]] > High[up_short_term[last_short_idx]] )
				{
					//中期安値の矢印表示
					showArrow("up",up_short_term[last_short_idx-1],clrBlue);

					mid_term_flag = true;


					//中期の安値を配列に追加する。
					ArrayResize(up_middle_term,ArraySize(up_middle_term)+1);			
					up_middle_term[ArraySize(up_middle_term)-1] = up_short_term[last_short_idx-1];
					
					if(ArraySize(up_middle_term) > 3)
					{

						//中期安値の末尾のインデックスを取得する。
						int last_mid_idx = ArraySize(up_middle_term)-1;

						//中期安値と中期安値の間に長期安値が形成されているか判定する。
						if(	High[up_middle_term[last_mid_idx-2]] < High[up_middle_term[last_mid_idx-1]] &&
							High[up_middle_term[last_mid_idx-1]] > High[up_middle_term[last_mid_idx]])
						{
							//長期安値の矢印表示
							showArrow("up",up_middle_term[last_mid_idx-1],clrLime);

							long_term_flag = true;
						
						}
					}
				}
			}
		}//上向き矢印の処理
	}


	showFlag();

	return(rates_total);
}


//+------------------------------------------------------------------+
void showArrow(string direction,int bar_num,int col)
{

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
		arrow_type = 218;
		pos = Low[bar_num];
		anchor = ANCHOR_LOWER;
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

void signallog(string signal_txt)
{

	int filehandle=FileOpen("signal.log",FILE_WRITE); 
	FileWrite(filehandle,signal_txt);
	FileFlush(filehandle);
	FileClose(filehandle); 

}

void showFlag()
{

	string objShort = "short_flg";
	string objMid = "mid_flg";
	string objLong = "long_flg";

	string short_txt,mid_txt,long_txt;
	color col_short,col_mid,col_long;

	ObjectDelete(objShort);
	ObjectDelete(objMid);
	ObjectDelete(objLong);

	if(short_term_flag == true)
	{
		short_txt = "短期：下落";
		col_short = clrMagenta;
	}
	else
	{
		short_txt = "短期：上昇";
		col_short = clrAqua;
	}

	
	//ObjectCreate(0,objShort, OBJ_ARROW,0,0,0);
	ObjectCreate(0,objShort,OBJ_LABEL,0,0,0);
	ObjectSetString(0,objShort,OBJPROP_TEXT,short_txt);    // 表示するテキスト
    ObjectSetString(0,objShort,OBJPROP_FONT,"ＭＳ　ゴシック");
    ObjectSetInteger(0,objShort,OBJPROP_FONTSIZE,14);                   // フォントサイズ
    ObjectSetInteger(0,objShort,OBJPROP_COLOR,col_short);                   // フォントサイズ
    ObjectSetInteger(0,objShort,OBJPROP_CORNER,CORNER_RIGHT_UPPER);  // コーナーアンカー設定
    ObjectSetInteger(0,objShort,OBJPROP_XDISTANCE,100);                // X座標
    ObjectSetInteger(0,objShort,OBJPROP_YDISTANCE,20);     



	if(mid_term_flag == true)
	{
		mid_txt = "中期：下落";
		col_mid = clrMagenta;
	}
	else
	{
		mid_txt = "中期：上昇";
		col_mid = clrAqua;
	}

	
	ObjectCreate(0,objMid,OBJ_LABEL,0,0,0);
	ObjectSetString(0,objMid,OBJPROP_TEXT,mid_txt);    // 表示するテキスト
    ObjectSetString(0,objMid,OBJPROP_FONT,"ＭＳ　ゴシック");
    ObjectSetInteger(0,objMid,OBJPROP_FONTSIZE,14);                   // フォントサイズ
    ObjectSetInteger(0,objMid,OBJPROP_COLOR,col_mid);                   // フォントサイズ
    ObjectSetInteger(0,objMid,OBJPROP_CORNER,CORNER_RIGHT_UPPER);  // コーナーアンカー設定
    ObjectSetInteger(0,objMid,OBJPROP_XDISTANCE,100);                // X座標
    ObjectSetInteger(0,objMid,OBJPROP_YDISTANCE,40);     




	if(long_term_flag == true)
	{
		long_txt = "長期：下落";
		col_long = clrMagenta;
	}
	else
	{
		long_txt = "長期：上昇";
		col_long = clrAqua;
	}

	
	ObjectCreate(0,objLong,OBJ_LABEL,0,0,0);
	ObjectSetString(0,objLong,OBJPROP_TEXT,long_txt);    // 表示するテキスト
    ObjectSetString(0,objLong,OBJPROP_FONT,"ＭＳ　ゴシック");
    ObjectSetInteger(0,objLong,OBJPROP_FONTSIZE,14);                   // フォントサイズ
    ObjectSetInteger(0,objLong,OBJPROP_COLOR,col_long);                   // フォントサイズ
    ObjectSetInteger(0,objLong,OBJPROP_CORNER,CORNER_RIGHT_UPPER);  // コーナーアンカー設定
    ObjectSetInteger(0,objLong,OBJPROP_XDISTANCE,100);                // X座標
    ObjectSetInteger(0,objLong,OBJPROP_YDISTANCE,60);     

}