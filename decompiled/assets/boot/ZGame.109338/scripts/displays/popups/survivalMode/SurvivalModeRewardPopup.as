package displays.popups.survivalMode
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.survivalModeManager.SurvivalModeDataHelper;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlewon.BattleWonPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class SurvivalModeRewardPopup extends BattleWonPopup
   {
      
      private var m_set:String = null;
      
      private var m_goButton:ZGameButton = null;
      
      private var m_loaders:Array = null;
      
      private var m_SurvivalMode:Boolean = true;
      
      public function SurvivalModeRewardPopup(param1:String, param2:Dictionary, param3:Array)
      {
         this.m_set = param1;
         super(param3,param2,null,this.m_SurvivalMode);
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         contentWidth = this.screen.width;
         contentHeight = this.screen.height;
         centerWithinStage(Zlab.mainStage);
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_goButton = new ZGameButton(this.screen.send_bt,this.onShare);
         this.m_goButton.text = ZGameUtils.ZlocT("Feeds","Survival60_Button");
         this.m_loaders = new Array();
         var _loc1_:SurvivalModeDataHelper = new SurvivalModeDataHelper(this.m_set);
         var _loc2_:String = _loc1_.ultimateRewardUnitName;
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
         if(_loc3_)
         {
            TextFieldUtil.compactTextField(this.screen.reward_mc.title_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeCompleteAward"));
            TextFieldUtil.compactTextField(this.screen.reward_mc.name_tf,_loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(this.screen.reward_mc.strength_mc.strength_tf,String(_loc3_.getUpgradedStrength()));
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"icon"),this.screen.reward_mc.icon));
            this.screen.reward_mc.visible = true;
         }
         else
         {
            this.screen.reward_mc.visible = false;
         }
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeCompleteTitle"));
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeCompleteBody1"));
         TextFieldUtil.compactTextField(this.screen.title03_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeCompleteAward"));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
      
      override protected function assetStr() : String
      {
         return "assets/displays/dialogs/PU_SurvivalMode_Victory.swf";
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.screen_mc.content_mc;
      }
      
      override protected function get windowWidth() : Number
      {
         return this.screen.width;
      }
      
      override protected function get windowHeight() : Number
      {
         return this.screen.height;
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeed("survival_completed",{});
      }
   }
}

