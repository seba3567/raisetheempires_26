package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import displays.popups.WorldGamesPopUp;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import transactions.TExchangeWorldGamesRewards;
   import transactions.TGiftBuilding;
   
   public class WorldGamesDialogState extends DialogState
   {
      
      public static var reward_golden_horten_bomber:String = "UB90";
      
      public static var reward_golden_bull_tank:String = "UN13";
      
      public static var reward_golden_varun_submarine:String = "UT94";
      
      public function WorldGamesDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            stateMachine.propertyBag.eventDispatcher.addEventListener(WorldGamesPopUp.EXCHANGEBOMBER,this.onExchangeBomber,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(WorldGamesPopUp.EXCHANGETANK,this.onExchangeTank,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(WorldGamesPopUp.EXCHANGESUBMARINE,this.onExchangeSubmarine,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(WorldGamesPopUp.GIFTBUILDING,this.onGiftBuilding,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(WorldGamesPopUp.DUMMYTXN,this.onDummyTransaction,false,0,true);
            _loc2_ = data.@desc;
            WorldGamesPopUp.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.code,_loc2_,owner,data.@tit);
            return;
         }
      }
      
      protected function onExchangeBomber(param1:Event) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.code = reward_golden_horten_bomber;
         TransactionManager.addTransaction(new TExchangeWorldGamesRewards(owner,_loc2_));
      }
      
      protected function onExchangeTank(param1:Event) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.code = reward_golden_bull_tank;
         TransactionManager.addTransaction(new TExchangeWorldGamesRewards(owner,_loc2_));
      }
      
      protected function onExchangeSubmarine(param1:Event) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.code = reward_golden_varun_submarine;
         TransactionManager.addTransaction(new TExchangeWorldGamesRewards(owner,_loc2_));
      }
      
      protected function onGiftBuilding(param1:Event) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.code = "WGS2";
         TransactionManager.addTransaction(new TGiftBuilding(owner,_loc2_));
         onCloseClick(null);
         clickNextStateClientUpdateOnly();
      }
      
      protected function onDummyTransaction(param1:Event) : void
      {
         TransactionManager.addTransaction(new TGiftBuilding(owner));
      }
   }
}

