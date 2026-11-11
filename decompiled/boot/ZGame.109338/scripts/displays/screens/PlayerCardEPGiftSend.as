package displays.screens
{
   import core.ui.MovieClipButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   
   public class PlayerCardEPGiftSend implements RequestDialogCardInterface
   {
      
      private static const UNSELECTED_OUT_STATE:int = 1;
      
      private static const SELECTED_OUT_STATE:int = 3;
      
      private var m_card:MovieClip;
      
      private var m_friendInfo:Object;
      
      private var m_icon:ImageLoader;
      
      private var m_amount:int;
      
      private var m_callback:Function;
      
      private var m_canAddCallback:Function;
      
      private var m_buttonInc:MovieClipButton;
      
      private var m_buttonDec:MovieClipButton;
      
      public function PlayerCardEPGiftSend(param1:Object, param2:Function, param3:Function, param4:int)
      {
         super();
         this.m_friendInfo = param1;
         this.m_amount = param4;
         this.m_callback = param2;
         this.m_canAddCallback = param3;
      }
      
      public function setCard(param1:MovieClip) : void
      {
         if(this.m_card)
         {
            this.dispose();
         }
         this.m_card = param1;
         if(!this.m_card)
         {
            return;
         }
         this.m_card.visible = true;
         if(!this.m_friendInfo)
         {
            this.m_card.visible = false;
            return;
         }
         this.m_buttonInc = this.createAndInitAmountButton(this.m_card.ep_gift_mc.pageUp_mc,this.onIncClicked);
         this.m_buttonDec = this.createAndInitAmountButton(this.m_card.ep_gift_mc.pageDown_mc,this.onDecClicked);
         this.m_card.ep_gift_mc.visible = true;
         this.m_card.dogLogo_mc.visible = false;
         this.m_card.epLogo_mc.visible = false;
         TextFieldUtil.compactTextField(this.m_card.name_tf,this.m_friendInfo.name,{
            "minScale":0.65,
            "maxLines":4,
            "fontSize":12
         });
         this.m_icon = ImageLoaderFactory.CreateImageLoader(this.m_friendInfo.pic_square,this.m_card.picture);
         this.valueChanged();
      }
      
      private function onIncClicked(param1:MouseEvent) : void
      {
         if(this.m_canAddCallback())
         {
            this.amount += 1;
         }
      }
      
      private function onDecClicked(param1:MouseEvent) : void
      {
         --this.amount;
      }
      
      private function createAndInitAmountButton(param1:MovieClip, param2:Function) : MovieClipButton
      {
         var _loc3_:MovieClipButton = new MovieClipButton(param1);
         param1.addEventListener(MouseEvent.CLICK,param2,false,0,true);
         param1.buttonMode = true;
         param1.useHandCursor = true;
         return _loc3_;
      }
      
      public function dispose() : void
      {
         if(this.m_icon)
         {
            this.m_icon.destroy();
            this.m_icon = null;
         }
         if(this.m_buttonInc)
         {
            this.m_buttonInc.dispose();
            this.m_buttonInc = null;
         }
         if(this.m_buttonDec)
         {
            this.m_buttonDec.dispose();
            this.m_buttonDec = null;
         }
         if(this.m_card)
         {
            this.m_card.ep_gift_mc.pageUp_mc.removeEventListener(MouseEvent.CLICK,this.onIncClicked);
            this.m_card.ep_gift_mc.pageDown_mc.removeEventListener(MouseEvent.CLICK,this.onDecClicked);
         }
         this.m_card = null;
      }
      
      public function release() : void
      {
         this.m_callback = null;
         this.m_canAddCallback = null;
         this.dispose();
      }
      
      public function get selected() : Boolean
      {
         return false;
      }
      
      public function get visible() : Boolean
      {
         return this.m_card.visible;
      }
      
      private function valueChanged() : void
      {
         if(this.m_amount)
         {
            this.m_card.gotoAndStop(SELECTED_OUT_STATE);
         }
         else
         {
            this.m_card.gotoAndStop(UNSELECTED_OUT_STATE);
         }
         this.m_card.ep_gift_tf.visible = true;
         var _loc1_:String = String(this.m_amount);
         TextFieldUtil.compactTextField(this.m_card.ep_gift_tf,_loc1_);
         TextFieldUtil.processTextField(this.m_card.name_tf,this.m_friendInfo.name);
         this.m_callback(this.m_friendInfo.uid,this.m_amount);
      }
      
      private function get amount() : int
      {
         return this.m_amount;
      }
      
      private function set amount(param1:int) : void
      {
         this.m_amount = Math.max(0,param1);
         this.valueChanged();
      }
   }
}

