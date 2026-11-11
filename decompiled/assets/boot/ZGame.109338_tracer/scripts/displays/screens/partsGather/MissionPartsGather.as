package displays.screens.partsGather
{
   import Engine.Managers.StatsManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsMissionItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.MissionContractsScreen;
   import displays.screens.contractScreen.MissionContractSlot;
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
   
   public class MissionPartsGather extends PartsGather
   {
      
      private var m_backButton:ZGameButton = null;
      
      private var m_greenButton:ZGameButton = null;
      
      private var m_iconLoader:ImageLoader = null;
      
      public function MissionPartsGather(param1:EventDispatcher, param2:String, param3:IEntity)
      {
         super(param1,param2,param3);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity) : void
      {
         WindowManager.instance.push(new MissionPartsGather(param1,param2,param3));
      }
      
      override protected function get assetUrl() : String
      {
         return "assets/displays/screens/PU_SpecialForcesParts.swf";
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
         _loc3_ = ZGameUtils.ZlocT("Dialogs","MissionPartsTitle",_loc2_);
         TextFieldUtil.processTextField(m_partsWindow.title_tf,_loc3_);
         m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(m_partsItem.getCachedImage("icon").url,m_partsWindow.icon);
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,PartsMissionItem) as PartsMissionItem;
      }
      
      override protected function setDescriptionText() : void
      {
         if(!canFinish())
         {
            TextFieldUtil.processTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","MissionPartsSubtitle"));
            m_partsWindow.green_bt.visible = false;
         }
         else
         {
            TextFieldUtil.processTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","MissionPartsSubtitleComplete"));
            this.m_greenButton = new ZGameButton(m_partsWindow.green_bt,onFinishClick);
            this.m_greenButton.text = ZGameUtils.ZlocT("Dialogs","MissionPartsFinish");
            this.m_greenButton.show();
            m_buyAllButton.hide();
         }
      }
      
      override protected function completePartsItem() : void
      {
         m_eventDispatcher.dispatchEvent(new WorldEvent(MissionContractSlot.FINISH_MISSION,{"unitItem":m_partsItem}));
         StatsManager.count("mission","earned",m_partsItem.code);
         closeWindow(null);
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_ != null)
         {
            _loc4_ = ZGlobal.getResearchPartsExperimentVariantByType(m_partsItem.subType);
            if(_loc2_.slotIndex == m_slotData.length - 1 || _loc2_.slotIndex == 0)
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_mission",{
                  "itemCode":_loc3_.code,
                  "missionName":m_partsItem.name,
                  "ITEMTOKitem":m_partsItem.name + "|",
                  "ITEMTOKreward":_loc3_.name + "|"
               },null);
            }
            else
            {
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name));
            }
         }
      }
      
      override protected function sendStatsEvent(param1:Boolean) : void
      {
         if(param1)
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":"mission_factory",
               "phylum":"buy_all"
            }));
         }
      }
      
      private function onBackClick(param1:MouseEvent) : void
      {
         closeWindow(param1);
         MissionContractsScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity);
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
      
      override protected function getAskForPartString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","MissionPartsAsk");
      }
      
      override protected function getBuildingPartsInstructionsString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","MissionPartsGatherInstructions");
      }
   }
}

