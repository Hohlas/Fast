void OUTPUT(){ 
   //if (!BUY.Val && !SEL.Val) return;
   float CloseSel=0, CloseBuy=0; // цена, по которой планируется закрываться
   bool  OutUp=0, OutDn=0;   
   if (OTr>0){// пропадание тренда - удаляем отложники, закрываем позы 
      if (!TrUp) {BUYSTP=0;   BUYLIM=0;   OutUp=1;}
      if (!TrDn) {SELSTP=0;   SELLIM=0;   OutDn=1;}
      }
   if (OTr<0){// появление противоположного тренда - удаляем отложники, закрываем позы 
      if (TrDn) {BUYSTP=0;    BUYLIM=0;   OutUp=1;}
      if (TrUp) {SELSTP=0;    SELLIM=0;   OutDn=1;}
      } 
   if (Out){// появление противоположного сигнала
      if (InDn) {BUYSTP=0;    BUYLIM=0;   OutUp=1;}  
      if (InUp) {SELSTP=0;    SELLIM=0;   OutDn=1;}  
      }  
   
   float Delta =ATR*OD/2; 
   switch (Oprc){  // расчет цены выходов: 
      case  1: // по рынку немедленно
         CloseBuy=float(Bid)+Delta;     
         CloseSel=float(Ask)-Delta;    
      break;   
      case  2: // профит на максимально достигнутой в сделке цене
         CloseBuy=MaxFromBuy +ATR/2-Delta; 
         CloseSel=MinFromSell-ATR/2+Delta; 
      break;   
      case  3: // на текущий экстремум
         CloseBuy=HI+ATR/2-Delta; 
         CloseSel=LO-ATR/2+Delta; 
      break; 
      }        
   if (OutUp) CLOSE_BUY(CloseBuy,Present,"OUT");// Выходим из длинной  
   if (OutDn) CLOSE_SEL(CloseSel,Present,"OUT");// Выходим из короткой  
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
void CLOSE_BUY(float ClosePrice, float MinProfit, string Reason){
   float mark=BUYSTP+BUYLIM+memBUY.Val;   // запоминаем для постановки крестика 
   BUYSTP=0;   BUYLIM=0;   memBUY.Val=0;  // удаление отложников
   if (BUY.Val){
      if (ClosePrice<BUY.Val+MinProfit) ClosePrice=BUY.Val+MinProfit; // двинем выход вверх, если требует жаба
      mark=ClosePrice;
      if (ClosePrice<BUY.Prf || BUY.Prf==0){ // если выход ниже профит таргета, или таргета нет вовсе
         if (ClosePrice-Bid<ATR/4)  BUY.Val=0;   
         else                       BUY.Prf=ClosePrice;
      }  }
   if (mark) X(Reason+"/CloseBuy", mark, 0, clrRed);   // Print("CloseBuy=",CloseBuy," Buy.Val=",BUY.Val); 
   }//ERROR_CHECK(__FUNCTION__+Reason);
   
void CLOSE_SEL(float ClosePrice, float MinProfit, string Reason){
   float mark=SELSTP+SELLIM+memSEL.Val;   // запоминаем для постановки крестика
   SELSTP=0;   SELLIM=0;   memSEL.Val=0;  // удаление отложников
   if (SEL.Val){
      if (ClosePrice>SEL.Val-MinProfit) ClosePrice=SEL.Val-MinProfit; // двинем выход вверх, если требует жаба
      mark=ClosePrice;
      if (ClosePrice>SEL.Prf || SEL.Prf==0){ // если выход ниже профит таргета, или таргета нет вовсе
         if (Ask-ClosePrice<ATR/4)  SEL.Val=0;   
         else                       SEL.Prf=ClosePrice;
      }  }
   if (mark) X(Reason+"/CloseSel", mark, 0, clrRed);   // Print("CloseBuy=",CloseBuy," Buy.Val=",BUY.Val); 
   }//ERROR_CHECK(__FUNCTION__+Reason);
          
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void TRAILING_STOP(){   // Подвигаем трейлинги:  
   if (Tk==0) return;
   float TrlBuy=0, TrlSell=0;
   if (Tk>0){ // 2,3,4,...
      TrlBuy  = N5(High[1]-ATR*Tk); // 
      TrlSell = N5(Low [1]+ATR*Tk);
      }
   if (Tk==1){  
      TrlBuy  = N5(LO-ATR/2); // стоп ниже LO на: 0.5 
      TrlSell = N5(HI+ATR/2);
      }
   if (Tk<0){            
      for (int b=bar; b<Bars; b++)  if (FIND_LO(bar,b,-Tk, TrlBuy, High[1]-Low[b]>-Tk*ATR))  {A("trlBUY ",TrlBuy,b,clrRed); break;} // ближайший фрактал шириной '2' на расстоянии SxATR от входа
      TrlBuy-=ATR/2;
      for (int b=bar; b<Bars; b++)  if (FIND_HI(bar,b,-Tk, TrlSell, High[b]-Low[1]>-Tk*ATR)) {V("TrlSell ",TrlSell,b,clrRed); break;}
      TrlSell+=ATR/2;
      }               
   //if (BUY.Val) LINE("TrlBuy",  bar,TrlBuy,  bar+1,TrlBuy,  clrPink,0);
   //if (SEL.Val) LINE("TrlSell", bar,TrlSell, bar+1,TrlSell, clrPink,0);                    
   if (BUY.Val && TrlBuy>BUY.Stp && TrlBuy<Bid-StopLevel && (TrlBuy>BUY.Val || TS==0)){
      LINE("TrlBuy", bar,TrlBuy, bar+1,TrlBuy, clrRed,1);
      BUY.Stp=TrlBuy;}
   if (SEL.Val && TrlSell<SEL.Stp && TrlSell>Ask+StopLevel && (TrlSell<SEL.Val || TS==0)){
      LINE("TrlSell", bar,TrlSell, bar+1,TrlSell, clrRed,1);
      SEL.Stp=TrlSell;} //{Print("SELL=",SEL.Val," TrlSell=",TrlSell);} 
   ERROR_CHECK(__FUNCTION__);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void TRAILING_PROFIT(){ // модификации профита (профитТаргет тока приближается к цене открытия)  
   if (PM1){// приближение профита при каждом откате
      if (BUY.Val && High[2]>High[1] && SHIFT(BUY.T)>1){// если был обратный откат против позы
         if (BUY.Prf==0)   BUY.Prf=MaxFromBuy;  
         else              BUY.Prf-=float((High[2]-High[1])*(PM1+1)*(PM1+1)*0.1); // приближаем тейк, либо ставим если не было                             
         if (BUY.Prf-Bid<ATR/4) BUY.Val=0; // тейк слишком близко к рынку, закрываем позу  
         LINE("BUY.Prf", bar,BUY.Prf, bar+1,BUY.Prf, clrBlue,1);
         }  
      if (SEL.Val &&  Low[2]<Low[1] && SHIFT(SEL.T)>1){
         if (SEL.Prf==0)   SEL.Prf=MinFromSell; 
         else              SEL.Prf+=float((Low[1]-Low [2])*(PM1+1)*(PM1+1)*0.1);
         if (SEL.Prf>=SEL.Val) SEL.Val=0; // 
         if (Ask-SEL.Prf<ATR/4) SEL.Val=0;
         LINE("SEL.Prf", bar,SEL.Prf, bar+1,SEL.Prf, clrBlue,1);
      }  }
   if (PM2){// если цена провалится от максимальнодостигнутого на xATR, выставляется тейк на максимальнодостигнутый уровень
      float Delta=ATR*(PM2+1); // 2  3  4  
      if (BUY.Val && MaxFromBuy-Low [1] >Delta && (BUY.Prf>MaxFromBuy  || BUY.Prf==0))   {BUY.Prf=MaxFromBuy;    LINE("BUY.Prf", bar,BUY.Prf, bar+1,BUY.Prf, clrBlue,1);}   //     V("MaxFromBuy", MaxFromBuy, bar, clrRed);
      if (SEL.Val && High[1]-MinFromSell>Delta && (SEL.Prf<MinFromSell || SEL.Prf==0))   {SEL.Prf=MinFromSell;   LINE("SEL.Prf", bar,SEL.Prf, bar+1,SEL.Prf, clrBlue,1);}  //     A("MinFromSell", MinFromSell, bar, clrRed);
      }  
   ERROR_CHECK(__FUNCTION__);
   }  
   
    
   
              



