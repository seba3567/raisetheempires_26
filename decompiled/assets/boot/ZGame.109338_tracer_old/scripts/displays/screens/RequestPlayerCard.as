package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.SoundItem;
   import core.managers.ExperimentsManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class RequestPlayerCard implements RequestDialogCardInterface
   {
      
      private static const UNSELECTED_OUT_STATE:int = 1;
      
      private static const UNSELECTED_OVER_STATE:int = 2;
      
      private static const SELECTED_OUT_STATE:int = 3;
      
      private static const SELECTED_OVER_STATE:int = 4;
      
      private var m_card:MovieClip;
      
      private var m_friendInfo:Object;
      
      private var m_icon:ImageLoader;
      
      private var m_selected:Boolean;
      
      private var m_preselectVariant:Number;
      
      private var m_buttonSound:SoundItem = null;
      
      private var m_checkCallback:Function;
      
      public var m_overlay:MovieClip = null;
      
      public function RequestPlayerCard(param1:Object, param2:Function)
      {
         super();
         this.m_buttonSound = ZGlobal.gameSettings.getButtonSoundByName(ButtonSound.DEFAULT,SoundItem) as SoundItem;
         this.m_friendInfo = param1;
         this.m_preselectVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_PRESELECT);
         if(Boolean(this.m_friendInfo) && Boolean(this.m_friendInfo.hasOwnProperty("is_app_user")) && Boolean(this.m_friendInfo.is_app_user) && this.m_preselectVariant < 3)
         {
            this.m_selected = true;
         }
         else
         {
            this.m_selected = false;
         }
         if(this.m_preselectVariant == 2 && ZGlobal.player.isZyngaFriend(this.m_friendInfo))
         {
            this.m_selected = true;
         }
         this.m_checkCallback = param2;
      }
      
      public function release() : void
      {
         this.dispose();
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
         if(this.m_icon)
         {
            this.m_icon.destroy();
            this.m_icon = null;
         }
         this.m_buttonSound = null;
         this.m_card = null;
      }
      
      public function setCard(param1:MovieClip) : void
      {
         var _loc2_:Rectangle = null;
         if(this.m_card)
         {
            this.dispose();
         }
         this.m_card = param1;
         if(this.m_card)
         {
            if(this.m_friendInfo)
            {
               this.m_overlay = new MovieClip();
               this.m_card.parent.addChild(this.m_overlay);
               this.m_card.name_tf.mouseEnabled = false;
               _loc2_ = this.m_card.getBounds(this.m_card.parent);
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
               TextFieldUtil.compactTextField(this.m_card.name_tf,this.m_friendInfo.name,{
                  "minScale":0.65,
                  "maxLines":4,
                  "fontSize":12
               });
               this.m_icon = ImageLoaderFactory.CreateImageLoader(this.m_friendInfo.pic_square,this.m_card.picture);
               this.m_card.dogLogo_mc.visible = false;
               this.m_card.epLogo_mc.visible = false;
               ZGameUtils.hideIfExists(this.m_card.ep_gift_mc);
               ZGameUtils.hideIfExists(this.m_card.ep_gift_tf);
               if(this.m_friendInfo.hasOwnProperty("is_app_user") && Boolean(this.m_friendInfo.is_app_user))
               {
                  this.m_card.epLogo_mc.visible = true;
               }
               else if(this.m_preselectVariant == 2 && ZGlobal.player.isZyngaFriend(this.m_friendInfo))
               {
                  this.m_card.dogLogo_mc.visible = true;
               }
               this.m_card.visible = true;
               this.m_overlay.mouseEnabled = true;
               this.updateSelected();
            }
            else
            {
               this.m_card.visible = false;
            }
         }
      }
      
      private function updateSelected() : void
      {
         if(this.selected)
         {
            this.m_card.gotoAndStop(SELECTED_OUT_STATE);
         }
         else
         {
            this.m_card.gotoAndStop(UNSELECTED_OUT_STATE);
         }
         TextFieldUtil.processTextField(this.m_card.name_tf,this.m_friendInfo.name);
         ZGameUtils.hideIfExists(this.m_card.ep_gift_mc);
         ZGameUtils.hideIfExists(this.m_card.ep_gift_tf);
      }
      
      public function setSelectedState() : void
      {
         if(!this.selected)
         {
            this.m_selected = true;
            if(Boolean(this.m_card) && Boolean(this.m_friendInfo))
            {
               this.updateSelected();
            }
         }
      }
      
      public function setDeselectedState() : void
      {
         if(this.selected)
         {
            this.m_selected = false;
            if(Boolean(this.m_card) && Boolean(this.m_friendInfo))
            {
               this.updateSelected();
            }
         }
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function get friendInfo() : Object
      {
         return this.m_friendInfo;
      }
      
      private function toggleSelected() : void
      {
         this.m_selected = !this.m_selected;
         var _loc1_:int = SELECTED_OVER_STATE;
         if(!this.m_selected)
         {
            _loc1_ = UNSELECTED_OVER_STATE;
            this.m_checkCallback(false);
         }
         else
         {
            this.m_checkCallback(true);
         }
         this.m_card.gotoAndStop(_loc1_);
         TextFieldUtil.processTextField(this.m_card.name_tf,this.m_friendInfo.name);
         ZGameUtils.hideIfExists(this.m_card.ep_gift_tf);
         ZGameUtils.hideIfExists(this.m_card.ep_gift_mc);
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
      
      private function onClick(param1:MouseEvent) : void
      {
         this.toggleSelected();
         this.playSound(ButtonSound.ON_CLICK);
      }
      
      private function playSound(param1:int) : void
      {
         if(null != this.m_buttonSound)
         {
            ButtonSound.getButtonSound(this.m_buttonSound.name).play(param1);
         }
      }
      
      public function get visible() : Boolean
      {
         return this.m_card.visible;
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

