package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.NuclearPowerManager;
   import core.managers.questManager.ZGameQuestManager;
   import dispatchers.UIDispatcher;
   import displays.popups.SpeechPopup;
   import displays.screens.partsGather.NuclearPowerPartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Timer;
   import transactions.TCollectNuclearCoins;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class NuclearPowerDialogState extends BuildingPartsDialogState
   {
      
      public static const QUEST_NAME:String = "QNP";
      
      protected var m_timer:Timer;
      
      public function NuclearPowerDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         UIDispatcher.instance.addEventListener(ZGameQuestManager.QUESTS_PARTSGATHER,this.onShowDialogFromQuestManager,false,0,true);
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
               stateMachine.propertyBag.eventDispatcher.addEventListener(NuclearPowerPartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(NuclearPowerPartsGather.COLLECTED,this.onCollected,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(NuclearPowerPartsGather.FAILURE_SPEECH,this.onFailure,false,0,true);
               _loc3_ = data.@desc;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               NuclearPowerPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc3_,owner,data.@tit);
               return;
            }
            this.onFinished(null);
         }
      }
      
      protected function onShowDialogFromQuestManager(param1:WorldEvent) : void
      {
         if(param1.eventData.code == NuclearPowerManager.BUILDING_CODE)
         {
            this.showDialog();
         }
      }
      
      protected function onCollected(param1:Event) : void
      {
         onCloseClick(null);
         TransactionManager.addTransaction(new TCollectNuclearCoins(owner));
         clickNextStateClientUpdateOnly();
      }
      
      override protected function onFinished(param1:Event) : void
      {
         super.onFinished(param1);
         PopupManager.instance.push(new SpeechPopup("Speech_Nuclear_Power_03",this.onSpeechPopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
      }
      
      protected function onSpeechPopupClosed(param1:Event) : void
      {
      }
      
      protected function onFailure(param1:Event) : void
      {
         PopupManager.instance.push(new SpeechPopup("Speech_Nuclear_Power_04",this.onSpeechFailurePopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
      }
      
      protected function onSpeechFailurePopupClosed(param1:Event) : void
      {
         onCloseClick(null);
         clickNextStateClientUpdateOnly();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         UIDispatcher.instance.removeEventListener(ZGameQuestManager.QUESTS_PARTSGATHER,this.onShowDialogFromQuestManager);
      }
   }
}

