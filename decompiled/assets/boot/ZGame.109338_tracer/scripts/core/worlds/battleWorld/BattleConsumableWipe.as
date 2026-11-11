package core.worlds.battleWorld
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.gameobjects.MercenaryItem;
   import core.gameobjects.questPower.QuestPower;
   import core.player.IAlly;
   import core.ui.menuitem.FriendsBarUIItem;
   import displays.ImageLoaderFactory;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.CombatBar.DeployableBanner;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BattleConsumableWipe extends BattleMovie
   {
      
      private var m_images:Array = null;
      
      private var m_consumable:ConsumableItem = null;
      
      private var m_name:String = null;
      
      public function BattleConsumableWipe(param1:DisplayObjectContainer, param2:SWFResource)
      {
         super(param1,param2);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_USED,this.onConsumableUsed);
         m_classes = new Array(1);
         m_classes[0] = DeployableBanner;
      }
      
      override public function dispose() : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONSUMABLE_USED,this.onConsumableUsed);
         super.dispose();
         this.m_images = null;
      }
      
      override protected function initMovie(param1:MovieClip, param2:int) : void
      {
         param1.x = BattleRendererComponent.WIDTH * 0.5;
         param1.y = 200;
         param1.PlayerIcon.icon_mc.source = this.m_images[0];
         param1.PlayerIcon.icon_mc.source.smoothing = true;
         param1.PlayerIcon.icon_mc.load();
         if(this.m_images[1] != null)
         {
            param1.ConsumableIcon.icon_mc.source = this.m_images[1];
            param1.ConsumableIcon.icon_mc.load();
         }
         else
         {
            param1.ConsumableIcon.visible = false;
         }
         var _loc3_:String = ZGameUtils.ZlocT("Combat","ConsumableCast",{"player":this.m_name});
         TextFieldUtil.compactTextField(param1.PlayerTextBox.title_tf,_loc3_,{
            "maxLines":1,
            "minScale":0.4,
            "onFail":"return"
         });
         TextFieldUtil.compactTextField(param1.ConsumableTextBox.title_tf,this.m_consumable.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "maxLines":1,
            "minScale":0.4,
            "onFail":"return"
         });
         this.m_consumable = null;
      }
      
      private function onConsumableUsed(param1:WorldEvent) : void
      {
         var _loc5_:IAlly = null;
         var _loc6_:String = null;
         this.m_consumable = param1.eventData.item;
         var _loc2_:String = param1.eventData.id;
         if(QuestPower.isQuestPower(_loc2_))
         {
            return;
         }
         this.m_images = new Array(2);
         var _loc3_:ItemImage = this.m_consumable.getCachedImage("icon");
         ImageLoaderFactory.CreateImageLoader(_loc3_.url,null,this.onConsumableImageLoaded);
         var _loc4_:MercenaryItem = ZGlobal.gameSettings.getItemByCode(_loc2_,MercenaryItem) as MercenaryItem;
         if(null != _loc4_)
         {
            this.m_name = _loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            ImageLoaderFactory.CreateImageLoader(_loc4_.imageUrl,null,this.onPlayerImageLoaded);
         }
         else
         {
            _loc5_ = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).findNeighborById(_loc2_);
            this.m_name = _loc5_.firstName;
            _loc6_ = _loc5_.imageUrl;
            if(null != _loc6_)
            {
               ImageLoaderFactory.CreateImageLoader(_loc6_,null,this.onPlayerImageLoaded,this.onPlayerImageFailed);
            }
            else
            {
               this.onPlayerImageFailed();
            }
         }
      }
      
      private function onPlayerImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(null != this.m_images)
         {
            this.m_images[0] = new Bitmap(param2);
            this.tryTrigger();
         }
      }
      
      private function onPlayerImageFailed() : void
      {
         this.onPlayerImageLoaded("",null);
      }
      
      private function onConsumableImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(null != this.m_images)
         {
            this.m_images[1] = new Bitmap(param2);
            this.tryTrigger();
         }
         else if(m_movieClip != null)
         {
            m_movieClip.ConsumableIcon.icon_mc.source = new Bitmap(param2);
            m_movieClip.ConsumableIcon.icon_mc.load();
            m_movieClip.ConsumableIcon.visible = true;
         }
      }
      
      private function tryTrigger() : void
      {
         if(this.m_images[0] != null)
         {
            SoundEvent.getSoundEvent("Roulette").play();
            triggerMovie(0);
            this.m_images = null;
         }
      }
      
      override protected function onComplete() : void
      {
         if(Boolean(m_movieClip) && Boolean(m_current))
         {
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_TRIGGER_CONSUMABLE));
         }
         super.onComplete();
      }
   }
}

