int INIT(){
   
   return(INIT_SUCCEEDED);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//double HHI, LLO, HHI1, LLO1;
bool EXPERT::COUNT(){// Общие расчеты для всего эксперта 
   ChartHistory="";
   MARKET_UPDATE(Symbol());
   iHILO();// Расчет экстремумов HL, ATR  
   SIGNAL(0,IN, Ik,InUp,InDn); // Input Signal count
   SIGNAL(1,TR,TRk,TrUp,TrDn); // Trend Signal count
   SIG_LINES(TrUp, "TrUp", TrDn, "TrDn", clrGreen);
   SIG_LINES(InUp, "InUp", InDn, "InDn", clrRed);
   ch[6]=atr; ch[7]=ATR; ch[8]=HI; ch[9]=LO;
     
   if (Mod==2) Present=0; else COUNT_OLD();
   LINE("HI", bar+1,HI1, bar,HI, clrBlack,0);
   LINE("LO", bar+1,LO1, bar,LO, clrBlack,0);
   
   //LINE("FIBO Buy", bar,Fibo( D), bar+1,Fibo( D), clrWhite,0);  LINE("FIBO BuyStp", bar,Fibo(D-S), bar+1,Fibo(D-S), clrRed,0);  LINE("FIBO BuyPrf", bar,Fibo(D+P), bar+1,Fibo(D+P), clrYellow,0); 
   //LINE("FIBO Sel", bar,Fibo(-D), bar+1,Fibo(-D), clrWhite,0);  LINE("FIBO SelStp", bar,Fibo(S-D), bar+1,Fibo(S-D), clrRed,0);  LINE("FIBO SelPrf", bar,Fibo(-D-P), bar+1,Fibo(-D-P), clrYellow,0); 
   if (HI==0 || LO==0 || ATR==0) {return(false);}
   
// НАЙДЕМ МАКСИМАЛЬНЫЕ/МИНИМАЛЬНЫЕ ЦЕНЫ С МОМЕНТА ОТКРЫТИЯ ПОЗ ////////////////////////////////////////////////////////////////////////
   if (BUY.Typ==MARKET){
      int shift=SHIFT(BUY.T);
      BUY.Min=(float)Low [iLowest (NULL,0,MODE_LOW ,shift,0)]; 
      BUY.Max=(float)High[iHighest(NULL,0,MODE_HIGH,shift,0)];} //  Print("BUY.Val=",BUY.Val," BuyTime=",BuyTime," Shift=",Shift," MinFromBuy=",MinFromBuy," MaxFromBuy=",MaxFromBuy);    
   if (SEL.Typ==MARKET){
      int shift=SHIFT(SEL.T);
      SEL.Min=(float)Low [iLowest (NULL,0,MODE_LOW ,shift,0)];
      SEL.Max=(float)High[iHighest(NULL,0,MODE_HIGH,shift,0)];
      }
   set.BUY.Exp=0;
   if (tk==0 && ExpirBars>0){
      if (Mod<3)  set.BUY.Exp=Time[0]+datetime((ExpirBars-1)*Period()*60 - Time[0]%(Period()*60)); // округляем период, если открытие задержалось 
      else        set.BUY.Exp=Time[0]+datetime(ExpirBars*Period()*60 - Time[0]%(Period()*60));     // ('-1' убрать в новой версии, осталось для совместимости со старыми)
      } 
   set.SEL.Exp=set.BUY.Exp;
   ERROR_CHECK(__FUNCTION__);
   return (true);
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void EXPERT::CONSTANT_COUNTER(){ // Однократное выполнение в OnInit(): индивидуальные константы MinProfit, PerAdapter, AtrPer, время входа/выхода...      
   float PerAdapter=float(60.00/Period()); //Print("PerAdapter=",PerAdapter);
   BarsInDay=ushort(24*60/Period());
   if (Mod==0) LimitBars=1000;         // предел поиска HI LO 
   else        LimitBars=BarsInDay*25;
   FastAtrPer=a*a; 
   SlowAtrPer=A*A;
   if (tk==0){ // без временного фильтра, активны только GTC и Tper(удержание отрытой позы)
      Tin=0;
      switch(T0){// расчет времени жизни отложников
         case 1: ExpirBars= 1;  break; 
         case 2: ExpirBars= 2;  break; 
         case 3: ExpirBars= 3;  break;     
         case 4: ExpirBars= 5;  break;
         case 5: ExpirBars= 8;  break;
         case 6: ExpirBars=13;  break;
         case 7: ExpirBars=21;  break;
         default:ExpirBars=0;   break; // при Т0=0, 8
         }
      switch(T1){// Время удержания открытой позы и период сделки 
         case 1: Tper= 1;  break;  
         case 2: Tper= 2;  break;  
         case 3: Tper= 3;  break;  
         case 4: Tper= 5;  break;     
         case 5: Tper= 8;  break;  
         case 6: Tper=13;  break;  
         case 7: Tper=21;  break;  
         default:Tper=0; // бесконечно 
         }
      ExpirBars=short(ExpirBars*PerAdapter);
      Tper=short(Tper*PerAdapter); // Print("T0=",T0," T1=",T1," Tper=",Tper);
      }
   else{ // при tk>0 торговля ведется в определенный период
      ExpirBars=0; Tper=0;   
      Tin=(8*(tk-1) + T0-1); // с какого бара начинать торговлю
      switch(T1){// Время удержания открытой позы и период сделки 
         case 1: Tout=Tin+ 1; break; 
         case 2: Tout=Tin+ 2; break; 
         case 3: Tout=Tin+ 3; break; 
         case 4: Tout=Tin+ 5; break;      
         case 5: Tout=Tin+ 8; break;
         case 6: Tout=Tin+12; break;
         case 7: Tout=Tin+16; break;
         default:Tout=Tin+20; break;// при Т1=0, 8
         }
      Tin =ushort(Tin*PerAdapter);   
      Tout=ushort(Tout*PerAdapter); 
      if (Tout>=BarsInDay) Tout-=BarsInDay;   // если время начала торговли будет 18:00, а Период 20 часов, то разрешено торговать с 18:00 до 14:00      
      } Print("CONSTANT_COUNTER for ",Magic,": T0=",T0," T1=",T1,"    Tin=",Tin," Tout=",Tout," PerAdapter=",PerAdapter,".  Или с ",MathFloor((Tin*Period())/60),":",Tin*Period()-MathFloor((Tin*Period())/60)*60," по ",MathFloor((Tout*Period())/60),":",Tout*Period()-MathFloor((Tout*Period())/60)*60); 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EXPERT::FINE_TIME(){ // время, в которое разрешено торговать 
   if (tk==0) return (true); // при tk=0 ограничение по времени не работает
   ushort CurTime=ushort((TimeHour(Time[0])*60+Minute())/Period()); // приводим текущее время в количесво баров с начала дня
   if ((Tin<Tout &&  Tin<=CurTime && CurTime<Tout)             //  00:00-нельзя / Tin-МОЖНО-Tout / нельзя-23:59
   ||  (Tout<Tin && (Tin<=CurTime || (0<=CurTime && CurTime<Tout)))){  //  00:00-можно / Tout-НЕЛЬЗЯ-Tin / можно-23:59  
      //Print("CurTime=",TimeHour(Time[0])," Tin=",Tin," Tout=",Tout);
      return (true);} 
   else return (false);   
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void EXPERT_PARENT_CLASS::GLOBAL_VARIABLES_LIST(){ 
   if (!Real) return;
   COPY(DM);       COPY(DMmax);    COPY(DMmin);
   COPY(HI);       COPY(HI1);      COPY(HI2);   
   COPY(LO);       COPY(LO1);      COPY(LO2);
   COPY(H);        COPY(L);        COPY(C);  
   COPY(Osc0);     COPY(Osc0);     COPY(hl); 
   COPY(BarDM);    COPY(BarHL);    COPY(BarLayers);
   COPY(UpTrend);  COPY(DnTrend);  COPY(HLtrend);
   COPY(mem);      COPY(daybar); 
   if (BarHL==0) BarHL=1; // при инициализации значение должно быть >0 
   }


         