package displays.screens.requests
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.SoundItem;
   import core.managers.ExperimentsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class RequestGiftCard
   {
      
      private static const UNSELECTED_OUT_STATE:int = 1;
      
      private static const UNSELECTED_OVER_STATE:int = 2;
      
      private static const SELECTED_OUT_STATE:int = 3;
      
      private static const SELECTED_OVER_STATE:int = 4;
      
      private var m_card:MovieClip;
      
      private var m_giftInfo:Object;
      
      private var m_giftItem:GameItem;
      
      private var m_giftFriendlyName:String;
      
      private var m_icon:ImageLoader;
      
      private var m_selected:Boolean = false;
      
      private var m_sendButton:ZGameButton = null;
      
      private var m_buttonSound:SoundItem = null;
      
      private var m_sendCallback:Function = null;
      
      private var m_partBuildingCode:String = null;
      
      public var m_overlay:MovieClip = null;
      
      public function RequestGiftCard(param1:Object, param2:Function, param3:String = null)
      {
         super();
         this.m_giftInfo = param1;
         this.m_partBuildingCode = param3;
         this.m_sendCallback = param2;
      }
      
      public function dispose() : void
      {
         if(this.m_overlay != null)
         {
            this.m_overlay.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            this.m_overlay.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            this.m_overlay.removeEventListener(MouseEvent.CLICK,this.onClick);
            this.m_overlay.parent.removeChild(this.m_overlay);
            this.m_overlay = null;
         }
         else if(this.m_card)
         {
            this.m_card.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            this.m_card.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            this.m_card.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
         if(this.m_icon)
         {
            this.m_icon.destroy();
            this.m_icon = null;
         }
         if(this.m_sendButton)
         {
            this.m_sendButton.dispose();
            this.m_sendButton = null;
         }
         this.m_buttonSound = null;
         this.m_card = null;
      }
      
      public function setCard(param1:MovieClip) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:String = null;
         if(this.m_card)
         {
            this.dispose();
         }
         this.m_card = param1;
         if(this.m_card)
         {
            if(this.m_giftInfo)
            {
               _loc2_ = this.m_card.getBounds(this.m_card.parent);
               if(this.m_overlay)
               {
                  this.m_card.parent.addChild(this.m_overlay);
                  this.m_overlay.graphics.beginFill(255,0);
                  this.m_overlay.graphics.drawRect(0,0,_loc2_.width,_loc2_.height);
                  this.m_overlay.graphics.endFill();
                  this.m_overlay.x = _loc2_.x;
                  this.m_overlay.y = _loc2_.y;
                  this.m_overlay.buttonMode = true;
                  this.m_overlay.useHandCursor = true;
                  this.m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
                  this.m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
                  this.m_overlay.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
                  this.m_overlay.mouseEnabled = true;
               }
               else
               {
                  this.m_card.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
                  this.m_card.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
                  this.m_card.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
               }
               this.m_card.name_tf.mouseEnabled = false;
               _loc3_ = 14;
               if(this.m_partBuildingCode)
               {
                  _loc5_ = ZGlobal.gameSettings.getItemByCode(this.m_partBuildingCode,GameItem) as GameItem;
                  _loc6_ = _loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  TextFieldUtil.compactTextField(this.m_card.unitName_mc.unitName_tf,_loc6_,{
                     "minScale":0.6,
                     "maxLines":3,
                     "fontSize":14
                  });
                  this.m_card.unitName_mc.visible = true;
                  _loc3_ = 12;
               }
               else
               {
                  this.m_card.unitName_mc.visible = false;
               }
               this.m_giftItem = ZGlobal.gameSettings.getItemByName(this.m_giftInfo.name,GameItem) as GameItem;
               this.m_giftFriendlyName = this.m_giftItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               TextFieldUtil.compactTextField(this.m_card.name_tf,this.m_giftFriendlyName,{
                  "minScale":0.6,
                  "maxLines":3,
                  "fontSize":_loc3_
               });
               this.m_icon = ImageLoaderFactory.CreateImageLoader(this.m_giftItem.getImageObject().url,this.m_card.picture);
               this.m_card.visible = true;
               _loc4_ = ZGameUtils.ZlocT("Dialogs","Send");
               this.m_sendButton = new ZGameButton(this.m_card.button_mc,this.onClick,1.1,true);
               this.m_sendButton.compactText(_loc4_,{
                  "maxLines":1,
                  "minScale":0.5,
                  "onFail":"return"
               });
               this.m_sendButton.sounds = ButtonSound.DEFAULT;
               this.m_sendButton.show();
               this.m_sendButton.enable();
            }
            else
            {
               this.m_card.visible = false;
            }
         }
      }
      
      public function get giftInfo() : Object
      {
         return this.m_giftInfo;
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:int = this.selected ? SELECTED_OUT_STATE : UNSELECTED_OUT_STATE;
         this.m_card.gotoAndStop(_loc2_);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:int = this.selected ? SELECTED_OVER_STATE : UNSELECTED_OVER_STATE;
         this.m_card.gotoAndStop(_loc2_);
         this.playSound(ButtonSound.ON_ROLLOVER);
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.playSound(ButtonSound.ON_CLICK);
         PopupManager.instance.push(new RequestGiftDialog(this.m_giftInfo.name,RequestGiftDialog.DEFAULT_GIFTTYPE,RequestDialog.TYPE_GIFT,ExperimentsManager.EXPERIMENT_REQUEST2_MFS,RequestDialog.SUBTYPE_TAB));
         this.m_sendCallback();
      }
      
      public function set sounds(param1:String) : void
      {
         this.m_buttonSound = ZGlobal.gameSettings.getButtonSoundByName(param1,SoundItem) as SoundItem;
      }
      
      private function playSound(param1:int) : void
      {
         if(null != this.m_buttonSound)
         {
            ButtonSound.getButtonSound(this.m_buttonSound.name).play(param1);
         }
      }
      
      public function show() : void
      {
         this.m_card.visible = true;
      }
      
      public function hide() : void
      {
         this.m_card.visible = false;
      }
   }
}

