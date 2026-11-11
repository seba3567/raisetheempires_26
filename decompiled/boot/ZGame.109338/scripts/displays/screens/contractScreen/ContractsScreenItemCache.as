package displays.screens.contractScreen
{
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.Player;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import flash.utils.Dictionary;
   import utils.BitArray;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class ContractsScreenItemCache
   {
      
      private static var m_instance:ContractsScreenItemCache = null;
      
      private var m_cache:Dictionary = null;
      
      private var m_requiredQuests:Array = null;
      
      private const MIN_LE_VISIBLE_LEVEL:int = 7;
      
      public function ContractsScreenItemCache()
      {
         super();
         this.m_cache = new Dictionary();
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestComplete);
         UIDispatcher.instance.addEventListener(Player.CONTRACT_UNLOCKED,this.onContractUnlocked);
      }
      
      public static function get instance() : ContractsScreenItemCache
      {
         if(!m_instance)
         {
            m_instance = new ContractsScreenItemCache();
         }
         return m_instance;
      }
      
      public function itemListForEntity(param1:IEntity, param2:String, param3:String, param4:Class, param5:Boolean, param6:Function = null) : Array
      {
         var _loc9_:XMLList = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc13_:XML = null;
         var _loc14_:Object = null;
         var _loc15_:GameItem = null;
         var _loc16_:Boolean = false;
         var _loc17_:BitArray = null;
         var _loc18_:int = 0;
         var _loc19_:String = null;
         var _loc20_:Array = null;
         var _loc21_:int = 0;
         var _loc22_:String = null;
         var _loc7_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         var _loc8_:String = _loc7_.gameData.name + "." + param2 + "." + param3;
         if(!this.m_cache[_loc8_] || param6 != null)
         {
            _loc9_ = ZGlobal.gameSettings.getItemsByType(param2,param3);
            _loc10_ = new Array();
            _loc11_ = new Array();
            _loc12_ = new Array();
            this.m_requiredQuests = new Array();
            for each(_loc13_ in _loc9_)
            {
               _loc14_ = ZGlobal.gameSettings.getItemByName(_loc13_.@name,param4) as param4;
               _loc15_ = _loc14_ as GameItem;
               if(_loc13_.@setBonusItem != undefined && _loc13_.@setBonusItem == "true")
               {
                  if(_loc15_.contractLocked && !ZGlobal.player.hasPurchasedContract(_loc13_.@code))
                  {
                     continue;
                  }
               }
               if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUYABLE_CONTRACTS) != ExperimentsManager.VARIANT_BUYABLE_CONTRACTS_ENABLED)
               {
                  if(_loc15_.subType == "contract" && _loc15_.type != "seed" && _loc15_.cash > 0)
                  {
                     continue;
                  }
               }
               else if(_loc15_.subType == "contract" && _loc15_.type != "seed" && _loc15_.cash > 0 && ZGlobal.player.level < _loc15_.xml.requiredLevel[0])
               {
                  continue;
               }
               if(!(_loc15_.xml.maxLevel[0] != undefined && (ZGlobal.player.level > _loc15_.xml.maxLevel[0] || _loc15_.xml.requiredLevel[0] != undefined && ZGlobal.player.level < _loc15_.xml.requiredLevel[0])))
               {
                  if(!DominationModeManager.instance.enabled)
                  {
                     if(_loc15_.requiredDominanceRank > 0)
                     {
                        continue;
                     }
                  }
                  _loc16_ = false;
                  _loc17_ = ZGlobal.player.checkGate(GameItem(_loc14_));
                  if(!_loc17_.isBitSet(Player.GATE_FAILURE_EXPERIMENT))
                  {
                     if(_loc17_.isBitSet(Player.GATE_FAILURE_QUEST))
                     {
                        _loc16_ = true;
                        _loc19_ = GameItem(_loc14_).requiredQuests;
                        _loc20_ = _loc19_.split(",");
                        _loc21_ = 0;
                        while(_loc21_ < _loc20_.length)
                        {
                           this.m_requiredQuests.push(_loc20_[_loc21_]);
                           _loc21_++;
                        }
                     }
                     if(!(param6 != null && !param6(_loc15_)))
                     {
                        _loc18_ = ZGameTimeUtil.instance.getDateStatus(null,GameItem(_loc14_).xml);
                        if(Boolean(_loc14_ as GameItem && GameItem(_loc14_).buyable) && Boolean(!GameItem(_loc14_).uiHidden) && (!_loc16_ || _loc18_ != ZGameTimeUtil.DATE_STATUS_NONE))
                        {
                           _loc22_ = _loc14_.getStateMachineName(_loc7_.gameData.name);
                           if((Boolean(_loc22_)) && _loc22_.length > 0)
                           {
                              if(_loc18_ == ZGameTimeUtil.DATE_STATUS_NONE)
                              {
                                 if(param5 && !_loc17_.anyBitSet())
                                 {
                                    _loc10_.push(_loc14_ as param4);
                                 }
                                 else if(_loc17_.isBitSet(Player.GATE_FAILURE_DOMINANCE))
                                 {
                                    _loc12_.push(_loc14_ as param4);
                                 }
                                 else
                                 {
                                    _loc11_.push(_loc14_ as param4);
                                 }
                              }
                              else if(_loc18_ == ZGameTimeUtil.DATE_STATUS_ACTIVE && ZGlobal.player.canSeeLEContent)
                              {
                                 _loc10_.push(_loc14_ as param4);
                              }
                              else if(GameItem(_loc14_).contractLocked && ZGlobal.player.hasPurchasedContract(GameItem(_loc14_).code))
                              {
                                 _loc10_.push(_loc14_ as param4);
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc10_.sort(this.sortItems);
            _loc12_.sort(ZGameUtils.sortRequiredDominanceLevel);
            _loc12_ = _loc12_.reverse();
            this.m_cache[_loc8_] = _loc10_.concat(_loc11_).concat(_loc12_);
         }
         return this.m_cache[_loc8_];
      }
      
      protected function sortItems(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:int = ZGameUtils.sortLE(param1,param2);
         if(_loc3_ == 0)
         {
            _loc3_ = ZGameUtils.sortStrongest(param1,param2);
         }
         return _loc3_;
      }
      
      public function onQuestComplete(param1:WorldEvent) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_requiredQuests.length)
         {
            if(this.m_requiredQuests[_loc2_] == param1.eventData.name)
            {
               this.m_cache = new Dictionary();
            }
            _loc2_++;
         }
      }
      
      public function onContractUnlocked(param1:WorldEvent) : void
      {
         this.m_cache = new Dictionary();
      }
   }
}

