package displays.screens
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.contractScreen.ContractsScreen;
   import displays.screens.contractScreen.UnitContractGrid;
   import entity.GameDataComponent;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class UnitContractsEnhancementScreen extends ContractsScreen
   {
      
      private var isExperimentEnabled:Boolean;
      
      public function UnitContractsEnhancementScreen(param1:IEntity, param2:String, param3:String)
      {
         this.checkExperiment();
         super(param1,param2,param3,this.getURL());
      }
      
      private function checkExperiment() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_ENHANCEMENTS) == ExperimentsManager.VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED)
         {
            this.isExperimentEnabled = true;
         }
         else
         {
            this.isExperimentEnabled = false;
         }
      }
      
      private function getURL() : String
      {
         var _loc1_:String = null;
         if(this.isExperimentEnabled)
         {
            _loc1_ = "assets/displays/screens/PU_UnitsContractSurvival.swf";
         }
         else
         {
            _loc1_ = "assets/displays/screens/PU_UnitsContract.swf";
         }
         return _loc1_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:ImageLoader = null;
         var _loc3_:GameDataComponent = null;
         super.onLoadComplete(param1);
         this.hideManaUI();
         this.createGrid();
         if(this.isExperimentEnabled)
         {
            if(ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh") > 2)
            {
               _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(SurvivalModeManager.instance.questIconName),m_window.icon);
            }
            else
            {
               _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/SurvivorMode_60.png"),m_window.icon);
            }
            _loc2_.smooth = true;
            TextFieldUtil.processTextField(m_window.survival_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeToasterButton"));
            m_window.survival_bt.buttonMode = true;
            m_window.survival_bt.mouseChildren = false;
            m_window.survival_bt.addEventListener(MouseEvent.CLICK,this.onSurvivalClicked,false,0,true);
            _loc3_ = GameDataComponent(m_entity.lookupComponentByType(GameDataComponent));
            TextFieldUtil.compactTextField(m_window.subtitle_tf,_loc3_.gameData.getSubtitle1());
         }
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CONTRACT_SCREEN_LOADED));
         }
      }
      
      private function onSurvivalClicked(param1:MouseEvent = null) : void
      {
         this.onCloseClicked();
         SurvivalModeManager.instance.launchSurvivalMode(SurvivalModeManager.ENTRY_POINT_BUILDING);
      }
      
      private function hideManaUI() : void
      {
         m_window.elementZ_mc.visible = false;
         m_window.elementZ_mc.glowAnim_mc.gotoAndStop(1);
      }
      
      protected function createGrid() : void
      {
         m_grid = new UnitContractGrid(m_window.grid_mc,m_resource,this,m_entity,m_type,m_subType);
      }
      
      override protected function onCloseClicked(param1:MouseEvent = null) : void
      {
         if(this.isExperimentEnabled)
         {
            m_window.survival_bt.removeEventListener(MouseEvent.CLICK,this.onSurvivalClicked);
         }
         super.onCloseClicked();
      }
   }
}

