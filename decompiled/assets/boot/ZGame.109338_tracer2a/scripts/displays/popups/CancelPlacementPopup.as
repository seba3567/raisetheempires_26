package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class CancelPlacementPopup extends ZGamePopUp
   {
      
      private var m_closeBtn:ZGameButton = null;
      
      private var m_imageLoaders:Array = new Array();
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_titleMessage:String = "CancelUnitPlacementPopupTitle";
      
      private var m_descriptionMessage:String;
      
      private var m_assetUrl:String = "assets/displays/screens/PU_AirDepot_Popup.swf";
      
      private var m_iconUrl:String;
      
      private var m_canBuildWarehouse:Boolean;
      
      private var m_messageData:Object;
      
      private var m_pageButtons:Array;
      
      public function CancelPlacementPopup(param1:String, param2:Boolean, param3:String, param4:String, param5:GameItem)
      {
         this.m_descriptionMessage = param1;
         this.m_canBuildWarehouse = param2;
         this.m_messageData = {"item":param5.getSentenceNameLocalizationObject()};
         if(this.m_canBuildWarehouse)
         {
            this.m_messageData.depot = WarehouseExperimentManager.getWarehouseItemByType(param4).getSentenceNameLocalizationObject();
         }
         this.m_assetUrl = "assets/displays/screens/PU_AirDepot_Popup.swf";
         this.m_iconUrl = param3;
         this.m_pageButtons = new Array();
         super(ZGlobal.getAssetURL(this.m_assetUrl));
      }
      
      public static function display(param1:String, param2:Boolean, param3:String, param4:String, param5:GameItem) : void
      {
         PopupManager.instance.push(new CancelPlacementPopup(param1,param2,param3,param4,param5));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc4_:ZGameButton = null;
         initDialog();
         var _loc2_:Class = param1.getAssetClass("errorDialog");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.panel_mc.width;
         this.contentHeight = m_window.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs",this.m_titleMessage));
         TextFieldUtil.processTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_descriptionMessage,this.m_messageData));
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         m_window.exit_bt.visible = true;
         Logger.print(this,"JMR: m_iconUrl: " + this.m_iconUrl);
         Logger.print(this,"JMR: m_window.icon: " + m_window.icon);
         var _loc3_:ImageLoader = ImageLoaderFactory.CreateImageLoader(this.m_iconUrl,m_window.icon);
         Logger.print(this,"JMR: imageLoader: " + _loc3_);
         _loc3_.smooth = true;
         this.m_imageLoaders.push(_loc3_);
         _loc4_ = new ZGameButton(m_window.add_bt,this.close);
         _loc4_.compactText(ZGameUtils.ZlocT("Dialogs","Okay"),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_pageButtons.push(_loc4_);
         this.m_buttonSounds.addButton(_loc4_.m_overlay,ButtonSound.DEFAULT);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:ZGameButton = null;
         deinitDialog();
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.close);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = null;
         for each(_loc2_ in this.m_pageButtons)
         {
            _loc2_.dispose();
         }
         this.m_pageButtons = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.dispose();
         super.close(param1);
      }
   }
}

