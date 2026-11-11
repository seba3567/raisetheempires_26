package displays.popups.decorations
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.DecorationItem;
   import core.managers.CrewManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.CountdownClock;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.immunityExtend.ImmunityExtend;
   import displays.screens.requests.RequestCrewDialog;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class CrewableDecorationPopup extends ImmunityExtend
   {
      
      private var m_owner:IEntity;
      
      private var m_gdc:GameDataComponent;
      
      private var m_item:DecorationItem;
      
      private var m_crewWrapper:CrewTemplateWrapper;
      
      private var m_resource:SWFResource;
      
      private var m_unitCards:Array = [];
      
      private var m_timer:Timer;
      
      private var m_buyOnceButton:ZGameButton;
      
      protected var m_slotButtonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private const MAX_CREW_MEMBERS:int = 3;
      
      public function CrewableDecorationPopup(param1:IEntity)
      {
         this.m_owner = param1;
         this.m_gdc = GameDataComponent.getGameDataComponent(param1);
         this.m_gdc.updateCrew();
         this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_gdc.gameData.code,DecorationItem) as DecorationItem;
         this.m_crewWrapper = ZGlobal.gameSettings.getCrewTemplateWrapper(this.m_item.getCrewTemplateName());
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
         this.m_owner.eventDispatcher.addEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated,false,0,true);
         super("assets/displays/dialogs/PU_DeccoCrew.swf");
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         StatsManager.count("dialog","Deco_interface","view",this.m_item.name);
         this.m_resource = param1;
         super.onLoadComplete(param1);
      }
      
      override protected function onExitClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog","Deco_interface","no");
         super.onExitClicked(param1);
      }
      
      private function getBonusAmountReplacement(param1:Boolean) : Object
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc2_:XMLList = this.m_item.effectsXML;
         if(Boolean(_loc2_) && Boolean(_loc2_.length()))
         {
            _loc3_ = _loc2_[0];
            _loc4_ = param1 ? DecorationsManager.LABEL_AMOUNT_CREWED : DecorationsManager.LABEL_AMOUNT_NORMAL;
            _loc5_ = DecorationsManager.instance.getEffectVariantAmount(_loc3_[_loc4_].toString(),_loc3_.@effect.toString());
            return {"amount":_loc5_};
         }
         return null;
      }
      
      private function getCurrentCrewBonusString(param1:Boolean) : String
      {
         var _loc3_:String = null;
         var _loc2_:Object = this.getBonusAmountReplacement(param1);
         if(_loc2_)
         {
            return ZGameUtils.ZlocT("Dialogs","CrewedDecorationsBuffBonusString",_loc2_);
         }
         return "";
      }
      
      override protected function addDialogTextAndImages() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","CrewedDecorationTitle");
         TextFieldUtil.processTextField(m_mc.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsTimeLabel");
         TextFieldUtil.processTextField(m_mc.timelabel_tf,_loc2_);
         var _loc3_:Object = {"building":this.m_item.getSentenceNameLocalizationObject()};
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsTimeDescNew",_loc3_);
         TextFieldUtil.processTextField(m_mc.title_tf2,_loc4_);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsFullyCrewed");
         TextFieldUtil.processTextField(m_mc.filled_tf,_loc5_);
         TextFieldUtil.compactTextField(m_mc.bonus01_tf,this.getCurrentCrewBonusString(true));
         TextFieldUtil.compactTextField(m_mc.bonus02_tf,this.getCurrentCrewBonusString(false));
         var _loc6_:String = this.m_item.getCachedImage("icon").url;
         var _loc7_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc6_,m_mc.icon);
         if(_loc7_)
         {
            m_imageLoaders.push(_loc7_);
         }
         super.addDialogTextAndImages();
      }
      
      override protected function createCards() : void
      {
         this.createCrewCards();
         super.createCards();
      }
      
      private function createCrewCards() : void
      {
         var _loc2_:int = 0;
         var _loc4_:String = null;
         var _loc5_:MovieClip = null;
         var _loc6_:CrewableDecorationPopupCard = null;
         var _loc1_:int = Math.min(this.MAX_CREW_MEMBERS,this.m_crewWrapper.numPositions);
         while(_loc2_ < _loc1_)
         {
            _loc4_ = "slotCard" + _loc2_;
            _loc5_ = m_mc[_loc4_];
            _loc6_ = new CrewableDecorationPopupCard(this,this.m_owner,_loc2_,this.m_crewWrapper,_loc5_,this.m_gdc,this.m_slotButtonSounds);
            _loc6_.addEventListener(CrewableDecorationPopupCard.REFRESH,this.onRefresh,false,0,true);
            _loc6_.addEventListener(CrewableDecorationPopupCard.ASK_CLICKED,this.onAskClicked,false,0,true);
            this.m_unitCards.push(_loc6_);
            _loc2_++;
         }
         var _loc3_:Boolean = _loc1_ == this.m_gdc.crewCount;
         m_mc.filled_tf.visible = _loc3_;
      }
      
      private function get removeCrewTS() : int
      {
         if(Boolean(this.m_gdc.userData) && Boolean(this.m_gdc.userData.removeCrewTS))
         {
            return this.m_gdc.userData.removeCrewTS;
         }
         return 0;
      }
      
      private function onTimer(param1:TimerEvent = null, param2:Boolean = false) : void
      {
         var _loc9_:int = 0;
         var _loc3_:int = GlobalEngine.serverTime / 1000;
         var _loc4_:int = Math.max(_loc3_,this.removeCrewTS);
         var _loc5_:int;
         var _loc6_:int = _loc5_ = _loc4_ - _loc3_;
         var _loc7_:int = this.m_gdc.crewCount;
         if(_loc7_ > 1 && !this.m_gdc.crewBuyOnceEnabled)
         {
            _loc9_ = DecorationsManager.instance.crewRemoveDuration;
            _loc6_ += (_loc7_ - 1) * _loc9_;
         }
         var _loc8_:Object = ZGameTimeUtil.instance.getTimeObject(_loc6_);
         CountdownClock.updateClockAsset(m_mc.clock_mc,false,_loc8_);
         if(_loc5_)
         {
            this.m_timer.start();
         }
         else if(!param2)
         {
            this.m_timer.stop();
            this.onRefresh();
         }
      }
      
      override protected function initDialog() : void
      {
         this.m_buyOnceButton = new ZGameButton(m_mc.skip_btn,this.onCrewBuyOnceClicked);
         var _loc1_:Object = ZGameUtils.CashTokenReplacements(DecorationsManager.instance.buyOnceAmount);
         this.m_buyOnceButton.text = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsBuyOnceButton",_loc1_);
         m_buttonSounds.addButton(this.m_buyOnceButton.m_overlay,ButtonSound.DEFAULT);
         var _loc2_:Object = this.getBonusAmountReplacement(true);
         if(_loc2_)
         {
            this.m_buyOnceButton.addTooltip(ZGameUtils.ZlocT("Dialogs","CrewedDecorationsBuyOnceButtonTooltip",_loc2_));
         }
         if(this.m_gdc.crewBuyOnceEnabled)
         {
            this.m_buyOnceButton.disable();
         }
         else
         {
            this.m_buyOnceButton.enable();
         }
         this.updateBuyOnceButton();
         this.onTimer(null,true);
         super.initDialog();
      }
      
      private function onCrewBuyOnceClicked(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup2B = null;
         StatsManager.count("dialog","Deco_interface","buyall",this.m_item.name);
         if(!this.m_gdc.crewBuyOnceEnabled)
         {
            if(ZGlobal.player.canBuyCash(DecorationsManager.instance.buyOnceAmount))
            {
               _loc2_ = ZGameUtils.CashTokenReplacements(DecorationsManager.instance.buyOnceAmount);
               _loc3_ = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsBuyOnceButtonConfirm",_loc2_);
               _loc4_ = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsHireConfirmTitle");
               _loc5_ = GenericPopup2B.NewYesNo(_loc3_,_loc4_,this.onCrewBuyOnceConfirmed);
               PopupManager.instance.push(_loc5_);
            }
         }
      }
      
      private function onCrewBuyOnceConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.m_gdc.buyPermanentCrew();
         }
      }
      
      private function onCrewUpdated(param1:WorldEvent) : void
      {
         this.onRefresh();
      }
      
      private function cleanupCards() : void
      {
         var _loc1_:MovieClip = null;
         this.m_slotButtonSounds.release();
         this.m_slotButtonSounds = new ButtonMouseEventSoundContainer();
         for each(_loc1_ in this.m_unitCards)
         {
            _loc1_.removeEventListener(CrewableDecorationPopupCard.REFRESH,this.onRefresh);
            _loc1_.removeEventListener(CrewableDecorationPopupCard.ASK_CLICKED,this.onAskClicked);
            _loc1_.dispose();
         }
         this.m_unitCards = [];
      }
      
      override protected function deinitDialog() : void
      {
         this.m_owner.eventDispatcher.removeEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         this.m_gdc = null;
         this.m_owner = null;
         this.m_crewWrapper = null;
         this.m_resource = null;
         this.m_item = null;
         this.cleanupCards();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer = null;
         super.deinitDialog();
      }
      
      private function onRefresh(param1:Event = null) : void
      {
         this.m_gdc.updateCrew(false);
         this.cleanupCards();
         this.createCards();
         this.onTimer(null,true);
         this.updateBuyOnceButton();
      }
      
      private function updateBuyOnceButton() : void
      {
         if(this.m_gdc.crewBuyOnceEnabled)
         {
            this.m_buyOnceButton.disable();
         }
         else
         {
            this.m_buyOnceButton.enable();
         }
      }
      
      private function onAskClicked(param1:Event) : void
      {
         StatsManager.count("dialog","Deco_interface","hire",this.m_gdc.gameData.name);
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         var _loc2_:Object = CrewManager.getCrewInfo(this.m_owner,this.m_gdc);
         var _loc3_:int = this.m_gdc.id;
         var _loc4_:int = Boolean(_loc2_) && Boolean(_loc2_.crew) ? int(_loc2_.crew.length) : 0;
         var _loc5_:CrewTemplateWrapper = ZGlobal.gameSettings.getCrewTemplateWrapper(this.m_gdc.gameData.name);
         PopupManager.instance.push(new RequestCrewDialog(_loc3_,this.m_gdc.gameData.name,this.m_crewWrapper.numPositions - _loc4_));
         close();
      }
      
      private function get numCrewMembers() : int
      {
         if(Boolean(this.m_gdc) && Boolean(this.m_gdc.userData) && Boolean(this.m_gdc.userData.crewInfo as Array))
         {
            return this.m_gdc.userData.crewInfo.length;
         }
         return 0;
      }
   }
}

