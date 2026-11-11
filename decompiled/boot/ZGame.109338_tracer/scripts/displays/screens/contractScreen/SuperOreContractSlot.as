package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.resource.WorldResource;
   import core.ui.Style;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextFormat;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class SuperOreContractSlot extends ResourceContractSlot
   {
      
      private var m_multiplier:int;
      
      public function SuperOreContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:GameItem, param9:Number, param10:String = null, param11:int = 1)
      {
         this.m_multiplier = param11;
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10);
      }
      
      override protected function populateCard() : void
      {
         var _loc4_:Array = null;
         var _loc5_:WorldResource = null;
         var _loc6_:GameDataComponent = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:TextFormat = null;
         var _loc10_:Number = NaN;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc1_:Boolean = false;
         disposeImageLoaders();
         m_imageLoaders = new Array();
         TextFieldUtil.setMouseEnabled([slot.itemName_tf,slot.detail_mc.resource0_tf,slot.detail_mc.resource1_tf,slot.detail_mc.costTitle_tf,slot.detail_mc.rewardTitle_tf,slot.detail_mc.duration_tf,slot.level_tf],false);
         slot.buttonMode = true;
         slot.useHandCursor = true;
         TextFieldUtil.processTextField(slot.itemName_tf,m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc2_:String = null;
         if(m_resourceType == null)
         {
            _loc2_ = m_item.resourceType == "rare" ? m_item.getContractImageURL(ZGlobal.hostPlayer.rareResourceType) : ZGlobal.gameSettings.getImageByName(m_item.name,"icon");
         }
         else
         {
            m_item.resourceName = m_resourceType;
            _loc2_ = m_item.getContractImageURL(WorldResourceManager.instance.getResourceIndexFromType(m_resourceType));
         }
         m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_,slot.icon));
         var _loc3_:BitArray = ZGlobal.player.checkGate(m_item);
         if(!_loc3_.anyBitSet())
         {
            m_isBuyable = true;
            if(m_item.cash > 0)
            {
               _loc1_ = true;
            }
            if(_loc1_)
            {
               m_buildBtn = new ZGameButton(slot.buy_bt,onBuyNowButton);
               m_buildBtn.text = ZLoc.t("Dialogs","BuyNow");
               slot.build_bt.visible = false;
            }
            else
            {
               m_buildBtn = new ZGameButton(slot.build_bt,onSelectButton);
               m_buildBtn.text = ZLoc.t("Dialogs","SelectButton");
               slot.buy_bt.visible = false;
            }
            slot.locked_mc.visible = false;
            slot.level_tf.visible = false;
            _loc4_ = m_item.resourceCosts;
            _loc5_ = _loc4_[0] as WorldResource;
            if(_loc1_)
            {
               TextFieldUtil.processTextField(slot.detail_mc.resource0_tf,Math.abs(m_item.cash * this.m_multiplier).toString());
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(EP_ICON_PATH),slot.detail_mc.resourceIcon0));
            }
            else if(_loc5_.valid)
            {
               TextFieldUtil.processTextField(slot.detail_mc.resource0_tf,Math.abs(_loc5_.amount).toString());
               _loc8_ = WorldResourceManager.instance.getResourceImageURLByType(_loc5_.type,WorldResourceManager.XTRA_SMALL_ICON);
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc8_,slot.detail_mc.resourceIcon0));
               if(!ZGlobal.player.hasResource(_loc5_))
               {
                  _loc9_ = new TextFormat();
                  _loc9_.color = Style.COLOR_UNSUFFICIENT_RESOURCES;
                  slot.detail_mc.resource0_tf.setTextFormat(_loc9_);
               }
            }
            _loc6_ = GameDataComponent(m_entity.lookupComponentByType(GameDataComponent));
            if(_loc1_)
            {
               TextFieldUtil.processTextField(slot.detail_mc.duration_tf,ZLoc.t("Dialogs","ContractInstantComplete"));
            }
            else
            {
               _loc10_ = m_item.getMatureDuration(_loc6_.gameData.name);
               _loc11_ = ZGameTimeUtil.instance.getTimeString(_loc10_);
               TextFieldUtil.processTextField(slot.detail_mc.duration_tf,_loc11_);
            }
            _loc7_ = null;
            if(m_resourceType == null)
            {
               _loc7_ = m_item.resourceType == "rare" ? WorldResourceManager.instance.getResourceImageURL(ZGlobal.hostPlayer.rareResourceType,WorldResourceManager.XTRA_SMALL_ICON) : WorldResourceManager.instance.getResourceImageURLByType(m_item.resourceType,WorldResourceManager.XTRA_SMALL_ICON);
            }
            else
            {
               _loc7_ = WorldResourceManager.instance.getResourceImageURLByType(m_resourceType,WorldResourceManager.XTRA_SMALL_ICON);
            }
            if(_loc7_)
            {
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc7_,slot.detail_mc.resourceIcon1));
            }
            TextFieldUtil.processTextField(slot.detail_mc.resource1_tf,(m_item.getProducesAmount(_loc6_.gameData.name) * this.m_multiplier).toString());
            TextFieldUtil.processTextField(slot.detail_mc.costTitle_tf,ZLoc.t("Dialogs","ContractCostTitle"));
            TextFieldUtil.processTextField(slot.detail_mc.rewardTitle_tf,ZLoc.t("Dialogs","ContractRewardTitle"));
         }
         else
         {
            slot.build_bt.visible = false;
            slot.buy_bt.visible = false;
            slot.detail_mc.visible = false;
            _loc12_ = m_item.getGateFailureString(_loc3_);
            TextFieldUtil.processTextField(slot.level_tf,_loc12_ ? _loc12_ : "");
            slot.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
      }
   }
}

