package displays.screens.researchScreens
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldUpgradeManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   
   public class UpgradesDisplay
   {
      
      private const BUBBLE_TEXT_OFFSET:int = 5;
      
      private var m_parent:MovieClip = null;
      
      private var m_tooltipContainer:MovieClip = null;
      
      private var m_unitItem:UnitItem = null;
      
      private var m_unitUpgrades:Array = null;
      
      private var m_upgradeClips:Array = null;
      
      private var m_upgradeTooltip:MovieClip = null;
      
      private var m_iconLoaders:Array = new Array();
      
      private var m_currentUpgradeMouseOver:UpgradeItem = null;
      
      private var m_researchTemplate:XMLList = null;
      
      private var m_forceShow:Boolean = false;
      
      public function UpgradesDisplay(param1:Array, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:UnitItem, param6:Array, param7:Boolean = false)
      {
         super();
         this.m_upgradeClips = param1;
         this.m_upgradeTooltip = param3;
         this.m_parent = param2;
         this.m_tooltipContainer = param4;
         this.m_unitItem = param5;
         this.m_unitUpgrades = param6;
         this.m_forceShow = param7;
         this.m_researchTemplate = WorldUpgradeManager.instance.getResearchTemplate(this.m_unitItem.researchTemplate);
         this.fillOutUpgrades();
         if(this.m_upgradeTooltip)
         {
            this.initTooltip();
         }
      }
      
      protected function fillOutUpgrades() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:UpgradeItem = null;
         var _loc4_:int = 0;
         var _loc5_:UpgradeItem = null;
         var _loc1_:int = ZGameTimeUtil.instance.getDateStatus(null,GameItem(this.m_unitItem).xml);
         if(!this.m_forceShow && (!ZGlobal.player.getSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG) || this.m_unitItem.zpoints))
         {
            if(this.m_parent)
            {
               this.m_parent.visible = false;
            }
            if(this.m_upgradeTooltip)
            {
               this.m_upgradeTooltip.visible = false;
            }
            return;
         }
         if(this.m_parent)
         {
            this.m_parent.visible = true;
         }
         if(Boolean(this.m_researchTemplate) && Boolean(this.m_upgradeClips))
         {
            this.m_iconLoaders = new Array();
            _loc2_ = WorldUpgradeManager.instance.getTotalUpgrades(this.m_unitItem.code);
            _loc3_ = null;
            _loc4_ = 0;
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && WorldUpgradeManager.instance.isTechResearch(this.m_unitItem.researchTemplate))
            {
               _loc4_ = 0;
               while(_loc4_ < _loc2_ - 1)
               {
                  _loc3_ = ZGlobal.gameSettings.getItemByCode(this.m_researchTemplate.upgrade[_loc4_].@code,UpgradeItem) as UpgradeItem;
                  _loc5_ = ZGlobal.gameSettings.getItemByCode(this.m_researchTemplate.upgrade[_loc4_ + 1].@code,UpgradeItem) as UpgradeItem;
                  if(Boolean(this.m_unitUpgrades) && this.m_unitUpgrades.indexOf(_loc3_.code) >= 0)
                  {
                     if(_loc3_.strengthModifier > 0 && this.m_unitUpgrades.indexOf(_loc5_.code) >= 0)
                     {
                        this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"ShieldStrengthIcon"),this.m_upgradeClips[_loc4_]));
                     }
                     else
                     {
                        this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"screenIcon"),this.m_upgradeClips[_loc4_]));
                     }
                  }
                  else if(Boolean(this.m_unitUpgrades) && Boolean(_loc3_.strengthModifier > 0) && this.m_unitUpgrades.indexOf(_loc5_.code) >= 0)
                  {
                     this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc5_.name,"screenIcon"),this.m_upgradeClips[_loc4_]));
                  }
                  else
                  {
                     this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,_loc5_.shieldModifier > 0 ? "screenIconGray_shield" : "screenIconGray"),this.m_upgradeClips[_loc4_]));
                  }
                  _loc4_++;
               }
            }
            else
            {
               _loc4_ = 0;
               while(_loc4_ < _loc2_)
               {
                  _loc3_ = ZGlobal.gameSettings.getItemByCode(this.m_researchTemplate.upgrade[_loc4_].@code,UpgradeItem) as UpgradeItem;
                  if(Boolean(this.m_unitUpgrades) && this.m_unitUpgrades.indexOf(_loc3_.code) >= 0)
                  {
                     this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"screenIcon"),this.m_upgradeClips[_loc4_]));
                  }
                  else
                  {
                     this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"screenIconGray"),this.m_upgradeClips[_loc4_]));
                  }
                  _loc4_++;
               }
            }
         }
      }
      
      protected function initTooltip() : void
      {
         var _loc1_:int = 0;
         if(this.m_researchTemplate)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_upgradeClips.length)
            {
               this.m_upgradeClips[_loc1_].addEventListener(MouseEvent.ROLL_OVER,this.onRollOverUpgrade,false,0,true);
               this.m_upgradeClips[_loc1_].addEventListener(MouseEvent.ROLL_OUT,this.onRollOutUpgrade,false,0,true);
               _loc1_++;
            }
         }
         this.m_upgradeTooltip.generic_tf.autoSize = TextFieldAutoSize.LEFT;
         this.m_upgradeTooltip.name_tf.autoSize = TextFieldAutoSize.LEFT;
         this.m_upgradeTooltip.visible = false;
      }
      
      protected function onRollOverUpgrade(param1:MouseEvent) : void
      {
         var _loc2_:int = this.getIndexFromEvent(param1);
         this.m_currentUpgradeMouseOver = ZGlobal.gameSettings.getItemByCode(this.m_researchTemplate.upgrade[_loc2_].@code,UpgradeItem) as UpgradeItem;
         this.fillOutTooltip();
         this.m_tooltipContainer.addChild(this.m_upgradeTooltip);
         var _loc3_:Number = param1.currentTarget.x + param1.currentTarget.width * 0.5;
         var _loc4_:Number = Number(param1.currentTarget.y);
         var _loc5_:Point = this.m_parent.localToGlobal(new Point(_loc3_,_loc4_));
         var _loc6_:Point = this.m_tooltipContainer.globalToLocal(_loc5_);
         this.m_upgradeTooltip.x = _loc6_.x;
         this.m_upgradeTooltip.y = _loc6_.y;
         this.m_upgradeTooltip.visible = true;
         this.m_upgradeTooltip.alpha = 0;
         TweenLite.to(this.m_upgradeTooltip,0.25,{"alpha":1});
      }
      
      protected function onRollOutUpgrade(param1:MouseEvent) : void
      {
         this.m_upgradeTooltip.visible = false;
         this.m_currentUpgradeMouseOver = null;
      }
      
      protected function fillOutTooltip() : void
      {
         var _loc1_:TextField = null;
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc4_:Object = null;
         if(this.m_currentUpgradeMouseOver)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && this.m_currentUpgradeMouseOver.strengthModifier > 0 && WorldUpgradeManager.instance.isTechResearch(this.m_unitItem.researchTemplate))
            {
               TextFieldUtil.processTextField(this.m_upgradeTooltip.name_tf,ZGameUtils.ZlocT("Tooltips","UpgradeTooltipHint_Shield"));
            }
            else
            {
               TextFieldUtil.processTextField(this.m_upgradeTooltip.name_tf,this.m_currentUpgradeMouseOver.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            }
            if(Boolean(this.m_unitUpgrades) && this.m_unitUpgrades.indexOf(this.m_currentUpgradeMouseOver.code) >= 0)
            {
               TextFieldUtil.processTextField(this.m_upgradeTooltip.generic_tf,this.m_currentUpgradeMouseOver.resultText);
            }
            else
            {
               _loc2_ = WorldUpgradeManager.getResearchBuildingCodeOfType(this.m_unitItem.subType);
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
               if(_loc3_)
               {
                  _loc4_ = {"building":_loc3_.getSentenceNameLocalizationObject("singular,definite")};
               }
               TextFieldUtil.processTextField(this.m_upgradeTooltip.generic_tf,ZGameUtils.ZlocT("Tooltips","UpgradeTooltipHint",_loc4_));
            }
            _loc1_ = this.m_upgradeTooltip.generic_tf.width > this.m_upgradeTooltip.name_tf.width ? this.m_upgradeTooltip.generic_tf : this.m_upgradeTooltip.name_tf;
            this.m_upgradeTooltip.bubble.width = _loc1_.width + 2 * this.BUBBLE_TEXT_OFFSET;
         }
      }
      
      public function setUnitItem(param1:UnitItem, param2:Array) : void
      {
         this.m_unitItem = param1;
         this.m_unitUpgrades = param2;
         this.m_researchTemplate = WorldUpgradeManager.instance.getResearchTemplate(this.m_unitItem.researchTemplate);
         this.clearIconLoaders();
         this.fillOutUpgrades();
         if(Boolean(this.m_upgradeTooltip) && this.m_upgradeTooltip.visible == true)
         {
            this.fillOutTooltip();
         }
      }
      
      public function get unitItem() : UnitItem
      {
         return this.m_unitItem;
      }
      
      public function dispose() : void
      {
         var _loc1_:int = 0;
         if(this.m_upgradeTooltip)
         {
            TweenLite.killTweensOf(this.m_upgradeTooltip);
            _loc1_ = 0;
            while(_loc1_ < this.m_upgradeClips.length)
            {
               this.m_upgradeClips[_loc1_].removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverUpgrade);
               this.m_upgradeClips[_loc1_].removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutUpgrade);
               _loc1_++;
            }
         }
         this.clearIconLoaders();
         this.m_researchTemplate = null;
      }
      
      protected function clearIconLoaders() : void
      {
         var _loc1_:int = 0;
         if(this.m_iconLoaders)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_iconLoaders.length)
            {
               ImageLoader(this.m_iconLoaders[_loc1_]).destroy();
               this.m_iconLoaders[_loc1_] = null;
               _loc1_++;
            }
         }
         this.m_iconLoaders = new Array();
      }
      
      protected function getIndexFromEvent(param1:MouseEvent) : int
      {
         var _loc2_:String = "0";
         if(param1 != null)
         {
            _loc2_ = String(param1.currentTarget.name).replace(/icon/,"");
         }
         return int(_loc2_);
      }
   }
}

