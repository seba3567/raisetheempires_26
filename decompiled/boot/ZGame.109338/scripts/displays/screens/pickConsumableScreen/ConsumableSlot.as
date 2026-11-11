package displays.screens.pickConsumableScreen
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.managers.tutorialManager.TutorialManager;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class ConsumableSlot extends GridSlot
   {
      
      public static const CLICKED:String = "clicked";
      
      protected var m_consumableItem:ConsumableItem = null;
      
      protected var m_iconLoaders:Array = null;
      
      protected var m_index:int = 0;
      
      public function ConsumableSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:ConsumableItem, param7:Boolean, param8:int, param9:Number)
      {
         this.m_consumableItem = param6;
         this.m_index = param8;
         super(param1,param2,param3);
         slot.x = param4 * (slot.width * param9);
         slot.y = param5 * (slot.height * param9);
         if(param7)
         {
            slot.selected_mc.visible = true;
         }
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      override public function getData() : Object
      {
         return {
            "item":this.m_consumableItem,
            "index":this.m_index
         };
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         if(TutorialManager.instance.active)
         {
            if(!TutorialManager.instance.specialPowerTooltipsEnabled)
            {
               return null;
            }
         }
         return new ItemTooltip(GameItem.CONSUMABLE_TOOLTIP,this.m_consumableItem,ItemTooltip.SOURCE_NONE);
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(slot.selected_mc.visible)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DESELECTED,this));
         }
         else
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
         }
         screen.dispatchEvent(new WorldEvent(CLICKED,this.m_consumableItem));
      }
      
      protected function filloutStats() : void
      {
         this.m_iconLoaders = new Array();
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_consumableItem.name,"icon"),slot.unitCard_mc.icon);
         _loc1_.smooth = true;
         this.m_iconLoaders.push(_loc1_);
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_consumableItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         ZGameUtils.hideIfExists(slot.unitCard_mc.energyValue_tf);
         ZGameUtils.hideIfExists(slot.unitCard_mc.strengthValue_tf);
         ZGameUtils.hideIfExists(slot.unitCard_mc.levelInfo_tf);
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_iconLoaders)
         {
            _loc1_.destroy();
         }
         this.m_iconLoaders = null;
         super.dispose();
      }
      
      override protected function getObjectCode() : String
      {
         return this.m_consumableItem.code;
      }
   }
}

