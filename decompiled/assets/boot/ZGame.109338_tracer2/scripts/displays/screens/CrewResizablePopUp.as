package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class CrewResizablePopUp extends SWFPopUp
   {
      
      public static const BUILT:String = "built";
      
      public static const CLOSED:String = "closed";
      
      public static const SLOT_BOUGHT:String = "bought";
      
      public static const SLOT_CLICKED:String = "clicked";
      
      public static const SLOT_FULL_CLICKED:String = "slotFullClicked";
      
      private static var DIALOG_MIN_WIDTH:int = 550;
      
      protected var m_mc:MovieClip;
      
      protected var m_wrapper:CrewTemplateWrapper;
      
      protected var m_crewInfo:Array;
      
      protected var m_crewReplaceCount:int;
      
      protected var m_fixedButtonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      protected var m_confirmButton:ZGameButton = null;
      
      private var m_buyPopup:GenericPopup2B = null;
      
      protected var m_slotCards:Array = new Array();
      
      protected var m_slotContainer:Sprite = new Sprite();
      
      protected var m_slotClass:Class;
      
      protected var CARD_SPACING_HORIZONTAL:int = 15;
      
      protected var CARD_SPACING_VERTICAL:int = 0;
      
      public function CrewResizablePopUp(param1:CrewTemplateWrapper, param2:Array, param3:Class)
      {
         this.m_wrapper = param1;
         this.m_crewInfo = param2;
         this.m_slotClass = param3;
         super(ZGlobal.getAssetURL(this.getAsset()));
         addEventListener(SLOT_BOUGHT,this.onSlotBought,false,0,true);
         addEventListener(SLOT_CLICKED,this.onSlotClicked,false,0,true);
         addEventListener(SLOT_FULL_CLICKED,this.onSlotFullClicked,false,0,true);
         CrewManager.instance.addEventListener(CrewManager.CREW_UPDATED,this.onCrewUpdated);
      }
      
      private function onCrewUpdated(param1:WorldEvent) : void
      {
         if(Boolean(param1) && Boolean(param1.eventData))
         {
            this.m_crewInfo = param1.eventData.crew;
         }
         this.updateElements();
      }
      
      protected function getAsset() : String
      {
         return null;
      }
      
      protected function onWidthSet(param1:uint) : void
      {
      }
      
      protected function get mc() : MovieClip
      {
         return this.m_mc;
      }
      
      protected function get dialogPaddingTop() : uint
      {
         return 100;
      }
      
      protected function get dialogPaddingBottom() : uint
      {
         return 30;
      }
      
      protected function get dialogPaddingLeft() : uint
      {
         return 50;
      }
      
      protected function get dialogPaddingRight() : uint
      {
         return 50;
      }
      
      protected function showConfirmButton() : Boolean
      {
         return true;
      }
      
      protected function get actionButtonMC() : MovieClip
      {
         return this.m_mc.build_bt;
      }
      
      protected function get centerDescription() : Boolean
      {
         return true;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc8_:int = 0;
         var _loc2_:Class = param1.getAssetClass("crew_mc");
         var _loc3_:Class = param1.getAssetClass("crewCard");
         this.m_mc = new _loc2_();
         if(this.m_mc.build_bt)
         {
            this.m_mc.build_bt.visible = false;
         }
         if(this.m_mc.build_bt2)
         {
            this.m_mc.build_bt2.visible = false;
         }
         if(this.m_mc.header_tf)
         {
            this.m_mc.header_tf.visible = false;
         }
         if(this.m_mc.title_tf)
         {
            this.m_mc.title_tf.mouseEnabled = false;
         }
         this.m_slotCards = this.createSlotCards(_loc3_);
         var _loc4_:Point = new Point(this.m_slotCards[0].width,this.m_slotCards[0].height);
         var _loc5_:int = this.m_wrapper.numPositions;
         var _loc6_:Point = this.getGridLayout(_loc5_);
         var _loc7_:Point = this.getGridLayoutDimensions(_loc6_,_loc4_);
         _loc8_ = _loc7_.y + this.dialogPaddingTop + this.dialogPaddingBottom;
         var _loc9_:int = _loc7_.x + this.dialogPaddingLeft + this.dialogPaddingRight;
         var _loc10_:uint = uint(this.m_mc.panel_mc.width);
         if(this.resize)
         {
            _loc9_ = Math.max(_loc9_,DIALOG_MIN_WIDTH);
            this.dialogWidth = _loc9_;
            this.dialogHeight = _loc8_;
         }
         this.onWidthSet(_loc10_);
         this.m_slotContainer.mouseEnabled = false;
         this.m_slotContainer.x = (_loc9_ - _loc7_.x) * 0.5;
         this.m_slotContainer.y = this.dialogPaddingTop;
         this.m_mc.addChild(this.m_slotContainer);
         if(this.resize)
         {
            contentWidth = this.dialogWidth;
            contentHeight = _loc8_;
         }
         else
         {
            contentWidth = this.dialogWidth;
            contentHeight = this.dialogHeight;
         }
         if(this.showConfirmButton())
         {
            this.initConfirmButtonMC();
            this.m_confirmButton = new ZGameButton(this.actionButtonMC,this.onConfirmClick);
            this.m_fixedButtonSounds.addButton(this.m_confirmButton.m_overlay,ButtonSound.DEFAULT);
         }
         this.initDialog();
         if(this.m_mc.exit_bt)
         {
            this.m_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
            this.m_fixedButtonSounds.addButton(this.m_mc.exit_bt,ButtonSound.DEFAULT);
            this.initExitButton();
            addChild(this.m_mc);
         }
         dispatchEvent(new Event(Event.COMPLETE));
         this.setupText();
         if(this.resize)
         {
            if(this.m_mc.title_tf)
            {
               this.m_mc.title_tf.width = this.dialogWidth;
            }
            if(this.centerDescription && Boolean(this.m_mc.description_tf))
            {
               this.centerHorizontally(this.m_mc.description_tf);
            }
            if(this.m_mc.title_tf)
            {
               this.centerHorizontally(this.m_mc.title_tf);
            }
         }
         this.initSlotCards(_loc6_,_loc4_);
      }
      
      protected function get resize() : Boolean
      {
         return true;
      }
      
      protected function setupText() : void
      {
      }
      
      private function updateCards() : void
      {
         var _loc1_:int = 0;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         while(_loc1_ < this.m_slotCards.length)
         {
            this.m_slotCards[_loc1_].update(this.m_crewInfo[_loc1_],this.m_buttonSounds);
            _loc1_++;
         }
      }
      
      override protected function initDialog() : void
      {
         this.updateElements();
         super.initDialog();
      }
      
      protected function updateElements() : void
      {
         this.updateCards();
         this.updateConfirmButton();
      }
      
      protected function get numStaff() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.m_crewInfo)
         {
            while(_loc2_ < this.m_crewInfo.length)
            {
               if(this.m_crewInfo[_loc2_])
               {
                  _loc1_++;
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      protected function canFinishBuilding() : Boolean
      {
         return this.numStaff >= this.m_wrapper.numPositions;
      }
      
      protected function updateConfirmButton() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(this.m_confirmButton)
         {
            _loc1_ = this.getButtonTextKey();
            _loc2_ = ZGameUtils.ZlocTP("Dialogs",_loc1_);
            this.m_confirmButton.compactText(_loc2_,{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
      }
      
      protected function getButtonTextKey() : String
      {
         return null;
      }
      
      protected function onConfirmClick(param1:MouseEvent) : void
      {
         if(this.canFinishBuilding())
         {
            this.onConfirmFinish();
            this.closeWindow(param1);
         }
         else
         {
            this.showHireController();
         }
      }
      
      protected function onConfirmFinish() : void
      {
      }
      
      protected function showHireController() : void
      {
         this.closeWindow(null);
      }
      
      protected function exitButtonClicked(param1:MouseEvent) : void
      {
         this.m_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         this.closeWindow(param1);
      }
      
      protected function closeWindow(param1:MouseEvent) : void
      {
         this.deinitDialog();
         if(param1)
         {
            param1.stopPropagation();
         }
         close();
         dispatchEvent(new Event(CLOSED));
      }
      
      private function buyStaffConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyStaff(param1.userData.cash,param1.userData.index);
         }
         this.m_buyPopup = null;
      }
      
      protected function buyStaff(param1:int, param2:int) : void
      {
      }
      
      private function disposeCards() : void
      {
         var _loc1_:CrewGatherSlot = null;
         for each(_loc1_ in this.m_slotCards)
         {
            if(_loc1_.parent)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
            _loc1_.dispose();
         }
         this.m_slotCards = null;
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_buttonSounds.release();
         this.m_fixedButtonSounds.release();
         removeEventListener(SLOT_BOUGHT,this.onSlotBought);
         removeEventListener(SLOT_CLICKED,this.onSlotClicked);
         CrewManager.instance.removeEventListener(CrewManager.CREW_UPDATED,this.onCrewUpdated);
         this.disposeCards();
         if(this.m_slotContainer.parent)
         {
            this.m_slotContainer.parent.removeChild(this.m_slotContainer);
         }
         if(this.m_confirmButton != null)
         {
            this.m_confirmButton.dispose();
            this.m_confirmButton = null;
         }
      }
      
      protected function hideCards() : void
      {
         var _loc1_:CrewGatherSlot = null;
         for each(_loc1_ in this.m_slotCards)
         {
            _loc1_.visible = false;
         }
      }
      
      protected function hideEmptyCards() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_slotCards.length)
         {
            if(this.m_crewInfo[_loc1_])
            {
               this.m_slotCards[_loc1_].visible = true;
            }
            else
            {
               this.m_slotCards[_loc1_].visible = false;
            }
            _loc1_++;
         }
      }
      
      protected function showCards() : void
      {
         var _loc1_:CrewGatherSlot = null;
         for each(_loc1_ in this.m_slotCards)
         {
            _loc1_.visible = true;
         }
      }
      
      protected function getGridLayout(param1:int) : Point
      {
         if(param1 <= 3)
         {
            return new Point(param1,1);
         }
         if(param1 <= 6)
         {
            return new Point(3,2);
         }
         if(param1 <= 8)
         {
            return new Point(4,2);
         }
         return new Point(4,3);
      }
      
      protected function getGridLayoutDimensions(param1:Point, param2:Point) : Point
      {
         var _loc3_:int = param2.x;
         var _loc4_:int = param2.y;
         if(param1.x > 1)
         {
            _loc3_ *= param1.x;
            _loc3_ += (param1.x - 1) * this.CARD_SPACING_HORIZONTAL;
         }
         if(param1.y > 1)
         {
            _loc4_ *= param1.y;
            _loc4_ = _loc4_ + (param1.y - 1) * this.CARD_SPACING_VERTICAL;
         }
         return new Point(_loc3_,_loc4_);
      }
      
      public function getPlayerInSlot(param1:int) : Player
      {
         if(param1 >= this.m_crewInfo.length)
         {
            return null;
         }
         return ZGlobal.player.findFriendById(this.m_crewInfo[param1]);
      }
      
      protected function createSlotCards(param1:Class) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:CrewGatherSlot = null;
         var _loc2_:Array = new Array();
         while(_loc3_ < this.m_wrapper.numPositions)
         {
            _loc4_ = new this.m_slotClass(this,param1,_loc3_,this.m_wrapper);
            this.m_slotContainer.addChild(_loc4_);
            _loc2_.push(_loc4_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function initConfirmButtonMC() : void
      {
         var _loc1_:int = 0;
         if(this.resize)
         {
            _loc1_ = this.dialogHeight;
            _loc1_ -= this.actionButtonMC.height * 0.5;
            this.centerHorizontally(this.actionButtonMC);
            this.actionButtonMC.y = _loc1_;
         }
         this.actionButtonMC.visible = true;
      }
      
      private function initExitButton() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.resize)
         {
            _loc1_ = this.dialogWidth;
            _loc2_ = 0;
            _loc1_ -= this.m_mc.exit_bt.width;
            this.m_mc.exit_bt.x = _loc1_ + 5;
            this.m_mc.exit_bt.y = _loc2_ - 5;
         }
      }
      
      protected function initSlotCards(param1:Point, param2:Point) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REPLACE_CREW) == ExperimentsManager.VARIANT_VALUE_REPLACE_CREW_ON;
         var _loc6_:int = 0;
         loop0:
         while(_loc6_ < param1.y)
         {
            _loc7_ = 0;
            while(true)
            {
               if(_loc7_ >= param1.x)
               {
                  _loc4_ += param2.y + this.CARD_SPACING_VERTICAL;
                  _loc3_ = 0;
                  _loc6_++;
                  continue loop0;
               }
               _loc8_ = _loc7_ + param1.x * _loc6_;
               if(_loc5_ && ZGlobal.isHome())
               {
                  this.updateSlotCardForReplaceability(this.m_slotCards[_loc8_],_loc8_,this.m_slotCards.length);
               }
               this.m_slotCards[_loc8_].x = _loc3_;
               this.m_slotCards[_loc8_].y = _loc4_;
               _loc3_ += param2.x + this.CARD_SPACING_HORIZONTAL;
               if(++_loc8_ >= this.m_slotCards.length)
               {
                  break;
               }
               _loc7_++;
            }
            return;
         }
      }
      
      private function updateSlotCardForReplaceability(param1:Object, param2:int, param3:int) : void
      {
         var _loc4_:CrewGatherSlot = null;
         if(param1 is CrewGatherSlot && CrewGatherSlot(param1).enableReplaceableTooltip())
         {
            _loc4_ = CrewGatherSlot(param1);
            if(param2 < param3 - this.m_crewReplaceCount)
            {
               _loc4_.setButtonReplaceMode();
            }
            else
            {
               _loc4_.setButtonResendReplaceMode();
            }
         }
      }
      
      private function onSlotClicked(param1:Event) : void
      {
         this.showHireController();
      }
      
      protected function onSlotFullClicked(param1:WorldEvent) : void
      {
      }
      
      private function onSlotBought(param1:WorldEvent) : void
      {
         var _loc3_:CrewGatherSlot = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:int = param1.eventData as int;
         if(_loc2_ < this.m_slotCards.length)
         {
            _loc3_ = this.m_slotCards[_loc2_];
            _loc4_ = _loc3_.cash;
            _loc5_ = _loc3_.positionName;
            if(!_loc4_ || ZGlobal.player.canBuyCash(_loc4_,true))
            {
               if(Boolean(_loc4_) && ZGlobal.gameSettings.showConfirmationPopup(_loc4_))
               {
                  _loc6_ = ZGameUtils.ZlocT("Dialogs","CrewDialogConfirmBuyTitle");
                  _loc7_ = ZGameUtils.ZlocT("Dialogs","CrewDialogConfirmBuyText",{
                     "position":ZGameUtils.ZlocTn(ZGameUtils.ZlocT("Crews",_loc5_ + "_sentenceName",{"user":ZGameUtils.ZlocTn("",ZGlobal.localizer.MASC)}),ZGlobal.localizer.MASC),
                     "amount":_loc4_,
                     "cash":ZGameUtils.ZlocTk("Objects","cash","",_loc4_)
                  });
                  this.m_buyPopup = GenericPopup2B.NewYesNo(_loc7_,_loc6_,this.buyStaffConfirmed);
                  this.m_buyPopup.userData = {
                     "cash":_loc4_,
                     "index":_loc2_
                  };
                  PopupManager.instance.push(this.m_buyPopup);
               }
               else
               {
                  this.buyStaff(_loc4_,_loc2_);
               }
            }
         }
      }
      
      protected function centerHorizontally(param1:DisplayObject) : void
      {
         param1.x = (this.dialogWidth - param1.width) * 0.5;
      }
      
      protected function get dialogWidth() : int
      {
         return this.m_mc.panel_mc.width;
      }
      
      protected function get dialogHeight() : int
      {
         return this.m_mc.panel_mc.height;
      }
      
      protected function set dialogWidth(param1:int) : void
      {
         this.m_mc.panel_mc.width = param1;
      }
      
      protected function set dialogHeight(param1:int) : void
      {
         this.m_mc.panel_mc.height = param1;
      }
      
      public function set crewReplaceCount(param1:int) : void
      {
         this.m_crewReplaceCount = param1;
      }
   }
}

