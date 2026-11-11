package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.immunityExtend.ImmunityExtend;
   import displays.screens.immunityExtend.WorldEmbassyImmunityExtend;
   import flash.events.Event;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class PVPImmunityDialogState extends DialogState
   {
      
      private var m_activeImageName:String;
      
      public function PVPImmunityDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@activeImageType.toString().length > 0)
         {
            this.m_activeImageName = m_data.@activeImageType.toString();
         }
      }
      
      private function immunityStarted(param1:Event) : void
      {
         this.updateAnimation();
      }
      
      private function showCooldownDialog(param1:Number) : void
      {
         var _loc2_:String = ZGameTimeUtil.instance.getTimeString(param1);
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","ImmunityStartCooldownActive",{"timeString":_loc2_});
         var _loc4_:GenericPopup = GenericPopup1B.NewOk(_loc3_,null);
         PopupManager.instance.push(_loc4_);
      }
      
      private function showStartDialog() : void
      {
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","ImmunityStartDialogTitle");
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","ImmunityStartDialogMessage");
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","StartButton");
         var _loc5_:int = GenericPopup.TYPE_SHARECANCEL;
         var _loc6_:Function = this.startDialogClosed;
         var _loc7_:String = ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon");
         var _loc8_:GenericPopup = new FeedPopup(_loc3_,_loc2_,_loc4_,_loc5_,_loc6_,_loc7_);
         PopupManager.instance.push(_loc8_);
      }
      
      private function immunityExpired(param1:Event) : void
      {
         this.updateAnimation();
      }
      
      private function updateAnimation() : void
      {
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         setImage(_loc1_,this.imageName);
      }
      
      private function startDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:ImmunityExtend = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            PVPManager.instance.startImmunity();
            _loc2_ = new WorldEmbassyImmunityExtend(PVPManager.instance.immunityContributors);
            WindowManager.instance.push(_loc2_);
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.isHome())
         {
            PVPManager.instance.addEventListener(PVPManager.IMMUNITY_STARTED,this.immunityStarted,false,0,true);
            PVPManager.instance.addEventListener(PVPManager.IMMUNITY_EXPIRED,this.immunityExpired,false,0,true);
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         this.cleanup();
      }
      
      override public function stop() : void
      {
         this.cleanup();
         super.stop();
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:ImmunityExtend = null;
         var _loc2_:Object = null;
         if(ZGlobal.isHome())
         {
            if(PVPManager.instance.isImmune)
            {
               _loc1_ = new WorldEmbassyImmunityExtend(PVPManager.instance.immunityContributors);
               WindowManager.instance.push(_loc1_);
            }
            else
            {
               _loc2_ = PVPManager.instance.getCooldownInfo();
               if(_loc2_.active)
               {
                  this.showCooldownDialog(_loc2_.timeLeft);
               }
               else
               {
                  this.showStartDialog();
               }
            }
         }
      }
      
      override protected function get imageName() : String
      {
         if(PVPManager.instance.isImmuneHost)
         {
            return this.m_activeImageName;
         }
         return super.imageName;
      }
      
      private function cleanup() : void
      {
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_STARTED,this.immunityStarted);
         PVPManager.instance.removeEventListener(PVPManager.IMMUNITY_EXPIRED,this.immunityExpired);
      }
   }
}

