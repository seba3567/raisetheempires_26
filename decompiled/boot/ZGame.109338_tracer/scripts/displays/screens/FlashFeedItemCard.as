package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.SoundItem;
   import core.gameobjects.UnitItem;
   import core.managers.FlashFeedManager;
   import core.managers.WorldUpgradeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class FlashFeedItemCard
   {
      
      private static const UNSELECTED_OUT_STATE:int = 1;
      
      private static const UNSELECTED_OVER_STATE:int = 2;
      
      private static const SELECTED_OUT_STATE:int = 3;
      
      private static const SELECTED_OVER_STATE:int = 4;
      
      private var m_card:MovieClip;
      
      private var m_itemInfo:Object;
      
      private var m_item:UnitItem;
      
      private var m_itemFriendlyName:String;
      
      private var m_itemTokenCount:String;
      
      private var m_icon:ImageLoader;
      
      private var m_selected:Boolean = false;
      
      private var m_redeemButton:ZGameButton = null;
      
      private var m_buttonSound:SoundItem = null;
      
      private var m_redeemCallback:Function = null;
      
      public function FlashFeedItemCard(param1:Object, param2:Function)
      {
         super();
         this.m_itemInfo = param1;
         this.m_redeemCallback = param2;
      }
      
      public function dispose() : void
      {
         if(this.m_icon)
         {
            this.m_icon.destroy();
            this.m_icon = null;
         }
         if(this.m_redeemButton)
         {
            this.m_redeemButton.dispose();
            this.m_redeemButton = null;
         }
         this.m_buttonSound = null;
         this.m_card = null;
      }
      
      public function setCard(param1:MovieClip, param2:Boolean) : void
      {
         var _loc3_:Rectangle = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         if(this.m_card)
         {
            this.dispose();
         }
         this.m_card = param1;
         if(this.m_card)
         {
            if(this.m_itemInfo)
            {
               _loc3_ = this.m_card.getBounds(this.m_card.parent);
               this.m_card.itemName_tf.mouseEnabled = false;
               this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_itemInfo.item,UnitItem) as UnitItem;
               if(this.m_item != null)
               {
                  this.m_itemFriendlyName = this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  this.m_itemTokenCount = this.m_itemInfo.tokens.toString() + "x " + ZGameUtils.ZlocT("Dialogs","FlashFeed_TokenName");
                  TextFieldUtil.compactTextField(this.m_card.itemName_tf,this.m_itemFriendlyName,{
                     "minScale":0.6,
                     "maxLines":3,
                     "fontSize":14
                  });
                  TextFieldUtil.compactTextField(this.m_card.count_tf,this.m_itemTokenCount);
                  _loc5_ = ZGlobal.gameSettings.getImageByName(GameItem(this.m_item).name,"icon");
                  if(null != _loc5_)
                  {
                     this.m_icon = ImageLoaderFactory.CreateImageLoader(_loc5_,this.m_card.icon);
                  }
                  _loc6_ = this.m_item.xml.unit.toString().length > 0;
                  if(_loc6_)
                  {
                     _loc7_ = this.m_item.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_itemInfo.item));
                     TextFieldUtil.compactTextField(this.m_card.strength_mc.strength_tf,_loc7_.toString());
                     this.m_card.strength_mc.visible = true;
                  }
                  else
                  {
                     this.m_card.strength_mc.visible = false;
                  }
                  this.m_card.visible = true;
               }
               else
               {
                  this.m_card.visible = false;
               }
               _loc4_ = ZGameUtils.ZlocT("Dialogs","Redeem");
               this.m_redeemButton = new ZGameButton(this.m_card.buy_bt,this.onClick);
               if(param2 == true)
               {
                  this.m_redeemButton.enable();
               }
               else
               {
                  this.m_redeemButton.disable(true);
               }
               this.m_redeemButton.compactText(_loc4_,{
                  "maxLines":1,
                  "minScale":0.5,
                  "onFail":"return"
               });
               this.m_redeemButton.show();
            }
            else
            {
               this.m_card.visible = false;
            }
         }
      }
      
      public function get itemInfo() : Object
      {
         return this.m_itemInfo;
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
         FlashFeedManager.getInstance().didRedeemItem(this.m_itemInfo.item,this.m_itemInfo.tokens);
         this.m_redeemCallback();
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

