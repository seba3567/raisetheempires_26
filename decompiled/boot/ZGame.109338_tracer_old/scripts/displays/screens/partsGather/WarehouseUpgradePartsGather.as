package displays.screens.partsGather
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.managers.viralsManager.ViralsManager;
   import displays.screens.requests.RequestAskPartsDialog;
   import displays.screens.warehouseScreen.WarehouseUnitScreen;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class WarehouseUpgradePartsGather extends PartsGather
   {
      
      protected var m_assetUrl:String = "assets/displays/screens/PU_UnitPartsGather.swf";
      
      protected var m_warehouse:WarehouseComponent;
      
      private var m_viralName:String = null;
      
      protected var m_desc:String = null;
      
      public function WarehouseUpgradePartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:WarehouseComponent)
      {
         var _loc6_:GameDataComponent = GameDataComponent.getGameDataComponent(param4);
         var _loc7_:String = _loc6_.gameData.warehouseType;
         this.m_warehouse = param5;
         if(_loc7_ == "air")
         {
            this.m_assetUrl = "assets/displays/screens/PU_AirDepot_Buildables.swf";
            this.m_viralName = "ask_for_parts_airdepot_upgrade";
         }
         else if(_loc7_ == "army")
         {
            this.m_assetUrl = "assets/displays/screens/PU_AirDepot_Buildables.swf";
            this.m_viralName = "ask_for_parts_armydepot_upgrade";
         }
         else if(_loc7_ == "navy")
         {
            this.m_assetUrl = "assets/displays/screens/PU_AirDepot_Buildables.swf";
            this.m_viralName = "ask_for_parts_navydepot_upgrade";
         }
         this.m_desc = param3 ? param3 : "DepotPartsGatherDescription";
         super(param1,param2,param4);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:WarehouseComponent) : void
      {
         WindowManager.instance.push(new WarehouseUpgradePartsGather(param1,param2,param3,param4,param5));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         super.onLoadComplete(param1);
         var _loc5_:LocalizationObjectToken = this.warehouseItem.getSentenceNameLocalizationObject("singular",false);
         _loc4_ = this.m_warehouse.tier + 1;
         if(_loc5_)
         {
            _loc2_ = {
               "item":_loc5_,
               "tier":_loc4_
            };
            _loc3_ = ZGameUtils.ZlocT("Dialogs","DepotPartsGatherTitle",_loc2_);
         }
         TextFieldUtil.processTextField(m_partsWindow.title_tf,_loc3_);
         m_partsWindow.instructions_tf.visible = false;
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,{
            "counter":"dialog",
            "kingdom":this.kingdom,
            "phylum":"view"
         }));
      }
      
      override protected function get assetUrl() : String
      {
         return this.m_assetUrl;
      }
      
      protected function get kingdom() : String
      {
         if(m_partsItem.isSupportFactory())
         {
            return m_partsItem.name;
         }
         return "depot_" + this.m_warehouse.type;
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,PartsItem) as PartsItem;
      }
      
      override protected function setDescriptionText() : void
      {
         var _loc1_:LocalizationObjectToken = null;
         var _loc2_:int = 0;
         if(!canFinish())
         {
            _loc1_ = this.warehouseItem.getSentenceNameLocalizationObject("singular",false);
            _loc2_ = this.m_warehouse.tier + 1;
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_desc,{
               "item":_loc1_,
               "tier":_loc2_,
               "capacity":this.m_warehouse.getCapacityAtTier(_loc2_)
            }));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","DepotPartsGatherComplete"));
         }
      }
      
      override protected function completePartsItem() : void
      {
         m_eventDispatcher.dispatchEvent(new WorldEvent(WarehouseUnitScreen.FINISH_UPGRADE,{"upgradeItem":m_partsItem}));
         closeWindow(null);
      }
      
      override protected function sendStatsEvent(param1:Boolean) : void
      {
         if(param1)
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":this.kingdom,
               "phylum":"buy_all"
            }));
         }
         else
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":this.kingdom,
               "phylum":"buy"
            }));
         }
      }
      
      override protected function onExitButtonClick(param1:MouseEvent) : void
      {
         super.onExitButtonClick(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,{
            "counter":"dialog",
            "kingdom":this.kingdom,
            "phylum":"close"
         }));
      }
      
      private function get warehouseItem() : GameItem
      {
         return this.m_warehouse.parentItem;
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_ != null)
         {
            if(_loc2_.slotIndex == m_slotData.length - 1 || _loc2_.slotIndex == 0)
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction(this.m_viralName,{
                  "itemCode":_loc3_.code,
                  "depotPartType":this.m_warehouse.type,
                  "ITEMTOKitem":m_partsItem.name + "|",
                  "ITEMTOKreward":_loc3_.name + "|"
               },null);
            }
            else
            {
               _loc4_ = new Array();
               _loc5_ = _loc3_.getSentenceNameLocalizationObject("plural",true);
               _loc4_["request_body"] = ZGameUtils.ZlocT("Requests","PartRequest_depotpart",{"gift":_loc5_});
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name,_loc4_));
            }
         }
      }
   }
}

