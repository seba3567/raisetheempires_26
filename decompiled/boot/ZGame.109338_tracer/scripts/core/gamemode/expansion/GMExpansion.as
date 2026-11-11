package core.gamemode.expansion
{
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.GridPointer;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.BuildManager;
   import core.managers.ExperimentsManager;
   import core.managers.PriceTestManager;
   import core.ui.PlayerFeedbackManager;
   import core.ui.menuitem.OptionUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import events.ExpansionEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import transactions.TBuyExpansion;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.utils.MathUtils;
   
   public class GMExpansion extends GMIsland
   {
      
      private var m_gameItem:ExpansionItem = null;
      
      private var m_lastValidIndex:int = -1;
      
      private var m_didPurchase:Boolean = false;
      
      private var m_discountInfo:Object;
      
      public function GMExpansion(param1:ExpansionItem, param2:Object = null)
      {
         super();
         this.m_gameItem = param1;
         this.m_didPurchase = false;
         this.m_discountInfo = param2;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         GridPointer.instance.useLargeCursor = true;
         GridPointer.instance.snapScale = 8;
         GridPointer.instance.reposition = false;
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         onMouseMove(null);
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         if(!this.m_didPurchase)
         {
            ZGlobal.player.refundMultiRequirementItem(ZGlobal.player.multiRequirementItemInfo);
         }
         this.m_gameItem = null;
         GridPointer.instance.useLargeCursor = false;
         GridPointer.instance.snapScale = 1;
         GridPointer.instance.reposition = true;
         GridPointer.instance.valid = true;
         GridPointer.instance.update();
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:GenericPopup = null;
         var _loc4_:Pt = null;
         var _loc5_:Vector3D = null;
         if(this.m_lastValidIndex >= 0)
         {
            if(ZGlobal.player.canBuy(this.m_gameItem,true))
            {
               _loc2_ = ZGameUtils.ZlocT("Dialogs","Expansion_Confirm");
               _loc3_ = GenericPopup2B.NewAcceptCancel(_loc2_,null,this.onConfirmPopupClose);
               _loc3_.setAcceptTextName("Expansion_Accept");
               _loc3_.setCancelTextName("Expansion_Cancel");
               PopupManager.instance.push(_loc3_);
            }
         }
         else
         {
            _loc4_ = GridPointer.instance.convertScreenCoordsToGrid(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
            _loc5_ = new Vector3D(_loc4_.x,_loc4_.y);
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","Error_IllegalToExpand"),_loc5_,ZGameUtils.ZlocT("Main","Error_IllegalToExpandMessage"));
         }
      }
      
      private function onConfirmPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyExpansion();
         }
      }
      
      private function buyExpansion() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = true;
         ZGlobal.player.buyMultiRequirementItem(ZGlobal.player.multiRequirementItemInfo,_loc1_,_loc2_);
         ZGlobal.player.multiRequirementItemInfo = null;
         this.m_didPurchase = true;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(_loc5_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            if(this.m_gameItem.isCrewableExpansion())
            {
               _loc4_ = true;
            }
            else if(this.m_gameItem.isCashExpansion())
            {
               _loc3_ = true;
            }
         }
         ZGlobal.player.buyItem(this.m_gameItem,_loc3_,1,null,false,this.m_discountInfo);
         ZGlobal.player.expansions.setBit(this.m_lastValidIndex);
         var _loc6_:Boolean = Boolean(this.m_discountInfo) && Boolean(this.m_discountInfo.impulseBuy);
         var _loc7_:String = _loc6_ ? PriceTestManager.ADDITIONALTYPE_IMPULSE : null;
         TransactionManager.addTransaction(new TBuyExpansion(this.m_gameItem.code,_loc3_,this.m_lastValidIndex,_loc7_),true);
         var _loc8_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         _loc8_.updateExpansion(ZGlobal.player.expansions);
         if(_loc4_)
         {
            UIDispatcher.instance.dispatchEvent(new ExpansionEvent(ExpansionEvent.EXPANSION_TYPE_CREW,0,this.m_gameItem.code));
         }
         else if(_loc3_)
         {
            UIDispatcher.instance.dispatchEvent(new ExpansionEvent(ExpansionEvent.EXPANSION_TYPE_CASH,0,this.m_gameItem.code));
         }
         else
         {
            UIDispatcher.instance.dispatchEvent(new ExpansionEvent(ExpansionEvent.EXPANSION_TYPE_COIN,0,this.m_gameItem.code));
         }
         var _loc9_:Object = {
            "expansionIndex":this.m_lastValidIndex,
            "expansionItemCode":this.m_gameItem.code
         };
         onExitMode(null);
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.EXPANSION_PURCHASED,_loc9_));
      }
      
      override protected function doHandleMouseMove(param1:Point) : void
      {
         var _loc2_:Pt = GridPointer.instance.convertScreenCoordsToGrid(param1.x,param1.y);
         GridPointer.instance.setPosition(_loc2_.x,_loc2_.y);
         _loc2_.x /= ZGlobal.cellSize;
         _loc2_.y /= ZGlobal.cellSize;
         var _loc3_:uint = MathUtils.gridToExpansionIndex(_loc2_.x / 4,_loc2_.y / 4,BuildManager.instance.width);
         _loc3_ = this.getClosestValidIndex(_loc3_);
         var _loc4_:Pt = MathUtils.expansionIndexToGrid(_loc3_,BuildManager.instance.width);
         _loc4_.x *= 8;
         _loc4_.y *= 8;
         GridPointer.instance.setPosition(_loc4_.x * ZGlobal.cellSize,_loc4_.y * ZGlobal.cellSize);
      }
      
      private function getValidCompassIndex(param1:uint, param2:Array, param3:uint) : int
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:uint = param3 * param3;
         for each(_loc5_ in param2)
         {
            _loc6_ = param1 + _loc5_;
            if(_loc6_ >= 0 && _loc6_ < _loc4_ && ZGlobal.player.expansions.isBitSet(_loc6_))
            {
               return param1;
            }
         }
         return -1;
      }
      
      private function getClosestValidIndex(param1:uint) : uint
      {
         var _loc2_:Boolean = ZGlobal.player.expansions.isBitSet(param1);
         GridPointer.instance.valid = _loc2_ == false;
         if(_loc2_)
         {
            this.m_lastValidIndex = -1;
            return param1;
         }
         var _loc3_:uint = BuildManager.instance.width / 8;
         var _loc4_:Array = [1,-1,_loc3_,-_loc3_];
         var _loc5_:int = this.getValidCompassIndex(param1,_loc4_,_loc3_);
         if(_loc5_ >= 0)
         {
            this.m_lastValidIndex = _loc5_;
            return _loc5_;
         }
         var _loc6_:uint = _loc3_ * _loc3_;
         var _loc7_:Boolean = false;
         var _loc8_:uint = _loc3_ / 2;
         var _loc9_:uint = _loc8_ * _loc3_ + _loc8_;
         var _loc10_:uint = 0;
         var _loc11_:int = 1;
         if(param1 % _loc3_ >= _loc8_)
         {
            _loc11_ = -1;
         }
         _loc10_ = param1;
         while(_loc10_ % _loc3_ + _loc11_ > 0 && _loc10_ % _loc3_ + _loc11_ < _loc3_)
         {
            if(ZGlobal.player.expansions.isBitSet(_loc10_ + _loc11_))
            {
               _loc7_ = true;
               param1 = _loc10_;
               this.m_lastValidIndex = _loc10_;
               break;
            }
            _loc10_ += _loc11_;
         }
         if(!_loc7_)
         {
            if(_loc10_ > _loc9_)
            {
               _loc11_ = -_loc3_;
            }
            else
            {
               _loc11_ = int(_loc3_);
            }
            _loc10_ = param1;
            while(_loc10_ + _loc11_ > 0 && _loc10_ + _loc11_ < _loc6_)
            {
               if(ZGlobal.player.expansions.isBitSet(_loc10_ + _loc11_))
               {
                  _loc7_ = true;
                  param1 = _loc10_;
                  this.m_lastValidIndex = _loc10_;
                  break;
               }
               _loc10_ += _loc11_;
            }
         }
         if(!_loc7_)
         {
            if(this.m_lastValidIndex >= 0)
            {
               param1 = uint(this.m_lastValidIndex);
            }
            else
            {
               GridPointer.instance.valid = false;
            }
         }
         return param1;
      }
   }
}

