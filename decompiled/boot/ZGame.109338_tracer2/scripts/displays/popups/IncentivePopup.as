package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.WorldResourceManager;
   import core.ui.GenericButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TClearIncentivePopup;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   
   public class IncentivePopup extends GallantPopup
   {
      
      private static var INCENTIVE_POPUP_OPTIONS:Object = {};
      
      private var m_button:GenericButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_items:Array = null;
      
      private var m_loaders:Array = null;
      
      private var m_resources:Array = null;
      
      private var m_ep:Array = null;
      
      private var m_descLabel:String = "incentiveDesc";
      
      private var m_descLabelTokens:Object;
      
      private var m_suppressTransaction:Boolean;
      
      private var m_quantityOverride:int = 1;
      
      public function IncentivePopup(param1:Object)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Incentive.swf"));
         if(param1.incentiveCode)
         {
            this.m_items = ZGlobal.gameSettings.getIncentiveItems(param1.incentiveCode);
            this.m_resources = ZGlobal.gameSettings.getIncentiveResources(param1.incentiveCode);
            this.m_ep = ZGlobal.gameSettings.getIncentiveEP(param1.incentiveCode);
         }
         else
         {
            if(param1.items as Array)
            {
               this.m_items = param1.items;
            }
            if(param1.resources as Array)
            {
               this.m_resources = param1.resources;
            }
         }
         if(param1.suppressTransaction)
         {
            this.m_suppressTransaction = param1.suppressTransaction;
         }
         if(param1.dialogTokens)
         {
            this.m_descLabelTokens = param1.dialogTokens;
         }
         if(param1.quantityOverride > 1)
         {
            this.m_quantityOverride = param1.quantityOverride;
         }
         if(param1.dialogLabel as String)
         {
            this.m_descLabel = param1.dialogLabel;
         }
         else if(Boolean(this.m_items) && this.m_items.length > 1)
         {
            this.m_descLabel = "incentiveDesc";
         }
         else
         {
            this.m_descLabel = "incentiveSingleDesc";
         }
      }
      
      public static function createSentGiftRewardPopup(param1:Boolean, param2:String, param3:XML) : void
      {
         var _loc5_:Object = null;
         var _loc14_:GameItem = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc4_:Object = rewardObjectFromZRTReward(ZGlobal.interstitialGiftingRewards);
         if(!_loc4_ || !_loc4_[param2])
         {
            return;
         }
         _loc5_ = _loc4_[param2];
         var _loc6_:int = int(_loc5_["count"]);
         var _loc7_:String = _loc5_["type"];
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:Boolean = _loc5_["overridepopupicon"] != null;
         var _loc11_:Boolean = _loc5_["overriderewardlabel"] != null;
         var _loc12_:int = 0;
         var _loc13_:int = 1;
         while(_loc13_ <= int(param2))
         {
            _loc12_ += _loc4_[_loc13_]["sentGiftsReceivedAmount"];
            _loc13_++;
         }
         switch(_loc7_)
         {
            case "item":
               _loc14_ = ZGlobal.gameSettings.getItemByCode(_loc5_["item"],GameItem) as GameItem;
               _loc8_ = [_loc14_.code];
               break;
            default:
               _loc15_ = "";
               _loc16_ = "";
               if(_loc10_)
               {
                  _loc15_ = ":" + _loc5_["overridepopupicon"];
               }
               if(_loc11_)
               {
                  _loc16_ = ":" + _loc5_["overriderewardlabel"];
               }
               _loc9_ = [_loc7_ + ":" + _loc6_ + _loc15_ + _loc16_];
         }
         createIncentivePopup(param1,_loc8_,_loc9_,"incentiveSentGiftsReceived",{"numSentGiftsReceived":_loc12_},true,_loc6_);
      }
      
      public static function createIncentivePopup(param1:Boolean, param2:Array = null, param3:Array = null, param4:String = null, param5:Object = null, param6:Boolean = true, param7:int = 0) : void
      {
         INCENTIVE_POPUP_OPTIONS.items = param2;
         INCENTIVE_POPUP_OPTIONS.dialogLabel = param4;
         INCENTIVE_POPUP_OPTIONS.dialogTokens = param5;
         INCENTIVE_POPUP_OPTIONS.suppressTransaction = param6;
         INCENTIVE_POPUP_OPTIONS.quantityOverride = param7;
         INCENTIVE_POPUP_OPTIONS.resources = param3;
         if(param1)
         {
            MessageOfTheDayManager.instance.addEventListener(MessageOfTheDayManager.EVENT_SHOWN_ALL_MESSAGES,doIncentivePopup,false,0,true);
         }
         else
         {
            doIncentivePopup();
         }
      }
      
      private static function doIncentivePopup(param1:Event = null) : void
      {
         var _loc2_:GallantPopup = new IncentivePopup(INCENTIVE_POPUP_OPTIONS);
         PopupManager.instance.push(_loc2_);
      }
      
      private static function rewardObjectFromZRTReward(param1:String) : Object
      {
         var zrtReward:Array = null;
         var itemXML:XML = null;
         var reward:Object = null;
         var zrt:String = param1;
         var itemsXML:XMLList = ZGlobal.gameSettings.getXML().interstitialItemInfo;
         var rewards:Object = new Object();
         var zrtRewards:Array = zrt.split("|");
         var i:int = 0;
         while(i < zrtRewards.length)
         {
            zrtReward = String(zrtRewards[i]).split(",");
            itemXML = itemsXML.itemInfo.(@id == zrtReward[2])[0];
            reward = {
               "sentGiftsReceivedAmount":int(zrtReward[0]),
               "count":int(zrtReward[1]),
               "interstitialIcon":itemXML.@image.toString()
            };
            if(itemXML.@overridedisplayedamount.toString().length)
            {
               reward["overridedisplayedamount"] = itemXML.@overridedisplayedamount.toString();
            }
            if(itemXML.@type.toString().length)
            {
               reward["type"] = itemXML.@type.toString();
            }
            if(itemXML.@item.toString().length)
            {
               reward["item"] = itemXML.@item.toString();
            }
            if(itemXML.@overridepopupicon.toString().length)
            {
               reward["overridepopupicon"] = itemXML.@overridepopupicon.toString();
            }
            if(itemXML.@overriderewardlabel.toString().length)
            {
               reward["overriderewardlabel"] = itemXML.@overriderewardlabel.toString();
            }
            rewards[String(i + 1)] = reward;
            i++;
         }
         return rewards;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = m_window.incentive.background_mc.width;
         this.contentHeight = m_window.incentive.background_mc.height;
         m_window.incentive.background_mc.visible = false;
         centerWithinStage(Zlab.mainStage);
         this.setUpPopupUI();
      }
      
      protected function setUpPopupUI() : void
      {
         this.m_loaders = new Array();
         TextFieldUtil.processTextField(m_window.incentive.title_tf,ZGameUtils.ZlocT("Dialogs","incentiveTitle"));
         TextFieldUtil.processTextField(m_window.incentive.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_descLabel,this.m_descLabelTokens));
         m_window.incentive.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_button = new GenericButton(m_window.incentive.green_bt,this.onExit);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","Accept");
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(m_window.incentive.exit_bt,ButtonSound.DEFAULT);
         this.setupRewards();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         super.deinitDialog();
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_button = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window.incentive.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         super.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         if(!this.m_suppressTransaction)
         {
            TransactionManager.addTransaction(new TClearIncentivePopup());
         }
         this.close();
      }
      
      private function setupRewards() : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:GameItem = null;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:Number = NaN;
         var _loc11_:LocalizationObjectToken = null;
         var _loc12_:ImageLoader = null;
         m_window.incentive.icons_even.visible = false;
         m_window.incentive.icons_odd.visible = false;
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.m_items)
         {
            _loc2_ += this.m_items.length;
         }
         if(this.m_resources)
         {
            _loc2_ += this.m_resources.length;
         }
         if(this.m_ep)
         {
            _loc2_ += this.m_ep.length;
         }
         if(_loc2_ % 2 == 0)
         {
            m_window.incentive.icons_even.visible = true;
            _loc1_ = [m_window.incentive.icons_even.icon1,m_window.incentive.icons_even.icon2];
         }
         else
         {
            m_window.incentive.icons_odd.visible = true;
            _loc1_ = [m_window.incentive.icons_odd.icon2,m_window.incentive.icons_odd.icon1,m_window.incentive.icons_odd.icon3];
         }
         var _loc3_:int = 0;
         if(this.m_items)
         {
            _loc6_ = 0;
            while(_loc6_ < this.m_items.length)
            {
               _loc7_ = ZGlobal.gameSettings.getItemByCode(this.m_items[_loc6_],GameItem) as GameItem;
               _loc1_[_loc6_].visible = true;
               _loc4_ = _loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               if(this.m_quantityOverride > 1)
               {
                  _loc5_ = ZGameUtils.ZlocT("Gifts","Quantity",{"quantity":this.m_quantityOverride});
                  _loc4_ += "  " + _loc5_;
               }
               TextFieldUtil.processTextField(_loc1_[_loc6_].name_tf,_loc4_);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc7_.getCachedImage("icon").url,_loc1_[_loc6_].icon));
               _loc3_++;
               _loc6_++;
            }
         }
         if(this.m_resources)
         {
            _loc8_ = _loc3_;
            _loc6_ = 0;
            while(_loc6_ < this.m_resources.length)
            {
               _loc9_ = this.m_resources[_loc6_].split(":");
               _loc1_[_loc6_].visible = true;
               _loc10_ = Number(_loc9_[1]);
               _loc11_ = ZGameUtils.ZlocTk("Items",_loc9_[0] + "_sentenceName","",_loc10_);
               TextFieldUtil.processTextField(_loc1_[_loc6_ + _loc8_].name_tf,ZGameUtils.ZlocT("Main","GenericItemAmount_Object",{
                  "amount":_loc10_,
                  "item":_loc11_
               }));
               if(_loc9_.length > 2)
               {
                  _loc12_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc9_[2]),_loc1_[_loc6_ + _loc8_].icon);
                  _loc12_.smooth = true;
               }
               else
               {
                  _loc12_ = ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType(_loc9_[0],WorldResourceManager.XTRA_LARGE_ICON),_loc1_[_loc6_ + _loc8_].icon);
               }
               this.m_loaders.push(_loc12_);
               _loc3_++;
               _loc6_++;
            }
         }
         if(this.m_ep)
         {
            _loc6_ = 0;
            while(_loc6_ < this.m_ep.length)
            {
               _loc1_[_loc6_].visible = true;
               _loc4_ = ZGameUtils.ZlocT("Main","Cash");
               _loc5_ = ZGameUtils.ZlocT("Gifts","Quantity",{"quantity":this.m_ep[_loc6_]});
               _loc4_ += "  " + _loc5_;
               TextFieldUtil.processTextField(_loc1_[_loc6_].name_tf,_loc4_);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_90.png"),_loc1_[_loc6_].icon));
               _loc3_++;
               _loc6_++;
            }
         }
         while(_loc3_ < _loc1_.length)
         {
            _loc1_[_loc3_].visible = false;
            _loc3_++;
         }
      }
   }
}

