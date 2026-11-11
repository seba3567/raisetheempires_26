package displays.screens.gridScreen
{
   import core.managers.tutorialManager.TutorialManager;
   import displays.screens.ItemTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class GridSlot
   {
      
      public static const CLICKED:String = "clicked";
      
      public static const SELECTED:String = "select";
      
      public static const DESELECTED:String = "deselected";
      
      public static const PURCHASE:String = "purchase";
      
      public static const STENCIL:String = "stencil";
      
      private var m_parent:MovieClip = null;
      
      protected var m_screen:MovieClip = null;
      
      private var m_slot:MovieClip = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_selected:Boolean = false;
      
      protected var m_enabled:Boolean = false;
      
      protected var m_xIndex:int = 0;
      
      protected var m_yIndex:int = 0;
      
      private var m_arrow:Boolean = false;
      
      private var m_rolloverHighlightEnabled:Boolean = true;
      
      public function GridSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int = 0, param5:int = 0)
      {
         super();
         this.m_parent = param2;
         this.m_screen = param3;
         this.m_xIndex = param4;
         this.m_yIndex = param5;
         this.m_slot = this.createSlot(param1);
         this.onSlotCreated();
         this.m_parent.addChild(this.m_slot);
         if(this.m_slot.highlightSelect_mc)
         {
            this.m_slot.highlightSelect_mc.visible = false;
         }
         if(this.m_slot.selected_mc)
         {
            this.deselect();
         }
         if(this.m_slot.sizer_mc)
         {
            this.m_slot.sizer_mc.visible = false;
         }
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.addEventListener(STENCIL,this.onStencil,false,0,true);
            TutorialManager.instance.addEventListener(TutorialManager.UI_HIGHLIGHT_ITEM,this.onArrow,false,0,true);
         }
         this.enable();
      }
      
      public function get hasContextMenu() : Boolean
      {
         return true;
      }
      
      protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass(this.className);
         var _loc3_:MovieClip = new _loc2_();
         return _loc3_.card_mc;
      }
      
      protected function onSlotCreated() : void
      {
      }
      
      public function dispose() : void
      {
         this.disable();
         this.m_parent.removeChild(this.m_slot);
         this.m_parent = null;
         this.m_slot = null;
         TutorialManager.instance.removeEventListener(STENCIL,this.onStencil);
         TutorialManager.instance.removeEventListener(TutorialManager.UI_HIGHLIGHT_ITEM,this.onArrow);
         if(this.m_arrow)
         {
            TutorialManager.instance.removeArrows();
         }
      }
      
      public function get width() : Number
      {
         return this.m_slot.width;
      }
      
      public function get height() : Number
      {
         return this.m_slot.height;
      }
      
      public function get sizerWidth() : Number
      {
         if(this.m_slot.sizer_mc)
         {
            return this.m_slot.sizer_mc.width;
         }
         return this.width;
      }
      
      public function get sizerHeight() : Number
      {
         if(this.m_slot.sizer_mc)
         {
            return this.m_slot.sizer_mc.height;
         }
         return this.height;
      }
      
      protected function get className() : String
      {
         return null;
      }
      
      public function get slot() : MovieClip
      {
         return this.m_slot;
      }
      
      public function get xIndex() : int
      {
         return this.m_xIndex;
      }
      
      public function get yIndex() : int
      {
         return this.m_yIndex;
      }
      
      public function fillOutTooltip() : ItemTooltip
      {
         return null;
      }
      
      public function get tooltipAnchorPositionX() : Number
      {
         return 0.5;
      }
      
      public function get tooltipAnchorPositionY() : Number
      {
         return 0.25;
      }
      
      protected function get screen() : MovieClip
      {
         return this.m_screen;
      }
      
      public function get parent() : MovieClip
      {
         return this.m_parent;
      }
      
      public function get rollOverTarget() : MovieClip
      {
         return this.m_slot;
      }
      
      protected function doOnClick(param1:MouseEvent) : void
      {
      }
      
      protected function addButtonSounds() : void
      {
         this.m_buttonSounds.addButton(this.m_slot,ButtonSound.PANEL);
      }
      
      public function enable() : void
      {
         this.m_enabled = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.addButtonSounds();
         this.m_slot.buttonMode = true;
         this.m_slot.useHandCursor = true;
         this.m_slot.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_slot.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.m_slot.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         this.m_slot.filters = null;
      }
      
      public function disable() : void
      {
         this.m_enabled = false;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_slot.removeEventListener(MouseEvent.CLICK,this.onClicked);
         this.m_slot.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_slot.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      public function enable_visual() : void
      {
         this.m_slot.filters = [];
         this.enable();
      }
      
      public function disable_visual() : void
      {
         this.m_slot.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         this.disable();
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         this.doOnClick(param1);
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         if(!this.isTutorialLocked() && this.m_rolloverHighlightEnabled && this.m_slot.highlightSelect_mc != undefined)
         {
            this.m_slot.highlightSelect_mc.visible = true;
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         if(this.m_slot.highlightSelect_mc != undefined)
         {
            this.m_slot.highlightSelect_mc.visible = false;
         }
      }
      
      protected function set rollOverHighlightEnabled(param1:Boolean) : void
      {
         this.m_rolloverHighlightEnabled = param1;
         if(!this.m_rolloverHighlightEnabled)
         {
            this.m_slot.highlightSelect_mc.visible = false;
         }
      }
      
      protected function getObjectCode() : String
      {
         return null;
      }
      
      private function shouldGiveTutorialFeedback(param1:String) : Boolean
      {
         return param1 == this.getObjectCode();
      }
      
      protected function isTutorialLocked() : Boolean
      {
         var _loc1_:String = this.getObjectCode();
         if(Boolean(_loc1_) && _loc1_.length > 0)
         {
            return TutorialManager.instance.isLocked(_loc1_);
         }
         return false;
      }
      
      protected function getStencilCircleOffset(param1:WorldEvent) : Point
      {
         return new Point(60,50);
      }
      
      protected function getStencilCircleModifier(param1:WorldEvent) : Number
      {
         return 1;
      }
      
      private function onStencil(param1:WorldEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         if(this.shouldGiveTutorialFeedback(param1.eventData as String))
         {
            _loc2_ = this.getStencilCircleOffset(param1);
            _loc3_ = this.getStencilCircleModifier(param1);
            TutorialManager.instance.addStencilToUIElement(this.slot,_loc2_,_loc3_);
         }
      }
      
      private function onArrow(param1:WorldEvent) : void
      {
         if(this.shouldGiveTutorialFeedback(param1.eventData as String))
         {
            TutorialManager.instance.addArrowToUIElement(this.slot,true,true);
            this.m_arrow = true;
         }
      }
      
      public function isSpecialSlot() : Boolean
      {
         return false;
      }
      
      public function select() : void
      {
         this.m_selected = true;
         this.slot.selected_mc.visible = true;
      }
      
      public function deselect() : void
      {
         this.m_selected = false;
         this.slot.selected_mc.visible = false;
      }
      
      public function getData() : Object
      {
         return null;
      }
      
      public function updateSlotForMastery() : void
      {
      }
      
      protected function setUseHandCursor(param1:Boolean) : void
      {
         this.m_slot.useHandCursor = param1;
      }
      
      protected function setButtonMode(param1:Boolean) : void
      {
         this.m_slot.buttonMode = param1;
      }
   }
}

