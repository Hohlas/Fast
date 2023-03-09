   
 
   
class MAIN_PARENT_CLASS { // parent class
   protected:
      bool     InUp, InDn, TrUp, TrDn;   
      short    FastAtrPer, SlowAtrPer, Tout, Tin, Tper,  ExpirBars;
      float    Present;
      
   public:
      
   }; 
  
     
class EXPERT : public MAIN_PARENT_CLASS { // дочерний класс печати внешних переменных на график
   #define  LOAD 1
   #define  SAVE 2
   #define PARAMS 50 // максимальное количество входных параметров эксперта
   #define MAX_EXPERTS_AMOUNT 100 // 

   private:
         uchar ExpNum, cnt, cnt_arr, mode; 
      
   
   public:     
      void MAIN();
      void INIT(uchar e){ExpNum=e;}
      bool FINE_TIME();
      void PENDING_ORDERS_DEL();
      bool COUNT();
      void CONSTANT_COUNTER();
      bool CAN_TRADE();
      void TRAILING_STOP();
      void TRAILING_PROFIT();
      void OUTPUT();
      void iHILO();
      void iHL(int B);
      void ATR_DOUBLE(int B);
      void TIMER();
      void ORDERS_CLOSE(uchar Position);
      void CLOSE_BUY(float ClosePrice, float MinProfit, string Reason);
      void CLOSE_SEL(float ClosePrice, float MinProfit, string Reason);
      void SET_BUY_STOP();
      void SET_SEL_STOP();
      void INPUT();    
      void VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
      bool EXPERT_SET();
      void AFTER();
      
      void GLOBAL_VARIABLES_LIST();    // функция со списком глобальных переменных. Запускается в COUNT()
      void BACKUP(); // сохранение списка переменных заданного эксперта
      void RESTORE(); // восстановление списка переменных заданного эксперта
      
      template <typename type1>     
      void EXPERT::DATA(type1 &Data){ // сохранение/восстановление любого типа переменных
         static type1 copy_data[PARAMS][MAX_EXPERTS_AMOUNT];
         if (mode==SAVE)   copy_data[cnt][ExpNum]=Data;
         if (mode==LOAD)   Data=copy_data[cnt][ExpNum];
         //Print("cnt=",cnt);
         cnt++; 
         }; 
         
      template <typename type0> 
      void EXPERT::DATA(type0 &arr[]){ // сохранение/восстановление любого типа массива переменных
         uint size=ArraySize(arr); 
         static type0 copy[][PARAMS][MAX_EXPERTS_AMOUNT];
         ArrayResize(copy,size,0);
         if (mode==SAVE)   for (uint i=0; i<size; i++) copy[i][cnt_arr][ExpNum]=arr[i];
         if (mode==LOAD)   for (uint i=0; i<size; i++) arr[i]=copy[i][cnt_arr][ExpNum];
         //Print("cnt_arr=",cnt_arr);
         cnt_arr++;
         }      
      
      
   }EXP[MAX_EXPERTS_AMOUNT];
   
void EXPERT::MAIN(){
   if (!EXPERT_SET()) return; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
   CONSTANT_COUNTER();
   ORDER_CHECK();  // подробности открытых и отложенных поз  Print("SELLSTOP=",SELLSTOP," BUYSTOP=",BUYSTOP);
   TIMER(); // может пора закрыть открытые позы?
   PENDING_ORDERS_DEL(); // удаление отложника, если остался один (при Del=2)
   if (!COUNT() || !CAN_TRADE()){// не торгуем и закрываем все позы в период запрета торговли
      AFTER(); 
      return;}
   if (BUY.Typ==MARKET || SEL.Typ==MARKET){
      TRAILING_STOP();
      TRAILING_PROFIT();
      OUTPUT();   
      }
   INPUT();    
   VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
   MODIFY();  
   if (set.BUY.Val!=0 || set.SEL.Val!=0){ 
      if (Real)   ORDERS_COLLECT();
      else{   
         if (Risk==0)   Lot=float(0.1);
         else           Lot=MM(MathMax(set.BUY.Val-set.BUY.Stp, set.SEL.Stp-set.SEL.Val), Risk, SYMBOL); Print("Lot=",Lot);
         Lot=float(0.1); ORDERS_SET();
      }  }   
      AFTER(); // сохранение на каждом баре переменных HI,LO,DM,DayBar... и значений индикаторов Real/Test    
   }  
        
      

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EXPERT::CAN_TRADE(){// удаление всех поз в период запрета торговли
   if (!FINE_TIME()                                                  // временной фильтр
   || (Wknd==1 && TimeDayOfWeek(TimeCurrent())==5 && TimeDay(TimeCurrent())>22)  // FOMC
   || (Wknd==2 && TimeDayOfWeek(TimeCurrent())==5 && TimeHour(TimeCurrent())>21)){// Weekend
      ORDERS_CLOSE(0); // все закрываем и удаляем
      MODIFY();   
      return (false);
      }
   return (true);
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void EXPERT::PENDING_ORDERS_DEL(){// УДАЛЕНИЕ ОТЛОЖНИКА, ЕСЛИ ОСТАЛСЯ ОДИН  
   if (Del!=2)  return;
   if (BUY.Typ==MARKET){ 
      if (SEL.Typ==STOP && SEL.Val!=mem.SEL.Val)  SEL.Val=0;   
      if (SEL.Typ==LIMIT)                         SEL.Val=0;  
      }
   if (SEL.Typ==MARKET){
      if (BUY.Typ==STOP && BUY.Val!=mem.BUY.Val)  BUY.Val=0;    
      if (BUY.Typ==LIMIT)                         BUY.Val=0;   
   }  }
   

void EXPERT::BACKUP(){ // сохранение списка переменных заданного эксперта
   cnt=0; cnt_arr=0;
   mode=SAVE; //Print("MODE=SAVE, expert=",SetExpertNum);
   GLOBAL_VARIABLES_LIST();
   }
   
void EXPERT::RESTORE(){ // восстановление списка переменных заданного эксперта
   cnt=0; cnt_arr=0;
   mode=LOAD; //Print("MODE=LOAD, expert=",SetExpertNum);
   GLOBAL_VARIABLES_LIST();
   }   
         
