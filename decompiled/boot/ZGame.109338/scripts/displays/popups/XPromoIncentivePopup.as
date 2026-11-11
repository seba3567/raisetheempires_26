package displays.popups
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.GenericButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TClearIncentivePopup;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class XPromoIncentivePopup extends GallantPopup
   {
      
      private static var INCENTIVE_POPUP_OPTIONS:Object = {};
      
      private var m_button:GenericButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_items:Array = null;
      
      private var m_loaders:Array = null;
      
      private var m_descLabel:String = "incentiveDesc";
      
      private var m_descLabelTokens:Object;
      
      private var m_suppressTransaction:Boolean;
      
      private var m_quantityOverride:int = 1;
      
      private var m_item_id:int = 0;
      
      public function XPromoIncentivePopup(param1:Object)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Incentive2.swf"));
         this.m_items = param1.xPromoItem.rewards;
         this.m_item_id = param1.xPromoItem.id;
         if(param1.suppressTransaction)
         {
            this.m_suppressTransaction = param1.suppressTransaction;
         }
         if(param1.dialogTokens)
         {
            this.m_descLabelTokens = param1.dialogTokens;
         }
         if(param1.quantityOverride > 1)
         {
            this.m_quantityOverride = param1.quantityOverride;
         }
         if(param1.dialogLabel as String)
         {
            this.m_descLabel = param1.dialogLabel;
         }
         else if(Boolean(this.m_items) && this.m_items.length > 1)
         {
            this.m_descLabel = "incentiveDesc";
         }
         else
         {
            this.m_descLabel = "incentiveSingleDesc";
         }
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
         TextFieldUtil.processTextField(m_window.incentive.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_descLabel,this.m_descLabelTokens));
         m_window.incentive.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_button = new GenericButton(m_window.incentive.green_bt,this.onExit);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","Accept");
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(m_window.incentive.exit_bt,ButtonSound.DEFAULT);
         this.setupRewards();
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
         m_window.incentive.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         super.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         if(!this.m_suppressTransaction)
         {
            TransactionManager.addTransaction(new TClearIncentivePopup());
         }
         this.close();
      }
      
      private function setupRewards() : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:GameItem = null;
         m_window.incentive.icons_even.visible = false;
         m_window.incentive.icons_odd.visible = false;
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.m_items)
         {
            _loc2_ += this.m_items.length;
         }
         if(_loc2_ % 2 == 0)
         {
            m_window.incentive.icons_even.visible = true;
            _loc1_ = [m_window.incentive.icons_even.icon1,m_window.incentive.icons_even.icon2,m_window.incentive.icons_even.icon3,m_window.incentive.icons_even.icon4];
         }
         else
         {
            m_window.incentive.icons_odd.visible = true;
            _loc1_ = [m_window.incentive.icons_odd.icon2,m_window.incentive.icons_odd.icon1,m_window.incentive.icons_odd.icon3];
         }
         var _loc3_:int = 0;
         if(this.m_items)
         {
            _loc6_ = 0;
            while(_loc6_ < this.m_items.length)
            {
               _loc7_ = ZGlobal.gameSettings.getItemByCode(this.m_items[_loc6_].code,GameItem) as GameItem;
               _loc1_[_loc6_].visible = true;
               if(_loc7_ != null)
               {
                  _loc4_ = _loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  if(this.m_quantityOverride > 1)
                  {
                     _loc5_ = ZGameUtils.ZlocT("Gifts","Quantity",{"quantity":this.m_quantityOverride});
                     _loc4_ += "  " + _loc5_;
                  }
                  TextFieldUtil.processTextField(_loc1_[_loc6_].name_tf,_loc4_);
                  this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc7_.getCachedImage("icon").url,_loc1_[_loc6_].icon));
                  _loc3_++;
               }
               _loc6_++;
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

