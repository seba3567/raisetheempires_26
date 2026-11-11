package displays.popups.decorations
{
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class CrewableDecorationPopupCard extends MovieClip
   {
      
      public static var REFRESH:String = "refresh";
      
      public static var ASK_CLICKED:String = "askClicked";
      
      private var m_dispatcher:EventDispatcher;
      
      private var m_owner:IEntity;
      
      private var m_crewIndex:int;
      
      private var m_crewWrapper:CrewTemplateWrapper;
      
      private var m_gdc:GameDataComponent;
      
      private var m_card:MovieClip;
      
      private var m_askButton:ZGameButton;
      
      private var m_buyButton:ZGameButton;
      
      private var m_imageLoader:ImageLoader;
      
      public function CrewableDecorationPopupCard(param1:EventDispatcher, param2:IEntity, param3:int, param4:CrewTemplateWrapper, param5:MovieClip, param6:GameDataComponent, param7:ButtonMouseEventSoundContainer)
      {
         super();
         this.m_dispatcher = param1;
         this.m_owner = param2;
         this.m_crewIndex = param3;
         this.m_crewWrapper = param4;
         this.m_gdc = param6;
         this.m_card = param5;
         var _loc8_:String = DecorationsManager.instance.crewDurationBonusString;
         TextFieldUtil.processTextField(this.m_card.bkg_locked.time_tf,_loc8_);
         TextFieldUtil.processTextField(this.m_card.bkg_empty.time_tf,_loc8_);
         TextFieldUtil.processTextField(this.m_card.bkg_filled.time_tf,_loc8_);
         this.m_askButton = new ZGameButton(param5.hire_bt,this.onAskButtonClicked);
         TextFieldUtil.compactTextField(param5.hire_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","CrewedDecorationsHireButton"));
         this.m_buyButton = new ZGameButton(param5.buy_bt,this.onBuyButtonClicked);
         this.m_buyButton.text = String(this.m_crewWrapper.price);
         param7.addButton(this.m_askButton.m_overlay,ButtonSound.DEFAULT);
         param7.addButton(this.m_buyButton.m_overlay,ButtonSound.DEFAULT);
         this.initializeState();
      }
      
      public static function crewReplacements(param1:int) : Object
      {
         return {
            "amount":param1,
            "slot":ZGameUtils.ZlocTk("Objects","slot","",param1)
         };
      }
      
      private function get filledStateString() : String
      {
         if(this.m_crewIndex)
         {
            return ZGameUtils.ZlocT("Dialogs","CrewedDecorationsFilledStatePending");
         }
         return ZGameUtils.ZlocT("Dialogs","CrewedDecorationsFilledStateCurrent");
      }
      
      private function initializeState() : void
      {
         var _loc1_:int = 0;
         var _loc3_:Player = null;
         var _loc2_:Object = CrewManager.getCrewInfo(this.m_owner,this.m_gdc,true);
         if(Boolean(_loc2_) && Boolean(_loc2_.crew))
         {
            _loc1_ = int(_loc2_.crew.length);
         }
         if(this.m_crewIndex < _loc1_)
         {
            _loc3_ = ZGlobal.player.findFriendById(_loc2_.crew[this.m_crewIndex]);
         }
         this.m_askButton.disable();
         this.m_buyButton.disable();
         this.m_askButton.hide();
         this.m_buyButton.hide();
         if(_loc3_)
         {
            this.m_card.player_01.visible = true;
            this.disposeLoader();
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(_loc3_.portraitURL,this.m_card.player_01.icon);
            TextFieldUtil.processTextField(this.m_card.player_01.name_tf,_loc3_.firstName);
         }
         else
         {
            this.m_card.player_01.visible = false;
            if(this.m_crewIndex == _loc1_)
            {
               this.m_askButton.enable();
               this.m_buyButton.enable();
               this.m_askButton.show();
               this.m_buyButton.show();
            }
         }
         this.updateCardBackground(_loc3_,_loc1_);
      }
      
      private function updateCardBackground(param1:Player, param2:int) : void
      {
         var _loc3_:String = null;
         this.m_card.bkg_filled.visible = false;
         this.m_card.bkg_empty.visible = false;
         this.m_card.bkg_locked.visible = false;
         if(param1)
         {
            this.m_card.bkg_filled.visible = true;
            TextFieldUtil.processTextField(this.m_card.bkg_filled.title_tf,this.filledStateString);
         }
         else if(this.m_crewIndex == param2)
         {
            this.m_card.bkg_empty.visible = true;
            this.m_card.bkg_empty.title_tf.visible = false;
         }
         else
         {
            this.m_card.bkg_locked.visible = true;
            _loc3_ = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsLockedSlot",crewReplacements(this.m_crewIndex));
            TextFieldUtil.processTextField(this.m_card.bkg_locked.title_tf,_loc3_);
         }
      }
      
      private function disposeLoader() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      public function dispose() : void
      {
         this.disposeLoader();
         if(this.m_askButton)
         {
            this.m_askButton.dispose();
            this.m_askButton = null;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.dispose();
            this.m_buyButton = null;
         }
         this.m_card = null;
      }
      
      private function onAskButtonClicked(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(ASK_CLICKED));
      }
      
      private function onBuyButtonClicked(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:GenericPopup2B = null;
         var _loc2_:int = this.m_crewWrapper.price;
         if(ZGlobal.player.canBuyCash(_loc2_,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc4_ = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsHireConfirmText",_loc3_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","CrewedDecorationsHireConfirmTitle");
               _loc6_ = GenericPopup2B.NewYesNo(_loc4_,_loc5_,this.fillPositionConfirmed);
               PopupManager.instance.push(_loc6_);
            }
            else
            {
               this.buySlot();
            }
         }
      }
      
      private function fillPositionConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buySlot();
         }
      }
      
      private function buySlot() : void
      {
         CrewManager.instance.buyCrewSlot(this.m_owner,this.m_crewWrapper.price,this.m_crewIndex);
         this.refresh();
      }
      
      private function refresh() : void
      {
         dispatchEvent(new Event(REFRESH));
      }
   }
}

