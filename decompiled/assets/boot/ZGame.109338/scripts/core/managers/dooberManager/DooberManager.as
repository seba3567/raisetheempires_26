package core.managers.dooberManager
{
   import core.ZGlobal;
   import utils.CriteriaUtil;
   
   public class DooberManager
   {
      
      public static var instance:DooberManager = new DooberManager();
      
      public static const COMBAT_ACTION_TYPE:String = "combat";
      
      public static const HOME_ISLAND_ACTION_TYPE:String = "harvest";
      
      public static const VISITOR_ACTION_TYPE:String = "tend";
      
      public static const MYSTERY_DOOBER_ITEM:String = "MG13";
      
      public static const ITEM_SCRAP:String = "scrap";
      
      public var m_mysteryDooberResults:Object = null;
      
      public function DooberManager()
      {
         super();
      }
      
      public function getRandomRewards(param1:Number, param2:String, param3:String, param4:Number = 1) : Array
      {
         var _loc7_:XML = null;
         var _loc8_:XMLList = null;
         var _loc5_:Array = new Array();
         var _loc6_:XMLList = ZGlobal.gameSettings.getXML().randomDoobers.doober;
         for each(_loc7_ in _loc6_)
         {
            _loc8_ = this.getRelevantGameAction(_loc7_,param2,param3);
            if(this.shouldGiveReward(param1,_loc8_,param4))
            {
               if(CriteriaUtil.meetsCriteria(_loc7_.criteria))
               {
                  _loc5_.push({
                     "item":_loc7_.@item.toString(),
                     "count":parseInt(_loc8_.@count)
                  });
               }
            }
         }
         return _loc5_;
      }
      
      public function getHarvestActionType() : String
      {
         return ZGlobal.isVisiting() ? VISITOR_ACTION_TYPE : HOME_ISLAND_ACTION_TYPE;
      }
      
      private function getRelevantGameAction(param1:XML, param2:String, param3:String) : XMLList
      {
         var gameAction:XMLList = null;
         var subAction:XMLList = null;
         var dooberInfo:XML = param1;
         var actionType:String = param2;
         var subActionType:String = param3;
         gameAction = dooberInfo.dropInfo.gameAction.(@type == actionType);
         if(gameAction)
         {
            subAction = gameAction.subAction.(@type == subActionType);
            if(Boolean(subAction) && subAction.length() >= 1)
            {
               return gameAction;
            }
         }
         return null;
      }
      
      private function shouldGiveReward(param1:Number, param2:XMLList, param3:Number) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         if(param2)
         {
            _loc4_ = Number(param2.@percent);
            _loc4_ = _loc4_ * param3;
            _loc5_ = int(param2.@count);
            if(param1 < _loc4_)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setMysteryDooberResult(param1:String, param2:Object) : void
      {
         this.m_mysteryDooberResults = new Object();
         this.m_mysteryDooberResults = param2;
      }
      
      public function get mysteryDooberResult() : Object
      {
         return this.m_mysteryDooberResults;
      }
      
      public function get isMysterDooberResultsSet() : Boolean
      {
         if(this.m_mysteryDooberResults)
         {
            return true;
         }
         return false;
      }
   }
}

