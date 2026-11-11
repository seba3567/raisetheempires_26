package core.gamemode.mission
{
   import core.ZGlobal;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.ui.PickManager;
   import core.ui.menuitem.OptionUIItem;
   import dispatchers.UIDispatcher;
   import flash.events.MouseEvent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class GMDeployMission extends GMIsland
   {
      
      private var m_strikeTeam:GameItem = null;
      
      private var m_strikeTeamPanel:StrikeTeamDeployPanel = null;
      
      public function GMDeployMission(param1:String)
      {
         super();
         this.m_strikeTeam = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
      }
      
      override public function enableMode() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(DeployMissionStencil.ADD_DEPLOY_STENCIL,{"disableChildren":false}));
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.MISSION_DEPLOY_MODE,{
            "active":true,
            "strikeTeam":this.m_strikeTeam.code
         }));
         this.m_strikeTeamPanel = new StrikeTeamDeployPanel();
         this.m_strikeTeamPanel.addPanel(this.m_strikeTeam);
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onDeployed,false,0,true);
         PickManager.selectPicks = true;
         super.enableMode();
      }
      
      override protected function getCursor() : Object
      {
         return null;
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         return false;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.MISSION_DEPLOY_MODE_CLICK,{"mouseEvent":param1}));
      }
      
      public function onDeployed(param1:WorldEvent) : void
      {
         exitMode();
      }
      
      override public function disableMode() : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(DeployMissionStencil.REMOVE_DEPLOY_STENCIL));
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.MISSION_DEPLOY_MODE,{"active":false}));
         this.m_strikeTeamPanel.removePanel();
         this.m_strikeTeamPanel = null;
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
         PVPManager.instance.removeEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onDeployed);
         PickManager.selectPicks = false;
         super.disableMode();
      }
   }
}

