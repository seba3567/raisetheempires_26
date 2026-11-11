package core.managers.questManager
{
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.PriceTestManager;
   import core.managers.WorldResourceManager;
   import core.managers.tutorialManager.TutorialManager;
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class ZGameTask
   {
      
      public static const DYNAMIC_DISCOUNT_OBJECT_COST:String = "cost";
      
      public static const DYNAMIC_DISCOUNT_OBJECT_DISCOUNT:String = "discount";
      
      protected var m_xml:XML = null;
      
      protected var m_questName:String = null;
      
      protected var m_cachedOwned:int = 0;
      
      protected var m_cachedNeed:int = 0;
      
      protected var m_complete:Boolean = false;
      
      protected var m_taskIndex:int = 0;
      
      protected var m_total:int = 0;
      
      protected var m_ghost:Boolean = false;
      
      public function ZGameTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super();
         this.m_xml = param2;
         this.m_taskIndex = param1;
         this.m_questName = param3;
         this.m_total = calcTotal(param2,int(param2.@total),param4,param3);
         this.m_cachedNeed = this.total;
         this.m_complete = this.getProgress() >= this.m_cachedNeed;
         this.m_ghost = this.m_xml.@desc.toString().length == 0;
      }
      
      public static function applyDiscountText(param1:DisplayObjectContainer, param2:int, param3:String = "discount_tf") : void
      {
         var _loc4_:TextField = null;
         _loc4_ = param1.getChildByName(param3) as TextField;
         if(_loc4_ != null)
         {
            if(param2 <= 0)
            {
               _loc4_.visible = false;
               TextFieldUtil.processTextField(_loc4_,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":0}));
            }
            else
            {
               _loc4_.visible = true;
               TextFieldUtil.processTextField(_loc4_,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":param2}));
            }
         }
      }
      
      public static function Create(param1:int, param2:XML, param3:String, param4:Number) : ZGameTask
      {
         var _loc5_:ZGameTask = null;
         if(param2.@action == "fight")
         {
            _loc5_ = new FightItemTask(param1,param2,param3,param4);
         }
         else if(param2.@action == "survivalFight")
         {
            _loc5_ = new SurvivalFightTask(param1,param2,param3,param4);
         }
         else if(param2.@action == "fullscreen")
         {
            _loc5_ = new FullScreenTask(param1,param2,param3,param4);
         }
         else if(param2.@action == "openDialog")
         {
            _loc5_ = new OpenDialogTask(param1,param2,param3,param4);
         }
         else if(param2.@action == "select")
         {
            _loc5_ = new SelectItemTask(param1,param2,param3,param4);
         }
         else if(param2.@action == "zoom")
         {
            _loc5_ = new ZoomTask(param1,param2,param3,param4);
         }
         else
         {
            _loc5_ = new ZGameTask(param1,param2,param3,param4);
         }
         if(!_loc5_.complete)
         {
            _loc5_.setActive(true);
         }
         return _loc5_;
      }
      
      public static function calcTotal(param1:XML, param2:int, param3:Number = 0, param4:String = null) : int
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:String = null;
         var _loc12_:Array = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Object = null;
         var _loc16_:String = null;
         var _loc17_:Array = null;
         var _loc18_:int = 0;
         var _loc19_:Array = null;
         var _loc20_:int = 0;
         var _loc21_:Array = null;
         var _loc5_:int = param2;
         param2 = 0;
         if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_asn_task_difficulty","2") && param1.hasOwnProperty("asnTotalModifier"))
         {
            _loc7_ = 0;
            _loc8_ = 100000;
            _loc9_ = false;
            _loc10_ = false;
            if(param1.asnTotalModifier.@min != undefined)
            {
               _loc7_ = int(param1.asnTotalModifier.@min);
               _loc9_ = true;
            }
            if(param1.asnTotalModifier.@max != undefined)
            {
               _loc8_ = int(param1.asnTotalModifier.@max);
               _loc10_ = true;
            }
            if(!(_loc9_ && _loc10_ && _loc7_ > _loc8_))
            {
               if(!(_loc10_ && _loc8_ < 0))
               {
                  if(Boolean(param1.asnTotalModifier.hasOwnProperty("experiment")) && Boolean(param1.asnTotalModifier.experiment.@id != undefined) && param1.asnTotalModifier.experiment.@values != undefined)
                  {
                     if(ExperimentsManager.instance.getExperimentVariant(param1.asnTotalModifier.experiment.@id) != 0)
                     {
                        _loc11_ = param1.asnTotalModifier.experiment.@values;
                        _loc12_ = _loc11_.split(",");
                        _loc13_ = ExperimentsManager.instance.getExperimentValue(param1.asnTotalModifier.experiment.@id,_loc12_,0);
                        _loc14_ = ZGlobal.player.asn;
                        _loc15_ = ZGlobal.player.questInitAsn;
                        if(param4 != null && _loc15_ != null && _loc15_[param4] != undefined)
                        {
                           _loc14_ = Number(ZGlobal.player.questInitAsn[param4]);
                        }
                        param2 = Math.floor(_loc14_ * _loc13_) as int;
                        if(_loc9_ && param2 < _loc7_)
                        {
                           param2 = _loc7_;
                        }
                        if(_loc10_ && param2 > _loc8_)
                        {
                           param2 = _loc8_;
                        }
                     }
                  }
               }
            }
         }
         if(param2 < 1)
         {
            param2 = _loc5_;
         }
         if(Boolean(param1.experiment) && param1.experiment != undefined)
         {
            _loc16_ = param1.experiment.@values;
            _loc17_ = _loc16_.split(",");
            _loc18_ = ExperimentsManager.instance.getExperimentValue(param1.experiment.@id,_loc17_,0);
            param2 += _loc18_;
         }
         var _loc6_:int = param2;
         if(param3 <= 0)
         {
            param3 = ZGlobal.player.level;
         }
         if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_difficulty","2") && param1.hasOwnProperty("totalModifier"))
         {
            _loc19_ = getTotalModifiers(param1);
            if(_loc19_.length > 0)
            {
               _loc20_ = 0;
               while(_loc20_ < _loc19_.length)
               {
                  if(!(Boolean(_loc19_[_loc20_].hasOwnProperty("experiment")) && Boolean(_loc19_[_loc20_].experiment != null) && !ExperimentsManager.instance.experimentGateEnabled(_loc19_[_loc20_].experiment,_loc19_[_loc20_].variant)))
                  {
                     if(param3 >= _loc19_[_loc20_].minLevel && param3 <= _loc19_[_loc20_].maxLevel)
                     {
                        param2 += _loc19_[_loc20_].amount;
                        break;
                     }
                  }
                  _loc20_++;
               }
            }
         }
         if(param1.hasOwnProperty("difficultyMode"))
         {
            if(param1.difficultyMode.hasOwnProperty("@experiment") && ExperimentsManager.instance.experimentGateEnabled(param1.difficultyMode.@experiment,param1.difficultyMode.@variant))
            {
               param2 = _loc5_;
               param3 = ZGlobal.player.level;
               _loc21_ = getDifficultyModifiers(param1,param4);
               if(_loc21_.length > 0)
               {
                  _loc20_ = 0;
                  while(_loc20_ < _loc21_.length)
                  {
                     if(param3 >= _loc21_[_loc20_].minLevel && param3 <= _loc21_[_loc20_].maxLevel)
                     {
                        param2 += _loc21_[_loc20_].amount;
                        break;
                     }
                     _loc20_++;
                  }
               }
            }
         }
         if(param2 <= 0)
         {
            param2 = _loc6_;
         }
         return param2;
      }
      
      public static function getTotalModifiers(param1:XML) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:Object = null;
         var _loc2_:Array = [];
         if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_difficulty","2") && param1.hasOwnProperty("totalModifier"))
         {
            _loc3_ = 0;
            while(_loc3_ < param1.totalModifier.length())
            {
               _loc4_ = param1.totalModifier[_loc3_];
               _loc5_ = new Object();
               if(_loc4_.@minLevel != undefined && _loc4_.@maxLevel != undefined && _loc4_.@amount != undefined)
               {
                  _loc5_.minLevel = int(_loc4_.@minLevel);
                  _loc5_.maxLevel = int(_loc4_.@maxLevel);
                  _loc5_.amount = int(_loc4_.@amount);
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
      
      public static function getDifficultyModifiers(param1:XML, param2:String) : Array
      {
         var _loc5_:String = null;
         var _loc6_:XMLList = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc3_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param2);
         var _loc4_:Array = [];
         if(Boolean(ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(_loc3_)) && Boolean(ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(_loc3_)["difficultyMode"]))
         {
            _loc5_ = ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(_loc3_)["difficultyMode"];
         }
         if(_loc5_ != null)
         {
            _loc6_ = param1.difficultyMode[_loc5_];
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length())
            {
               _loc8_ = new Object();
               if(_loc6_[_loc7_].@minLevel != undefined && _loc6_[_loc7_].@maxLevel != undefined && _loc6_[_loc7_].@amount != undefined)
               {
                  _loc8_.minLevel = int(_loc6_[_loc7_].@minLevel);
                  _loc8_.maxLevel = int(_loc6_[_loc7_].@maxLevel);
                  _loc8_.amount = int(_loc6_[_loc7_].@amount);
                  _loc4_.push(_loc8_);
               }
               _loc7_++;
            }
         }
         return _loc4_;
      }
      
      public static function getCostModifiers(param1:XML) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:Object = null;
         var _loc2_:Array = [];
         if(param1.cost.hasOwnProperty("costModifier"))
         {
            _loc3_ = 0;
            while(_loc3_ < param1.cost.costModifier.length())
            {
               _loc4_ = param1.cost.costModifier[_loc3_];
               _loc5_ = new Object();
               if(_loc4_.@minLevel != undefined && _loc4_.@maxLevel != undefined && _loc4_.@amount != undefined)
               {
                  _loc5_.minLevel = int(_loc4_.@minLevel);
                  _loc5_.maxLevel = int(_loc4_.@maxLevel);
                  _loc5_.amount = int(_loc4_.@amount);
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
      
      public function get total() : int
      {
         return this.m_total;
      }
      
      public function set total(param1:int) : void
      {
         this.m_total = param1;
      }
      
      public function get buyable() : Boolean
      {
         return this.buyAmountCash > 0;
      }
      
      public function get buyAmountCash() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:ZGameQuest = null;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         if(null != this.m_xml.cost)
         {
            _loc1_ = int(this.m_xml.cost.@amount);
            _loc2_ = ZGlobal.player.level;
            if(this.m_xml.cost.hasOwnProperty("costModifier"))
            {
               _loc1_ = int(this.m_xml.cost.@amount);
               _loc4_ = getCostModifiers(this.m_xml);
               if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_cost","2"))
               {
                  if(_loc4_.length > 0)
                  {
                     _loc3_ = 0;
                     while(_loc3_ < _loc4_.length)
                     {
                        if(!(Boolean(_loc4_[_loc3_].hasOwnProperty("experiment")) && Boolean(_loc4_[_loc3_].experiment != null) && !ExperimentsManager.instance.experimentGateEnabled(_loc4_[_loc3_].experiment,_loc4_[_loc3_].variant)))
                        {
                           if(_loc2_ >= _loc4_[_loc3_].minLevel && _loc2_ <= _loc4_[_loc3_].maxLevel)
                           {
                              _loc1_ += _loc4_[_loc3_].amount;
                              break;
                           }
                        }
                        _loc3_++;
                     }
                  }
               }
               else if(_loc4_.length > 0)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc4_.length)
                  {
                     if(Boolean(_loc4_[_loc3_].hasOwnProperty("experiment")) && Boolean(_loc4_[_loc3_].experiment != null) && ExperimentsManager.instance.experimentGateEnabled(_loc4_[_loc3_].experiment,_loc4_[_loc3_].variant))
                     {
                        _loc1_ = int(this.m_xml.cost.@amount);
                        if(_loc2_ >= _loc4_[_loc3_].minLevel && _loc2_ <= _loc4_[_loc3_].maxLevel)
                        {
                           _loc1_ += _loc4_[_loc3_].amount;
                           break;
                        }
                     }
                     _loc3_++;
                  }
               }
            }
            if(_loc1_ > 0)
            {
               if(Boolean(this.m_xml.cost.experiment) && this.m_xml.cost.experiment != undefined)
               {
                  _loc7_ = this.m_xml.cost.experiment.@values;
                  _loc8_ = _loc7_.split(",");
                  _loc9_ = ExperimentsManager.instance.getExperimentValue(this.m_xml.cost.experiment.@id,_loc8_,1);
                  _loc1_ = Math.ceil(_loc1_ * _loc9_);
               }
               _loc5_ = QuestSettingsInit.getInstance().getItemByName(this.m_questName) as ZGameQuest;
               _loc6_ = 1;
               if(Boolean(_loc5_) && !_loc5_.isLimitedEdition())
               {
                  _loc6_ = PriceTestManager.instance.costMultiplierByType("questpurchase");
               }
               _loc1_ = Math.ceil(_loc1_ * _loc6_);
            }
            return Math.max(0,_loc1_);
         }
         return 0;
      }
      
      public function get requestable() : Boolean
      {
         return this.requestButtonAction != null;
      }
      
      public function get requestButtonAction() : String
      {
         if(this.m_xml.@requestButton != undefined)
         {
            return this.m_xml.@requestButton.toString();
         }
         return null;
      }
      
      public function get requestButtonText() : String
      {
         if(this.m_xml.@requestButton != undefined)
         {
            if(this.m_xml.@requestButtonText != undefined)
            {
               return this.m_xml.@requestButtonText.toString();
            }
         }
         return null;
      }
      
      public function get feedData() : Object
      {
         if(Boolean(this.m_xml.feed) && this.m_xml.feed != undefined)
         {
            return {
               "code":this.m_xml.feed.@code,
               "name":this.m_xml.feed.@name,
               "button":this.m_xml.feed.@button,
               "type":this.m_xml.feed.@type
            };
         }
         return null;
      }
      
      public function get battleData() : Object
      {
         if(Boolean(this.m_xml.fight) && this.m_xml.fight != undefined)
         {
            return {"button":this.m_xml.fight.@button};
         }
         return null;
      }
      
      public function get survivalBattleData() : Object
      {
         if(Boolean(this.m_xml.survivalFight) && this.m_xml.survivalFight != undefined)
         {
            return {"button":this.m_xml.survivalFight.@button};
         }
         return null;
      }
      
      public function get itemBuyable() : Boolean
      {
         return Boolean(this.item) && this.m_xml.@itemBuyable != undefined;
      }
      
      public function get item() : String
      {
         if(Boolean(this.m_xml.@item) && this.m_xml.@item.toString().length > 0)
         {
            return this.m_xml.@item.toString();
         }
         return null;
      }
      
      public function get itemToken() : String
      {
         if(Boolean(this.m_xml.@itemTk) && this.m_xml.@itemTk.toString().length > 0)
         {
            return this.m_xml.@itemTk.toString();
         }
         return null;
      }
      
      public function get invite() : Object
      {
         if(Boolean(this.m_xml.@action == "neighborsAdded") && Boolean(this.m_xml.invite) && this.m_xml.invite != undefined)
         {
            return {"button":this.m_xml.invite.@button};
         }
         return null;
      }
      
      public function get spendButton() : Object
      {
         if(this.m_xml.@action == "spend")
         {
            return {
               "button":this.m_xml.@button,
               "tooltip":this.m_xml.@buttonTooltip,
               "type":this.m_xml.@type
            };
         }
         return null;
      }
      
      public function get taskPan() : String
      {
         if(this.m_xml.@panButton != undefined)
         {
            return this.m_xml.@panButton;
         }
         return null;
      }
      
      public function get panButtonText() : String
      {
         if(this.m_xml.@panButtonText != undefined)
         {
            return this.m_xml.@panButtonText;
         }
         return null;
      }
      
      public function get taskBuild() : String
      {
         if(this.m_xml.@buildButton != undefined)
         {
            return this.m_xml.@buildButton;
         }
         return null;
      }
      
      public function get buildButtonText() : String
      {
         if(this.m_xml.@buildButtonText != undefined)
         {
            return this.m_xml.@buildButtonText;
         }
         return null;
      }
      
      public function get showPartsGather() : String
      {
         if(this.m_xml.@showpartsgather != undefined)
         {
            return this.m_xml.@showpartsgather.toString();
         }
         return null;
      }
      
      public function get showPartsGatherText() : String
      {
         if(this.m_xml.@showpartsgathertext != undefined)
         {
            return this.m_xml.@showpartsgathertext.toString();
         }
         return null;
      }
      
      public function get fleetName() : String
      {
         if(this.m_xml.@fleetname != undefined)
         {
            return this.m_xml.@fleetname.toString();
         }
         return this.questName;
      }
      
      public function get questName() : String
      {
         return this.m_questName;
      }
      
      public function get complete() : Boolean
      {
         return this.m_complete;
      }
      
      public function get ghost() : Boolean
      {
         return this.m_ghost;
      }
      
      public function get mainText() : String
      {
         return this.getText();
      }
      
      public function get villain() : String
      {
         return this.m_xml.@villain.toString().length ? this.m_xml.@villain.toString() : null;
      }
      
      public function get fleetname() : String
      {
         return this.m_xml.@fleetname.toString().length ? this.m_xml.@fleetname.toString() : null;
      }
      
      public function get pveVillain() : String
      {
         return this.m_xml.@pveVillain.toString().length ? this.m_xml.@pveVillain.toString() : null;
      }
      
      public function get icon() : String
      {
         var _loc2_:int = 0;
         var _loc1_:String = this.m_xml.@icon.toString();
         if(_loc1_.indexOf("rare") >= 0)
         {
            _loc2_ = WorldResourceManager.instance.rareResourceIndex(_loc1_);
            _loc1_ = WorldResourceManager.instance.getResourceImageURL(_loc2_,WorldResourceManager.LARGE_ICON);
         }
         return _loc1_;
      }
      
      public function get iconType() : String
      {
         return this.m_xml.@iconType.toString().length ? this.m_xml.@iconType.toString() : null;
      }
      
      public function get counterType() : String
      {
         return this.m_xml.@counterType.toString() ? this.m_xml.@counterType.toString() : null;
      }
      
      public function get hint() : String
      {
         var _loc1_:String = this.m_xml.@hint.toString();
         if(_loc1_.length > 0)
         {
            return ZGameUtils.ZlocTP(_loc1_.split(":")[0],_loc1_.split(":")[1]);
         }
         _loc1_ = this.m_xml.@desc.toString();
         if(_loc1_.length > 0)
         {
            if(_loc1_.split(":")[1] == "quest_7120_task_01")
            {
               return ZGameUtils.ZlocTP(_loc1_.split(":")[0],"quest_7120_hint");
            }
            return ZGameUtils.ZlocTP(_loc1_.split(":")[0],_loc1_.split(":")[1] + "_hint");
         }
         return null;
      }
      
      public function get progressText() : String
      {
         return this.getprogressText();
      }
      
      public function get fleetComposition() : Array
      {
         return null;
      }
      
      public function get hasCombatSetup() : Boolean
      {
         return false;
      }
      
      public function get combatSetup() : Object
      {
         return null;
      }
      
      public function get combatAllies() : Array
      {
         return null;
      }
      
      public function start() : void
      {
      }
      
      public function get remainingItemAmount() : int
      {
         if(this.item)
         {
            return Math.max(0,this.total - this.getProgress());
         }
         return 0;
      }
      
      public function get remainingItemCash() : int
      {
         var _loc1_:int = 0;
         var _loc2_:GameItem = null;
         if(this.item)
         {
            _loc1_ = this.remainingItemAmount;
            if(_loc1_ > 0)
            {
               _loc2_ = GameItem(ZGlobal.gameSettings.getItemByCode(this.item,GameItem));
               if(_loc2_)
               {
                  return _loc1_ * _loc2_.cash;
               }
            }
         }
         return 0;
      }
      
      public function get removeItemOnComplete() : Boolean
      {
         if(this.m_xml.@removeItemOnComplete != undefined && this.m_xml.@removeItemOnComplete == "true")
         {
            return true;
         }
         return false;
      }
      
      protected function gameItemMatches(param1:GameItem, param2:String) : Boolean
      {
         var _loc3_:String = this.m_xml.@subtype.toString();
         if(_loc3_.length > 0)
         {
            return this.itemMatches(param1.subType,_loc3_);
         }
         return this.itemMatches(param1.code,param2);
      }
      
      protected function itemMatches(param1:String, param2:String) : Boolean
      {
         var _loc3_:Array = param2.split(",");
         if(_loc3_.indexOf(param1) >= 0)
         {
            return true;
         }
         return false;
      }
      
      protected function getResourceName(param1:String) : String
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:String = param1;
         var _loc3_:int = _loc2_.indexOf("rare");
         if(_loc3_ >= 0)
         {
            _loc4_ = "rare";
            _loc5_ = ZGlobal.player.rareResourceType;
            if(_loc3_ > 0 && _loc2_.charAt(_loc3_ - 1) == "n")
            {
               _loc4_ = _loc2_.substr(_loc3_ - 1,6);
               _loc5_ = WorldResourceManager.instance.rareResourceIndex(_loc4_);
            }
            _loc6_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc5_);
            _loc2_ = _loc2_.replace(_loc4_,_loc6_);
         }
         return _loc2_;
      }
      
      protected function getText() : String
      {
         var _loc2_:Object = null;
         var _loc1_:String = this.m_xml.@desc.toString();
         if(_loc1_.length > 0)
         {
            if(_loc1_ == "Megaseries:QTMS09_06_task_03")
            {
               _loc2_ = this.getTextParams();
               _loc2_.total = 5;
               return ZGameUtils.ZlocTP("Quests",_loc1_,_loc2_);
            }
            return ZGameUtils.ZlocTP("Quests",_loc1_,this.getTextParams());
         }
         return null;
      }
      
      protected function getProgress() : int
      {
         var _loc1_:Object = QuestManager.getInstance().getQuestProgressByName(this.m_questName);
         if(_loc1_)
         {
            if(this.m_taskIndex < _loc1_.progress.length)
            {
               return _loc1_.progress[this.m_taskIndex];
            }
         }
         return 0;
      }
      
      protected function getprogressText() : String
      {
         var _loc1_:int = 0;
         var _loc2_:GameItem = null;
         var _loc3_:String = null;
         if(this.m_cachedNeed > 0)
         {
            _loc1_ = this.getProgress();
            if(this.counterType == "item")
            {
               if(this.item != null && this.item.length > 0)
               {
                  _loc2_ = GameItem(ZGlobal.gameSettings.getItemByCode(this.item,GameItem));
               }
               _loc1_ = ZGlobal.player.inventory[_loc2_.code] ? int(ZGlobal.player.inventory[_loc2_.code]) : 0;
            }
            else if(this.counterType == "resource" && Boolean(this.spendButton))
            {
               _loc3_ = WorldResourceManager.instance.resourceFromRareResource(this.spendButton.type);
               if(_loc3_)
               {
                  _loc1_ = int(ZGlobal.player.resources.resourceAmounts[_loc3_]);
               }
            }
            _loc1_ = Math.min(_loc1_,this.m_cachedNeed);
            return "(" + _loc1_ + "/" + this.m_cachedNeed + ")";
         }
         return "";
      }
      
      protected function getTextParams() : Object
      {
         var _loc3_:String = null;
         var _loc1_:Object = ZGameUtils.buildLocalizedParams();
         _loc1_.total = this.total;
         _loc1_.itemTk = ZGameUtils.ZlocTk("Items",this.itemToken,"",this.total);
         var _loc2_:Object = ZGameUtils.callFunctionFromXml(this.m_xml.@textReplacements);
         for(_loc3_ in _loc2_)
         {
            _loc1_[_loc3_] = _loc2_[_loc3_];
         }
         return _loc1_;
      }
      
      private function unlockTutorial() : void
      {
         var _loc1_:String = this.m_xml.@unlockTutorial.toString();
         if(_loc1_.length > 0)
         {
            TutorialManager.instance.tutorial = _loc1_;
         }
      }
      
      protected function onSetActive(param1:Boolean) : void
      {
      }
      
      private function setActive(param1:Boolean) : void
      {
         this.onSetActive(param1);
      }
      
      public function buyCompletion() : void
      {
      }
      
      public function setComplete() : void
      {
         if(!this.m_complete)
         {
            this.m_complete = true;
            this.setActive(false);
            this.unlockTutorial();
            if(!this.ghost)
            {
               QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.TASK_COMPLETE,this.m_questName));
               ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_QUEST_TASK_COMPLETE,{
                  "quest":this.m_questName,
                  "task":this.m_xml.attribute("desc")
               }));
            }
         }
      }
      
      public function getDynamicSkipCost() : Object
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc1_:Object = {};
         var _loc2_:int = this.buyAmountCash;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DYNAMIC_QUEST_TASK_PRICING);
         if(_loc3_ == ExperimentsManager.VARIANT_VALUE_DYNAMIC_QUEST_TASK_PRICING_ENABLED)
         {
            _loc4_ = this.getProgress();
            _loc4_ = Math.min(_loc4_,this.m_cachedNeed);
            if(this.m_cachedNeed > 0)
            {
               _loc5_ = _loc4_ / this.m_cachedNeed;
               _loc6_ = Math.ceil(_loc2_ - _loc5_ * _loc2_);
               _loc1_[DYNAMIC_DISCOUNT_OBJECT_COST] = _loc6_;
               _loc1_[DYNAMIC_DISCOUNT_OBJECT_DISCOUNT] = int((1 - _loc6_ / _loc2_) * 100);
            }
         }
         else
         {
            _loc1_[DYNAMIC_DISCOUNT_OBJECT_COST] = _loc2_;
            _loc1_[DYNAMIC_DISCOUNT_OBJECT_DISCOUNT] = 0;
         }
         return _loc1_;
      }
   }
}

