package core.ui.menuitem.battleListMenu
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.domination.DominationModeManager;
   import core.ui.menuitem.OptionUIItem;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import zlabs.resource.SWFResource;
   
   public class BattleListMenuGrid extends GridScreen
   {
      
      private static const NUM_CARDS_IN_GRID:int = 6;
      
      private var m_dominationInfo:Object = {
         "buttonTextKey":"BattleButtonTextDomination",
         "enabled":DominationModeManager.instance.enabled,
         "iconName":ZGlobal.gameSettings.getString("DominationBattleListIcon"),
         "battleType":OptionUIItem.BATTLETYPE_DOMINATION,
         "highlightNew":true
      };
      
      private var m_bbInfo:Object = {
         "buttonTextKey":"BattleButtonTextBBlitz",
         "enabled":PVPManager.instance.canShowGlobalPVPBar(true),
         "iconName":ZGlobal.gameSettings.getString("GlobalPVPBattleListIcon"),
         "battleType":OptionUIItem.BATTLETYPE_BBLITZ,
         "highlightNew":false
      };
      
      private var m_bbReturnInfo:Object = {
         "buttonTextKey":"BattleButtonTextBBlitzOff",
         "enabled":true,
         "iconName":ZGlobal.gameSettings.getString("GlobalPVPBattleListIcon"),
         "battleType":OptionUIItem.BATTLETYPE_BBLITZ,
         "highlightNew":false
      };
      
      private var m_deathMatchInfo:Object = {
         "buttonTextKey":"BattleButtonTextDeathMatch",
         "enabled":true,
         "iconName":ZGlobal.gameSettings.getString("DeathMatchBattleListIcon"),
         "battleType":OptionUIItem.BATTLETYPE_DEATHMATCH,
         "highlightNew":true
      };
      
      private var m_slotInfo:Array = [];
      
      public function BattleListMenuGrid(param1:MovieClip)
      {
         if(PVPManager.instance.canHideGlobalPVPBar())
         {
            this.m_slotInfo.push(this.m_bbReturnInfo);
         }
         else
         {
            this.m_slotInfo.push(this.m_bbInfo);
         }
         this.m_slotInfo.push(this.m_dominationInfo);
         if(DeathMatchManager.instance.isExperimentEnabled)
         {
            this.m_slotInfo.push(this.m_deathMatchInfo);
         }
         super();
         m_isVerticalGrid = true;
         setAnchor(param1.anchor_mc.x,param1.anchor_mc.y);
         setDimensions(1,NUM_CARDS_IN_GRID);
         load(param1,null);
      }
      
      override public function get numCards() : int
      {
         return this.m_slotInfo.length;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new BattleListMenuGridSlot(param2,param3,param4,this.m_slotInfo[param5]);
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function setupArrows() : void
      {
      }
      
      override protected function disposeArrows() : void
      {
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(Boolean(m_screen.arrowLt_bt) && Boolean(m_screen.arrowLt_bt))
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
               super.fixArrows(param1);
            }
         }
      }
   }
}

