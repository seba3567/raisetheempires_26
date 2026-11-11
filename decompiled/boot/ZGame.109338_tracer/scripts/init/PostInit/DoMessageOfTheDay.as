package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.player.Player;
   import flash.events.Event;
   
   public class DoMessageOfTheDay extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoMessageOfTheDay";
      
      public function DoMessageOfTheDay(param1:Player)
      {
         super(INIT_ID);
         addDependency(DoStartPromoManager.INIT_ID);
         MessageOfTheDayManager.instance.setPlayer(param1);
         MessageOfTheDayManager.instance.addedToActionQueue = true;
      }
      
      override public function execute() : void
      {
         MessageOfTheDayManager.instance.addEventListener(MessageOfTheDayManager.EVENT_SHOWN_ALL_MESSAGES,this.onMOTDDone,false,0,true);
         MessageOfTheDayManager.instance.queuePopups();
      }
      
      public function onMOTDDone(param1:Event) : void
      {
         MessageOfTheDayManager.instance.removeEventListener(MessageOfTheDayManager.EVENT_SHOWN_ALL_MESSAGES,this.onMOTDDone);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

