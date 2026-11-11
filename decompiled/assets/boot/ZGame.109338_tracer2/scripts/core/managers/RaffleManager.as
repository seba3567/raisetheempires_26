package core.managers
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.entities.components.UIControllerComponent;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class RaffleManager extends EventDispatcher
   {
      
      public static const START_CLICK:String = "start_click";
      
      public static const NEW_TICKET:String = "new_ticket";
      
      public static const RE_DRAW:String = "re_draw";
      
      public static const ROLL:String = "roll";
      
      public static const RAFFLE_CENTER_NAME:String = "Raffle Center";
      
      public static const ROLL_COMPLETE:String = "roll_complete";
      
      public static var globalCurrentPrizeNumber:int = 0;
      
      private static var m_instance:RaffleManager = null;
      
      private var m_Xml:XML = null;
      
      public var itemCodes:Array = null;
      
      public var rewards:Array = null;
      
      public var buyableTicketCost:int = 0;
      
      public function RaffleManager(param1:IEventDispatcher = null)
      {
         var _loc2_:int = 0;
         super(param1);
         this.m_Xml = ZGlobal.gameSettings.getRaffleXml();
         this.itemCodes = new Array();
         _loc2_ = 0;
         while(_loc2_ <= this.m_Xml.@collectDuration)
         {
            this.itemCodes.push(this.m_Xml.items.item[_loc2_].@code.toString());
            _loc2_++;
         }
         this.buyableTicketCost = int(this.m_Xml.items.item[_loc2_ - 1].@cost);
         this.rewards = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.m_Xml.rewards.reward.length())
         {
            this.rewards.push({
               "text":this.m_Xml.rewards.reward[_loc3_].@text,
               "code":this.m_Xml.rewards.reward[_loc3_].@code,
               "giftCode":this.m_Xml.rewards.reward[_loc3_].@giftCode,
               "itemCode":this.m_Xml.rewards.reward[_loc3_].@itemCode,
               "count":this.m_Xml.rewards.reward[_loc3_].@total,
               "pBase":this.m_Xml.rewards.reward[_loc3_].@probabilityBase,
               "pExtra":this.m_Xml.rewards.reward[_loc3_].@probabilityExtra,
               "icon":this.m_Xml.rewards.reward[_loc3_].@icon
            });
            _loc3_++;
         }
         this.addEventListener(RE_DRAW,this.onTicketAdded);
      }
      
      public static function get instance() : RaffleManager
      {
         if(!m_instance)
         {
            m_instance = new RaffleManager();
         }
         return m_instance;
      }
      
      public function onStart() : void
      {
         var _loc2_:AutoActionPanToEntity = null;
         var _loc3_:AutoActionShowSpeechPopup = null;
         var _loc1_:IEntity = this.getBuildingByCode(this.m_Xml.@centerCode);
         if(!_loc1_)
         {
            return;
         }
         _loc3_ = new AutoActionShowSpeechPopup();
         _loc3_.data = {"speechId":this.m_Xml.@initPanSpeechID};
         _loc2_ = new AutoActionPanToEntity();
         _loc2_.data = {"target":_loc1_};
         _loc2_.setNextAction(_loc3_);
         _loc2_.nextActionTimeDelay = 3000;
         _loc2_.startAction();
         StatsManager.count("dialog","Raffle","speech_bubble");
      }
      
      public function addReward(param1:int) : void
      {
         ZGlobal.player.addToInventory(this.m_Xml.rewards.reward[param1].@code,1,true);
      }
      
      public function onTicketAdded(param1:Event) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.raffle = true;
         this.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_TOOLTIP_UPDATE,_loc2_));
      }
      
      public function get day() : int
      {
         var _loc1_:Object = {"stringNotUsed":true};
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.m_Xml);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return int(this.m_Xml.@collectDuration) - int(_loc1_.delta / 86400) + 2;
         }
         return -3;
      }
      
      public function get codePrefix() : String
      {
         return this.m_Xml.items[0].@codePrefix;
      }
      
      public function get questCodePrefix() : String
      {
         return this.m_Xml.@questCodePrefix;
      }
      
      public function get maxCollectable() : int
      {
         return parseInt(this.m_Xml.@maxCollectable);
      }
      
      public function get buildingCode() : String
      {
         return this.m_Xml.@centerCode;
      }
      
      public function get collectDuration() : int
      {
         return int(this.m_Xml.@collectDuration);
      }
      
      public function get ticketRangeStart() : int
      {
         return int(this.m_Xml.@ticketRangeStart);
      }
      
      public function get ticketRangeEnd() : int
      {
         return int(this.m_Xml.@ticketRangeEnd);
      }
      
      public function get startDate() : String
      {
         return this.m_Xml.requiredDate.@start;
      }
      
      public function get collectDateRange() : XML
      {
         return this.m_Xml.collectDate[0];
      }
      
      public function get rollDateRange() : XML
      {
         return this.m_Xml.rollDate[0];
      }
      
      public function getbuyableCount(param1:int) : int
      {
         return int(this.m_Xml["@buyableCount" + param1.toString()]);
      }
      
      public function get rewardCount() : int
      {
         return this.rewards.length;
      }
      
      public function get remainingCollectTime() : int
      {
         var _loc1_:Object = {"stringNotUsed":true};
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.collectDateRange);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return _loc1_.delta;
         }
         return 0;
      }
      
      public function getBuildingByCode(param1:String) : IEntity
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:GameDataComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:IEntity = null;
         if(_loc2_)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc6_)) && _loc6_.gameData.code == param1)
               {
                  _loc3_ = _loc6_.owner;
                  break;
               }
            }
         }
         return _loc3_;
      }
   }
}

