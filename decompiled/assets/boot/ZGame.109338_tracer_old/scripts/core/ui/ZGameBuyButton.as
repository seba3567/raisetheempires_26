package core.ui
{
   import core.ZGlobal;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class ZGameBuyButton extends ZGameButton
   {
      
      private var m_event:MouseEvent = null;
      
      private var m_data:Object = null;
      
      private var m_confirmationPopupActive:Boolean = false;
      
      private var m_disposeCalled:Boolean = false;
      
      public function ZGameBuyButton(param1:MovieClip, param2:Object, param3:Function = null, param4:Number = 1.1, param5:Boolean = false, param6:Function = null, param7:Function = null)
      {
         super(param1,param3,param4,param5,param6,param7);
         this.m_data = param2;
      }
      
      override public function dispose() : void
      {
         if(this.m_confirmationPopupActive)
         {
            this.m_disposeCalled = true;
         }
         else
         {
            super.dispose();
         }
      }
      
      override protected function clickAction(param1:MouseEvent) : void
      {
         if(ZGlobal.player.canBuyCash(this.m_data.cash,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(this.m_data.cash))
            {
               this.m_event = param1;
               this.requestConfirmation();
            }
            else
            {
               super.clickAction(param1);
            }
         }
      }
      
      private function requestConfirmation() : void
      {
         var _loc1_:String = this.m_data.confirmationData.message;
         var _loc2_:String = this.m_data.confirmationData.title;
         var _loc3_:Array = null;
         if(this.m_data.confirmationData.hasOwnProperty("statsData"))
         {
            _loc3_ = this.m_data.confirmationData.statsData;
         }
         else
         {
            _loc3_ = new Array("EmpirePointsConfirm","","","");
         }
         PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc1_,_loc2_,this.onConfirmed,_loc3_),0,false);
         this.m_confirmationPopupActive = true;
      }
      
      private function onConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            super.clickAction(this.m_event);
         }
         this.m_confirmationPopupActive = false;
         if(this.m_disposeCalled)
         {
            super.dispose();
         }
      }
      
      public function set data(param1:Object) : void
      {
         this.m_data = param1;
      }
   }
}

