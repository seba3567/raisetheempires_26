package displays.screens.researchScreens
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.InventoryList;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.domination.DominationModeManager;
   import core.player.Player;
   import dispatchers.UIDispatcher;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import utils.BitArray;
   import utils.ZGameTimeUtil;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class ResearchUnitsGrid extends GridScreen
   {
      
      public static const EVENT_UPDATE_RESEARCH_SLOTS:String = "updateResearchGridSlots";
      
      protected static var m_pageNum:int = 0;
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_units:Array = new Array();
      
      protected var m_unitItem:UnitItem = null;
      
      protected var m_useSavedPageNum:Boolean = false;
      
      protected var m_megaUnitsOnly:Boolean = false;
      
      protected var m_cacheList:Array = null;
      
      public function ResearchUnitsGrid(param1:MovieClip, param2:SWFResource, param3:String, param4:String, param5:UnitItem, param6:Boolean = true, param7:Boolean = false)
      {
         this.m_type = param3;
         this.m_subtype = param4;
         this.m_unitItem = param5;
         this.m_useSavedPageNum = param6;
         this.m_megaUnitsOnly = param7;
         super();
         this.init(param1,param2);
      }
      
      public static function setPageNum(param1:int) : void
      {
         m_pageNum = param1;
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         setDimensions(4,1);
         this.load(param1,param2);
         if(Boolean(this.m_unitItem) && !this.m_useSavedPageNum)
         {
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc4_ < this.m_units.length)
            {
               if(this.m_units[_loc4_].code == this.m_unitItem.code)
               {
                  _loc3_ = _loc4_;
               }
               _loc4_++;
            }
            goToPage(_loc3_ / m_cardsPerPage);
         }
         else
         {
            goToPage(m_pageNum,false);
         }
         UIDispatcher.instance.addEventListener(EVENT_UPDATE_RESEARCH_SLOTS,this.onUpdateSlots,false,0,true);
      }
      
      override public function dispose() : void
      {
         UIDispatcher.instance.removeEventListener(EVENT_UPDATE_RESEARCH_SLOTS,this.onUpdateSlots);
         super.dispose();
      }
      
      override public function get numCards() : int
      {
         return this.m_units.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1.045;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new ResearchUnitSlot(param1,param2,screen,param3,param4,this.m_units[param5],this.getMultFactor(),this.m_unitItem);
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.createItemList();
         super.load(param1,param2);
         setAnchor(23,155);
         this.fillOutHeader();
      }
      
      protected function fillOutHeader() : void
      {
         screen.header_tf.text = "units";
      }
      
      protected function createItemList() : void
      {
         var _loc14_:String = null;
         var _loc15_:UnitItem = null;
         var _loc16_:String = null;
         var _loc17_:XMLList = null;
         var _loc18_:String = null;
         var _loc19_:BitArray = null;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:Object = null;
         var _loc1_:Array = new Array();
         var _loc2_:uint = 0;
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         var _loc5_:Array = new Array();
         var _loc6_:Array = new Array();
         var _loc7_:Array = new Array();
         var _loc8_:Array = new Array();
         var _loc9_:Array = new Array();
         var _loc10_:Array = new Array();
         var _loc11_:Array = InventoryList.instance.itemsByEffectiveness;
         var _loc12_:int = 0;
         for(; _loc12_ < _loc11_.length; _loc12_++)
         {
            _loc14_ = _loc11_[_loc12_];
            _loc15_ = ZGlobal.gameSettings.getItemByCode(_loc14_,UnitItem) as UnitItem;
            _loc16_ = _loc15_.researchTemplate;
            _loc17_ = WorldUpgradeManager.instance.getResearchTemplate(_loc16_);
            if(!(!_loc17_ || !_loc17_.length()))
            {
               _loc18_ = _loc15_.researchDialogBehavior;
               switch(_loc18_)
               {
                  case ResearchUnitSelectionScreen.SHOW_ONLY_IF_OWNED:
                     _loc20_ = int(ZGlobal.player.inventory[_loc15_.code]);
                     _loc21_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc15_.code);
                     if(!(_loc20_ + _loc21_))
                     {
                     }
               }
               if(ZGameTimeUtil.instance.isLimitedEdition(_loc15_.xml))
               {
                  _loc22_ = ZGameTimeUtil.instance.getDateStatus(null,_loc15_.xml);
                  if(_loc15_.contractLocked)
                  {
                     if(_loc22_ != ZGameTimeUtil.DATE_STATUS_ACTIVE && !ZGlobal.player.hasPurchasedContract(_loc15_.code))
                     {
                        continue;
                     }
                  }
                  else if(_loc22_ != ZGameTimeUtil.DATE_STATUS_ACTIVE)
                  {
                     continue;
                  }
                  if(ExperimentsManager.instance.getExperimentVariant("empire_research_le") != Player.RESEARCH_LE_ON)
                  {
                     continue;
                  }
               }
               if(_loc15_.xml.@setBonusItem != undefined && _loc15_.xml.@setBonusItem == "true")
               {
                  if(!ZGlobal.player.hasPurchasedContract(_loc15_.code))
                  {
                     continue;
                  }
               }
               if(!(!DominationModeManager.instance.enabled && Boolean(_loc15_.requiredDominanceRank)))
               {
                  _loc19_ = ZGlobal.player.checkGate(_loc15_);
                  if(_loc15_.type == this.m_type && _loc15_.subType == this.m_subtype && !_loc15_.zpoints && !_loc19_.isBitSet(Player.GATE_FAILURE_QUEST) && !_loc15_.hasType(UnitItem.MEGA_UNIT) && !this.m_megaUnitsOnly)
                  {
                     _loc1_.push(_loc15_);
                     _loc23_ = WorldUpgradeManager.instance.getNumCompletedUpgrades(_loc15_.code);
                     if(_loc23_ == WorldUpgradeManager.instance.getTotalUpgrades(_loc15_.code))
                     {
                        _loc7_.push(_loc2_);
                     }
                     else if(ZGameTimeUtil.instance.isLimitedEdition(_loc15_.xml))
                     {
                        if(_loc19_.isBitSet(Player.GATE_FAILURE_LEVEL))
                        {
                           _loc6_.push(_loc2_);
                        }
                        else if(_loc15_.contractLocked && !ZGlobal.player.hasPurchasedContract(_loc15_.code))
                        {
                           _loc4_.push(_loc2_);
                        }
                        else if(!ZGlobal.player.hasUnlockedUnit(_loc15_.code))
                        {
                           _loc3_.push(_loc2_);
                        }
                        else
                        {
                           _loc4_.push(_loc2_);
                        }
                     }
                     else if(_loc15_.requiredDominanceRank)
                     {
                        if(_loc19_.isBitSet(Player.GATE_FAILURE_DOMINANCE))
                        {
                           _loc9_.push(_loc2_);
                        }
                        else
                        {
                           _loc8_.push(_loc2_);
                        }
                     }
                     else if(_loc19_.isBitSet(Player.GATE_FAILURE_LEVEL))
                     {
                        _loc6_.push(_loc2_);
                     }
                     else if(ZGlobal.player.hasUnlockedUnit(_loc15_.code))
                     {
                        _loc5_.push(_loc2_);
                     }
                     else
                     {
                        _loc5_.push(_loc2_);
                     }
                     _loc2_++;
                  }
                  if(_loc15_.type == this.m_type && _loc15_.subType == this.m_subtype && _loc15_.hasType(UnitItem.MEGA_UNIT) && this.m_megaUnitsOnly)
                  {
                     _loc10_.push(_loc15_);
                  }
               }
            }
         }
         _loc3_.reverse();
         _loc4_.reverse();
         _loc5_.reverse();
         _loc6_.reverse();
         _loc7_.reverse();
         _loc8_.reverse();
         _loc9_.reverse();
         var _loc13_:uint = 0;
         for each(_loc13_ in _loc3_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         for each(_loc13_ in _loc4_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         for each(_loc13_ in _loc5_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         for each(_loc13_ in _loc8_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         for each(_loc13_ in _loc6_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         for each(_loc13_ in _loc9_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         for each(_loc13_ in _loc7_)
         {
            this.m_units.push(_loc1_[_loc13_]);
         }
         if(this.m_megaUnitsOnly && this.m_units.length == 0)
         {
            _loc10_.reverse();
            for each(_loc24_ in _loc10_)
            {
               this.m_units.push(_loc24_);
            }
            return;
         }
      }
      
      private function onUpdateSlots(param1:WorldEvent) : void
      {
         updateCards();
      }
      
      public function set filterRequiredUnitType(param1:String) : void
      {
         var _loc3_:UnitItem = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(!this.m_cacheList)
         {
            this.m_cacheList = this.m_units;
         }
         var _loc2_:Array = this.m_cacheList;
         this.m_units = new Array();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.hasType(param1))
            {
               this.m_units.push(_loc3_);
            }
         }
         updateCards();
         if(Boolean(this.m_unitItem) && !this.m_useSavedPageNum)
         {
            _loc4_ = 0;
            _loc5_ = 0;
            while(_loc5_ < this.m_units.length)
            {
               if(this.m_units[_loc5_].code == this.m_unitItem.code)
               {
                  _loc4_ = _loc5_;
               }
               _loc5_++;
            }
            goToPage(_loc4_ / m_cardsPerPage);
         }
      }
      
      public function findIndex(param1:Array) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for(; _loc3_ < this.m_units.length; _loc3_++)
         {
            if(this.m_units[_loc3_].code == this.m_unitItem.code)
            {
               _loc2_ = 0;
               while(_loc2_ < param1.length)
               {
                  if(this.m_units[_loc3_].hasType(param1[_loc2_]))
                  {
                     return _loc2_;
                  }
                  _loc2_++;
               }
            }
         }
         return 0;
      }
   }
}

