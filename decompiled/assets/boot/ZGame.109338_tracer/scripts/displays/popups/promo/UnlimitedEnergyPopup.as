package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.promoManager.PromoManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.MOTDCountdownClock;
   import displays.popups.genericPopup.GenericPopup1B;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class UnlimitedEnergyPopup extends GallantPopup
   {
      
      private static const PANEL_WIDTH:int = 572;
      
      private static const PANEL_HEIGHT:int = 350;
      
      private var m_clock:MOTDCountdownClock;
      
      private var m_buttons:Array = new Array();
      
      private var m_imageLoaders:Array = new Array();
      
      private var m_sounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      public function UnlimitedEnergyPopup()
      {
         var _loc1_:String = ZGlobal.getAssetURL("assets/displays/dialogs/PU_Bundle3Item.swf");
         super(_loc1_);
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("Dialog3Item_mc");
         return new _loc2_();
      }
      
      override protected function initDialog() : void
      {
         m_window.icons1slot.visible = false;
         m_window.icons2slots.visible = false;
         m_window.buy_bt.visible = false;
         m_window.description_tf2.visible = false;
         this.initCards();
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClick,false,0,true);
         this.m_sounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         this.m_clock = new MOTDCountdownClock(m_window.clock_mc,PromoManager.instance.unlimitedEnergyXML);
         contentWidth = PANEL_WIDTH;
         contentHeight = PANEL_HEIGHT;
         var _loc1_:String = ZGameUtils.ZlocT("Promo","promo_UnlimitedEnergy_Dialog_Title");
         TextFieldUtil.processTextField(m_window.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Promo","promo_UnlimitedEnergy_Dialog_Desc");
         TextFieldUtil.processTextField(m_window.description_tf,_loc2_);
         StatsManager.count("dialog","MOTDUnlimited_energy","view");
         super.initDialog();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ZGameButton = null;
         var _loc2_:ImageLoader = null;
         super.deinitDialog();
         for each(_loc1_ in this.m_buttons)
         {
            if(_loc1_)
            {
               _loc1_.dispose();
            }
         }
         this.m_buttons = null;
         for each(_loc2_ in this.m_imageLoaders)
         {
            _loc2_.destroy();
         }
         this.m_imageLoaders = null;
         this.m_sounds.release();
         this.m_sounds = null;
      }
      
      private function onExitClick(param1:MouseEvent) : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClick);
         StatsManager.count("dialog","MOTDUnlimited_energy","no");
         close();
      }
      
      private function initCards() : void
      {
         var _loc5_:MovieClip = null;
         var _loc6_:ZGameButton = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:ImageLoader = null;
         var _loc1_:Array = [m_window.icons.icon1,m_window.icons.icon2,m_window.icons.icon3];
         var _loc2_:XMLList = PromoManager.instance.unlimitedEnergyImages;
         var _loc3_:Array = PromoManager.instance.unlimitedEnergyData;
         var _loc4_:int = 0;
         for each(_loc5_ in _loc1_)
         {
            if(_loc4_ < _loc3_.length && _loc4_ < _loc2_.length())
            {
               _loc5_.strength_mc.visible = false;
               _loc5_.name_tf.visible = false;
               _loc6_ = new ZGameButton(_loc5_.buy_bt,this.onBuyButtonClicked);
               if(_loc6_)
               {
                  _loc7_ = _loc3_[_loc4_];
                  _loc8_ = ZGameTimeUtil.instance.getTimeString(_loc7_.duration);
                  TextFieldUtil.processTextField(_loc5_.name2_tf,_loc8_);
                  _loc9_ = _loc2_[_loc4_].@url == undefined ? null : _loc2_[_loc4_].@url.toString();
                  _loc10_ = ZGlobal.getAssetURL(_loc9_);
                  _loc11_ = ImageLoaderFactory.CreateImageLoader(_loc10_,_loc5_.icon);
                  if(_loc11_)
                  {
                     this.m_imageLoaders.push(_loc11_);
                  }
                  _loc6_.buttonValue = String(_loc4_);
                  _loc6_.text = _loc7_.cost;
                  this.m_sounds.addButton(_loc6_.m_overlay,ButtonSound.DEFAULT);
                  this.m_buttons.push(_loc6_);
               }
            }
            else
            {
               _loc5_.visible = false;
            }
            _loc4_++;
         }
      }
      
      private function onBuyButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.target.buttonValue);
         StatsManager.count("dialog","MOTDUnlimited_energy","yes" + String(_loc2_ + 1));
         close();
         if(ZGlobal.player.m_energy.updateAndCheckUnlimitedEnergy())
         {
            this.onAlreadyActive();
         }
         else
         {
            ZGlobal.player.m_energy.buyUnlimitedEnergyWithConfirmation(_loc2_);
         }
      }
      
      private function onAlreadyActive() : void
      {
         var _loc1_:int = ZGlobal.player.m_energy.unlimitedEnergyTimeRemaining;
         var _loc2_:String = ZGameTimeUtil.instance.getTimeString(_loc1_);
         var _loc3_:String = ZGameUtils.ZlocT("Promo","promo_UnlimitedEnergy_Dialog_AlreadyUnlimited",{"timeString":_loc2_});
         var _loc4_:IWindow = GenericPopup1B.NewOk(_loc3_,"");
         PopupManager.instance.push(_loc4_);
      }
   }
}

