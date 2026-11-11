package displays.popups
{
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.QuestBuildableManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import events.MarketEvent;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class QuestBuildableRewardPopup extends ZGamePopUp
   {
      
      private var m_itemCode:String;
      
      private var m_initialised:Boolean = false;
      
      protected var placeButton:ZGameButton;
      
      public function QuestBuildableRewardPopup(param1:String)
      {
         this.m_itemCode = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_QuestBuildableComplete.swf"));
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
      
      private function setupWindow() : void
      {
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            this.initDialog();
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         m_window.screen_mc.exit_bt.visible = false;
         TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_Complete"));
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader((ZGlobal.gameSettings.getItemByCode(QuestBuildableManager.GOLDEN_STATUE,GameItem) as GameItem).getCachedImage("screenicon").url,m_window.screen_mc.bigIcon);
         _loc1_.smooth = true;
         TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Quests","quest_QB001_complete"));
         TextFieldUtil.compactTextField(m_window.screen_mc.place_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","QuestBuildable_PlaceButton"));
         this.placeButton = new ZGameButton(m_window.screen_mc.place_bt,this.onplaceButtonClicked);
         centerWithinStage(Zlab.mainStage);
      }
      
      private function onplaceButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         if(ZGlobal.isHome())
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(QuestBuildableManager.GOLDEN_STATUE,GameItem) as GameItem;
            if(_loc2_)
            {
               _loc3_ = ZGlobal.player.getNumberOfInventoryItems(QuestBuildableManager.GOLDEN_STATUE);
               if(_loc3_ > 0)
               {
                  GameModeManager.instance.addGameMode(new GMObjectPlace(_loc2_.name,MarketEvent.SOURCE_INVENTORY,true));
               }
            }
         }
         close();
      }
   }
}

