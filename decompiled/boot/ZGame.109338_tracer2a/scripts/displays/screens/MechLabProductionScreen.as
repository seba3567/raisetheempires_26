package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import displays.screens.contractScreen.ContractSlot;
   import displays.screens.contractScreen.TitanContractGrid;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class MechLabProductionScreen extends MechLabScreen
   {
      
      private var m_resource:SWFResource = null;
      
      private var m_grid:TitanContractGrid = null;
      
      private var m_tabData:Array = null;
      
      private var m_requiredUnitType:String = null;
      
      private var m_currentlySelectedTab:uint = 4294967295;
      
      public function MechLabProductionScreen(param1:EventDispatcher, param2:IEntity, param3:String = "assets/displays/screens/MechLabMain.swf")
      {
         super(param1,param2,ZGlobal.getAssetURL(param3));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity) : PopUpBase
      {
         var _loc3_:PopUpBase = null;
         _loc3_ = new MechLabProductionScreen(param1,param2);
         WindowManager.instance.push(_loc3_);
         return _loc3_;
      }
      
      override protected function get kingdom() : String
      {
         return "weapon_screen";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
      }
      
      private function get numTabs() : uint
      {
         return 3;
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_grid = new TitanContractGrid(screen.buildPanel_mc,this.m_resource,this,stateEntity,"Buildable","army",["mega",this.currentRequiredUnitType]);
         this.initTabs();
         this.initText();
         addEventListener(ContractSlot.CONTRACT_SLOT_PURCHASE,this.onContractSlotPurchase,false,0,true);
         screen.buildPanel_mc.mouseEnabled = false;
         screen.buildPanel_mc.mouseChildren = true;
         screen.buildPanel_mc.frame_mc.mouseEnabled = false;
      }
      
      private function initTabs() : void
      {
         var _loc2_:Object = null;
         var _loc3_:MovieClip = null;
         this.m_tabData = [{
            "tabClip":this.panel.tab01_mc,
            "mechClips":[screen.mech2_mc.mechItemHead_mc],
            "text":ZGameUtils.ZlocT("Dialogs","MechLabProductionTab1"),
            "requiredUnitType":"controller"
         },{
            "tabClip":this.panel.tab02_mc,
            "mechClips":[screen.mech2_mc.mechItemArmRight_mc,screen.mech2_mc.mechItemArmLeft_mc],
            "text":ZGameUtils.ZlocT("Dialogs","MechLabProductionTab2"),
            "requiredUnitType":"arm"
         },{
            "tabClip":this.panel.tab03_mc,
            "mechClips":[screen.mech2_mc.mechItemShoulderRight2_mc,screen.mech2_mc.mechItemShoulderLeft2_mc],
            "text":ZGameUtils.ZlocT("Dialogs","MechLabProductionTab3"),
            "requiredUnitType":"shoulder"
         }];
         var _loc1_:uint = 0;
         while(_loc1_ < this.numTabs)
         {
            _loc2_ = this.m_tabData[_loc1_];
            _loc2_.tabClip.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
            _loc2_.tabClip.addEventListener(MouseEvent.MOUSE_OVER,this.onTabOver,false,0,true);
            _loc2_.tabClip.addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
            for each(_loc3_ in _loc2_.mechClips)
            {
               _loc3_.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
               _loc3_.addEventListener(MouseEvent.MOUSE_OVER,this.onTabOver,false,0,true);
               _loc3_.addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
            }
            _loc1_++;
         }
         this.currentTab = 0;
      }
      
      private function initText() : void
      {
         TextFieldUtil.compactTextField(screen.screenTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabProductionTitle",{"titanName":ZGlobal.player.titanName}));
      }
      
      override protected function initUI() : void
      {
         screen.partsPanel_mc.visible = false;
         screen.mech_mc.visible = false;
         screen.badges_mc.visible = false;
         screen.complete_mc.visible = false;
         screen.comingSoon_mc.visible = false;
         screen.finish_bt.visible = false;
         screen.activationPanel_mc.visible = false;
         screen.leftPanel_mc.activate_bt.visible = false;
         screen.leftPanel_mc.screenDesc_mc.visible = false;
         screen.buildPanel_mc.visible = true;
         screen.mech2_mc.visible = true;
      }
      
      override protected function deinitDialog() : void
      {
         removeEventListener(ContractSlot.CONTRACT_SLOT_PURCHASE,this.onContractSlotPurchase);
         this.deinitTabs();
         this.m_grid.dispose();
         this.m_grid = null;
         super.deinitDialog();
      }
      
      private function deinitTabs() : void
      {
         var _loc2_:Object = null;
         var _loc3_:MovieClip = null;
         var _loc1_:uint = 0;
         while(_loc1_ < this.numTabs)
         {
            _loc2_ = this.m_tabData[_loc1_];
            _loc2_.tabClip.removeEventListener(MouseEvent.MOUSE_OUT,this.onTabOut);
            _loc2_.tabClip.removeEventListener(MouseEvent.MOUSE_OVER,this.onTabOver);
            _loc2_.tabClip.removeEventListener(MouseEvent.CLICK,this.onTabClick);
            for each(_loc3_ in _loc2_.mechClips)
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OUT,this.onTabOut);
               _loc3_.removeEventListener(MouseEvent.MOUSE_OVER,this.onTabOver);
               _loc3_.removeEventListener(MouseEvent.CLICK,this.onTabClick);
            }
            _loc1_++;
         }
      }
      
      override protected function get panel() : MovieClip
      {
         return screen.buildPanel_mc;
      }
      
      private function get currentRequiredUnitType() : String
      {
         return this.m_requiredUnitType;
      }
      
      private function set currentRequiredUnitType(param1:String) : void
      {
         this.m_requiredUnitType = param1;
         this.m_grid.requiredUnitTypes = ["mega",this.m_requiredUnitType];
      }
      
      private function getIndexForClip(param1:MovieClip) : uint
      {
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc2_:uint = 0;
         loop0:
         while(_loc2_ < this.numTabs)
         {
            _loc3_ = this.m_tabData[_loc2_];
            if(_loc3_.tabClip == param1)
            {
               return _loc2_;
            }
            var _loc5_:int = 0;
            var _loc6_:* = _loc3_.mechClips;
            do
            {
               for each(_loc4_ in _loc6_)
               {
               }
               _loc2_++;
               continue loop0;
            }
            while(_loc4_ != param1);
            return _loc2_;
         }
         return uint.MAX_VALUE;
      }
      
      private function getIndexForMechClip(param1:MovieClip) : uint
      {
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc2_:uint = 0;
         loop0:
         while(_loc2_ < this.numTabs)
         {
            _loc3_ = this.m_tabData[_loc2_];
            var _loc5_:int = 0;
            var _loc6_:* = _loc3_.mechClips;
            do
            {
               for each(_loc4_ in _loc6_)
               {
               }
               _loc2_++;
               continue loop0;
            }
            while(_loc4_ != param1);
            return _loc2_;
         }
         return uint.MAX_VALUE;
      }
      
      private function onTabOut(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc2_:uint = this.getIndexForClip(param1.currentTarget as MovieClip);
         if(_loc2_ != this.currentTab)
         {
            _loc3_ = this.m_tabData[_loc2_];
            (_loc3_.tabClip as MovieClip).gotoAndStop(1);
            TextFieldUtil.processTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
            for each(_loc4_ in _loc3_.mechClips)
            {
               _loc4_.gotoAndStop("up");
            }
         }
      }
      
      private function onTabOver(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc2_:uint = this.getIndexForClip(param1.currentTarget as MovieClip);
         if(_loc2_ != this.currentTab)
         {
            _loc3_ = this.m_tabData[_loc2_];
            (_loc3_.tabClip as MovieClip).gotoAndStop(2);
            TextFieldUtil.processTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
            for each(_loc4_ in _loc3_.mechClips)
            {
               _loc4_.gotoAndStop("over");
            }
         }
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         var _loc2_:uint = this.getIndexForClip(param1.currentTarget as MovieClip);
         if(_loc2_ != this.currentTab)
         {
            this.currentTab = _loc2_;
         }
      }
      
      private function get currentTab() : uint
      {
         return this.m_currentlySelectedTab;
      }
      
      private function set currentTab(param1:uint) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         if(this.m_currentlySelectedTab != param1)
         {
            if(param1 < this.numTabs)
            {
               _loc2_ = 0;
               while(_loc2_ < this.numTabs)
               {
                  _loc3_ = this.m_tabData[_loc2_];
                  if(_loc2_ == param1)
                  {
                     _loc3_.tabClip.gotoAndStop(4);
                     TextFieldUtil.processTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
                     for each(_loc4_ in _loc3_.mechClips)
                     {
                        _loc4_.gotoAndStop("hit");
                     }
                     this.currentRequiredUnitType = _loc3_.requiredUnitType;
                  }
                  else
                  {
                     _loc3_.tabClip.gotoAndStop(1);
                     TextFieldUtil.processTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
                     for each(_loc4_ in _loc3_.mechClips)
                     {
                        _loc4_.gotoAndStop("up");
                     }
                  }
                  _loc2_++;
               }
               this.m_currentlySelectedTab = param1;
            }
         }
      }
      
      override protected function get currentActivationStage() : uint
      {
         return 4;
      }
      
      protected function onContractSlotPurchase(param1:WorldEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc2_:GameItem = param1.eventData as GameItem;
         if(_loc2_)
         {
            _loc3_ = false;
            _loc4_ = false;
            if(_loc2_.usesCashOnly())
            {
               _loc3_ = ZGlobal.player.canBuyCash(_loc2_.cash,true);
               _loc4_ = !_loc3_;
            }
            else
            {
               _loc3_ = ZGlobal.player.canBuy(_loc2_,true);
            }
            if(_loc3_)
            {
               dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONTRACT,_loc2_.name,MarketEvent.SOURCE_NONE));
               WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ITEM_PURCHASED,_loc2_.code));
               close();
            }
            else if(_loc4_)
            {
               close();
            }
         }
      }
      
      override protected function get hasConsumablePanel() : Boolean
      {
         return true;
      }
   }
}

