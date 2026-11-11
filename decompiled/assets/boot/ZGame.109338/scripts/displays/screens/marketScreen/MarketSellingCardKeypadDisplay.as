package displays.screens.marketScreen
{
   import core.ui.Style;
   import core.ui.ZGameButton;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   
   public class MarketSellingCardKeypadDisplay
   {
      
      private static const COST_DEFAULT_TEXT_COLOR:Object = 16777215;
      
      private var m_callback:Function = null;
      
      private var m_digitClips:Array = null;
      
      private var m_digitButtons:Array = null;
      
      private var m_clearButton:ZGameButton = null;
      
      private var m_display:TextField = null;
      
      private var m_value:int = 0;
      
      private var m_capValue:int = -1;
      
      private var m_userSet:Boolean = false;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function MarketSellingCardKeypadDisplay(param1:MovieClip, param2:Function = null)
      {
         var _loc4_:ZGameButton = null;
         super();
         this.m_callback = param2;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_digitClips = [param1.key0,param1.key1,param1.key2,param1.key3,param1.key4,param1.key5,param1.key6,param1.key7,param1.key8,param1.key9];
         this.m_digitButtons = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.m_digitClips.length)
         {
            _loc4_ = new ZGameButton(this.m_digitClips[_loc3_],this.onKeyButton,1,true);
            _loc4_.text = String(_loc3_);
            this.m_buttonSounds.addButton(_loc4_.m_overlay,ButtonSound.DEFAULT);
            this.m_digitButtons.push(_loc4_);
            _loc3_++;
         }
         this.m_clearButton = new ZGameButton(param1.key_clear,this.onClearButton);
         this.m_buttonSounds.addButton(this.m_clearButton.m_overlay,ButtonSound.DEFAULT);
         this.m_display = param1.display_tf;
         this.updateDisplay();
      }
      
      public function dispose() : void
      {
         var _loc1_:ZGameButton = null;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         for each(_loc1_ in this.m_digitButtons)
         {
            _loc1_.dispose();
         }
         this.m_digitButtons = null;
         this.m_digitClips = null;
         this.m_clearButton.dispose();
      }
      
      public function enable() : void
      {
         var _loc1_:ZGameButton = null;
         for each(_loc1_ in this.m_digitButtons)
         {
            _loc1_.enable();
         }
         this.m_clearButton.enable();
      }
      
      public function disable() : void
      {
         var _loc1_:ZGameButton = null;
         for each(_loc1_ in this.m_digitButtons)
         {
            _loc1_.disable_visual();
         }
         this.m_clearButton.disable_visual();
      }
      
      public function get value() : int
      {
         return this.m_value;
      }
      
      public function set value(param1:int) : void
      {
         this.m_value = param1;
         this.updateDisplay();
      }
      
      public function set capValue(param1:int) : void
      {
         this.m_capValue = param1;
         this.updateDisplay();
      }
      
      public function set userSet(param1:Boolean) : void
      {
         this.m_userSet = param1;
      }
      
      private function updateDisplay() : void
      {
         if(this.m_capValue >= 0 && this.m_value > this.m_capValue)
         {
            TextFieldUtil.setTextFieldColor(this.m_display,Style.COLOR_UNSUFFICIENT_FUNDS);
         }
         else
         {
            TextFieldUtil.setTextFieldColor(this.m_display,COST_DEFAULT_TEXT_COLOR);
         }
         TextFieldUtil.processTextField(this.m_display,String(this.m_value));
      }
      
      private function updateCallback() : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
      
      private function onKeyButton(param1:MouseEvent) : void
      {
         var _loc2_:int = this.indexOfButton(param1.target as DisplayObject);
         if(!this.m_userSet)
         {
            this.m_value = 0;
            this.m_userSet = true;
         }
         if(_loc2_ >= 0)
         {
            this.m_value = this.m_value * 10 + _loc2_;
            this.updateDisplay();
            this.updateCallback();
         }
      }
      
      private function onClearButton(param1:MouseEvent) : void
      {
         this.m_value = 0;
         this.updateDisplay();
         this.updateCallback();
      }
      
      private function indexOfButton(param1:DisplayObject) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_digitClips.length)
         {
            if(this.m_digitClips[_loc2_].contains(param1))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
   }
}

