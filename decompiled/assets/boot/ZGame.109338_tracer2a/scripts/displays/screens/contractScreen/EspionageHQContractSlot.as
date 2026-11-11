package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.EspionageHQManager;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class EspionageHQContractSlot extends GridSlot
   {
      
      public static const DEPLOY_SPY:String = "deploy_spy";
      
      public static const EQUIP_SPY:String = "equip_spy";
      
      public static const FINISH_SPY:String = "finish_spy";
      
      private var m_item:GameItem;
      
      protected var m_deployBtn:ZGameButton;
      
      protected var m_buildBtn:ZGameButton;
      
      protected var m_iconLoaders:Array = null;
      
      public function EspionageHQContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:GameItem, param5:Number, param6:int = 0, param7:int = 0)
      {
         super(param1,param2,param3);
         this.m_item = param4;
         slot.x = param6 * (sizerWidth * param5);
         slot.y = param7 * (sizerHeight * param5);
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      override public function getData() : Object
      {
         return this.m_item;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return null;
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_buildBtn) && this.m_buildBtn.enabled)
         {
            this.onEquipClicked(param1);
         }
      }
      
      protected function filloutStats() : void
      {
         var _loc1_:String = null;
         var _loc2_:UnitItem = null;
         slot.unitCard_mc.icon.filters = [];
         slot.unitCard_mc.gotoAndStop("powerup");
         slot.unitCard_mc.bg_mc_plan.visible = false;
         slot.unitCard_mc.bg_mc_locked.visible = false;
         slot.unitCard_mc.bg_mc_soon.visible = false;
         slot.unitCard_mc.bg_mc_sf_ready.visible = false;
         slot.unitCard_mc.highlightSelect_mc.visible = false;
         slot.unitCard_mc.soon_tf.visible = false;
         slot.unitCard_mc.locked_tf.visible = false;
         slot.unitCard_mc.count_mc.visible = false;
         slot.unitCard_mc.buy_bt.visible = false;
         this.m_buildBtn = new ZGameButton(slot.unitCard_mc.build_bt,this.onEquipClicked);
         this.m_buildBtn.text = ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Dialog_Equip_Button");
         m_buttonSounds.addButton(this.m_buildBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_deployBtn = new ZGameButton(slot.unitCard_mc.deploy_bt,this.onDeployClicked);
         this.m_deployBtn.text = ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Dialog_Send_Button");
         m_buttonSounds.addButton(this.m_deployBtn.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(slot.unitCard_mc.header_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Tier_Button_" + this.m_item.code));
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.m_iconLoaders = new Array();
         this.m_buildBtn.show();
         this.m_deployBtn.show();
         if(EspionageHQManager.instance.hasStolenUnit)
         {
            _loc1_ = EspionageHQManager.instance.stolenUnit;
            this.m_buildBtn.disable(true);
            this.m_deployBtn.disable(true);
            if(EspionageHQManager.instance.spyDeployed == this.m_item.code)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_,UnitItem) as UnitItem;
               slot.unitCard_mc.bg_mc_sf_ready.visible = true;
               this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon"),slot.unitCard_mc.icon));
               TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            }
            else
            {
               slot.unitCard_mc.bg_mc_plan.visible = true;
               this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon"),slot.unitCard_mc.icon));
               slot.unitCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            }
         }
         else if(EspionageHQManager.instance.spyDeployed == this.m_item.code)
         {
            this.m_buildBtn.disable(true);
            this.m_deployBtn.disable(true);
            slot.unitCard_mc.bg_mc_sf_ready.visible = true;
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon"),slot.unitCard_mc.icon));
         }
         else if(EspionageHQManager.instance.spyDeployed != null)
         {
            this.m_buildBtn.disable(true);
            this.m_deployBtn.disable(true);
            slot.unitCard_mc.bg_mc_plan.visible = true;
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon"),slot.unitCard_mc.icon));
            slot.unitCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
         else if(EspionageHQManager.instance.isSpyEquipped(this.m_item.code))
         {
            this.m_buildBtn.disable(true);
            slot.unitCard_mc.bg_mc_plan.visible = true;
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon"),slot.unitCard_mc.icon));
         }
         else
         {
            this.m_deployBtn.disable(true);
            slot.unitCard_mc.bg_mc_plan.visible = true;
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon"),slot.unitCard_mc.icon));
         }
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
      }
      
      protected function onEquipClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(EQUIP_SPY,this));
      }
      
      protected function onDeployClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(DEPLOY_SPY,{"spyItem":this.m_item}));
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_deployBtn)
         {
            this.m_deployBtn.dispose();
         }
         if(this.m_buildBtn)
         {
            this.m_buildBtn.dispose();
         }
         if(this.m_iconLoaders != null)
         {
            for each(_loc1_ in this.m_iconLoaders)
            {
               _loc1_.destroy();
            }
            this.m_iconLoaders = null;
         }
         super.dispose();
      }
   }
}

