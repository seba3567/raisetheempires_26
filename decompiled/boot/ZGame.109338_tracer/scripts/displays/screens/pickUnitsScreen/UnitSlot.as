package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class UnitSlot extends GridSlot
   {
      
      protected var m_unitItem:UnitItem = null;
      
      protected var m_iconLoaders:Array = null;
      
      protected var m_index:int = 0;
      
      public function UnitSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Boolean, param8:int, param9:Number)
      {
         super(param1,param2,param3);
         slot.x = param4 * (sizerWidth * param9);
         slot.y = param5 * (sizerHeight * param9);
         if(param7)
         {
            select();
         }
         this.m_unitItem = param6;
         this.m_index = param8;
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      protected function get usingCash() : Boolean
      {
         return false;
      }
      
      override public function getData() : Object
      {
         return {
            "item":this.m_unitItem,
            "index":this.m_index,
            "useCash":this.usingCash
         };
      }
      
      override protected function getObjectCode() : String
      {
         return this.m_unitItem.code;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         if(!isTutorialLocked())
         {
            return new ItemTooltip(GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP,this.m_unitItem,ItemTooltip.SOURCE_NONE);
         }
         return null;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(m_selected)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DESELECTED,this));
         }
         else if(!isTutorialLocked())
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
         }
      }
      
      protected function filloutStats() : void
      {
         this.m_iconLoaders = new Array();
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_unitItem.name,"icon"),slot.unitCard_mc.icon));
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/unitEnergy.png"),slot.unitCard_mc.energyIcon_mc));
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/unitStrength.png"),slot.unitCard_mc.strengthIcon_mc));
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         TextFieldUtil.processTextField(slot.unitCard_mc.energyValue_tf,this.m_unitItem.attackCost.toString());
         TextFieldUtil.processTextField(slot.unitCard_mc.strengthValue_tf,String(this.m_unitItem.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_unitItem.code))));
         slot.unitCard_mc.strengthValue_tf.mouseEnabled = false;
         slot.unitCard_mc.levelInfo_tf.visible = false;
         slot.unitCard_mc.levelInfo_tf.mouseEnabled = false;
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
   }
}

