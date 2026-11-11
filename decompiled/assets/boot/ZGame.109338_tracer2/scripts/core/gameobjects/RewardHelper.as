package core.gameobjects
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import utils.ZGameUtils;
   
   public class RewardHelper
   {
      
      private var m_type:String = null;
      
      private var m_code:String = null;
      
      private var m_count:int = 0;
      
      private var m_multiplier:Number = 1;
      
      private var m_multiplierMinimum:uint = 0;
      
      private var m_buyable:Boolean = false;
      
      public function RewardHelper(param1:XML)
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         super();
         if(null != param1)
         {
            _loc2_ = false;
            if(param1.@buyable != undefined && param1.@buyable == true)
            {
               _loc2_ = true;
            }
            _loc3_ = ZGlobal.player.level;
            if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_rewards","2") && param1.hasOwnProperty("rewardModifier"))
            {
               _loc4_ = getRewardModifiers(param1);
               if(_loc4_.length > 0)
               {
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length)
                  {
                     if(!(Boolean(_loc4_[_loc5_].hasOwnProperty("experiment")) && Boolean(_loc4_[_loc5_].experiment != null) && !ExperimentsManager.instance.experimentGateEnabled(_loc4_[_loc5_].experiment,_loc4_[_loc5_].variant)))
                     {
                        if(_loc3_ >= _loc4_[_loc5_].minLevel && _loc3_ <= _loc4_[_loc5_].maxLevel)
                        {
                           if(param1.hasOwnProperty("difficultyMode"))
                           {
                              if(param1.difficultyMode.hasOwnProperty("@experiment") && param1.difficultyMode.hasOwnProperty("@variant") && ExperimentsManager.instance.experimentGateEnabled(param1.difficultyMode.@experiment,param1.difficultyMode.@variant))
                              {
                                 if(param1.difficultyMode.hasOwnProperty("@id"))
                                 {
                                    if(Boolean(ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(param1.difficultyMode.@id)) && Boolean(ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(param1.difficultyMode.@id)["difficultyMode"]))
                                    {
                                       _loc6_ = ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(param1.difficultyMode.@id)["difficultyMode"];
                                       this.init(_loc4_[_loc5_].type,parseInt(param1.difficultyMode[_loc6_].@count),_loc4_[_loc5_].item,_loc4_[_loc5_].buyable);
                                       return;
                                    }
                                 }
                              }
                           }
                           this.init(_loc4_[_loc5_].type,parseInt(_loc4_[_loc5_].count),_loc4_[_loc5_].item,_loc4_[_loc5_].buyable);
                           return;
                        }
                     }
                     _loc5_++;
                  }
               }
            }
            this.init(param1.@type,parseInt(param1.@count),param1.@item,_loc2_);
         }
      }
      
      public static function getRewardModifiers(param1:XML) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:Object = null;
         var _loc2_:Array = [];
         if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_rewards","2") && param1.hasOwnProperty("rewardModifier"))
         {
            _loc3_ = 0;
            while(_loc3_ < param1.rewardModifier.length())
            {
               _loc4_ = param1.rewardModifier[_loc3_];
               _loc5_ = new Object();
               if(_loc4_.@minLevel != undefined && _loc4_.@maxLevel != undefined && _loc4_.@type != undefined)
               {
                  _loc5_.minLevel = int(_loc4_.@minLevel);
                  _loc5_.maxLevel = int(_loc4_.@maxLevel);
                  _loc5_.type = _loc4_.@type;
                  _loc5_.count = _loc4_.@count;
                  _loc5_.item = _loc4_.@item;
                  if(_loc4_.@buyable != undefined && _loc4_.@buyable == true)
                  {
                     _loc5_.buyable = true;
                  }
                  else
                  {
                     _loc5_.buyable = false;
                  }
                  if(_loc4_.@experiment != undefined && _loc4_.@experiment.toString() != "")
                  {
                     _loc5_.experiment = _loc4_.@experiment.toString();
                     _loc5_.variant = _loc4_.@variant.toString();
                  }
                  _loc2_.push(_loc5_);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function modifiedReward() : String
      {
         return this.m_code;
      }
      
      public function modifiedRewardCount() : int
      {
         return this.m_count;
      }
      
      public function set multiplier(param1:Number) : void
      {
         this.m_multiplier = param1;
      }
      
      public function set multiplierMinimum(param1:uint) : void
      {
         this.m_multiplierMinimum = param1;
      }
      
      public function init(param1:String, param2:int, param3:String, param4:Boolean = false) : void
      {
         this.m_type = param1;
         this.m_count = param2;
         this.m_code = param3;
         this.m_buyable = param4;
      }
      
      public function get isItem() : Boolean
      {
         return this.m_type == "item";
      }
      
      private function getMultipliedCount() : int
      {
         return Math.ceil(this.m_count > this.m_multiplierMinimum ? Math.max(this.m_multiplier * this.m_count,this.m_multiplierMinimum) : this.m_multiplier * this.m_count);
      }
      
      public function execute() : void
      {
         var _loc1_:int = 0;
         var _loc2_:GameItem = null;
         if(this.m_multiplier != 1)
         {
            this.m_count = this.getMultipliedCount();
         }
         if(this.m_type == "socialXpGood")
         {
            ZGlobal.player.socialXpGood += this.m_count;
         }
         else if(this.m_type == "socialXpBad")
         {
            ZGlobal.player.socialXpBad += this.m_count;
         }
         else if(this.m_type == "xp")
         {
            ZGlobal.player.xp += this.m_count;
         }
         else if(this.m_type == "cash")
         {
            ZGlobal.player.cash += this.m_count;
         }
         else if(this.isItem)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_count)
            {
               ZGlobal.player.addToInventory(this.m_code);
               _loc1_++;
            }
         }
         else if(this.m_type == "island")
         {
            this.unlockIsland(this.m_code.toString());
         }
         else if(this.m_type == "unlockContract")
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(this.m_code,GameItem) as GameItem;
            ZGlobal.player.unlockContract(_loc2_,true);
         }
         else
         {
            this.m_type = WorldResourceManager.instance.getResourceTypeFromIndex(this.getResourceIndex(this.m_type));
            ZGlobal.player.resources.updateResourceAmount(this.m_type,this.m_count);
         }
      }
      
      private function addSocialXpUI(param1:Object, param2:String, param3:String) : void
      {
         if(param1.rewardPairs)
         {
            param1.rewardPairs.push({
               "reward":param2,
               "count":this.m_count
            });
         }
         if(param1.rewardText)
         {
            param1.rewardText.push(ZGameUtils.ZlocT("Main","GenericItemAmount",{
               "amount":this.m_count,
               "item":param2
            }));
         }
         if(param1.rewardIcons)
         {
            param1.rewardIcons.push(param3);
         }
      }
      
      public function buildUI(param1:Object, param2:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:GameItem = null;
         var _loc10_:Object = null;
         var _loc11_:UnitItem = null;
         var _loc12_:String = null;
         var _loc13_:LocalizationObjectToken = null;
         var _loc14_:int = 0;
         if(this.m_multiplier != 1)
         {
            this.m_count = this.getMultipliedCount();
         }
         if(this.m_type == "socialXpGood")
         {
            _loc3_ = ZGameUtils.ZlocT("Main","SocialXpGood");
            _loc4_ = ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/RedHeart_01_60.png");
            this.addSocialXpUI(param1,_loc3_,_loc4_);
         }
         else if(this.m_type == "socialXpBad")
         {
            _loc5_ = ZGameUtils.ZlocT("Main","SocialXpBad");
            _loc6_ = ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BlackHeart_01_60.png");
            this.addSocialXpUI(param1,_loc5_,_loc6_);
         }
         else if(this.m_type == "xp")
         {
            _loc7_ = ZGameUtils.ZlocT("Main","XP");
            if(null != param1.rewardPairs)
            {
               param1.rewardPairs.push({
                  "reward":_loc7_,
                  "count":this.m_count
               });
            }
            if(null != param1.rewardText)
            {
               param1.rewardText.push(ZGameUtils.ZlocT("Main","GenericItemAmount",{
                  "amount":this.m_count,
                  "item":_loc7_
               }));
            }
            if(null != param1.rewardIcons)
            {
               if(param2 == WorldResourceManager.XTRA_LARGE_ICON)
               {
                  param1.rewardIcons.push(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/Star_96.png"));
               }
               else
               {
                  param1.rewardIcons.push(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Star_60.png"));
               }
            }
         }
         else if(this.m_type == "cash")
         {
            _loc8_ = ZGameUtils.ZlocT("Main","Cash");
            if(null != param1.rewardPairs)
            {
               param1.rewardPairs.push({
                  "reward":_loc8_,
                  "count":this.m_count
               });
            }
            if(null != param1.rewardText)
            {
               param1.rewardText.push(ZGameUtils.ZlocT("Main","GenericItemAmount",{
                  "amount":this.m_count,
                  "item":_loc8_
               }));
            }
            if(null != param1.rewardIcons)
            {
               if(param2 == WorldResourceManager.XTRA_LARGE_ICON)
               {
                  param1.rewardIcons.push(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_90.png"));
               }
               else
               {
                  param1.rewardIcons.push(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_60.png"));
               }
            }
         }
         else if(this.m_type == "item" || this.m_type == "unlockContract")
         {
            _loc9_ = ZGlobal.gameSettings.getItemByCode(this.m_code,GameItem) as GameItem;
            if(null != param1.rewardPairs)
            {
               _loc10_ = {
                  "reward":_loc9_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME),
                  "count":this.m_count
               };
               if(_loc9_.isUnit())
               {
                  _loc11_ = ZGlobal.gameSettings.getItemByCode(this.m_code,UnitItem) as UnitItem;
                  _loc10_["strength"] = _loc11_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc11_.code));
               }
               param1.rewardPairs.push(_loc10_);
            }
            if(null != param1.rewardText)
            {
               _loc12_ = this.m_count == 1 ? "singular" : "plural";
               _loc13_ = _loc9_.getSentenceNameLocalizationObject(_loc12_);
               if(_loc13_)
               {
                  if(_loc9_.localizeAmount)
                  {
                     param1.rewardText.push(_loc13_.getString());
                  }
                  else
                  {
                     param1.rewardText.push(ZGameUtils.ZlocT("Main","GenericItemAmount_Object",{
                        "amount":this.m_count,
                        "item":_loc13_
                     }));
                  }
               }
               else
               {
                  param1.rewardText.push(ZGameUtils.ZlocT("Main","GenericItemAmount",{
                     "amount":this.m_count,
                     "item":_loc9_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
                  }));
               }
            }
            if(null != param1.rewardIcons)
            {
               param1.rewardIcons.push(ZGlobal.gameSettings.getImageByName(_loc9_.name,"icon"));
            }
            if(null != param1.rewardBuyable)
            {
               param1.rewardBuyable.push(this.m_buyable);
            }
            if(null != param1.rewardItems)
            {
               param1.rewardItems.push(this.m_code);
            }
         }
         else
         {
            _loc14_ = this.getResourceIndex(this.m_type);
            if(null != param1.rewardPairs)
            {
               param1.rewardPairs.push({
                  "reward":WorldResourceManager.instance.getResourceFriendlyNameFromIndex(_loc14_,GameItem.SENTENCE_FRIENDLYNAME,this.m_count > 1),
                  "count":this.m_count
               });
            }
            if(null != param1.rewardText)
            {
               param1.rewardText.push(this.m_count.toString() + " " + WorldResourceManager.instance.getResourceFriendlyNameFromIndex(_loc14_,GameItem.SENTENCE_FRIENDLYNAME,this.m_count > 1));
            }
            if(null != param1.rewardIcons)
            {
               this.m_type = WorldResourceManager.instance.getResourceTypeFromIndex(_loc14_);
               param1.rewardIcons.push(WorldResourceManager.instance.getResourceImageURLByType(this.m_type,param2));
            }
         }
      }
      
      private function getResourceIndex(param1:String) : int
      {
         var _loc2_:int = 0;
         if(param1.indexOf("rare") >= 0)
         {
            return WorldResourceManager.instance.rareResourceIndex(param1);
         }
         return WorldResourceManager.instance.getResourceIndexFromType(param1);
      }
      
      private function unlockIsland(param1:String) : void
      {
         var _loc2_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         _loc2_.setUnlocked(param1,true);
      }
   }
}

