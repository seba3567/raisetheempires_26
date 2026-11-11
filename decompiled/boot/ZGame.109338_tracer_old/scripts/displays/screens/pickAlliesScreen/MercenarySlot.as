package displays.screens.pickAlliesScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.MercenaryItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class MercenarySlot extends GridSlot
   {
      
      public static const TYPE_MERCENARY:String = "mercenary";
      
      private var m_mercenaryItem:MercenaryItem = null;
      
      private var m_iconLoaders:Array = null;
      
      public function MercenarySlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:MercenaryItem, param7:Number)
      {
         this.m_mercenaryItem = param6;
         super(param1,param2,param3,param4,param5);
         slot.x = param4 * (slot.width * param7);
         slot.y = param5 * (slot.height * param7);
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "PickMercenaryCard";
      }
      
      override public function getData() : Object
      {
         return this.m_mercenaryItem;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(!isTutorialLocked() && param1.target == slot.buy_bt)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(PURCHASE,this));
         }
      }
      
      private function filloutStats() : void
      {
         this.m_iconLoaders = new Array();
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(this.m_mercenaryItem.imageUrl,slot.mercenaryCard_mc.icon));
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Cash_24.png"),slot.mercenaryCard_mc.cash_mc));
         TextFieldUtil.processTextField(slot.mercenaryCard_mc.name_tf,this.m_mercenaryItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.processTextField(slot.mercenaryCard_mc.level_tf,this.m_mercenaryItem.level.toString());
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_iconLoaders)
         {
            _loc1_.destroy();
         }
         this.m_mercenaryItem = null;
         super.dispose();
      }
      
      override protected function getObjectCode() : String
      {
         return this.m_mercenaryItem.code;
      }
   }
}

