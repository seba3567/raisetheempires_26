package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.QuestBuildableManager;
   import core.managers.questManager.ZGameQuestManager;
   import displays.popups.GoldenStatuePopUp1;
   import displays.popups.GoldenStatuePopUp2;
   import displays.popups.GoldenStatuePopUp3;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GoldenStatueDialogState extends DialogState
   {
      
      public static const SHOWUI:String = "showui";
      
      public function GoldenStatueDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         QuestBuildableManager.instance.addEventListener(SHOWUI,this.reShowDialog,false,0,true);
      }
      
      protected function reShowDialog(param1:Event) : void
      {
         this.showDialog();
      }
      
      override protected function showDialog() : void
      {
         onCloseClick(null);
         if(ZGlobal.isHome())
         {
            stateMachine.propertyBag.eventDispatcher.addEventListener(GoldenStatuePopUp3.COMPLETE,this.onComplete,false,0,true);
            if(ZGlobal.player.didCompleteQuest(GoldenStatuePopUp2.QUEST_ID))
            {
               GoldenStatuePopUp3.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher));
            }
            else if(ZGlobal.player.didCompleteQuest(GoldenStatuePopUp1.QUEST_ID))
            {
               if(ZGameQuestManager.instance.getQuestProgressByName(GoldenStatuePopUp2.QUEST_ID) != null)
               {
                  GoldenStatuePopUp2.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher));
               }
            }
            else
            {
               QuestBuildableManager.instance.dispatchEvent(new Event(QuestBuildableManager.REMOVE_SITE));
               if(ZGameQuestManager.instance.getQuestProgressByName(GoldenStatuePopUp1.QUEST_ID) != null)
               {
                  GoldenStatuePopUp1.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher));
               }
            }
         }
      }
      
      protected function onComplete(param1:Event) : void
      {
         onCloseClick(null);
         clickNextState();
      }
   }
}

