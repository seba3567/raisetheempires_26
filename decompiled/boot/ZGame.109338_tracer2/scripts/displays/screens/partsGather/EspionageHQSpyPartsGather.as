package displays.screens.partsGather
{
   import Engine.Managers.StatsManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.EspionageHQSpyPartsItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.EspionageHQScreen;
   import displays.screens.contractScreen.EspionageHQContractSlot;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class EspionageHQSpyPartsGather extends PartsGather
   {
      
      private var m_spy:String;
      
      private var m_backButton:ZGameButton = null;
      
      private var m_greenButton:ZGameButton = null;
      
      private var m_iconLoader:ImageLoader = null;
      
      public function EspionageHQSpyPartsGather(param1:EventDispatcher, param2:String, param3:IEntity)
      {
         this.m_spy = param2;
         super(param1,param2,param3);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity) : void
      {
         WindowManager.instance.push(new EspionageHQSpyPartsGather(param1,param2,param3));
      }
      
      override protected function get assetUrl() : String
      {
         return "assets/displays/dialogs/PU_EspionageParts.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         super.onLoadComplete(param1);
         m_partsWindow.back_bt.visible = true;
         this.m_backButton = new ZGameButton(m_partsWindow.back_bt,this.onBackClick);
         this.m_backButton.text = ZGameUtils.ZlocT("Dialogs","BuildingPartsBack");
         _loc2_ = {"item":m_partsItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME)};
         _loc3_ = ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Equip_Title",_loc2_);
         TextFieldUtil.processTextField(m_partsWindow.title_tf,_loc3_);
         m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(m_partsItem.getCachedImage("icon").url,m_partsWindow.icon);
      }
      
      override protected function setDescriptionText() : void
      {
         if(!canFinish())
         {
            TextFieldUtil.processTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Equip_Desc"));
            m_partsWindow.green_bt.visible = false;
         }
         else
         {
            TextFieldUtil.processTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Equip_Finish_Desc"));
            this.m_greenButton = new ZGameButton(m_partsWindow.green_bt,onFinishClick);
            this.m_greenButton.text = ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Equip_Finish_Button");
            this.m_greenButton.show();
            m_buyAllButton.hide();
         }
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,EspionageHQSpyPartsItem) as EspionageHQSpyPartsItem;
      }
      
      override protected function completePartsItem() : void
      {
         m_eventDispatcher.dispatchEvent(new WorldEvent(EspionageHQContractSlot.FINISH_SPY,{"spyItem":m_partsItem}));
         StatsManager.count("EspionageHQ","earned",m_partsItem.code);
         closeWindow(null);
         EspionageHQScreen.display(m_eventDispatcher,m_entity);
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:EspionageHQSpyPartsItem = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_)
         {
            _loc4_ = null;
            _loc5_ = null;
            _loc6_ = m_partsItem as EspionageHQSpyPartsItem;
            _loc4_ = _loc6_.getPartsAskMethod(_loc2_.slotIndex);
            _loc5_ = _loc6_.getPartsAskName(_loc2_.slotIndex);
            if(Boolean(_loc4_) && _loc4_ == "feed")
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction(_loc5_,{
                  "itemCode":_loc3_.code,
                  "buildingName":m_partsItem.name,
                  "ITEMTOKOVERRIDEitem":_loc3_.name + "|"
               },null);
            }
            else
            {
               _loc7_ = null;
               _loc8_ = _loc6_.getPartsType();
               if(_loc8_)
               {
                  _loc9_ = _loc3_.getSentenceNameLocalizationObject("plural",true);
                  _loc10_ = ZGameUtils.ZlocT("Requests","PartRequest_" + _loc8_,{"gift":_loc9_});
                  if(_loc10_)
                  {
                     _loc7_ = new Array();
                     _loc7_["request_body"] = _loc10_;
                  }
               }
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name,_loc7_));
            }
         }
      }
      
      override protected function sendStatsEvent(param1:Boolean) : void
      {
         if(param1)
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":"espionage_hq",
               "phylum":"buy_all"
            }));
         }
      }
      
      private function onBackClick(param1:MouseEvent) : void
      {
         closeWindow(param1);
         EspionageHQScreen.display(m_eventDispatcher,m_entity);
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_backButton != null)
         {
            this.m_backButton.dispose();
            this.m_backButton = null;
         }
         if(this.m_greenButton != null)
         {
            this.m_greenButton.dispose();
            this.m_greenButton = null;
         }
         if(this.m_iconLoader != null)
         {
            this.m_iconLoader.destroy();
            this.m_iconLoader = null;
         }
         super.deinitDialog();
      }
   }
}

