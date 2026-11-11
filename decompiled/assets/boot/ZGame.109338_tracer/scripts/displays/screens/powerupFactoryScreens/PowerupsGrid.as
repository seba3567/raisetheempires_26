package displays.screens.powerupFactoryScreens
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.managers.ExperimentsManager;
   import core.managers.InventoryList;
   import core.player.Player;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import zlabs.resource.SWFResource;
   
   public class PowerupsGrid extends GridScreen
   {
      
      protected static var m_pageNum:int = 0;
      
      private static var m_tacNukeCode:String = "N37";
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_units:Array = new Array();
      
      protected var m_useSavedPageNum:Boolean = false;
      
      protected var m_highestTier:int;
      
      protected var m_codeIndex:Dictionary = new Dictionary();
      
      public function PowerupsGrid(param1:MovieClip, param2:SWFResource, param3:String, param4:String, param5:Boolean = true)
      {
         this.m_type = param3;
         this.m_subtype = param4;
         this.m_useSavedPageNum = param5;
         super();
         this.init(param1,param2);
      }
      
      public static function setPageNum(param1:int) : void
      {
         m_pageNum = param1;
      }
      
      private function passesTierCheck(param1:ConsumableItem) : Boolean
      {
         var _loc2_:int = param1.tier;
         if(_loc2_ == 1)
         {
            return true;
         }
         var _loc3_:Array = param1.requiredTierVariants;
         var _loc4_:String = "empire_powerup_factory_tier" + _loc2_;
         var _loc5_:int = ExperimentsManager.instance.getExperimentVariant(_loc4_);
         if(_loc3_.indexOf(_loc5_.toString()) >= 0)
         {
            return true;
         }
         return false;
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(4,1);
         this.load(param1,param2);
         if(this.m_useSavedPageNum)
         {
            goToPage(m_pageNum,false);
         }
         else
         {
            goToPage(0,false);
         }
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
         var _loc6_:Boolean = this.m_highestTier > 1 && this.m_units[param5].tier == this.m_highestTier;
         return new PowerupSlot(param1,param2,screen,param3,param4,this.m_units[param5],this.getMultFactor(),_loc6_);
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
      
      private function sortPowerups(param1:ConsumableItem, param2:ConsumableItem) : int
      {
         var _loc3_:Boolean = ZGlobal.player.checkGate(param1).isBitSet(Player.GATE_FAILURE_LEVEL);
         var _loc4_:Boolean = ZGlobal.player.checkGate(param2).isBitSet(Player.GATE_FAILURE_LEVEL);
         if(_loc3_ != _loc4_)
         {
            if(_loc4_)
            {
               return -1;
            }
            return 1;
         }
         var _loc5_:int = param1.tier;
         var _loc6_:int = param2.tier;
         if(_loc5_ > _loc6_)
         {
            return -1;
         }
         if(_loc6_ > _loc5_)
         {
            return 1;
         }
         var _loc7_:Boolean = param1.code == m_tacNukeCode;
         var _loc8_:Boolean = param2.code == m_tacNukeCode;
         if(_loc7_ && !_loc8_)
         {
            return -1;
         }
         if(!_loc7_ && _loc8_)
         {
            return 1;
         }
         var _loc9_:int = this.m_codeIndex[param1.code] ? int(this.m_codeIndex[param1.code]) : 10000;
         var _loc10_:int = this.m_codeIndex[param2.code] ? int(this.m_codeIndex[param2.code]) : 10000;
         if(_loc9_ < _loc10_)
         {
            return -1;
         }
         return 1;
      }
      
      protected function createItemList() : void
      {
         var _loc3_:String = null;
         var _loc4_:ConsumableItem = null;
         var _loc1_:Array = InventoryList.instance.itemsByEffectiveness;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,ConsumableItem) as ConsumableItem;
            if(_loc4_.type == "consumable" && ZGlobal.player.hasOverrideGateCheck(_loc4_,null))
            {
               if(this.passesTierCheck(_loc4_))
               {
                  if(_loc4_.subType == this.m_subtype)
                  {
                     this.m_units.push(_loc4_);
                     this.m_highestTier = Math.max(this.m_highestTier,_loc4_.tier);
                     this.m_codeIndex[_loc4_.code] = _loc2_;
                  }
               }
            }
            _loc2_++;
         }
         this.m_units.sort(this.sortPowerups);
      }
   }
}

