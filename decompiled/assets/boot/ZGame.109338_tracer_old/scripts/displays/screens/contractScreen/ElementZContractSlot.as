package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.resource.WorldResource;
   import core.ui.Style;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.InventoryLimitPopup;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextFormat;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class ElementZContractSlot extends ResourceContractSlot
   {
      
      private var inventoryLimit:Boolean = false;
      
      private var elementUrl:String = "assets/game/GeneralAssetGroup_UI.swf/ElementZ_90.png";
      
      private var manaItem:GameItem = null;
      
      private var m_popup:InventoryLimitPopup = null;
      
      public function ElementZContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:GameItem, param9:Number, param10:String = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10);
      }
      
      override protected function populateCard() : void
      {
         var _loc3_:GameDataComponent = null;
         var _loc7_:Array = null;
         var _loc8_:WorldResource = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc16_:TextFormat = null;
         var _loc17_:String = null;
         disposeImageLoaders();
         m_imageLoaders = new Array();
         TextFieldUtil.setMouseEnabled([slot.itemName_tf,slot.detail_mc.resource0_tf,slot.detail_mc.resource1_tf,slot.detail_mc.costTitle_tf,slot.detail_mc.rewardTitle_tf,slot.detail_mc.duration_tf,slot.level_tf],false);
         slot.buttonMode = true;
         slot.useHandCursor = true;
         TextFieldUtil.processTextField(slot.itemName_tf,m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc1_:String = null;
         if(m_resourceType == null)
         {
            _loc1_ = ZGlobal.gameSettings.getImageByName(m_item.name,"icon");
         }
         else
         {
            m_item.resourceName = m_resourceType;
            _loc1_ = m_item.getContractImageURL(WorldResourceManager.instance.getResourceIndexFromType(m_resourceType));
         }
         m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc1_,slot.icon));
         var _loc2_:BitArray = ZGlobal.player.checkGate(m_item);
         _loc3_ = GameDataComponent(m_entity.lookupComponentByType(GameDataComponent));
         var _loc4_:String = m_item.getProducesCode(_loc3_.gameData.name);
         this.manaItem = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
         var _loc5_:int = ZGlobal.player.inventory[_loc4_] ? int(ZGlobal.player.inventory[_loc4_]) : 0;
         var _loc6_:int = this.manaItem.inventoryCap;
         if(_loc5_ >= _loc6_)
         {
            slot.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            this.inventoryLimit = true;
         }
         if(!_loc2_.anyBitSet())
         {
            m_isBuyable = true;
            m_buildBtn = new ZGameButton(slot.build_bt,this.onSelectButton);
            m_buildBtn.text = ZLoc.t("Dialogs","SelectButton");
            slot.buy_bt.visible = false;
            slot.locked_mc.visible = false;
            slot.level_tf.visible = false;
            _loc7_ = m_item.resourceCosts;
            _loc8_ = _loc7_[0] as WorldResource;
            if(_loc8_.valid)
            {
               TextFieldUtil.processTextField(slot.detail_mc.resource0_tf,Math.abs(_loc8_.amount).toString());
               _loc15_ = WorldResourceManager.instance.getResourceImageURLByType(_loc8_.type,WorldResourceManager.XTRA_SMALL_ICON);
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc15_,slot.detail_mc.resourceIcon0));
               if(!ZGlobal.player.hasResource(_loc8_))
               {
                  _loc16_ = new TextFormat();
                  _loc16_.color = Style.COLOR_UNSUFFICIENT_RESOURCES;
                  slot.detail_mc.resource0_tf.setTextFormat(_loc16_);
               }
            }
            _loc9_ = ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/ElementZ_24.png");
            m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc9_,slot.detail_mc.resourceIcon1));
            _loc10_ = ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Star_24.png");
            m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc10_,slot.detail_mc.resourceIcon2));
            _loc8_ = _loc7_[1] as WorldResource;
            if(_loc8_.valid)
            {
               TextFieldUtil.processTextField(slot.detail_mc.resource0_tf_a,Math.abs(_loc8_.amount).toString());
               _loc15_ = WorldResourceManager.instance.getResourceImageURLByType(_loc8_.type,WorldResourceManager.XTRA_SMALL_ICON);
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc15_,slot.detail_mc.resourceIcon0a));
               if(!ZGlobal.player.hasResource(_loc8_))
               {
                  _loc16_ = new TextFormat();
                  _loc16_.color = Style.COLOR_UNSUFFICIENT_RESOURCES;
                  slot.detail_mc.resource0_tf_a.setTextFormat(_loc16_);
               }
            }
            _loc11_ = m_item.getMatureDuration(_loc3_.gameData.name);
            _loc12_ = ZGameTimeUtil.instance.getTimeString(_loc11_);
            TextFieldUtil.processTextField(slot.detail_mc.duration_tf,_loc12_);
            _loc13_ = this.manaItem.manaYield;
            TextFieldUtil.processTextField(slot.detail_mc.resource1_tf,_loc13_.toString());
            _loc14_ = int(m_item.getStateMachineValues("ElementZCollider")["$HarvestXP"]);
            TextFieldUtil.processTextField(slot.detail_mc.resource1_tf_a,_loc14_.toString());
            TextFieldUtil.processTextField(slot.detail_mc.costTitle_tf,ZLoc.t("Dialogs","ContractCostTitle"));
            TextFieldUtil.processTextField(slot.detail_mc.rewardTitle_tf,ZLoc.t("Dialogs","ContractRewardTitle"));
         }
         else
         {
            slot.build_bt.visible = false;
            slot.buy_bt.visible = false;
            slot.detail_mc.visible = false;
            _loc17_ = m_item.getGateFailureString(_loc2_);
            TextFieldUtil.processTextField(slot.level_tf,_loc17_ ? _loc17_ : "");
            slot.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
      }
      
      override protected function onSelectButton(param1:MouseEvent) : void
      {
         if(this.inventoryLimit)
         {
            this.m_popup = new InventoryLimitPopup("ElementZCollider_Dialog_03",this.elementUrl,this.manaItem.manaYield);
            WindowManager.instance.push(this.m_popup);
         }
         else
         {
            super.onSelectButton(param1);
         }
      }
   }
}

