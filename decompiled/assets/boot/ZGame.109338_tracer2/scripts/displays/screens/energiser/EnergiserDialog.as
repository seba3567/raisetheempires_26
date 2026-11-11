package displays.screens.energiser
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.EnergiserManager;
   import core.managers.WorldResourceManager;
   import core.resource.WorldResource;
   import core.ui.Style;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class EnergiserDialog extends ZGamePopUp
   {
      
      public static const ENERGIZER_ACTIVATED:String = "energized_activated";
      
      protected var m_eventDispatcher:EventDispatcher;
      
      protected var m_entity:IEntity;
      
      protected var m_active:Boolean;
      
      protected var m_display:Boolean;
      
      protected var m_remainingTime:String;
      
      protected var m_reqItem:GameItem;
      
      protected var m_supplyButton:ZGameButton;
      
      protected var m_okButton:ZGameButton;
      
      public function EnergiserDialog(param1:EventDispatcher, param2:IEntity, param3:Boolean = false, param4:Boolean = false, param5:String = null)
      {
         this.m_eventDispatcher = param1;
         this.m_entity = param2;
         this.m_active = param3;
         this.m_display = param4;
         this.m_remainingTime = param5;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_EnergonBooster.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity, param3:Boolean = false, param4:Boolean = false, param5:String = null) : PopUpBase
      {
         var _loc6_:PopUpBase = new EnergiserDialog(param1,param2,param3,param4,param5);
         WindowManager.instance.push(_loc6_);
         return _loc6_;
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         return param1.clip.screen_mc;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         initDialog();
         this.setupText();
         this.setupResources();
         this.setupIcons();
         addChild(m_window);
         m_origOffsetX = param1.clip.x;
         m_origOffsetY = param1.clip.y;
         centerWithinStage(Zlab.mainStage);
      }
      
      protected function setupText() : void
      {
         var _loc3_:String = null;
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_02_Title");
         TextFieldUtil.compactTextField(m_window.title_tf,_loc1_);
         if(this.m_active)
         {
            _loc3_ = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_02_Desc_01",{"time":this.m_remainingTime});
            TextFieldUtil.compactTextField(m_window.description_tf_0,_loc3_);
         }
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_02_Desc_02");
         TextFieldUtil.compactTextField(m_window.description_tf_1,_loc2_);
      }
      
      protected function setupResources() : void
      {
         var _loc6_:WorldResource = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc1_:GameItem = EnergiserManager.instance.getResourceItem();
         var _loc2_:Array = _loc1_.resourceCosts;
         var _loc3_:uint = 0;
         var _loc4_:Array = [m_window.resource_mc_0,m_window.resource_mc_1];
         var _loc5_:Array = [];
         for each(_loc6_ in _loc2_)
         {
            _loc7_ = ZGameUtils.ZlocT("Items",_loc6_.type + "_menuName");
            TextFieldUtil.compactTextField(_loc4_[_loc3_].name_tf,_loc7_);
            _loc8_ = Math.abs(_loc6_.amount).toString();
            _loc5_[_loc3_] = _loc8_;
            TextFieldUtil.compactTextField(_loc4_[_loc3_].num_tf,_loc8_);
            _loc9_ = WorldResourceManager.instance.getResourceImageURLByType(_loc6_.type,WorldResourceManager.LARGE_ICON);
            ImageLoaderFactory.CreateImageLoader(_loc9_,_loc4_[_loc3_].icon);
            if(!ZGlobal.player.hasResource(_loc6_))
            {
               this.setTextFieldColor(_loc4_[_loc3_].num_tf,false);
            }
            _loc3_++;
         }
         if(!this.m_active)
         {
            _loc10_ = ZGameUtils.ZlocT("Items",ZGlobal.player.rareResourceName + "_menuName");
            _loc11_ = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_03_Desc_01",{
               "amount1":_loc5_[0],
               "amount2":_loc5_[1],
               "rare":_loc10_
            });
            TextFieldUtil.compactTextField(m_window.description_tf_0,_loc11_);
         }
         this.m_reqItem = _loc1_;
      }
      
      private function setTextFieldColor(param1:TextField, param2:Boolean) : void
      {
         var _loc3_:TextFormat = null;
         var _loc4_:Object = null;
         if(param1)
         {
            _loc3_ = param1.getTextFormat();
            _loc4_ = _loc3_.color;
            _loc3_.color = param2 ? _loc4_ : Style.COLOR_UNSUFFICIENT_RESOURCES;
            param1.setTextFormat(_loc3_);
         }
      }
      
      protected function setupIcons() : void
      {
         var _loc1_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         var _loc2_:GameItem = _loc1_.gameData;
         var _loc3_:String = ZGlobal.gameSettings.getImageByName(_loc2_.name,"screenicon");
         ImageLoaderFactory.CreateImageLoader(_loc3_,m_window.icon);
         m_window.ok_bt.visible = false;
         this.m_okButton = null;
         this.m_supplyButton = null;
         if(this.m_active)
         {
            m_window.place_bt.gotoAndStop(m_window.place_bt.totalFrames);
         }
         else
         {
            this.m_supplyButton = new ZGameButton(m_window.place_bt,this.onSupplyClick);
         }
         m_window.place_bt.generic_tf.visible = true;
         TextFieldUtil.compactTextField(m_window.place_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_02_Button"));
      }
      
      protected function onSupplyClick(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = ZGlobal.player.canBuy(this.m_reqItem,true);
         if(_loc2_)
         {
            ZGlobal.player.buyItem(this.m_reqItem,false,1);
            this.m_eventDispatcher.dispatchEvent(new WorldEvent(ENERGIZER_ACTIVATED));
            this.onExitClicked(null);
         }
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         if(this.m_supplyButton)
         {
            this.m_supplyButton.dispose();
         }
         if(this.m_okButton)
         {
            this.m_okButton.dispose();
         }
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         super.close();
      }
   }
}

