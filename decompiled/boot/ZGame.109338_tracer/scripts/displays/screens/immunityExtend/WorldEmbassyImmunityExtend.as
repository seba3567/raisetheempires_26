package displays.screens.immunityExtend
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class WorldEmbassyImmunityExtend extends ImmunityExtend
   {
      
      protected var m_contributors:Array = null;
      
      public function WorldEmbassyImmunityExtend(param1:Array)
      {
         this.m_contributors = param1;
         super("assets/displays/dialogs/PU_Pvp_Immunity.swf");
      }
      
      override protected function addDialogTextAndImages() : void
      {
         TextFieldUtil.processTextField(m_mc.title_tf,ZGameUtils.ZlocT("Dialogs","PVPImmunityExtendTitle"));
         TextFieldUtil.processTextField(m_mc.title_tf2,ZGameUtils.ZlocT("Dialogs","PVPImmunityExtendMessage"));
         TextFieldUtil.processTextField(m_mc.title01_tf,ZGameUtils.ZlocT("Dialogs","PVPImmunityExtendTotalLabel"));
      }
      
      override protected function checkTimer() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(PVPManager.instance.isImmune)
         {
            _loc1_ = PVPManager.instance.immunityEndTime;
            _loc2_ = Math.max(0,_loc1_ - GlobalEngine.serverTime / 1000);
            updateImmunityDurationTimer(_loc2_);
         }
      }
      
      override protected function addEventListeners() : void
      {
         PVPManager.instance.addEventListener(PVPManager.IMMUNITY_TIMER_UPDATED,this.onImmunityTimerUpdated,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.IMMUNITY_EXPIRED,this.onImmunityExpired,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.IMMUNITY_CONTRIBUTORS_CHANGED,this.onContributorsChanged,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_TIMER_UPDATED,this.onImmunityTimerUpdated);
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_EXPIRED,this.onImmunityExpired);
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_CONTRIBUTORS_CHANGED,this.onContributorsChanged);
      }
      
      override protected function createCards() : void
      {
         var _loc1_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         var _loc5_:String = null;
         var _loc6_:ZGameButton = null;
         var _loc7_:ZGameButton = null;
         var _loc8_:MovieClip = null;
         var _loc9_:String = null;
         var _loc10_:Player = null;
         var _loc11_:String = null;
         var _loc12_:ImageLoader = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc2_:* = PVPManager.NUM_IMMUNITY_CONTRIBUTORS;
         while(_loc2_--)
         {
            _loc3_ = "anchor" + _loc2_;
            _loc4_ = m_mc[_loc3_];
            _loc6_ = null;
            _loc7_ = null;
            if(_loc2_ == 0)
            {
               _loc1_ = new m_largeCardClass();
               _loc5_ = "PVPImmunityDefendingTitle";
               _loc8_ = _loc1_.bkg_filled;
            }
            else
            {
               _loc1_ = new m_smallCardClass();
               if(_loc2_ < this.m_contributors.length)
               {
                  _loc8_ = _loc1_.bkg_filled;
                  _loc1_.bkg_empty.visible = false;
                  _loc5_ = "PVPImmunityReadyTitle";
               }
               else
               {
                  _loc8_ = _loc1_.bkg_empty;
                  _loc1_.bkg_filled.visible = false;
                  _loc5_ = "PVPImmunityAddTitle";
               }
               if(_loc2_ == this.m_contributors.length)
               {
                  _loc6_ = new ZGameButton(_loc1_.buy_bt,this.onBuyClicked);
                  _loc6_.text = String(PVPManager.instance.immunityPurchaseCost);
                  m_buttonSounds.addButton(_loc6_.m_overlay,ButtonSound.DEFAULT);
                  _loc7_ = new ZGameButton(_loc1_.hire_bt,this.onHireClicked);
                  _loc7_.text = ZGameUtils.ZlocT("Dialogs","PVPImmunityHireFriends");
                  m_buttonSounds.addButton(_loc7_.m_overlay,ButtonSound.DEFAULT);
               }
               else
               {
                  _loc1_.buy_bt.visible = false;
                  _loc1_.hire_bt.visible = false;
               }
            }
            if(_loc2_ < this.m_contributors.length)
            {
               _loc10_ = ZGlobal.player.findFriendById(this.m_contributors[_loc2_]);
               if(_loc10_)
               {
                  _loc11_ = _loc10_.snUser.picture;
                  _loc12_ = ImageLoaderFactory.CreateImageLoader(_loc11_,_loc1_.player_01.icon);
                  m_imageLoaders.push(_loc12_);
                  TextFieldUtil.processTextField(_loc1_.player_01.name_tf,_loc10_.snUser.firstName);
               }
            }
            else
            {
               _loc1_.player_01.name_tf.visible = false;
            }
            if(_loc8_.time_tf)
            {
               if(this.m_contributors[_loc2_] == ZGlobal.player.uid)
               {
                  _loc13_ = PVPManager.getImmunityDuration(true);
               }
               else
               {
                  _loc13_ = PVPManager.getImmunityDuration(false);
               }
               _loc14_ = _loc13_ / (60 * 60);
               _loc15_ = ZGameUtils.ZlocT("Dialogs","PVPImmunitySlotDuration",{"hours":_loc14_});
               TextFieldUtil.processTextField(_loc8_.time_tf,_loc15_);
            }
            _loc9_ = ZGameUtils.ZlocT("Dialogs",_loc5_);
            TextFieldUtil.processTextField(_loc8_.title_tf,_loc9_);
            m_mc.addChild(_loc1_);
            _loc1_.x = _loc4_.x;
            _loc1_.y = _loc4_.y;
            m_cards.push({
               "mc":_loc1_,
               "buyButton":_loc6_,
               "hireButton":_loc7_
            });
         }
      }
      
      override protected function onBuyClicked(param1:Event) : void
      {
         PVPManager.instance.extendImmunity();
      }
      
      override protected function onHireClicked(param1:Event) : void
      {
         ViralsManager.instance.requestImmunityExtension(PVPManager.instance.numImmunityContributors);
         closeWindow(null);
      }
      
      private function onContributorsChanged(param1:WorldEvent) : void
      {
         clearImageLoaders();
         clearCards();
         m_cards = new Array();
         this.m_contributors = param1.eventData as Array;
         this.createCards();
      }
      
      private function onImmunityTimerUpdated(param1:WorldEvent) : void
      {
         updateImmunityDurationTimer(param1.eventData.remaining);
      }
      
      private function onImmunityExpired(param1:Event) : void
      {
         closeWindow();
      }
   }
}

