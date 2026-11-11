package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.CyclonePowerManager;
   import displays.popups.SpeechPopup;
   import displays.screens.partsGather.CyclonePowerPartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import transactions.TCollectCycloneCoins;
   import zlabs.managers.PopupManager;
   
   public class CyclonePowerDialogState extends BuildingPartsDialogState
   {
      
      public static const BUILD_PART1:String = "B933";
      
      public static const BUILD_PART2:String = "B934";
      
      public static const BUILD_PART3:String = "B935";
      
      public static const BUILD_PART4:String = "B936";
      
      public static const BUILD_PART5:String = "B937";
      
      public static const BUILD_PART6:String = "B938";
      
      protected var m_cancelNextState:String = null;
      
      public function CyclonePowerDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         CyclonePowerManager.instance.addEventListener(CyclonePowerManager.SHOWDIALOG,this.onShowDialogFromQuestManager,false,0,true);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(CyclonePowerPartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CyclonePowerPartsGather.COLLECTED,this.onCollected,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CyclonePowerPartsGather.FAILURE_SPEECH,this.onFailure,false,0,true);
               _loc3_ = data.@desc;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               CyclonePowerPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc3_,owner,data.@tit);
               return;
            }
            this.onFinished(null);
         }
      }
      
      protected function onShowDialogFromQuestManager(param1:Event) : void
      {
         this.showDialog();
      }
      
      protected function onCollected(param1:Event) : void
      {
         onCloseClick(null);
         TransactionManager.addTransaction(new TCollectCycloneCoins(owner));
         clickNextStateClientUpdateOnly();
      }
      
      override protected function onFinished(param1:Event) : void
      {
         super.onFinished(param1);
         PopupManager.instance.push(new SpeechPopup("Speech_Cyclone_Power_03",this.onSpeechPopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
      }
      
      protected function onSpeechPopupClosed(param1:Event) : void
      {
      }
      
      protected function onFailure(param1:Event) : void
      {
         PopupManager.instance.push(new SpeechPopup("Speech_Cyclone_Power_04",this.onSpeechFailurePopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
      }
      
      protected function onSpeechFailurePopupClosed(param1:Event) : void
      {
         onCloseClick(null);
         clickNextStateClientUpdateOnly();
      }
   }
}

