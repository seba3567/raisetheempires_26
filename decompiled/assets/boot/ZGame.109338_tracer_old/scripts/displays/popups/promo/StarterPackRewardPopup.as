package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.promoManager.PromoManager;
   import core.ui.GenericButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class StarterPackRewardPopup extends GallantPopup
   {
      
      private var m_button:GenericButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_items:Array = null;
      
      private var m_loaders:Array = null;
      
      private var m_resources:Array = null;
      
      private var m_promoData:PromoData;
      
      public function StarterPackRewardPopup(param1:PromoData)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Incentive.swf"));
         this.m_promoData = param1;
         while(ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON) <= ZGlobal.gameSettings.getNumber("promoIconSeenAmount"))
         {
            ZGlobal.player.setSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON);
         }
         PromoManager.instance.dispatchEvent(new Event(PromoManager.EVENT_CLOSE_STARTER_PACK_HUD_ICON));
         if(this.m_promoData)
         {
            this.m_items = param1.items;
         }
         this.m_resources = new Array();
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = m_window.incentive.background_mc.width;
         this.contentHeight = m_window.incentive.background_mc.height;
         m_window.incentive.background_mc.visible = false;
         centerWithinStage(Zlab.mainStage);
         this.setUpPopupUI();
      }
      
      protected function setUpPopupUI() : void
      {
         this.m_loaders = new Array();
         TextFieldUtil.processTextField(m_window.incentive.title_tf,ZGameUtils.ZlocT("Dialogs","incentiveTitle"));
         TextFieldUtil.processTextField(m_window.incentive.description_tf,ZGameUtils.ZlocT("Promo","promo_StarterPack_congratulations_desc"));
         m_window.incentive.exit_bt.addEventListener(MouseEvent.CLICK,this.onDecline,false,0,true);
         this.m_button = new GenericButton(m_window.incentive.green_bt,this.onAccept);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","Share");
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(m_window.incentive.exit_bt,ButtonSound.DEFAULT);
         this.setupRewards();
         StatsManager.count("dialog",this.m_promoData.trackingConfirmPromoKingdom,"view");
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         super.deinitDialog();
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_button = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window.incentive.exit_bt.removeEventListener(MouseEvent.CLICK,this.onDecline);
         super.close();
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_promoData.trackingConfirmPromoKingdom,"yes");
         if(this.m_promoData)
         {
            if(this.m_promoData.shareFeedFunction != null)
            {
               this.m_promoData.shareFeedFunction(this.m_promoData.shareFeedParams);
            }
         }
         this.close();
      }
      
      private function onDecline(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_promoData.trackingConfirmPromoKingdom,"no");
         this.close();
      }
      
      private function setupRewards() : void
      {
         var _loc4_:int = 0;
         var _loc5_:GameItem = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         m_window.incentive.icons_even.visible = false;
         m_window.incentive.icons_odd.visible = false;
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.m_items)
         {
            _loc2_ += this.m_items.length;
         }
         if(this.m_resources)
         {
            _loc2_ += this.m_resources.length;
         }
         if(_loc2_ % 2 == 0)
         {
            m_window.incentive.icons_even.visible = true;
            _loc1_ = [m_window.incentive.icons_even.icon1,m_window.incentive.icons_even.icon2];
         }
         else
         {
            m_window.incentive.icons_odd.visible = true;
            _loc1_ = [m_window.incentive.icons_odd.icon2,m_window.incentive.icons_odd.icon1,m_window.incentive.icons_odd.icon3];
         }
         var _loc3_:int = 0;
         if(this.m_items)
         {
            _loc4_ = 0;
            while(_loc4_ < this.m_items.length)
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(this.m_items[_loc4_],GameItem) as GameItem;
               _loc1_[_loc4_].visible = true;
               TextFieldUtil.processTextField(_loc1_[_loc4_].name_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc5_.getCachedImage("icon").url,_loc1_[_loc4_].icon));
               _loc3_++;
               _loc4_++;
            }
         }
         if(this.m_resources)
         {
            _loc6_ = _loc3_;
            _loc4_ = 0;
            while(_loc4_ < this.m_resources.length)
            {
               _loc7_ = this.m_resources[_loc4_].split(":");
               _loc1_[_loc4_].visible = true;
               TextFieldUtil.processTextField(_loc1_[_loc4_ + _loc6_].name_tf,ZGameUtils.ZlocT("Main","GenericItemAmount",{
                  "amount":_loc7_[1],
                  "item":_loc7_[0]
               }));
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURL(_loc7_[0],WorldResourceManager.XTRA_LARGE_ICON),_loc1_[_loc4_ + _loc6_].icon));
               _loc3_++;
               _loc4_++;
            }
         }
         while(_loc3_ < _loc1_.length)
         {
            _loc1_[_loc3_].visible = false;
            _loc3_++;
         }
      }
   }
}

