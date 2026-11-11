package displays.screens.immunityExtend
{
   import core.ZGlobal;
   import displays.ImageLoader;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import zlabs.resource.SWFResource;
   
   public class ImmunityExtend extends ZGamePopUp
   {
      
      protected var m_mc:MovieClip;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      protected var m_cards:Array = new Array();
      
      protected var m_imageLoaders:Array = new Array();
      
      protected var m_largeCardClass:Class;
      
      protected var m_smallCardClass:Class;
      
      public function ImmunityExtend(param1:String)
      {
         super(ZGlobal.getAssetURL(param1));
      }
      
      protected function updateImmunityDurationTimer(param1:int) : void
      {
         var _loc2_:String = ZGameTimeUtil.instance.getClockString(param1,true);
         TextFieldUtil.processTextField(this.m_mc.totalTime_tf,_loc2_);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.m_largeCardClass = param1.getAssetClass("ImmunityCardLarge");
         this.m_smallCardClass = param1.getAssetClass("ImmunityCardNormal");
         var _loc2_:Class = param1.getAssetClass("ImmunityExtendMC");
         this.m_mc = new _loc2_();
         addChild(this.m_mc);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_buttonSounds.addButton(this.m_mc.exit_bt,ButtonSound.DEFAULT);
         contentWidth = this.m_mc.width;
         contentHeight = this.m_mc.height;
         this.addDialogTextAndImages();
         this.checkTimer();
         this.addEventListeners();
         this.createCards();
         initDialog();
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.removeEventListeners();
         this.clearCards();
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         this.clearImageLoaders();
      }
      
      protected function closeWindow(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         close();
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.closeWindow(param1);
      }
      
      protected function clearCards() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         while(_loc1_ < this.m_cards.length)
         {
            _loc2_ = this.m_cards[_loc1_].mc;
            if(_loc2_)
            {
               _loc2_.parent.removeChild(_loc2_);
               delete this.m_cards[_loc1_].mc;
            }
            if(this.m_cards[_loc1_].buyButton)
            {
               this.m_buttonSounds.removeButton(this.m_cards[_loc1_].buyButton.m_overlay);
               this.m_cards[_loc1_].buyButton.dispose();
               this.m_cards[_loc1_].buyButton = null;
            }
            if(this.m_cards[_loc1_].hireButton)
            {
               this.m_buttonSounds.removeButton(this.m_cards[_loc1_].hireButton.m_overlay);
               this.m_cards[_loc1_].hireButton.dispose();
               this.m_cards[_loc1_].hireButton = null;
            }
            _loc1_++;
         }
      }
      
      protected function clearImageLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = new Array();
      }
      
      protected function addDialogTextAndImages() : void
      {
      }
      
      protected function checkTimer() : void
      {
      }
      
      protected function addEventListeners() : void
      {
      }
      
      protected function removeEventListeners() : void
      {
      }
      
      protected function createCards() : void
      {
      }
      
      protected function onBuyClicked(param1:Event) : void
      {
      }
      
      protected function onHireClicked(param1:Event) : void
      {
      }
   }
}

