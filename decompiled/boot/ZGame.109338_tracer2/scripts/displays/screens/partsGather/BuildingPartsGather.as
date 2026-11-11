package displays.screens.partsGather
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.gameobjects.PartsItem;
   import core.managers.viralsManager.ViralsManager;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class BuildingPartsGather extends PartsGather
   {
      
      public static const FINISHED:String = "finished";
      
      protected var m_desc:String = null;
      
      protected var m_title:String = null;
      
      protected var m_complte_desc:String = null;
      
      protected var m_hint:String = null;
      
      public function BuildingPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null, param7:String = null)
      {
         this.m_complte_desc = param6 ? param6 : "BuildingPartsGatherComplete";
         this.m_desc = param3 ? param3 : "BuildingPartsGatherDescription";
         this.m_title = param5.length != 0 ? param5 : "BuildingPartsGatherTitle";
         this.m_hint = param7;
         super(param1,param2,param4);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null, param7:String = null) : void
      {
         WindowManager.instance.push(new BuildingPartsGather(param1,param2,param3,param4,param5,param6,param7));
      }
      
      public function getRemainingBuildingPartsAmount(param1:String) : int
      {
         return getRemainingPartsAmount(this.getPartsItem(param1));
      }
      
      override protected function get assetUrl() : String
      {
         if(m_partsItem.buildingPartsDialog)
         {
            return "assets/displays/dialogs/" + m_partsItem.buildingPartsDialog + ".swf";
         }
         return "assets/displays/screens/PU_UnitPartsGather.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,{
            "counter":"dialog",
            "kingdom":this.kingdom,
            "phylum":"view"
         }));
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,PartsBuildingItem) as PartsBuildingItem;
      }
      
      override protected function setTitleText() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:LocalizationObjectToken = m_partsItem.getSentenceNameLocalizationObject("singular",false);
         if(_loc3_)
         {
            _loc1_ = {"item":_loc3_};
            _loc2_ = ZGameUtils.ZlocT("Dialogs",this.m_title,_loc1_);
         }
         TextFieldUtil.compactTextField(m_partsWindow.title_tf,_loc2_);
      }
      
      override protected function setDescriptionText() : void
      {
         var _loc1_:LocalizationObjectToken = null;
         if(!canFinish())
         {
            _loc1_ = m_partsItem.getSentenceNameLocalizationObject("singular",false);
            super.setDescriptionText();
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_desc,{"item":_loc1_}));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_complte_desc));
         }
      }
      
      override protected function setHintText() : void
      {
         if(m_partsWindow.hint_tf)
         {
            if(Boolean(this.m_hint) && this.m_hint.toString().length > 0)
            {
               TextFieldUtil.compactTextField(m_partsWindow.hint_tf,ZGameUtils.ZlocT("Dialogs",this.m_hint));
            }
         }
      }
      
      override protected function completePartsItem() : void
      {
         closeWindow(null);
         m_eventDispatcher.dispatchEvent(new Event(FINISHED));
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:PartsBuildingItem = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:Object = null;
         var _loc11_:String = null;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_ != null)
         {
            _loc4_ = null;
            _loc5_ = null;
            _loc6_ = m_partsItem as PartsBuildingItem;
            if(_loc6_)
            {
               _loc4_ = _loc6_.getPartsAskMethod(_loc2_.slotIndex);
               _loc5_ = _loc6_.getPartsAskName(_loc2_.slotIndex);
            }
            if(!_loc4_ || !_loc5_)
            {
               if(_loc2_.slotIndex == m_partsItem.numParts - 1 || _loc2_.slotIndex == 0 && _loc3_.subType == GameItem.SUBTYPE_TREASUREVAULTPART || _loc2_.slotIndex != 1 && _loc3_.subType == GameItem.SUBTYPE_PALACEPART)
               {
                  _loc4_ = "feed";
                  if(_loc3_.subType == GameItem.SUBTYPE_SUPPORTBUILDINGPART)
                  {
                     _loc5_ = "ask_for_parts_supportbuilding";
                  }
                  else if(_loc3_.subType == GameItem.SUBTYPE_TREASUREVAULTPART)
                  {
                     _loc5_ = "ask_for_parts_treasurevault";
                  }
                  else if(_loc3_.subType == GameItem.SUBTYPE_PALACEPART)
                  {
                     _loc5_ = "ask_for_parts_palace";
                  }
                  else
                  {
                     _loc5_ = "ask_for_parts_building";
                  }
               }
               else
               {
                  _loc4_ = "request";
                  if(_loc3_.subType == GameItem.SUBTYPE_SUPPORTBUILDINGPART)
                  {
                     _loc5_ = "supportbuilding_part";
                  }
                  else if(_loc3_.subType == GameItem.SUBTYPE_TREASUREVAULTPART)
                  {
                     _loc5_ = "treasurevault_part";
                  }
                  else if(_loc3_.subType == GameItem.SUBTYPE_PALACEPART)
                  {
                     _loc5_ = "palace_part";
                  }
                  else
                  {
                     _loc5_ = "building_part";
                  }
               }
            }
            if(_loc4_ == "feed")
            {
               _loc7_ = _loc6_.getTimedBuidlableFeed();
               ViralsManager.instance.sendFeedWithLotsOfFriction(_loc5_,{
                  "itemCode":_loc3_.code,
                  "buildingName":m_partsItem.name,
                  "feedForVolcano":_loc7_,
                  "ITEMTOKOVERRIDEitem":_loc3_.name + "|"
               },null);
            }
            else
            {
               _loc8_ = null;
               _loc9_ = _loc6_.getPartsType();
               if(_loc9_)
               {
                  _loc10_ = _loc3_.getSentenceNameLocalizationObject("plural",true);
                  _loc11_ = ZGameUtils.ZlocT("Requests","PartRequest_" + _loc9_,{"gift":_loc10_});
                  if(_loc11_)
                  {
                     _loc8_ = new Array();
                     _loc8_["request_body"] = _loc11_;
                  }
               }
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name,_loc8_));
            }
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":this.kingdom,
               "phylum":"ask_for_parts"
            }));
         }
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
      
      protected function get kingdom() : String
      {
         if(m_partsItem.isSupportFactory())
         {
            return m_partsItem.name;
         }
         if(m_partsItem.buildingPartsKingdom)
         {
            return m_partsItem.buildingPartsKingdom;
         }
         return "defense_tower_build";
      }
   }
}

