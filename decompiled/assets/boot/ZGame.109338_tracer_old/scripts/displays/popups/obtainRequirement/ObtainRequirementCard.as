package displays.popups.obtainRequirement
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class ObtainRequirementCard
   {
      
      public static const TYPE_ASK:int = 0;
      
      public static const TYPE_BUY:int = 1;
      
      public static const TYPE_BUY_CASH:int = 2;
      
      public static const TYPE_GO_NOW:int = 3;
      
      public static const TYPE_USE_ITEM:int = 4;
      
      private var m_card:MovieClip;
      
      private var m_info:IObtainRequirementPopupInfo;
      
      private var m_button:ZGameButton = null;
      
      private var m_loaders:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function ObtainRequirementCard(param1:MovieClip, param2:IObtainRequirementPopupInfo, param3:int, param4:Function, param5:Boolean = false, param6:Boolean = false)
      {
         var _loc7_:ObtainRequirementPopupInfoUseItem = null;
         var _loc8_:uint = 0;
         super();
         this.m_card = param1;
         this.m_info = param2;
         this.m_loaders = new Array();
         if(this.m_card.cost_tf)
         {
            this.m_card.cost_tf.visible = false;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_button = new ZGameButton(this.m_card.ok_bt,param4);
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         switch(param3)
         {
            case TYPE_ASK:
               this.setOrHideText(this.m_card.itemName_tf,this.m_info.askTitleText);
               this.setOrHideText(this.m_card.generic_tf,this.m_info.askDescText);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(this.m_info.askIconURL,this.m_card.icon));
               this.m_button.text = this.m_info.askButtonText;
               ZGameUtils.hideIfExists(this.m_card.icon_01);
               break;
            case TYPE_BUY:
               this.setOrHideText(this.m_card.itemName_tf,this.m_info.buyTitleText);
               this.setOrHideText(this.m_card.generic_tf,this.m_info.buyDescText);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(this.m_info.buyIconURL,this.m_card.icon));
               this.m_button.text = this.m_info.buyButtonText;
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Cash_24.png"),this.m_card.icon_01));
               break;
            case TYPE_BUY_CASH:
               this.setOrHideText(this.m_card.itemName_tf,this.m_info.buyTitleText);
               this.setOrHideText(this.m_card.generic_tf,this.m_info.buyDescText);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(this.m_info.buyIconURL,this.m_card.icon));
               this.m_button.text = this.m_info.buyButtonText;
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Cash_24.png"),this.m_card.icon_01));
               break;
            case TYPE_GO_NOW:
               this.setOrHideText(this.m_card.itemName_tf,this.m_info.goNowTitleText);
               this.setOrHideText(this.m_card.generic_tf,this.m_info.goNowDescText);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(this.m_info.goNowIconURL,this.m_card.icon));
               this.m_button.text = this.m_info.goNowButtonText;
               if(param6)
               {
                  this.m_button.disable_visual(true);
               }
               break;
            case TYPE_USE_ITEM:
               _loc7_ = this.m_info as ObtainRequirementPopupInfoUseItem;
               this.setOrHideText(this.m_card.itemName_tf,_loc7_.askTitleText);
               this.setOrHideText(this.m_card.generic_tf,_loc7_.askDescText);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc7_.askIconURL,this.m_card.icon));
               this.m_button.text = this.m_info.askButtonText;
               if(param6)
               {
                  this.m_button.disable_visual(true);
               }
         }
         this.m_card.underlay_mc.visible = this.m_card.itemName_tf != null && this.m_card.itemName_tf.numLines > 1;
         if(ZGlobal.player.allowOneClickBuy() && param5)
         {
            _loc8_ = Math.round(100 * (1 - this.m_info.buyCost / this.m_info.requirementGameItem.cash));
            if(_loc8_ > 0)
            {
               this.m_card.discount_tf.visible = true;
               TextFieldUtil.processTextField(this.m_card.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOff",{"amount":_loc8_}));
            }
            else
            {
               this.m_card.discount_tf.visible = false;
            }
            this.m_card.value_tf.visible = true;
            TextFieldUtil.processTextField(this.m_card.value_tf,ZGameUtils.ZlocT("Dialogs","OneClickBuyBestOffer"));
         }
         else
         {
            if(this.m_card.hasOwnProperty("value_tf"))
            {
               this.m_card.value_tf.visible = false;
            }
            if(this.m_card.hasOwnProperty("discount_tf"))
            {
               this.m_card.discount_tf.visible = false;
            }
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_button)
         {
            this.m_button.dispose();
         }
      }
      
      public function get card() : MovieClip
      {
         return this.m_card;
      }
      
      public function get info() : IObtainRequirementPopupInfo
      {
         return this.m_info;
      }
      
      private function setOrHideText(param1:TextField, param2:String) : void
      {
         if(param1)
         {
            if(param2)
            {
               TextFieldUtil.processTextField(param1,param2);
               param1.visible = true;
            }
            else
            {
               param1.visible = false;
            }
         }
      }
   }
}

