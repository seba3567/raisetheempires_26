package core.player.questTrees
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import core.managers.ExperimentsManager;
   import core.managers.WorldObjectManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.worldEventManager.BaseWorldEvent;
   import core.managers.worldEventManager.WorldEventManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import displays.popups.miniSeriesDialogBubble.MiniSeriesDifficultyMode;
   import displays.screens.questTreeScreen.DailyQuestScreen;
   import displays.screens.questTreeScreen.DailyRevealScreen;
   import displays.screens.questTreeScreen.DoorQuestTreeScreen;
   import displays.screens.questTreeScreen.InvasionMapScreen;
   import displays.screens.questTreeScreen.MiniSeries008QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries009QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries011QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries012QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries013QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries014QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries018QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries019QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries020QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries021QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries022QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries023QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries024QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries025QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries026QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries027QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries028QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries029QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries030QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries031QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries032QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries033QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries034QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries035QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries036QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries037QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries038QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries039QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries040QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries041QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries042QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries043QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries044QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries045QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries046QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries047QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries048QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries049QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries050QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries051QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries052QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries053QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries054QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries055QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries056QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries057QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries058QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries059QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries060QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries061QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries062QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries063QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries064QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries065QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries066QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries067QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries068QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries069QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries070QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries071QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries072QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries073QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries074QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries075QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries076QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries077QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries078QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries079QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries080QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries081QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries082QuestTreeScreen;
   import displays.screens.questTreeScreen.MiniSeries083QuestTreeScreen;
   import displays.screens.questTreeScreen.MysteryCrateQuestTreeScreen;
   import displays.screens.questTreeScreen.QuestTreeScreen;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TQuestTreeStartQuest;
   import transactions.TQuestTreeUnlockQuest;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class QuestTree
   {
      
      private static var dialogTypes:Array = [QuestTreeScreen,MysteryCrateQuestTreeScreen,DailyQuestScreen,DailyRevealScreen,DoorQuestTreeScreen,MiniSeries008QuestTreeScreen,MiniSeries009QuestTreeScreen,MiniSeries011QuestTreeScreen,MiniSeries012QuestTreeScreen,MiniSeries013QuestTreeScreen,MiniSeries014QuestTreeScreen,MiniSeries018QuestTreeScreen,MiniSeries019QuestTreeScreen,MiniSeries020QuestTreeScreen,MiniSeries021QuestTreeScreen,MiniSeries022QuestTreeScreen,MiniSeries024QuestTreeScreen,MiniSeries022QuestTreeScreen,MiniSeries023QuestTreeScreen,MiniSeries025QuestTreeScreen,MiniSeries026QuestTreeScreen,MiniSeries027QuestTreeScreen,MiniSeries028QuestTreeScreen,MiniSeries029QuestTreeScreen,MiniSeries030QuestTreeScreen,MiniSeries031QuestTreeScreen,MiniSeries032QuestTreeScreen,MiniSeries033QuestTreeScreen,MiniSeries034QuestTreeScreen,MiniSeries035QuestTreeScreen,MiniSeries036QuestTreeScreen,MiniSeries037QuestTreeScreen,MiniSeries038QuestTreeScreen,MiniSeries039QuestTreeScreen,MiniSeries040QuestTreeScreen
      ,MiniSeries041QuestTreeScreen,MiniSeries042QuestTreeScreen,MiniSeries043QuestTreeScreen,MiniSeries044QuestTreeScreen,MiniSeries045QuestTreeScreen,MiniSeries046QuestTreeScreen,MiniSeries047QuestTreeScreen,MiniSeries048QuestTreeScreen,MiniSeries049QuestTreeScreen,MiniSeries050QuestTreeScreen,MiniSeries051QuestTreeScreen,MiniSeries052QuestTreeScreen,MiniSeries053QuestTreeScreen,MiniSeries054QuestTreeScreen,MiniSeries055QuestTreeScreen,MiniSeries056QuestTreeScreen,MiniSeries057QuestTreeScreen,MiniSeries058QuestTreeScreen,MiniSeries059QuestTreeScreen,MiniSeries060QuestTreeScreen,MiniSeries061QuestTreeScreen,MiniSeries062QuestTreeScreen,MiniSeries063QuestTreeScreen,MiniSeries064QuestTreeScreen,MiniSeries065QuestTreeScreen,MiniSeries066QuestTreeScreen,MiniSeries067QuestTreeScreen,MiniSeries068QuestTreeScreen,MiniSeries069QuestTreeScreen,MiniSeries070QuestTreeScreen,MiniSeries071QuestTreeScreen,MiniSeries072QuestTreeScreen,MiniSeries073QuestTreeScreen,MiniSeries074QuestTreeScreen,MiniSeries075QuestTreeScreen
      ,MiniSeries076QuestTreeScreen,MiniSeries077QuestTreeScreen,MiniSeries078QuestTreeScreen,MiniSeries079QuestTreeScreen,MiniSeries080QuestTreeScreen,MiniSeries081QuestTreeScreen,MiniSeries082QuestTreeScreen,MiniSeries083QuestTreeScreen,InvasionMapScreen];
      
      private var m_progress:Array = null;
      
      private var m_xml:XML = null;
      
      private var m_item:GameItem = null;
      
      private var m_hookEntity:IEntity = null;
      
      private var m_restarts:int = 0;
      
      private var m_validHookPos:Boolean = false;
      
      public var m_isQuestTreeDialogActive:Boolean = false;
      
      public function QuestTree(param1:String, param2:Object)
      {
         super();
         this.m_progress = param2.questTrees[param1] as Array;
         this.m_restarts = param2.questTreesRestarts ? int(param2.questTreesRestarts[param1]) : 0;
         this.m_xml = ZGlobal.gameSettings.getQuestTree(param1);
      }
      
      public static function showScreen(param1:String, param2:String) : void
      {
         var _loc3_:QuestTree = ZGlobal.player.questTrees.getQuestTree(param1);
         _loc3_.showScreen();
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,{
            "counter":"dialog",
            "kingdom":"mini_series",
            "phylum":_loc3_.id,
            "zclass":"view",
            "family":param2
         }));
      }
      
      public function get nodes() : XMLList
      {
         return this.m_xml.node;
      }
      
      public function get id() : String
      {
         return this.m_xml.@id;
      }
      
      public function get title() : String
      {
         if(this.m_xml.@title != undefined)
         {
            return this.m_xml.@title;
         }
         return this.m_xml.ui.mainScreen.@header;
      }
      
      public function get desc() : String
      {
         return this.m_xml.@desc;
      }
      
      public function hasTextReplacements() : Boolean
      {
         return this.m_xml.@textReplacements != undefined;
      }
      
      public function get textReplacements() : String
      {
         return this.m_xml.@textReplacements;
      }
      
      public function get popup() : String
      {
         if(this.m_xml.@popup != undefined)
         {
            return this.m_xml.@popup;
         }
         return this.m_xml.ui.mainScreen.@description;
      }
      
      public function get character() : String
      {
         return this.m_xml.ui.mainScreen.@character;
      }
      
      public function get hintTitle() : String
      {
         if(this.m_xml.@hintTitle != undefined)
         {
            return this.m_xml.@hintTitle;
         }
         return this.m_xml.ui.mainScreen.@hintTitle;
      }
      
      public function get hint() : String
      {
         if(this.m_xml.@hint != undefined)
         {
            return this.m_xml.@hint;
         }
         return this.m_xml.ui.mainScreen.@hint;
      }
      
      public function get rewardTitle() : String
      {
         if(this.m_xml.ui.mainScreen.@rewardTitle != undefined)
         {
            return this.m_xml.ui.mainScreen.@rewardTitle;
         }
         return "Rewards";
      }
      
      public function get steps() : int
      {
         return this.m_xml.@steps;
      }
      
      public function get mainReward() : String
      {
         return this.m_xml.@mainReward;
      }
      
      public function get grantReward() : String
      {
         return this.m_xml.@grantReward;
      }
      
      public function get xml() : XML
      {
         return this.m_xml;
      }
      
      public function get hookCode() : String
      {
         return this.m_xml.hook.@item;
      }
      
      public function get screenUrl() : String
      {
         if(this.m_xml.screen.@url != undefined)
         {
            return this.m_xml.screen.@url;
         }
         return this.m_xml.ui.mainScreen.@url;
      }
      
      public function get difficultyModeEnabled() : Boolean
      {
         if(this.m_xml.hasOwnProperty("difficultyMode"))
         {
            if(ExperimentsManager.instance.experimentGateEnabled(this.m_xml.difficultyMode.@experiment,this.m_xml.difficultyMode.@variant))
            {
               return true;
            }
         }
         return false;
      }
      
      public function get finalRewardDialogUrl() : String
      {
         return this.m_xml.ui.finalReward.@url;
      }
      
      public function get rememberUnlocks() : Boolean
      {
         if(this.m_xml.@rememberUnlocks != undefined)
         {
            if(this.m_xml.@rememberUnlocks.toString() == "false")
            {
               return false;
            }
         }
         return true;
      }
      
      public function get detailsUrl() : String
      {
         if(this.m_xml.screen.@details != undefined)
         {
            return this.m_xml.screen.@details;
         }
         return this.m_xml.ui.questDetails.@url;
      }
      
      public function get finalUrl() : String
      {
         if(this.m_xml.screen.@final != undefined)
         {
            return this.m_xml.screen.@final;
         }
         return this.m_xml.ui.finalReward.@url;
      }
      
      public function get unlockAllNodesAtStart() : Boolean
      {
         if(this.m_xml.@unlockAllNodesAtStart != undefined)
         {
            if(this.m_xml.@unlockAllNodesAtStart == "true")
            {
               return true;
            }
         }
         return false;
      }
      
      public function shouldAutoReset() : Boolean
      {
         return this.m_xml.@autoReset != undefined && this.m_xml.@autoReset == "true";
      }
      
      public function validForRestarting() : Boolean
      {
         var _loc1_:int = int(this.m_xml.@maxPlays);
         return this.m_restarts < _loc1_;
      }
      
      public function reset() : void
      {
         ++this.m_restarts;
      }
      
      public function resetNode(param1:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         this.reset();
         var _loc2_:Array = new Array();
         _loc2_.push(param1);
         var _loc3_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         if(_loc3_)
         {
            _loc6_ = _loc3_.sequels;
            for each(_loc7_ in _loc6_)
            {
               _loc2_.push(_loc7_);
            }
         }
         for each(_loc5_ in _loc2_)
         {
            _loc4_ = this.m_progress.indexOf(_loc5_);
            if(_loc4_ >= 0)
            {
               this.m_progress.splice(_loc4_,1);
            }
         }
      }
      
      public function resetQuests(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         for each(_loc2_ in param1)
         {
            _loc3_ = this.m_progress.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               this.m_progress.splice(_loc3_,1);
            }
         }
      }
      
      public function loadWorldObjects() : void
      {
         this.disposeHookEntity();
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(Boolean(this.m_xml.hook) && this.m_xml.hook.@item != undefined)
            {
               this.createHookEntity();
            }
         }
      }
      
      public function isQuestTreeComplete() : Boolean
      {
         var _loc1_:XML = null;
         for each(_loc1_ in this.nodes)
         {
            if(!ZGlobal.player.didCompleteQuest(_loc1_.@quest))
            {
               return false;
            }
         }
         return true;
      }
      
      public function get lastUnlockedQuest() : String
      {
         var _loc1_:String = null;
         var _loc2_:ZGameQuest = null;
         var _loc3_:String = null;
         if(Boolean(this.m_progress) && Boolean(this.m_progress.length))
         {
            _loc1_ = this.m_progress[this.m_progress.length - 1];
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(_loc1_) as ZGameQuest;
            for each(_loc3_ in _loc2_.sequels)
            {
               if(ZGlobal.player.didCompleteQuest(_loc3_))
               {
                  return _loc3_;
               }
            }
            return _loc1_;
         }
         return null;
      }
      
      public function get iconURL() : String
      {
         if(this.m_xml.@icon != undefined)
         {
            return ZGlobal.getAssetURL(this.m_xml.@icon.toString());
         }
         return ZGlobal.getAssetURL(this.m_xml.ui.questButtonIcon.@url.toString());
      }
      
      public function get backgroundURL() : String
      {
         if(this.m_xml.@backgroundURL == undefined)
         {
            return "";
         }
         return ZGlobal.getAssetURL(this.m_xml.@backgroundURL.toString());
      }
      
      public function get rewardTextHeader() : String
      {
         if(this.m_xml.@rewardTextHeader != undefined)
         {
            return ZGameUtils.ZlocTP(null,this.m_xml.@rewardTextHeader.toString());
         }
         return ZGameUtils.ZlocTP(null,this.m_xml.ui.finalReward.@header.toString());
      }
      
      public function get rewardTextHeader2() : String
      {
         return ZGameUtils.ZlocTP(null,this.m_xml.ui.finalReward.@header2.toString());
      }
      
      public function get rewardTextDescription() : String
      {
         var _loc1_:Object = {};
         var _loc2_:BaseWorldEvent = WorldEventManager.instance.getWorldEvent(this.id);
         if(_loc2_)
         {
            _loc1_ = {"num":_loc2_.data};
         }
         if(this.m_xml.@rewardTextDescription != undefined)
         {
            return ZGameUtils.ZlocTP(null,this.m_xml.@rewardTextDescription.toString(),_loc1_);
         }
         return ZGameUtils.ZlocTP(null,this.m_xml.ui.finalReward.@description.toString(),_loc1_);
      }
      
      public function rewardTextDescWithParams(param1:Object) : String
      {
         if(this.m_xml.@rewardDifficultyModeDesc != undefined)
         {
            return ZGameUtils.ZlocTP(null,this.m_xml.@rewardDifficultyModeDesc.toString(),param1);
         }
         return ZGameUtils.ZlocTP(null,this.m_xml.ui.finalReward.@description.toString(),param1);
      }
      
      public function get firstQuest() : String
      {
         var _loc1_:String = null;
         var _loc2_:XML = null;
         var _loc3_:String = null;
         if(Boolean(this.m_xml) && Boolean(this.m_xml.node))
         {
            for each(_loc2_ in this.m_xml.node)
            {
               if(_loc2_.@quest != undefined)
               {
                  _loc3_ = _loc2_.@quest.toString();
                  if(!_loc1_)
                  {
                     _loc1_ = _loc3_;
                     break;
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function startQuest(param1:String) : void
      {
         var _loc2_:TQuestTreeStartQuest = new TQuestTreeStartQuest(this.id,param1);
         TransactionManager.addTransaction(_loc2_);
         ZGameQuestManager.instance.clientActivateQuest(param1);
         this.m_progress.push(param1);
      }
      
      public function unlockQuest(param1:String) : void
      {
         var _loc2_:TQuestTreeUnlockQuest = new TQuestTreeUnlockQuest(this.id,param1);
         TransactionManager.addTransaction(_loc2_);
      }
      
      public function get remainingTime() : int
      {
         var _loc1_:Object = {"stringNotUsed":true};
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.m_xml);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return _loc1_.delta;
         }
         return 0;
      }
      
      private function createHookEntity() : void
      {
         this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_xml.hook.@item,GameItem) as GameItem;
         var _loc1_:QuadSpatialManager = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc3_:IsoScene = IsoScene(_loc2_.getSceneByID("gameScene"));
         var _loc4_:EntityInit = new EntityInit();
         _loc4_.m_isoScene = _loc3_;
         _loc4_.m_spatialComponent = _loc1_;
         _loc4_.m_item = this.m_item;
         _loc4_.m_position = this.getHookPosition(this.m_item);
         _loc4_.m_group = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         this.m_hookEntity = BuildingEntity.createEntity(_loc4_);
         WorldObjectManager.instance.addObjectToTypeDictionary(this.m_item.type,this.m_item.subType,this.m_hookEntity.name,this.m_hookEntity);
         BuildManager.instance.alwaysGetObject(this.m_hookEntity);
      }
      
      private function getHookPosition(param1:GameItem) : Pt
      {
         var hookPos:String = null;
         var hookPosElements:Array = null;
         var waterIslandXml:XML = null;
         var waterTile:XML = null;
         var pos:Array = null;
         var X:int = 0;
         var Y:int = 0;
         var item:GameItem = param1;
         hookPos = null;
         hookPosElements = null;
         for each(hookPos in this.m_xml.hook.pos)
         {
            hookPosElements = hookPos.split(",");
            if(BuildManager.instance.checkFreeForMSHookPlacement(hookPosElements[0],hookPosElements[1]) && this.checkPlacement(hookPosElements[0],hookPosElements[1],item.sizeX,item.sizeY))
            {
               BuildManager.instance.setHookPositionData(hookPosElements[0],hookPosElements[1]);
               return new Pt(hookPosElements[0],hookPosElements[1]);
            }
         }
         waterIslandXml = ZGlobal.gameSettings.getXML().islands..*.(hasOwnProperty("@name") && @name == "Island3_Water")[0];
         if(waterIslandXml != null)
         {
            for each(waterTile in waterIslandXml.children())
            {
               pos = waterTile.@pos.split(",");
               if(pos != null && pos.length >= 2)
               {
                  X = int(pos[0]);
                  Y = int(pos[1]);
                  if(4 < X && X < 24 && (4 < Y && Y < 24))
                  {
                     X *= 4;
                     Y *= 4;
                     if(BuildManager.instance.checkFreeForMSHookPlacement(X,Y) && this.checkPlacement(X,Y,item.sizeX,item.sizeY))
                     {
                        BuildManager.instance.setHookPositionData(X,Y);
                        return new Pt(X,Y);
                     }
                  }
               }
            }
         }
         return new Pt(0,0);
      }
      
      private function checkPlacement(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc7_:Dictionary = null;
         var _loc8_:IEntity = null;
         var _loc9_:GameDataComponent = null;
         var _loc10_:BuildingSpatialComponent = null;
         var _loc11_:Pt = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc6_:Point = MathUtils.convertPtToPoint(MathUtils.tileToWorld(param1,param2,0,ZGlobal.cellSize));
         if(BuildManager.instance.getObjectsAt(_loc6_) == null)
         {
            _loc7_ = WorldObjectManager.instance.getObjectsBySubType(GameItem.TYPE_BUILDABLE,GameItem.SUBTYPE_HOOK);
            for each(_loc8_ in _loc7_)
            {
               _loc9_ = _loc8_.lookupComponentByType(GameDataComponent) as GameDataComponent;
               _loc10_ = _loc8_.lookupComponentByType(BuildingSpatialComponent) as BuildingSpatialComponent;
               _loc11_ = MathUtils.worldToTile(MathUtils.convertVector3DtoPt(_loc10_.position),ZGlobal.cellSize);
               _loc12_ = _loc11_.x;
               _loc13_ = _loc11_.y;
               _loc14_ = _loc11_.x + _loc9_.gameData.sizeX;
               _loc15_ = _loc11_.y - _loc9_.gameData.sizeY;
               if(!(_loc12_ <= param1 && param1 <= _loc14_) && !(_loc13_ <= param2 && param2 <= _loc15_))
               {
                  if(!(_loc12_ <= param1 + param3 && param1 + param3 <= _loc14_) && !(_loc13_ <= param2 && param2 <= _loc15_))
                  {
                     if(!(_loc12_ <= param1 && param1 <= _loc14_) && !(_loc13_ <= param2 + param4 && param2 + param4 <= _loc15_))
                     {
                        if(!(_loc12_ <= param1 + param3 && param1 + param3 <= _loc14_) && !(_loc13_ <= param2 + param4 && param2 + param4 <= _loc15_))
                        {
                           _loc5_ = true;
                        }
                     }
                  }
               }
            }
         }
         return _loc5_;
      }
      
      private function disposeHookEntity() : void
      {
         if(this.m_hookEntity)
         {
            WorldObjectManager.instance.removeObject(this.m_item.type,this.m_item.subType,this.m_hookEntity.name,this.m_item.code,this.m_item.categoryLimitName);
            BuildManager.instance.alwaysGetObject(null);
            this.m_hookEntity.destroy();
            this.m_hookEntity = null;
         }
         this.m_item = null;
      }
      
      public function showScreen() : void
      {
         var _loc1_:MiniSeriesDifficultyMode = null;
         var _loc2_:Class = null;
         if(this.difficultyModeEnabled && ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(this.id)["difficultyMode"] == undefined)
         {
            _loc1_ = new MiniSeriesDifficultyMode(this.id,this.m_xml.difficultyMode.@url);
            PopupManager.instance.push(_loc1_);
         }
         else
         {
            if(this.m_xml.screen.@className != undefined)
            {
               _loc2_ = getDefinitionByName("displays.screens.questTreeScreen." + this.m_xml.screen.@className) as Class;
            }
            else
            {
               _loc2_ = getDefinitionByName("displays.screens.questTreeScreen." + this.m_xml.ui.mainScreen.@className) as Class;
            }
            WindowManager.instance.push(new _loc2_(this.id));
         }
      }
      
      public function hasEndTask() : Boolean
      {
         var _loc1_:XML = null;
         for each(_loc1_ in this.nodes)
         {
            if(_loc1_.@end != undefined)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getFirstActiveQuest() : String
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:ZGameQuestManager = null;
         var _loc1_:String = null;
         if(Boolean(this.m_xml) && Boolean(this.m_xml.node))
         {
            for each(_loc2_ in this.m_xml.node)
            {
               if(_loc2_.@quest != undefined)
               {
                  _loc3_ = _loc2_.@quest.toString();
                  _loc4_ = QuestManager.getInstance() as ZGameQuestManager;
                  if(_loc4_.isQuestActive(_loc3_))
                  {
                     _loc1_ = _loc3_;
                     break;
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function get isQuestTreeDialogActive() : Boolean
      {
         return this.m_isQuestTreeDialogActive;
      }
      
      public function setquestTreeDialogActive(param1:Boolean) : void
      {
         this.m_isQuestTreeDialogActive = param1;
      }
      
      public function get rewardQuestNames() : Array
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:Array = new Array();
         if(Boolean(this.m_xml) && Boolean(this.m_xml.node))
         {
            for each(_loc2_ in this.m_xml.node)
            {
               if(_loc2_.@quest != undefined)
               {
                  _loc3_ = _loc2_.@quest.toString();
                  if(_loc3_.indexOf("reward") > 0)
                  {
                     _loc1_.push(_loc3_);
                  }
               }
            }
         }
         return _loc1_;
      }
   }
}

