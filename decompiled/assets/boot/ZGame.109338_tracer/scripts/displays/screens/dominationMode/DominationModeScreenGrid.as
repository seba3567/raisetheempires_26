package displays.screens.dominationMode
{
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class DominationModeScreenGrid extends GridScreen
   {
      
      private static const NUM_CARDS_IN_GRID:int = 4;
      
      private var m_numCards:int = 10;
      
      private var m_dominationData:Array = null;
      
      private var m_isRival:Boolean = false;
      
      private var m_activeEnemyID:String = null;
      
      private var m_foundActive:Boolean = false;
      
      private var m_motdActive:Boolean = false;
      
      private var m_rivalListLength:int = 0;
      
      private var m_isAlliance:Boolean = false;
      
      private var m_activeAllianceEnemy:String = null;
      
      public function DominationModeScreenGrid(param1:MovieClip, param2:SWFResource, param3:Array, param4:Boolean, param5:Number = 0, param6:Number = 0, param7:int = 0, param8:Boolean = false)
      {
         super();
         m_isVerticalGrid = true;
         setAnchor(param1.anchor_mc.x,param1.anchor_mc.y);
         m_slotAnchorPosition = param5;
         m_clickPosition = param6;
         setDimensions(1,NUM_CARDS_IN_GRID);
         m_resource = param2;
         this.m_isRival = param4;
         this.m_rivalListLength = param7;
         this.m_isAlliance = param8;
         this.m_dominationData = param3;
         this.setActiveEnemy();
         this.setActiveAllianceEnemy();
         load(param1,param2);
      }
      
      override public function dispose() : void
      {
         this.cleanupMOTDFlow();
         super.dispose();
      }
      
      private function setActiveEnemy() : void
      {
         this.m_activeEnemyID = null;
         var _loc1_:Fleet = ZGlobal.player.fleets.getFleetByName(DominationModeManager.FLEET_DOMINATION_ENEMY_NAME);
         if(_loc1_)
         {
            this.m_activeEnemyID = _loc1_.uid;
            this.m_foundActive = false;
         }
         else
         {
            this.m_foundActive = true;
         }
      }
      
      private function setActiveAllianceEnemy() : void
      {
         this.m_activeAllianceEnemy = AlliancesManager.instance.allianceBattleInProgress();
         if(DominationModeManager.instance.getAllianceInfo(this.m_activeAllianceEnemy) == null)
         {
            this.m_activeAllianceEnemy = null;
         }
      }
      
      override protected function setupArrows() : void
      {
         m_buttonSounds.addButton(m_screen.down_mc,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.up_mc,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.pageDown_mc,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.pageUp_mc,ButtonSound.DEFAULT);
         m_screen.down_mc.addEventListener(MouseEvent.CLICK,this.onDownClick,false,0,true);
         m_screen.up_mc.addEventListener(MouseEvent.CLICK,this.onUpClick,false,0,true);
         m_screen.pageDown_mc.addEventListener(MouseEvent.CLICK,this.onPageDownClick,false,0,true);
         m_screen.pageUp_mc.addEventListener(MouseEvent.CLICK,this.onPageUpClick,false,0,true);
      }
      
      override protected function disposeArrows() : void
      {
         m_screen.down_mc.removeEventListener(MouseEvent.CLICK,this.onDownClick);
         m_screen.up_mc.removeEventListener(MouseEvent.CLICK,this.onUpClick);
         m_screen.pageDown_mc.removeEventListener(MouseEvent.CLICK,this.onPageDownClick);
         m_screen.pageUp_mc.removeEventListener(MouseEvent.CLICK,this.onPageUpClick);
      }
      
      override public function get numCards() : int
      {
         return this.m_dominationData ? int(this.m_dominationData.length) : 0;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:DominationModeScreenGridSlot = null;
         var _loc7_:AllianceModeScreenGridSlot = null;
         if(this.m_dominationData[param5] != null)
         {
            if(this.m_isRival && param5 >= this.m_rivalListLength || this.m_isAlliance)
            {
               _loc7_ = new AllianceModeScreenGridSlot(m_resource,param2,param3,param4,this.m_dominationData[param5],param5,!this.m_isAlliance);
               if(this.m_activeAllianceEnemy)
               {
                  if(this.m_activeAllianceEnemy != _loc7_.allianceID && AlliancesManager.instance.clanId != _loc7_.allianceID)
                  {
                     _loc7_.disable_visual();
                  }
               }
               return _loc7_;
            }
            _loc6_ = new DominationModeScreenGridSlot(m_resource,param2,param3,param4,this.m_dominationData[param5],param5,this.m_isRival,this.m_activeEnemyID);
            if(this.m_activeEnemyID != null)
            {
               if(_loc6_.getEnemyID() != this.m_activeEnemyID)
               {
                  _loc6_.disable_visual();
               }
               else
               {
                  this.m_foundActive = true;
               }
            }
            return _loc6_;
         }
         return null;
      }
      
      public function activeEnemyNotFound() : Boolean
      {
         return !this.m_foundActive;
      }
      
      public function activateFirstCard() : void
      {
         if(m_cards[0])
         {
            m_cards[0].enable();
         }
      }
      
      public function beginMOTDFlow() : void
      {
         if(Boolean(m_cards[0]) && Boolean(m_cards[0].getAttackButton()) && !this.m_motdActive)
         {
            this.m_motdActive = true;
            TutorialManager.instance.registerUIItem(m_cards[0].getAttackButton(),TutorialManager.DOMINATION_FIRST_FIGHT);
            TutorialManager.instance.sendEvent(TutorialManager.UI_DOMINATION_FIRST_FIGHT,true);
         }
      }
      
      private function cleanupMOTDFlow() : void
      {
         if(this.m_motdActive)
         {
            TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
            TutorialManager.instance.sendEvent(TutorialManager.UI_DISABLE);
            TutorialManager.instance.sendEvent(TutorialManager.UI_ENABLE);
            this.m_motdActive = false;
         }
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(this.numCards <= numCardsPerPage)
         {
            m_screen.down_mc.visible = false;
            m_screen.up_mc.visible = false;
            m_screen.pageDown_mc.visible = false;
            m_screen.pageUp_mc.visible = false;
         }
         else
         {
            m_screen.down_mc.visible = true;
            m_screen.up_mc.visible = true;
            m_screen.pageDown_mc.visible = true;
            m_screen.pageUp_mc.visible = true;
         }
         var _loc2_:Boolean = !clickPosition;
         var _loc3_:Boolean = clickPosition <= -(m_cards.length - numCardsPerPage);
         this.enableTopButtons(!_loc2_);
         this.enableBottomButtons(!_loc3_);
      }
      
      private function enableTopButtons(param1:Boolean) : void
      {
         ZGameUtils.setButtonEnabled(m_screen.up_mc,this.onUpClick,param1);
         ZGameUtils.setButtonEnabled(m_screen.pageUp_mc,this.onPageUpClick,param1);
      }
      
      private function enableBottomButtons(param1:Boolean) : void
      {
         ZGameUtils.setButtonEnabled(m_screen.down_mc,this.onDownClick,param1);
         ZGameUtils.setButtonEnabled(m_screen.pageDown_mc,this.onPageDownClick,param1);
      }
      
      protected function onDownClick(param1:MouseEvent) : void
      {
         slide(-1);
      }
      
      protected function onUpClick(param1:MouseEvent) : void
      {
         slide(1);
      }
      
      protected function onPageDownClick(param1:MouseEvent) : void
      {
         slide(-m_cardsPerPage);
      }
      
      protected function onPageUpClick(param1:MouseEvent) : void
      {
         slide(m_cardsPerPage);
      }
      
      override public function hide() : void
      {
         super.hide();
         m_screen.visible = false;
      }
      
      override public function show() : void
      {
         super.show();
         m_screen.visible = true;
      }
      
      public function get anyActiveEnemies() : Boolean
      {
         var _loc1_:Object = null;
         for each(_loc1_ in m_cards)
         {
            if(!(_loc1_ is AllianceModeScreenGridSlot))
            {
               _loc1_ = DominationModeScreenGridSlot(_loc1_);
               if(_loc1_.active)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get slotAnchorPositionPublic() : Number
      {
         return m_slotAnchorPosition;
      }
      
      public function get clickPositionPublic() : Number
      {
         return m_clickPosition;
      }
   }
}

