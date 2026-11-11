package displays.screens.researchScreens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.ui.Style;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class UpgradeSlot extends MovieClip
   {
      
      public static const SELECTED:String = "selected";
      
      protected var m_unitItem:UnitItem;
      
      protected var m_templateXml:XML;
      
      protected var m_iconLoaders:Array = null;
      
      protected var m_content:MovieClip = null;
      
      protected var m_upgradeItem:UpgradeItem = null;
      
      protected var m_upgradeBtn:ZGameButton;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_discountInfo:Dictionary;
      
      protected var m_decoEffects:Array;
      
      protected var m_decoTargetEntity:IEntity;
      
      private var m_arrow:MovieClip;
      
      public function UpgradeSlot(param1:MovieClip, param2:XML, param3:UnitItem, param4:MovieClip, param5:Dictionary, param6:Array = null, param7:IEntity = null)
      {
         super();
         this.m_content = param1;
         this.m_templateXml = param2;
         this.m_unitItem = param3;
         this.m_arrow = param4;
         this.m_discountInfo = param5;
         this.m_decoEffects = param6;
         this.m_decoTargetEntity = param7;
         this.filloutStats();
      }
      
      public function getData() : Object
      {
         return {
            "researchItem":this.m_unitItem,
            "referenceItem":this.m_upgradeItem
         };
      }
      
      public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(GameItem.UPGRADE_TOOLTIP,this.m_upgradeItem,ItemTooltip.SOURCE_NONE);
      }
      
      protected function onUpgradeClicked(param1:MouseEvent) : void
      {
         if(Boolean(this.m_upgradeBtn) && this.m_upgradeBtn.enabled)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
         }
      }
      
      protected function filloutStats() : void
      {
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         var _loc13_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:TextFormat = null;
         var _loc18_:int = 0;
         var _loc19_:Object = null;
         this.m_upgradeItem = ZGlobal.gameSettings.getItemByCode(this.m_templateXml.@code,UpgradeItem) as UpgradeItem;
         TextFieldUtil.processTextField(this.m_content.itemName_tf,this.m_upgradeItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.m_content.itemName_tf.mouseEnabled = false;
         this.m_content.highlight_mc.visible = false;
         this.m_iconLoaders = new Array();
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_upgradeItem.name,"icon"),this.m_content.icon);
         _loc1_.smooth = true;
         this.m_iconLoaders.push(_loc1_);
         var _loc2_:Boolean = true;
         var _loc3_:String = this.m_templateXml.@requires;
         if(Boolean(_loc3_) && _loc3_.length > 0)
         {
            _loc6_ = _loc3_.split(",");
            for each(_loc7_ in _loc6_)
            {
               if(!WorldUpgradeManager.instance.hasUpgrade(this.m_unitItem.code,_loc7_))
               {
                  _loc2_ = false;
               }
            }
         }
         var _loc4_:Array = WorldUpgradeManager.instance.getUpgradesByCode(this.m_unitItem.code);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         var _loc5_:int = _loc4_.indexOf(this.m_upgradeItem.code);
         if(_loc5_ >= 0)
         {
            this.m_content.gotoAndStop("completed");
            this.m_content.levelInfo_tf.visible = false;
            this.m_content.upgradeInfo_tf.visible = true;
            TextFieldUtil.processTextField(this.m_content.upgradeInfo_tf,this.m_upgradeItem.resultText);
            if(this.m_arrow)
            {
               this.m_arrow.gotoAndStop("filled");
            }
         }
         else if(!_loc2_)
         {
            this.m_content.gotoAndStop("locked");
            TextFieldUtil.processTextField(this.m_content.levelInfo_tf,this.requirementsString(_loc3_));
            this.m_content.levelInfo_tf.visible = true;
            this.m_content.upgradeInfo_tf.visible = false;
            this.m_content.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
         else
         {
            this.m_content.gotoAndStop("available");
            this.m_content.buttonMode = true;
            this.m_content.useHandCursor = true;
            TextFieldUtil.processTextField(this.m_content.costTitle_tf,ZGameUtils.ZlocT("Dialogs","ContractCostTitle"));
            this.m_content.costTitle_tf.mouseEnabled = false;
            this.m_content.levelInfo_tf.visible = false;
            this.m_content.upgradeInfo_tf.visible = false;
            _loc8_ = 0;
            _loc9_ = [this.m_content.resource_mc_0,this.m_content.resource_mc_1,this.m_content.resource_mc_2,this.m_content.resource_mc_3];
            _loc10_ = [this.m_content.resource_tf_0,this.m_content.resource_tf_1,this.m_content.resource_tf_2,this.m_content.resource_tf_3];
            if(!this.m_upgradeItem.usesCash())
            {
               _loc13_ = this.m_upgradeItem.resourceCosts;
               _loc1_ = null;
               _loc14_ = 0;
               while(_loc14_ < _loc13_.length)
               {
                  if(_loc8_ < _loc10_.length && Boolean(_loc13_[_loc14_].valid))
                  {
                     _loc15_ = int(_loc13_[_loc14_].amount);
                     if(this.m_discountInfo)
                     {
                        _loc18_ = 0;
                        for each(_loc19_ in this.m_discountInfo)
                        {
                           if(Boolean(_loc19_.resources) && Boolean(_loc19_.resources as Array) && _loc19_.resources.indexOf(_loc13_[_loc14_].type) >= 0)
                           {
                              _loc18_ += _loc19_.amount;
                           }
                        }
                        _loc15_ = DecorationsManager.instance.applyResourceDiscount(_loc15_,_loc18_);
                     }
                     TextFieldUtil.processTextField(_loc10_[_loc8_],Math.abs(_loc15_).toString());
                     _loc16_ = WorldResourceManager.instance.getResourceImageURLByType(_loc13_[_loc14_].type,WorldResourceManager.XTRA_SMALL_ICON);
                     _loc1_ = ImageLoaderFactory.CreateImageLoader(_loc16_,_loc9_[_loc8_]);
                     this.m_iconLoaders.push(_loc1_);
                     _loc10_[_loc8_].visible = true;
                     _loc10_[_loc8_].mouseEnabled = false;
                     _loc17_ = new TextFormat();
                     _loc17_.color = !ZGlobal.player.hasResource(_loc13_[_loc14_]) ? Style.COLOR_UNSUFFICIENT_RESOURCES : 0;
                     _loc10_[_loc8_].setTextFormat(_loc17_);
                  }
                  _loc8_++;
                  _loc14_++;
               }
            }
            else
            {
               TextFieldUtil.processTextField(_loc10_[_loc8_],this.m_upgradeItem.cash.toString());
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Cash_24.png"),_loc9_[_loc8_]);
               this.m_iconLoaders.push(_loc1_);
               _loc10_[_loc8_].visible = true;
               _loc10_[_loc8_].mouseEnabled = false;
               _loc17_ = new TextFormat();
               _loc17_.color = !ZGlobal.player.canBuyCash(this.m_upgradeItem.cash,false) ? Style.COLOR_UNSUFFICIENT_FUNDS : 0;
               _loc10_[_loc8_].setTextFormat(_loc17_);
               _loc8_++;
            }
            while(_loc8_ < _loc10_.length)
            {
               _loc10_[_loc8_].visible = false;
               _loc10_[_loc8_].mouseEnabled = false;
               _loc8_++;
            }
            _loc11_ = this.m_upgradeItem.getMatureDuration(null);
            if(this.m_decoEffects != null && this.m_decoEffects.indexOf(DecorationsManager.EFFECT_ARMY_RESEARCH_ACCELERATION) != -1)
            {
               _loc11_ = DecorationsManager.instance.applyResearchAccelerationDecoEffect(_loc11_,this.m_decoTargetEntity);
            }
            _loc12_ = ZGameTimeUtil.instance.getTimeString(_loc11_);
            TextFieldUtil.processTextField(this.m_content.duration_tf,_loc12_);
            this.m_content.duration_tf.mouseEnabled = false;
            this.m_upgradeBtn = new ZGameButton(this.m_content.upgrade_bt,this.onUpgradeClicked,1.025);
            this.m_upgradeBtn.text = ZGameUtils.ZlocT("Dialogs","ResearchButtonText");
            this.m_buttonSounds.addButton(this.m_upgradeBtn.m_overlay,ButtonSound.DEFAULT);
            this.m_content.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverUpgrade,false,0,true);
            this.m_content.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutUpgrade,false,0,true);
            this.m_content.addEventListener(MouseEvent.CLICK,this.onUpgradeClicked,false,0,true);
            if(this.m_arrow)
            {
               this.m_arrow.gotoAndStop("filled");
            }
         }
         this.m_buttonSounds.addButton(this.m_content,ButtonSound.PANEL);
      }
      
      private function onRollOverUpgrade(param1:MouseEvent) : void
      {
         this.m_content.highlight_mc.visible = true;
      }
      
      private function onRollOutUpgrade(param1:MouseEvent) : void
      {
         this.m_content.highlight_mc.visible = false;
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_iconLoaders)
         {
            _loc1_.destroy();
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_iconLoaders = null;
         if(this.m_upgradeBtn)
         {
            this.m_upgradeBtn.dispose();
         }
         this.m_content.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverUpgrade);
         this.m_content.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutUpgrade);
         this.m_content.removeEventListener(MouseEvent.CLICK,this.onUpgradeClicked);
      }
      
      private function requirementsString(param1:String) : String
      {
         var _loc3_:UpgradeItem = null;
         var _loc4_:UpgradeItem = null;
         var _loc2_:Array = param1.split(",");
         switch(_loc2_.length)
         {
            case 1:
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_[0],UpgradeItem) as UpgradeItem;
               return ZGameUtils.ZlocT("Dialogs","ResearchRequirements1",{"req1":_loc3_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
            case 2:
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_[0],UpgradeItem) as UpgradeItem;
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc2_[1],UpgradeItem) as UpgradeItem;
               return ZGameUtils.ZlocT("Dialogs","ResearchRequirements2",{
                  "req1":_loc3_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME),
                  "req2":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)
               });
            default:
               return "";
         }
      }
   }
}

