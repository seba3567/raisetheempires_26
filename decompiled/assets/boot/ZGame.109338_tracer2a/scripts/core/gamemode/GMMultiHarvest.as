package core.gamemode
{
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.avatar.GMAvatar;
   import core.managers.BuildManager;
   import core.managers.ExperimentsManager;
   import core.ui.PickManager;
   import core.ui.actionfeedback.EnergyActionFeedback;
   import core.ui.menuitem.OptionUIItem;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import transactions.TMultiHarvest;
   import utils.TextFieldUtil;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class GMMultiHarvest extends GMAvatar
   {
      
      private static var m_pvpWarningSeen:Boolean;
      
      public static var HARVEST_ENABLED:String = "notHarvestable";
      
      public static var MODE_DISABLED:String = "modeDisabled";
      
      public static var POLL:String = "poll";
      
      public static var CLICKED:String = "clicked";
      
      private static var MULTIHARVEST_ENABLED_VARIANT:int = 2;
      
      private var m_currentPos:Point;
      
      private var m_rect:IsoOutlineRect;
      
      private var m_pvpInfluence:Boolean;
      
      private var m_energyTotal:int;
      
      private var m_objIDs:Array = new Array();
      
      private var m_status:String = "";
      
      private var m_statusMC:MovieClip;
      
      public function GMMultiHarvest()
      {
         var _loc1_:Array = [Cursor_MultiHarvest];
         super();
      }
      
      public static function get multiHarvestEnabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_multi_harvester");
         return _loc1_ >= MULTIHARVEST_ENABLED_VARIANT;
      }
      
      private static function harvestAreaCenterToRoot(param1:Point) : Point
      {
         var _loc2_:int = harvestAreaSize;
         var _loc3_:Point = new Point();
         _loc3_.x = param1.x - Math.floor(_loc2_ * 0.5);
         _loc3_.y = param1.y - Math.floor(_loc2_ * 0.5);
         return _loc3_;
      }
      
      private static function get harvestAreaSize() : int
      {
         return ZGlobal.gameSettings.getInt("MultiHarvestGridSize",5);
      }
      
      public function registerEnergy(param1:int, param2:Boolean, param3:int) : void
      {
         if(param1 < 0)
         {
            this.m_pvpInfluence = this.m_pvpInfluence || param2;
            this.m_energyTotal += param1;
            this.m_objIDs.push(param3);
         }
      }
      
      override public function focusLost() : void
      {
         this.updateStatus("");
         this.disposeRect();
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         PickManager.picksEnabled = false;
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         UIDispatcher.instance.addEventListener(HARVEST_ENABLED,this.onHarvestEnabled,false,0,true);
      }
      
      override public function disableMode() : void
      {
         this.disposeStatusText();
         this.disposeRect();
         UIDispatcher.instance.removeEventListener(HARVEST_ENABLED,this.onHarvestEnabled);
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
         UIDispatcher.instance.dispatchEvent(new Event(MODE_DISABLED));
         PickManager.picksEnabled = true;
         super.disableMode();
      }
      
      override protected function canBeClicked(param1:MouseEvent) : Boolean
      {
         return false;
      }
      
      override protected function doHandleMouseMove(param1:Point) : void
      {
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:Point = this.currentTilePos;
         if(!this.m_currentPos || (_loc2_.x != this.m_currentPos.x || _loc2_.y != this.m_currentPos.y))
         {
            if(!this.m_rect)
            {
               _loc4_ = harvestAreaSize;
               this.m_rect = new IsoOutlineRect(_loc4_,_loc4_);
               updateCursor();
            }
            this.m_currentPos = _loc2_.clone();
            this.dispatchEvent(POLL,this.m_currentPos);
            _loc3_ = harvestAreaCenterToRoot(this.m_currentPos);
            this.m_rect.setPosition(_loc3_);
            if(this.validLocation(_loc3_) && Boolean(this.m_objIDs.length))
            {
               this.m_rect.setColor(255,true);
               this.m_energyTotal = Math.abs(this.m_energyTotal);
               _loc5_ = this.getDiscountedEnergyCost(this.m_energyTotal);
               _loc6_ = this.getStatusString(this.m_objIDs.length,_loc5_,this.m_energyTotal);
               this.updateStatus(_loc6_);
            }
            else
            {
               this.m_rect.setColor(16711680,true);
               this.updateStatus("");
            }
         }
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         if(this.m_currentPos)
         {
            _loc2_ = harvestAreaCenterToRoot(this.m_currentPos);
            if(this.validLocation(_loc2_))
            {
               this.doMultiHarvest({"pos":this.m_currentPos});
            }
         }
      }
      
      override protected function getCursor() : Object
      {
         return new Cursor_MultiHarvest(1,1);
      }
      
      private function doMultiHarvest(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:GenericPopup2B = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         var _loc8_:TMultiHarvest = null;
         var _loc9_:Vector3D = null;
         var _loc10_:EnergyActionFeedback = null;
         var _loc4_:Point = param1.pos;
         this.dispatchEvent(POLL,_loc4_);
         if(this.m_objIDs.length)
         {
            if(!m_pvpWarningSeen && this.m_pvpInfluence)
            {
               _loc2_ = ZGameUtils.ZlocT("Dialogs","MultiHarvesterPVPWarning");
               _loc3_ = GenericPopup2B.NewYesNo(_loc2_,null,this.onPVPWarningClosed);
               _loc3_.userData = param1;
               PopupManager.instance.push(_loc3_);
               m_pvpWarningSeen = true;
            }
            else
            {
               _loc5_ = Math.abs(this.m_energyTotal);
               _loc6_ = this.getDiscountedEnergyCost(_loc5_);
               if(ZGlobal.player.m_energy.checkEnergy(_loc6_))
               {
                  BuyEnergyPopup.enableWatchToEarn();
                  BuyEnergyPopup.show();
               }
               else
               {
                  _loc7_ = harvestAreaCenterToRoot(_loc4_);
                  _loc8_ = new TMultiHarvest(this.m_objIDs,_loc7_,_loc5_,_loc6_);
                  TransactionManager.addTransaction(_loc8_);
                  this.dispatchEvent(CLICKED,_loc4_);
                  ZGlobal.player.m_energy.energy -= _loc6_;
                  this.updateStatus("");
                  _loc9_ = new Vector3D(_loc4_.x * ZGlobal.cellSize,_loc4_.y * ZGlobal.cellSize);
                  _loc10_ = new EnergyActionFeedback(_loc9_,-_loc6_);
               }
            }
         }
      }
      
      private function onPVPWarningClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.doMultiHarvest(param1.userData);
         }
      }
      
      private function getDiscountedEnergyCost(param1:int) : int
      {
         var _loc2_:String = ZGlobal.gameSettings.getString("MultiHarvesterPriceScale","1,1,1,0.8");
         var _loc3_:Array = _loc2_.split(",");
         var _loc4_:int = ExperimentsManager.instance.getExperimentVariant("empire_multi_harvester");
         if(_loc4_ >= 0 && _loc4_ < _loc3_.length)
         {
            param1 = Math.ceil(_loc3_[_loc4_] * param1);
         }
         return param1;
      }
      
      private function dispatchEvent(param1:String, param2:Point) : void
      {
         var _loc3_:Point = harvestAreaCenterToRoot(param2);
         var _loc4_:int = harvestAreaSize;
         var _loc5_:Point = new Point(_loc4_,_loc4_);
         var _loc6_:Dictionary = BuildManager.instance.getObjectIDsOverlappingVolume(_loc3_,_loc5_);
         this.m_pvpInfluence = false;
         this.m_energyTotal = 0;
         this.m_objIDs = [];
         UIDispatcher.instance.dispatchEvent(new WorldEvent(param1,{
            "objIDs":_loc6_,
            "gm":this
         }));
      }
      
      private function get currentWorldPos() : Pt
      {
         var _loc1_:Point = new Point(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
         return screenToIso(new Pt(_loc1_.x,_loc1_.y,0));
      }
      
      private function get currentTilePos() : Point
      {
         var _loc1_:Pt = this.currentWorldPos;
         var _loc2_:Point = TileUtil.worldPointToTilePoint(_loc1_);
         _loc2_.x = int(_loc2_.x);
         _loc2_.y = int(_loc2_.y);
         return _loc2_;
      }
      
      private function validLocation(param1:Point) : Boolean
      {
         return true;
      }
      
      private function onHarvestEnabled(param1:WorldEvent) : void
      {
         if(this.m_currentPos)
         {
            this.dispatchEvent(POLL,this.m_currentPos);
         }
      }
      
      private function getStatusString(param1:int, param2:int, param3:int) : String
      {
         var _loc4_:String = param1 == 1 ? "MultiHarvestTooltip_Single" : "MultiHarvestTooltip_Discount";
         var _loc5_:Object = {
            "numBuildings":param1,
            "numEnergy":param2
         };
         return ZGameUtils.ZlocT("Tooltips",_loc4_,_loc5_);
      }
      
      private function updateStatus(param1:String) : void
      {
         var _loc2_:TextField = null;
         if(param1 != this.m_status)
         {
            this.m_status = param1;
            if(!this.m_status || !this.m_status.length)
            {
               this.disposeStatusText();
            }
            else
            {
               if(!this.m_statusMC)
               {
                  this.m_statusMC = new LootText();
                  _loc2_ = this.m_statusMC.text_tf;
                  this.m_statusMC.text_tf.textColor = 6711039;
                  this.m_statusMC.text_tf.scaleX = _loc2_.scaleY = 0.8;
                  Zlab.mainStage.addChild(this.m_statusMC);
                  Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove,false,10,true);
               }
               TextFieldUtil.processSingleLineTextField(this.m_statusMC.text_tf,this.m_status,15);
               this.positionStatus();
            }
         }
      }
      
      private function onStageMouseMove(param1:MouseEvent) : void
      {
         this.positionStatus();
      }
      
      private function positionStatus(param1:Event = null) : void
      {
         if(this.m_statusMC)
         {
            this.m_statusMC.x = Zlab.mainStage.mouseX - this.m_statusMC.width * 0.5;
            this.m_statusMC.y = Zlab.mainStage.mouseY - 30;
         }
      }
      
      private function disposeStatusText() : void
      {
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
         if(this.m_statusMC)
         {
            if(this.m_statusMC.parent)
            {
               this.m_statusMC.parent.removeChild(this.m_statusMC);
            }
            this.m_statusMC = null;
         }
      }
      
      private function disposeRect() : void
      {
         if(this.m_rect)
         {
            this.m_rect.dispose();
            this.m_rect = null;
         }
      }
   }
}

