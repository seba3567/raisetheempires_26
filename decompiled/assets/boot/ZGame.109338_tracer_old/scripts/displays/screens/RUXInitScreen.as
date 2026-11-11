package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.QuestsUIItem;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class RUXInitScreen extends ZGamePopUp
   {
      
      private var m_initialised:Boolean = false;
      
      private var go_button:ZGameButton;
      
      public function RUXInitScreen()
      {
         var _loc1_:String = null;
         switch(ZGlobal.player.activeRUXDay)
         {
            case 1:
               _loc1_ = "assets/displays/screens/MOTD_RUX1.swf";
               break;
            case 2:
               _loc1_ = "assets/displays/screens/MOTD_RUX2.swf";
               break;
            case 3:
               _loc1_ = "assets/displays/screens/MOTD_RUX3.swf";
         }
         super(ZGlobal.getAssetURL(_loc1_));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function setupWindow() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            this.initDialog();
            _loc1_ = this.x;
            _loc2_ = this.y;
            centerWithinStage(Zlab.mainStage);
            if(this.x < 0 || this.y < 0)
            {
               this.x = _loc1_;
               this.y = _loc2_;
            }
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:ImageLoader = null;
         var _loc3_:ImageLoader = null;
         var _loc4_:ImageLoader = null;
         var _loc5_:ImageLoader = null;
         var _loc6_:ImageLoader = null;
         var _loc7_:ImageLoader = null;
         var _loc8_:ImageLoader = null;
         var _loc9_:ImageLoader = null;
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         switch(ZGlobal.player.activeRUXDay)
         {
            case 1:
               TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Title"));
               TextFieldUtil.compactTextField(this.screen.description_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Description",{"x":ZGlobal.player.ruxDelta}));
               TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Generic"));
               TextFieldUtil.compactTextField(this.screen.giftTitle1_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Gift1"));
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_1.swf/Bldg_Res_Farm_CTEH_01_96.png"),this.screen.icon1);
               _loc1_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.giftTitle2_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Gift2"));
               _loc2_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_1.swf/DefenseForceSheild_01_96.png"),this.screen.icon2);
               _loc2_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.giftTitle3_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Gift3"));
               _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_1.swf/ClearTree_01_96.png"),this.screen.icon3);
               _loc3_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.incentive_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Incentive"));
               _loc4_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_42.png"),this.screen.reward0);
               _loc4_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.qty0_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward0"));
               TextFieldUtil.compactTextField(this.screen.instructions_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_RewardMessage"));
               TextFieldUtil.compactTextField(this.screen.reward1_tf,ZGameUtils.ZlocT("Items","wood_menuName"));
               _loc5_ = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode("RS17",GameItem) as GameItem).getCachedImage("icon").url,this.screen.reward1);
               _loc5_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.reward2_tf,ZGameUtils.ZlocT("Items","oil_menuName"));
               _loc6_ = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode("RS18",GameItem) as GameItem).getCachedImage("icon").url,this.screen.reward2);
               _loc6_.smooth = true;
               if(ZGlobal.player.level < ZGlobal.gameSettings.getInt("ruxLevelGate1",30))
               {
                  TextFieldUtil.compactTextField(this.screen.qty1_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward1_1"));
                  TextFieldUtil.compactTextField(this.screen.qty2_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward2_1"));
               }
               else if(ZGlobal.player.level < ZGlobal.gameSettings.getInt("ruxLevelGate2",50))
               {
                  TextFieldUtil.compactTextField(this.screen.qty1_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward1_2"));
                  TextFieldUtil.compactTextField(this.screen.qty2_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward2_2"));
               }
               else
               {
                  TextFieldUtil.compactTextField(this.screen.qty1_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward1_3"));
                  TextFieldUtil.compactTextField(this.screen.qty2_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Reward2_3"));
               }
               TextFieldUtil.compactTextField(this.screen.footnote_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_Progress"));
               TextFieldUtil.compactTextField(this.screen.go_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day0_GoButton"));
               break;
            case 2:
               TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_Title"));
               TextFieldUtil.compactTextField(this.screen.description_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_Description"));
               TextFieldUtil.compactTextField(this.screen.giftTitle1_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_Gift1"));
               _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_0.swf/EmpirePoints_96.png"),this.screen.icon1);
               _loc7_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.incentive_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_Incentive"));
               _loc8_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_42.png"),this.screen.reward0);
               _loc8_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.qty0_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_Reward0"));
               TextFieldUtil.compactTextField(this.screen.footnote_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_Progress"));
               TextFieldUtil.compactTextField(this.screen.go_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day1_GoButton"));
               break;
            case 3:
               TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day2_Title"));
               TextFieldUtil.compactTextField(this.screen.description_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day2_Description"));
               TextFieldUtil.compactTextField(this.screen.giftTitle1_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day2_Gift1"));
               _loc9_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_0.swf/EmpirePoints_96.png"),this.screen.icon1);
               _loc9_.smooth = true;
               TextFieldUtil.compactTextField(this.screen.footnote_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day2_Progress"));
               TextFieldUtil.compactTextField(this.screen.go_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","RUX_Day2_GoButton"));
         }
         this.go_button = new ZGameButton(this.screen.go_bt,this.onGoClicked);
         this.screen.go_bt.addEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      public function onExit(param1:Event) : void
      {
         close();
         var _loc2_:QuestsUIItem = UIManager.instance.getMenuItemByName("questsUIItem") as QuestsUIItem;
         _loc2_.showRUXTaskArrowOnQuest();
      }
      
      public function onGoClicked(param1:Event) : void
      {
         close();
         var _loc2_:QuestsUIItem = UIManager.instance.getMenuItemByName("questsUIItem") as QuestsUIItem;
         _loc2_.showRUXQuestSpeech();
      }
      
      private function onSpeechClose(param1:Event) : void
      {
         close();
      }
   }
}

