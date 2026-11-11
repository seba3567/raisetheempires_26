package displays.popups.miniSeriesDialogBubble
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.unitClassManager.*;
   import core.player.questTrees.QuestTree;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeriesDifficultyMode extends GallantPopup
   {
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_callback:Function = null;
      
      private var m_questTree:String = null;
      
      private var m_questTreeId:String = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_loader:ImageLoader = null;
      
      private var m_difficulty1:ZGameButton = null;
      
      private var m_difficulty2:ZGameButton = null;
      
      private var m_difficulty3:ZGameButton = null;
      
      public function MiniSeriesDifficultyMode(param1:String, param2:String)
      {
         this.m_questTreeId = param1;
         super(ZGlobal.getAssetURL(param2));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc5_:ZGameQuest = null;
         var _loc6_:XML = null;
         var _loc7_:RewardHelper = null;
         var _loc8_:UnitItem = null;
         var _loc9_:UnitClass = null;
         super.initializeScreen();
         var _loc1_:int = ZGlobal.player.level;
         if(_loc1_ >= 12 && _loc1_ <= 30)
         {
            this.screen.difficulty1_mc.gotoAndStop(1);
            this.screen.difficulty2_mc.gotoAndStop(2);
            this.screen.difficulty3_mc.gotoAndStop(3);
         }
         else if(_loc1_ >= 31 && _loc1_ <= 50)
         {
            this.screen.difficulty1_mc.gotoAndStop(2);
            this.screen.difficulty2_mc.gotoAndStop(3);
            this.screen.difficulty3_mc.gotoAndStop(4);
         }
         else
         {
            this.screen.difficulty1_mc.gotoAndStop(3);
            this.screen.difficulty2_mc.gotoAndStop(4);
            this.screen.difficulty3_mc.gotoAndStop(5);
         }
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("QuestTrees","MS_diff_mode_title"));
         TextFieldUtil.compactTextField(this.screen.description_tf,ZGameUtils.ZlocT("QuestTrees","MS_diff_mode_desc"));
         if(!this.m_difficulty1 && !this.m_difficulty2 && !this.m_difficulty3)
         {
            this.m_difficulty1 = new ZGameButton(this.screen.difficulty1_bt,this.onDifficultyMode);
            this.m_difficulty1.text = ZGameUtils.ZlocT("QuestTrees","MS_diff_mode_01");
            this.m_difficulty1.buttonValue = "veteran";
            this.m_difficulty1.enable();
            this.m_difficulty2 = new ZGameButton(this.screen.difficulty2_bt,this.onDifficultyMode);
            this.m_difficulty2.text = ZGameUtils.ZlocT("QuestTrees","MS_diff_mode_02");
            this.m_difficulty2.buttonValue = "elite";
            this.m_difficulty2.enable();
            this.m_difficulty3 = new ZGameButton(this.screen.difficulty3_bt,this.onDifficultyMode);
            this.m_difficulty3.text = ZGameUtils.ZlocT("QuestTrees","MS_diff_mode_03");
            this.m_difficulty3.buttonValue = "master";
            this.m_difficulty3.enable();
         }
         var _loc2_:QuestTree = ZGlobal.player.questTrees.getQuestTree(this.m_questTreeId);
         var _loc3_:Array = _loc2_.rewardQuestNames;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = QuestSettingsInit.getInstance().getItemByName(_loc3_[_loc4_]) as ZGameQuest;
            _loc6_ = new XML(_loc5_.xml.reward.toXMLString());
            _loc7_ = new RewardHelper(_loc6_);
            _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc7_.modifiedReward(),UnitItem) as UnitItem;
            TextFieldUtil.compactTextField(this.screen.strength_mc.strength_tf,_loc8_.getStrength(null,null).toString());
            _loc9_ = UnitClassManager.instance.unitClassNamed(_loc8_.unitClass);
            if(_loc9_)
            {
               this.m_loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc9_.getIconURL()),this.screen.strength_mc.icon);
               this.m_loader.smooth = true;
            }
            TextFieldUtil.compactTextField(this.screen.tierRating_mc.tier_tf,String(_loc8_.tier));
            _loc4_++;
         }
      }
      
      protected function get screen() : MovieClip
      {
         return m_window.difficultyDialog_mc;
      }
      
      protected function onDifficultyMode(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.target.buttonValue;
         ZGlobal.player.questTrees.setMsDifficultyMode(this.m_questTreeId,_loc2_);
         close();
         QuestTree.showScreen(this.m_questTreeId,"other");
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_loader)
         {
            this.m_loader.destroy();
         }
         super.deinitDialog();
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         close();
         this.m_callback();
      }
   }
}

