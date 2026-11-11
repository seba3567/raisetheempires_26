package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.managers.promoManager.PromoManager;
   import flash.events.Event;
   
   public class DoStartPromoManager extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartPromoManager";
      
      private var m_acceptedCrossPromos:Object;
      
      private var m_availableCrossPromos:Object;
      
      public function DoStartPromoManager(param1:Object, param2:Object)
      {
         super(INIT_ID);
         this.m_acceptedCrossPromos = param1;
         this.m_availableCrossPromos = param2;
      }
      
      override public function execute() : void
      {
         PromoManager.instance.addEventListener(PromoManager.EVENT_SHOWN_ALL_MESSAGES,this.onPromoDone,false,0,true);
         PromoManager.instance.initialize(this.m_acceptedCrossPromos,this.m_availableCrossPromos);
      }
      
      public function onPromoDone(param1:Event) : void
      {
         PromoManager.instance.removeEventListener(PromoManager.EVENT_SHOWN_ALL_MESSAGES,this.onPromoDone);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

