package init
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.gamemode.mission.DeployMissionStencil;
   import core.gamemode.prebattle.PreBattleUI;
   import core.managers.tutorialManager.TutorialStencil;
   import core.ui.CursorManager;
   import core.ui.UIManager;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.NarratorUIItem;
   import core.ui.menuitem.OptionUIItem;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.ui.menuitem.PromoMenuItemContainer;
   import core.ui.menuitem.QuestsUIItem;
   import core.ui.menuitem.SettingsUIItem;
   import core.ui.menuitem.VisitorEnergyUIItem;
   import flash.events.Event;
   import utils.ZGameConfig;
   import zlabs.ZGameBase;
   import zlabs.displays.popups.PopupAniConfig;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class UIInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "UIInit";
      
      public function UIInit()
      {
         super(INIT_ID);
         addDependency(GlobalsInit.INIT_ID);
         addDependency(LocalizationInit.INIT_ID);
         addDependency(FontMapperInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         this.localizePlayerData();
         ZGameConfig.ANIMATION_SIDE_TWIST = new PopupAniConfig(-55,-44,-29,0,0,500);
         CursorManager.initialize();
         UIManager.instance.registerComponent(new SettingsUIItem());
         UIManager.instance.registerComponent(new ContextualBarUIItem());
         UIManager.instance.registerComponent(new PreBattleUI());
         UIManager.instance.registerComponent(new PromoMenuItemContainer());
         UIManager.instance.registerComponent(new OptionUIItem());
         UIManager.instance.registerComponent(new QuestsUIItem());
         UIManager.instance.registerComponent(new VisitorEnergyUIItem());
         UIManager.instance.registerComponent(new PlayerStatsUIItem());
         UIManager.instance.registerComponent(new TutorialStencil());
         UIManager.instance.registerComponent(new DeployMissionStencil());
         UIManager.instance.registerComponent(new NarratorUIItem());
         ZGameBase.layerUI.addChild(UIManager.instance.uiDisplay);
         CursorManager.subscribe(UIManager.instance.uiDisplay);
         CursorManager.subscribe(WindowManager.instance.container);
         CursorManager.subscribe(PopupManager.instance.container);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function localizePlayerData() : void
      {
         if(ZGlobal.player.deferredLoc)
         {
            ZGlobal.player.localizeDeferredData();
         }
      }
   }
}

