package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import com.greensock.TweenMax;
   import com.greensock.easing.Sine;
   import core.ZGlobal;
   import core.managers.promoManager.PromoManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class PromoStarterPackUIItem extends PromoMenuItem
   {
      
      public static const ITEM_ID:String = "PromoStarterPackUIItem";
      
      private static const WOBBLE_MILLS:int = 1000;
      
      private static const IDLE_MILLS:int = 3000;
      
      private var loaderContentStart:Point = new Point();
      
      public function PromoStarterPackUIItem()
      {
         PromoManager.instance.addEventListener(PromoManager.EVENT_CLOSE_STARTER_PACK_HUD_ICON,this.onCloseSelf);
         swfPath = "assets/game/quests/Quests_Icons_0.swf/MOTD_FootLocker_64.png";
         toolTipFileName = "Promo";
         toolTipText = "promo_StarterPackHUD_toolTip";
         visible = false;
         tweenTimeSeconds = 2;
         super(ITEM_ID);
         m_removeOnClick = this.shouldBeRemovedOnClick();
         priority = 1;
      }
      
      private function onCloseSelf(param1:Event = null) : void
      {
         while(ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON) <= ZGlobal.gameSettings.getNumber("promoIconSeenAmount"))
         {
            ZGlobal.player.setSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON);
         }
         m_removeOnClick = this.shouldBeRemovedOnClick();
         dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false));
      }
      
      override protected function cleanup() : void
      {
         PromoManager.instance.removeEventListener(PromoManager.EVENT_CLOSE_STARTER_PACK_HUD_ICON,this.onCloseSelf);
         super.cleanup();
         Zlab.processManager.removeScheduledObject(this);
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
         StatsManager.countSample(100,"hud_icon","starter_pack","icon_viewed");
      }
      
      override protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         super.onLoadComplete(param1,param2);
         var _loc3_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
         Tooltip.subscribe(m_uiloader,_loc3_);
         this.loaderContentStart.x = m_uiloader.content.x;
         this.loaderContentStart.y = m_uiloader.content.y;
         Zlab.processManager.schedule(1000,this,this.startWobble);
      }
      
      private function startWobble() : void
      {
         TweenMax.killTweensOf(m_uiloader.content);
         m_uiloader.content.x = this.loaderContentStart.x;
         m_uiloader.content.y = this.loaderContentStart.y;
         var _loc1_:Number = 1.125;
         var _loc2_:Number = 0.5;
         var _loc3_:Number = -(_loc1_ - 1);
         var _loc4_:int = m_uiloader.content.width * (_loc3_ * 0.5);
         var _loc5_:int = m_uiloader.content.height * (_loc3_ * 0.5);
         TweenMax.to(m_uiloader.content,_loc2_,{
            "x":_loc4_.toString(),
            "y":_loc5_.toString(),
            "scaleX":_loc1_,
            "scaleY":_loc1_,
            "ease":Sine.easeInOut,
            "yoyo":true,
            "repeat":-1
         });
         Zlab.processManager.schedule(WOBBLE_MILLS,this,this.sitIdle);
      }
      
      private function sitIdle() : void
      {
         TweenMax.killTweensOf(m_uiloader.content);
         Zlab.processManager.schedule(IDLE_MILLS,this,this.startWobble);
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         m_removeOnClick = this.shouldBeRemovedOnClick();
         super.onClicked(param1);
         PromoManager.instance.openStarterPackPopup();
         ZGlobal.player.setSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON);
         StatsManager.countSample(100,"hud_icon","starter_pack","icon_clicked","delay","","",elapsedSinceShow);
      }
      
      private function shouldBeRemovedOnClick() : Boolean
      {
         if(ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON) >= ZGlobal.gameSettings.getNumber("promoIconSeenAmount") - 1)
         {
            return true;
         }
         return false;
      }
   }
}

