package core.managers.rewardPickupManager
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.domination.DominationModeManager;
   import core.ui.PlayerFeedbackManager;
   import core.ui.feedbacktext.ItemFeedbackText;
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class MysteryItemRewardPickup extends RewardPickup
   {
      
      private var m_item:GameItem = null;
      
      private var pos:Pt = null;
      
      private var jiggling2Waiting:Boolean = false;
      
      private var dooberAcceptBitmapLoaded:Boolean = false;
      
      private var m_mysterBoxOpenBitmap:BitmapData = null;
      
      public var m_result:Object = new Object();
      
      private var m_partFeature:Object = new Object();
      
      public function MysteryItemRewardPickup(param1:GameItem, param2:Object)
      {
         var _loc8_:Array = null;
         var _loc9_:Object = null;
         this.m_item = param1;
         var _loc3_:Array = new Array();
         var _loc4_:Number = DominationModeManager.instance.rivalsDominationRank;
         if(_loc4_ == -1)
         {
            _loc4_ = 1;
         }
         var _loc5_:Number = 2 * _loc4_;
         var _loc6_:Number = 10 * _loc4_;
         var _loc7_:Number = 200 * _loc4_;
         if(param2.hasOwnProperty("ore"))
         {
            this.m_result[RewardPickupSpawner.RESOURCE.toString()] = {"amount":_loc5_};
         }
         if(param2.hasOwnProperty("oil"))
         {
            this.m_result[RewardPickupSpawner.OIL.toString()] = {"amount":_loc6_};
         }
         if(param2.hasOwnProperty("coin"))
         {
            this.m_result[RewardPickupSpawner.COINS.toString()] = {"amount":_loc7_};
         }
         if(param2.hasOwnProperty("items"))
         {
            _loc8_ = param2.items;
            for each(_loc9_ in _loc8_)
            {
               _loc3_.push(_loc9_.code);
               if(_loc9_.hasOwnProperty("feature"))
               {
                  this.m_partFeature[_loc9_.code] = _loc9_.feature;
               }
            }
         }
         this.m_result[RewardPickupSpawner.ITEM.toString()] = _loc3_;
         m_feedbackText = new ItemFeedbackText(this.m_item.code,1);
         super(1,"mysteryitem",false);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.addToInventory(this.m_item.code);
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         if(this.m_item.hasCachedImage("doober"))
         {
            return this.m_item.getCachedImage("doober").url;
         }
         return this.m_item.getCachedImage("icon").url;
      }
      
      private function getDooberAcceptedImageUrl(param1:int) : String
      {
         return this.m_item.getCachedImage("openicon").url;
      }
      
      override protected function startMovement() : void
      {
         ImageLoaderFactory.CreateImageLoader(this.getDooberAcceptedImageUrl(m_amount),null,this.onDooberAcceptedImageLoaded);
         super.startMovement();
      }
      
      private function onDooberAcceptedImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(null != m_bitmap)
         {
            this.m_mysterBoxOpenBitmap = param2;
            if(this.jiggling2Waiting)
            {
               this.changeDooberIcon();
               this.onStartTimedJiggling2();
            }
            else
            {
               this.dooberAcceptBitmapLoaded = true;
            }
         }
      }
      
      private function changeDooberIcon() : void
      {
         var _loc1_:Number = NaN;
         this.pos = this.currPos;
         if(null != m_bitmap)
         {
            m_bitmap.bitmapData = this.m_mysterBoxOpenBitmap;
            m_bitmap.smoothing = true;
            if(this.scaleto60)
            {
               _loc1_ = 60 / m_bitmap.bitmapData.width;
               m_bitmap.scaleX = m_bitmap.scaleY = _loc1_;
            }
            createParticles(20);
         }
      }
      
      private function showNewItem() : void
      {
         var _loc2_:GameItem = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:GameItem = null;
         var _loc8_:String = null;
         createParticles(50);
         this.changeDooberIcon();
         var _loc1_:RewardPickupSpawner = new RewardPickupSpawner(this.pos);
         var _loc3_:int = 0;
         if(this.m_result)
         {
            for(_loc4_ in this.m_result)
            {
               if(_loc4_ != RewardPickupSpawner.ITEM.toString())
               {
                  if(!this.m_result[_loc4_])
                  {
                     continue;
                  }
                  _loc3_ = int(this.m_result[_loc4_].amount);
                  switch(_loc4_)
                  {
                     case RewardPickupSpawner.XP.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.XP,
                           "amount":_loc3_
                        });
                        break;
                     case RewardPickupSpawner.COINS.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.COINS,
                           "amount":_loc3_
                        });
                        break;
                     case RewardPickupSpawner.RESOURCE.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.RESOURCE,
                           "rareType":ZGlobal.player.rareResourceName,
                           "amount":_loc3_
                        });
                        break;
                     case RewardPickupSpawner.ENERGY.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.ENERGY,
                           "amount":_loc3_
                        });
                        break;
                     case RewardPickupSpawner.AMMO.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.AMMO,
                           "amount":_loc3_
                        });
                        break;
                     case RewardPickupSpawner.OIL.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.OIL,
                           "amount":_loc3_
                        });
                        break;
                     case RewardPickupSpawner.MANA.toString():
                        _loc1_.addLoot({
                           "type":RewardPickupSpawner.MANA,
                           "amount":_loc3_
                        });
                  }
               }
               else
               {
                  for each(_loc5_ in this.m_result[_loc4_])
                  {
                     _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
                     _loc1_.addLoot({
                        "type":RewardPickupSpawner.ITEM,
                        "item":_loc5_
                     });
                     if(Boolean(this.m_partFeature) && this.m_partFeature.hasOwnProperty(_loc5_))
                     {
                        _loc6_ = this.m_partFeature[_loc5_];
                        _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_,GameItem) as GameItem;
                        _loc8_ = _loc7_.getCachedImage("icon").url;
                        if(_loc7_)
                        {
                           PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Doober_Toaster_Msg",{
                              "part":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                              "building":_loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
                           }),null,null,null,_loc8_);
                        }
                     }
                  }
               }
               delete this.m_result[_loc4_];
            }
         }
         _loc1_.delay = 500;
         _loc1_.go(RewardPickup.FLAG_LEFT_ONLY);
      }
      
      override protected function onStartTimedJiggling2() : void
      {
         if(!this.dooberAcceptBitmapLoaded)
         {
            this.jiggling2Waiting = true;
            return;
         }
         Zlab.processManager.schedule(750,this,this.changeDooberIcon);
         Zlab.processManager.schedule(1000,this,this.showNewItem);
         jiggle(0.1,1.5);
      }
      
      override protected function onClick(param1:MouseEvent) : void
      {
         m_sprite.removeEventListener(MouseEvent.CLICK,this.onClick);
         removeFromScheduler();
         this.onStartTimedJiggling2();
         Zlab.processManager.schedule(2000,this,doDooberPickup);
      }
      
      override protected function onOver(param1:MouseEvent) : void
      {
         m_sprite.removeEventListener(MouseEvent.CLICK,this.onClick);
         removeFromScheduler();
         this.onStartTimedJiggling2();
         Zlab.processManager.schedule(2000,this,doDooberPickup);
      }
      
      override protected function get uiName() : String
      {
         return this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
      }
      
      override public function get pickupName() : String
      {
         return "mysteryitem";
      }
      
      override protected function get soundEvent() : String
      {
         if(Boolean(this.m_item.xml.sound) && this.m_item.xml.sound.length() > 0)
         {
            return this.m_item.xml.sound[0].@name;
         }
         return "xpPickup";
      }
      
      override protected function get scaleto60() : Boolean
      {
         return true;
      }
   }
}

