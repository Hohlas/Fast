void INPUT(){ // Ф И Л Ь Т Р Ы    В Х О Д А    ///////////////////////////////////////////////////////
   bool SigUp=(InUp && TrUp && !BUY.Val && !memBUY.Val); 
   bool SigDn=(InDn && TrDn && !SEL.Val && !memSEL.Val);  
   if (!SigUp && !SigDn) return; // Print(" Up=",Up," Dn=",Dn);   
   float Delta =ATR*D/2;   // 0 .. 2.5 
   //if (D>0) Delta+=ATR/2;   
   //if (D<0) Delta-=ATR/2;     
   switch (Iprice){  // расчет цены входов:         
      case 1:  // по рынку + ATR          
         setBUY.Val=float(Open[0])+Spred+Delta;     // ask и bid формируем из Open[0],
         setSEL.Val=float(Open[0])-Delta;          // чтоб отложники не зависели от шустрых движух   
      break;
      case 2:  // HI / LO
         setBUY.Val=HI+Delta;    
         setSEL.Val=LO-Delta;    
      break; 
      case 3: // по ФИБО уровням       
         setBUY.Val=FIBO( D);       
         setSEL.Val=FIBO(-D);     
      break;
      case 4:  // LO / HI (was Not used in previous release)
         setBUY.Val = LO+Delta;     
         setSEL.Val = HI-Delta;     
      break;
      }    
   if (SigUp){  // 
      if (!BrkBck) SET_BUY_STOP(); // ставим стоп, если не включен режим "виртуальных" ордеров
      if (Del==1){      // удаление старого ордера при появлении нового сигнала  
         if (BUYSTP     && MathAbs(setBUY.Val-BUYSTP)>ATR/2)      BUYSTP=0;     // если старый ордер далеко от нового
         if (memBUY.Val && MathAbs(setBUY.Val-memBUY.Val)>ATR/2)  memBUY.Val=0;
         if (BUYLIM     && MathAbs(setBUY.Val-BUYLIM)>ATR/2)      BUYLIM=0;     // то удаляем его
         }
      if (Del==2) CLOSE_SEL(float(Ask),Present,"LongSignal");   // при появлении нового сигнала удаляем противоположный или если ордер остался один;
      }    
   if (SigDn){  // 
      if (!BrkBck) SET_SEL_STOP();
      if (Del==1){
         if (SELSTP     && MathAbs(setSEL.Val-SELSTP)>ATR/2)      SELSTP=0; 
         if (memSEL.Val && MathAbs(setSEL.Val-memSEL.Val)>ATR/2)  memSEL.Val=0; 
         if (SELLIM     && MathAbs(setSEL.Val-SELLIM)>ATR/2)      SELLIM=0;  
         }
      if (Del==2) CLOSE_BUY(float(Bid),Present,"ShortSignal");   
      }    
   if (!SigUp || BUYSTP || BUYLIM || memBUY.Val) setBUY.Val=0;  // если остались старые ордера,
   if (!SigDn || SELSTP || SELLIM || memSEL.Val) setSEL.Val=0;  // новые не выставляем 
   ERROR_CHECK(__FUNCTION__);
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SET_BUY_STOP(){// стопы в отдельную ф., чтобы использовать в откатах VIRTUAL_ORDERS() 
   if (S>0)    setBUY.Stp=setBUY.Val-ATR*S;   
   else{
      for (int b=bar; b<Bars; b++)  if (FIND_LO(bar,b,-S, setBUY.Stp, setBUY.Val-Low[b]>-S*ATR))  {A("stpBUY ",setBUY.Stp,b,clrRed); break;} // ближайший фрактал шириной '2' на расстоянии SxATR от входа
      //if (S!=0 && setBUY.Val-setBUY.Stp>ATR*(2*(-S)+1))  {X("STOP too far away",setBUY.Val,bar,clrRed); setBUY.Val=0;} // пик стопа далековато, отменяем ордер
      setBUY.Stp-=ATR/2; // чуть дальше 
      }
   if (P==0)   setBUY.Prf =0;                else
   if (P>0)    setBUY.Prf=setBUY.Val+ATR*P;  else
   if (P<0)    setBUY.Prf=setBUY.Val-(setBUY.Val-setBUY.Stp)/2*P;    
   }   
void SET_SEL_STOP(){
   if (S>0)    setSEL.Stp=setSEL.Val+ATR*S;  
   else{        
      for (int b=bar; b<Bars; b++)  if (FIND_HI(bar,b,-S, setSEL.Stp, High[b]-setSEL.Val>-S*ATR)) {V("stpSEL ",setSEL.Stp,b,clrRed); break;}
      //if (S!=0 && setSEL.Stp-setSEL.Val>ATR*(2*(-S)+1))  {X("STOP too far away",setSEL.Val,bar,clrRed); setSEL.Val=0;} // пик стопа далековато, отменяем ордер
      setSEL.Stp+=ATR/2;
      }
   if (P==0)   setSEL.Prf =0;                else
   if (P>0)    setSEL.Prf=setSEL.Val-ATR*P;  else
   if (P<0)    setSEL.Prf=setSEL.Val+(setSEL.Stp-setSEL.Val)/2*P;   
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void VIRTUAL_ORDERS(){ // виртуальные ордера для откатов после пробоя
   if (BrkBck==0) {memBUY.Val=0; memSEL.Val=0; return;}  
   if (setBUY.Val){  // выставлен/обновлен лонг                              L O N G
      memBUY=setBUY; // запоминаем его параметры в виртуальник
      setBUY.Val=0;  // и удаляем сам ордер
      V("memBUY "+S4(memBUY.Val),memBUY.Val,bar,clrBlue);
      }
   if (ExpirBars && memBUY.Val && Time[0]>memBUY.Exp){ // Экспирация виртуального ордера проверяется вручную
      X("BUY_Expiration",memBUY.Val,bar,clrBlue);
      memBUY.Val=0;                     // удаляем виртуальник
      }
   if (memBUY.Val){ // стоит виртуальник (стоп либо лимит)
      int B=bar;
      if (High[1]>memBUY.Val && High[2]<memBUY.Val){ // пересечение стоп-ордера снизу вверх, стваим лимитник ниже
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (High[B]<High[B+1]) break; // ближайшая впадина
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (High[B]>High[B+1] && High[B]>High[B-1] && High[B]<memBUY.Val-(ATR*(-BrkBck-2))) break; // ближайший пик
         if (BrkBck>0)     setBUY.Val=memBUY.Val-ATR*BrkBck;   // откат ниже пробитого уровня
         else{ 
            if (B<Bars-3)  setBUY.Val=(float)High[B];
         }  }
      if (Low[1]<memBUY.Val && Low[2]>memBUY.Val){ // пересечение лимитника сверху вниз, ставим стоп ордер выше
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]>Low[B+1] && Low[B]>memBUY.Val) break;
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]<Low[B+1] && Low[B]<Low[B-1] && Low[B]>memBUY.Val+(ATR*(-BrkBck-2))) break;
         if (BrkBck>0)     setBUY.Val=memBUY.Val+ATR*BrkBck;
         else{  
            if (B<Bars-3)  setBUY.Val=(float)Low[B]; 
         }  }
      if (setBUY.Val){  // если виртуальник зацепило, т.е. выставлен реальный ордер  
         SET_BUY_STOP();// ставим к нему стоп
         V("BUY "+S4(setBUY.Val),memBUY.Val,bar,clrBlue);
         memBUY.Val=0; // удаляем виртуальник
      }  }          
   if (setSEL.Val){ //                                                        S H O R T        
      memSEL=setSEL;
      setSEL.Val=0;
      A("memSEL "+S4(memSEL.Val),memSEL.Val,bar,clrGreen);
      }
   if (ExpirBars && memSEL.Val && Time[0]>memSEL.Exp){
      X("SEL_Expiration",memSEL.Val,bar,clrGreen);
      memSEL.Val=0;
      }
   if (memSEL.Val){
      int B=bar;
      if (Low[1]<memSEL.Val && Low[2]>memSEL.Val){
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]>Low[B+1]) break;
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (Low[B]<Low[B+1] && Low[B]<Low[B-1] && Low[B]>memSEL.Val+(ATR*(-BrkBck-2))) break;
         if (BrkBck>0)     setSEL.Val=memSEL.Val+ATR*BrkBck;  
         else{             
            if (B<Bars-3)  setSEL.Val=(float)Low[B]; 
         }  }
      if (High[1]>memSEL.Val && High[2]<memSEL.Val){
         if (BrkBck==-1)   for (B=bar+1; B<Bars-2; B++)  if (High[B]<High[B+1] && High[B]<memSEL.Val) break; // ближайшая впадина 
         if (BrkBck<=-2)   for (B=bar+1; B<Bars-2; B++)  if (High[B]>High[B+1] && High[B]>High[B-1] && High[B]<memSEL.Val-(ATR*(-BrkBck-2))) break;   // ближайший пик
         if (BrkBck>0)     setSEL.Val=memSEL.Val-ATR*BrkBck;
         else{              
            if (B<Bars-3)  setSEL.Val=(float)High[B];  
         }  }
      if (setSEL.Val){   
         SET_SEL_STOP();
         A("SEL "+S4(setSEL.Val),memSEL.Val,bar,clrGreen);
         memSEL.Val=0;   
   }  }  } 
   
   
      
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
float FIBO(int FiboLevel){ // Считаем ФИБУ:  Разбиваем диапазон HL   0   11.8   23.6   38.2  50  61.8   76.4  88.2   100 
   double Fib=0;
   switch(FiboLevel){
      case 16: Fib= (HI-LO)*2.500; break;
      case 15: Fib= (HI-LO)*2.382; break;
      case 14: Fib= (HI-LO)*2.236; break;
      case 13: Fib= (HI-LO)*2.118; break;
      case 12: Fib= (HI-LO)*2.000; break;
      case 11: Fib= (HI-LO)*1.882; break;
      case 10: Fib= (HI-LO)*1.764; break;
      case  9: Fib= (HI-LO)*1.618; break;
      case  8: Fib= (HI-LO)*1.500; break;
      case  7: Fib= (HI-LO)*1.382; break;
      case  6: Fib= (HI-LO)*1.236; break;
      case  5: Fib= (HI-LO)*1.118; break;
      case  4: Fib= (HI-LO)*1.000; break; // Hi
      case  3: Fib= (HI-LO)*0.882; break;
      case  2: Fib= (HI-LO)*0.764; break; 
      case  1: Fib= (HI-LO)*0.618; break; // Золотое сечение
      case  0: Fib= (HI-LO)*0.500; break; 
      case -1: Fib= (HI-LO)*0.382; break; // Золотое сечение 
      case -2: Fib= (HI-LO)*0.236; break;
      case -3: Fib= (HI-LO)*0.118; break; 
      case -4: Fib= (HI-LO)*0;     break; // Lo   
      case -5: Fib=-(HI-LO)*0.118; break; 
      case -6: Fib=-(HI-LO)*0.236; break;
      case -7: Fib=-(HI-LO)*0.382; break; 
      case -8: Fib=-(HI-LO)*0.500; break; 
      case -9: Fib=-(HI-LO)*0.618; break; 
      case-10: Fib=-(HI-LO)*0.764; break;
      case-11: Fib=-(HI-LO)*0.882; break;
      case-12: Fib=-(HI-LO)*1.000; break;
      case-13: Fib=-(HI-LO)*1.118; break;
      case-14: Fib=-(HI-LO)*1.236; break;
      case-15: Fib=-(HI-LO)*1.382; break;
      case-16: Fib=-(HI-LO)*1.500; break;
      } //Print("FIBO: HI=",S4(HI)," LO=",S4(LO));
   return(N5(LO+Fib));
   }


   
   
         
         
         
         
         
         
         
         
      

