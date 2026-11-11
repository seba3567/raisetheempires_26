package displays.screens.questTreeScreen
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleQuest;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import core.managers.worldEventManager.BaseWorldEvent;
   import core.managers.worldEventManager.WorldEventManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.MOTDCountdownClock;
   import flash.geom.Point;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class MiniSeries008QuestTreeScreen extends DailyRevealScreen
   {
      
      public function MiniSeries008QuestTreeScreen(param1:String)
      {
         super(param1);
      }
      
      override protected function initializeUI() : void
      {
         var _loc2_:ImageLoader = null;
         contentWidth = 578;
         contentHeight = 587;
         root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth * 0.5,stage.stageHeight * 0.5);
         var _loc1_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_questTree.mainReward,UnitItem) as UnitItem;
         m_loader = ImageLoaderFactory.CreateImageLoader(_loc1_.getCachedImage("icon").url,screen.reward_mc.rewardIcon);
         m_loader.smooth = true;
         screen.reward_mc.rewardIcon.visible = false;
         screen.reward_mc.strength_mc.visible = false;
         screen.reward_mc.name_tf.visible = false;
         _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(m_questTree.xml.@advisor),screen.panelTop_mc.panelCharacter);
         _loc2_.smooth = true;
         m_loaders.push(_loc2_);
         var _loc3_:Object = null;
         if(m_questTree.hasTextReplacements())
         {
            _loc3_ = ZGameUtils.callFunctionFromXml(m_questTree.textReplacements);
         }
         TextFieldUtil.processTextField(screen.panelTop_mc.title_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.title));
         TextFieldUtil.processTextField(screen.panelTop_mc.popupBox_tf,ZGameUtils.ZlocT("QuestTrees",m_questTree.desc,_loc3_));
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"));
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.hint_tf,ZGameUtils.ZlocT("QuestTrees","QT04_Hint"));
         TextFieldUtil.processTextField(screen.reward_mc.strength_mc.strength_tf,_loc1_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc1_.code)).toString());
         TextFieldUtil.processTextField(screen.reward_mc.name_tf,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(screen.reward_mc.reward_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Reward"),{"maxLines":1});
         TextFieldUtil.processTextField(screen.reward_mc.qty_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Quantity"));
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.time_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         m_clock = new MOTDCountdownClock(screen.panelBottomAssets_mc.clock_mc,m_questTree.xml,true);
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.killsTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_MyKills"));
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.kills_tf,ZGlobal.player.getSeenFlag(BattleQuest.TITAN_KILLS).toString());
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.mechsTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_MechsLeft"));
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         Zlab.processManager.schedule(2000,this,this.onUpdateTotalKills);
      }
      
      override protected function deinitDialog() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         super.deinitDialog();
      }
      
      override protected function updateProgress() : void
      {
         super.updateProgress();
         var _loc1_:Number = numCompleted() / m_questTree.steps;
         screen.panelBottomAssets_mc.progressBar_mc.loadBar_mc.width = screen.panelBottomAssets_mc.progressBar_mc.loadBase_mc.width * _loc1_;
         this.updateTotalKills();
      }
      
      override protected function createNode(param1:XML, param2:int) : Node
      {
         var _loc3_:String = param1.@screenId;
         return new MiniSeries008Node(screen.panelBottomAssets_mc[_loc3_],null,param1,m_questTree.id,param2,onImageLoaded);
      }
      
      protected function onUpdateTotalKills() : void
      {
         this.updateTotalKills();
         Zlab.processManager.schedule(2000,this,this.onUpdateTotalKills);
      }
      
      protected function updateTotalKills() : void
      {
         var _loc1_:BaseWorldEvent = WorldEventManager.instance.getWorldEvent(m_questTree.id);
         TextFieldUtil.processTextField(screen.panelBottomAssets_mc.mechs_tf,_loc1_.data);
      }
   }
}

