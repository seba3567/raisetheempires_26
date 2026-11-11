package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gamemode.prebattle.PreBattleUI;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.EspionageHQManager;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.ui.Tooltip;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StackedUnitsSlot extends UnitSlotV2
   {
      
      private var m_unitInfo:StackedUnitInfo = null;
      
      public function StackedUnitsSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:StackedUnitInfo, param7:int, param8:Number)
      {
         this.m_unitInfo = param6;
         super(param1,param2,param3,param4,param5,param6.unitItem,false,param7,param8);
         m_removeBtn.hide();
         this.updateUIButtons();
      }
      
      public function get unitInfo() : StackedUnitInfo
      {
         return this.m_unitInfo;
      }
      
      public function getUnitInfoForSlot() : StackedUnitInfo
      {
         var _loc1_:UnitItem = null;
         if(this.m_unitInfo.unitItem.hasType(UnitItem.MEGA_UNIT_WEAPON))
         {
            _loc1_ = (PreBattleUI.getPreBattleUI() as PreBattleUI).titanUI.getMegaUnitFromUnits(this.m_unitInfo.unitItem.megaUnits);
            return new StackedUnitInfo(_loc1_,1);
         }
         return this.m_unitInfo;
      }
      
      protected function get canEnableAddButton() : Boolean
      {
         return true;
      }
      
      private function updateUIButtons() : void
      {
         if(this.canEnableAddButton && this.m_unitInfo.quantity > 0)
         {
            m_addBtn.enable();
         }
         else
         {
            m_addBtn.disable_visual();
         }
      }
      
      public function enableAddButton() : void
      {
         m_addBtn.enable();
      }
      
      public function disableAddButton() : void
      {
         m_addBtn.disable_visual();
      }
      
      public function updateQuantityUI(param1:int, param2:String) : Boolean
      {
         var _loc3_:Boolean = this.unitInfo.incrementQuantity(param1,param2);
         slot.unitCard_mc.unitNum_tf.text = this.m_unitInfo.quantity;
         this.updateUIButtons();
         if(!_loc3_)
         {
            if(param1 < 0)
            {
               return this.unitInfo.quantity == 0;
            }
         }
         return _loc3_;
      }
      
      public function disableStolenUnitUI() : void
      {
         slot.cloned_mc.alpha = 0;
         this.updateUIButtons();
      }
      
      public function enableStolenUnitUI() : void
      {
         slot.cloned_mc.alpha = 100;
         this.updateUIButtons();
      }
      
      public function addTooltip(param1:String) : void
      {
         Tooltip.subscribe(slot,param1,{"followMouse":false});
         Tooltip.unsubscribe(slot.unitCard_mc.strengthBar_mc);
      }
      
      public function removeTooltip() : void
      {
         Tooltip.unsubscribe(slot);
         this.initStrenghBarTooltip();
      }
      
      override protected function filloutStats() : void
      {
         m_iconLoaders = new Array();
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(m_unitItem.getCachedImage("icon").url,slot.unitCard_mc.icon);
         _loc1_.smooth = true;
         m_iconLoaders.push(_loc1_);
         if(slot.unitCard_mc.tierRating_mc)
         {
            slot.unitCard_mc.tierRating_mc.visible = false;
         }
         var _loc2_:UnitClass = UnitClassManager.instance.unitClassForUnit(m_unitItem);
         if(_loc2_)
         {
            m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_.getSmIconURL()),slot.unitCard_mc.class_icon));
         }
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         slot.unitCard_mc.underlay_mc.visible = slot.unitCard_mc.itemName_tf.numLines > 1;
         var _loc3_:int = m_unitItem.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(m_unitItem.code));
         TextFieldUtil.processTextField(slot.unitCard_mc.strengthValue_tf,String(_loc3_));
         this.resizeStrengthText(slot.unitCard_mc.strengthValue_tf,_loc3_);
         slot.unitCard_mc.strengthValue_tf.mouseEnabled = false;
         TextFieldUtil.processTextField(slot.unitCard_mc.unitNum_tf,String(this.m_unitInfo.quantity));
         slot.unitCard_mc.unitNum_tf.mouseEnabled = false;
         if(Boolean(slot.unitCard_mc.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
         {
            TextFieldUtil.compactTextField(slot.unitCard_mc.tierRating_mc.tier_tf,String(m_unitItem.tier));
            slot.unitCard_mc.tierRating_mc.visible = true;
         }
         if(!EspionageHQManager.instance.isUnitInPreBattle && EspionageHQManager.instance.stolenUnit == m_unitItem.code && EspionageHQManager.instance.shouldShowCard())
         {
            slot.cloned_mc.alpha = 100;
         }
         this.initStrenghBarTooltip();
      }
      
      private function resizeStrengthText(param1:TextField, param2:int) : void
      {
         var _loc3_:TextFormat = null;
         if(param2 >= 1000)
         {
            _loc3_ = new TextFormat();
            _loc3_.size = 10;
            param1.setTextFormat(_loc3_);
            param1.x -= 3;
            param1.width += 3;
         }
      }
      
      private function initStrenghBarTooltip() : void
      {
         Tooltip.subscribe(slot.unitCard_mc.strengthBar_mc,ZGameUtils.ZlocT("Tooltips","StrengthTooltip"));
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         if(!isTutorialLocked())
         {
            return new ItemTooltip(this.m_unitInfo.unitItem.secondaryAbility ? GameItem.SUPPORT_UNIT_TOOLTIP : GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP,this.m_unitInfo.unitItem);
         }
         return null;
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      override protected function getStencilCircleModifier(param1:WorldEvent) : Number
      {
         return 0.65;
      }
      
      override public function dispose() : void
      {
         Tooltip.unsubscribe(slot.unitCard_mc.strengthBar_mc);
         Tooltip.unsubscribe(slot);
         super.dispose();
      }
   }
}

