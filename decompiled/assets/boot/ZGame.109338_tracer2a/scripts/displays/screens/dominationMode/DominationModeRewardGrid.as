package displays.screens.dominationMode
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.domination.DominationModeManager;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import zlabs.resource.SWFResource;
   
   public class DominationModeRewardGrid extends GridScreen
   {
      
      private static const NUM_CARDS_IN_GRID:int = 5;
      
      private var m_rewards:Array = null;
      
      private var m_firstLockedIndex:int = -1;
      
      public function DominationModeRewardGrid(param1:MovieClip, param2:SWFResource)
      {
         super();
         m_isVerticalGrid = false;
         setAnchor(param1.anchor_mc.x,param1.anchor_mc.y);
         setDimensions(NUM_CARDS_IN_GRID,1);
         m_resource = param2;
         this.m_rewards = this.getDominationRewards();
         load(param1,param2);
         this.postInit();
      }
      
      private function postInit() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < m_cards.length)
         {
            if(!m_cards[_loc1_].strengthBarVisible)
            {
               break;
            }
            _loc1_++;
         }
         slide(-_loc1_ + NUM_CARDS_IN_GRID / 2);
      }
      
      override protected function setupArrows() : void
      {
         m_buttonSounds.addButton(m_screen.arrowRtSingle_bt,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.arrowLtSingle_bt,ButtonSound.DEFAULT);
         m_screen.arrowRtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleRightClick,false,0,true);
         m_screen.arrowLtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleLeftClick,false,0,true);
         super.setupArrows();
      }
      
      override protected function disposeArrows() : void
      {
         m_screen.arrowRtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleRightClick);
         m_screen.arrowLtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleLeftClick);
         super.disposeArrows();
      }
      
      override public function get numCards() : int
      {
         return this.m_rewards.length;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         if(this.m_rewards[param5] != null)
         {
            return new DominationModeRewardGridSlot(m_resource,param2,param3,param4,this.m_rewards[param5],param5 == this.m_firstLockedIndex);
         }
         return null;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(this.numCards <= numCardsPerPage)
         {
            m_screen.arrowLt_bt.visible = false;
            m_screen.arrowRt_bt.visible = false;
         }
         else
         {
            m_screen.arrowLt_bt.visible = true;
            m_screen.arrowRt_bt.visible = true;
         }
      }
      
      private function getDominationRewards() : Array
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc5_:UnitItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:XMLList = ZGlobal.gameSettings.getItems();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_["requiredDominanceRank"] != undefined && _loc3_["requiredDominanceRank"] > 0)
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc3_.@code,UnitItem) as UnitItem;
               _loc1_.push(_loc5_);
            }
         }
         _loc1_.sort(this.sortUnits);
         _loc4_ = 0;
         while(_loc4_ < _loc1_.length)
         {
            if(_loc1_[_loc4_].xml["requiredDominanceRank"] > DominationModeManager.instance.dominanceRank)
            {
               this.m_firstLockedIndex = _loc4_;
               break;
            }
            _loc4_++;
         }
         return _loc1_;
      }
      
      private function sortUnits(param1:UnitItem, param2:UnitItem) : int
      {
         if(param1.requiredDominanceRank > param2.requiredDominanceRank)
         {
            return 1;
         }
         return -1;
      }
      
      private function onSingleRightClick(param1:MouseEvent) : void
      {
         slide(-1);
      }
      
      private function onSingleLeftClick(param1:MouseEvent) : void
      {
         slide(1);
      }
   }
}

