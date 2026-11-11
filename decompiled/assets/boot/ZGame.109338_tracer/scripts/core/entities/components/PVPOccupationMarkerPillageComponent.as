package core.entities.components
{
   import core.ZGlobal;
   import core.gamemode.GMSell;
   import core.managers.PVPManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.Tooltip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class PVPOccupationMarkerPillageComponent extends PVPOccupationMarkerPickOnlyComponent
   {
      
      private static var m_exists:Boolean;
      
      public static var PLACING_VALID:String = "PlacingValid";
      
      public static var PLACING_VALID_PROTECTED:String = "PlacingValidProtected";
      
      public static var PLACING_INVALID:String = "PlacingInvalid";
      
      private static var STATE_PLACING_VALID:int = 0;
      
      private static var STATE_PLACING_VALID_PROTECTED:int = 1;
      
      private static var STATE_PLACING_INVALID:int = 2;
      
      private static var STATE_PLACED:int = 3;
      
      private static var STATE_ACTIVE:int = 4;
      
      private var m_state:int;
      
      public function PVPOccupationMarkerPillageComponent(param1:Player)
      {
         super(param1);
         this.state = STATE_PLACING_VALID;
      }
      
      public static function get hasInstance() : Boolean
      {
         return m_exists;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         PVPManager.instance.addEventListener(PVPManager.PILLAGE_ENABLED,this.onPillageEnabled,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.PILLAGE_PLACED,this.onPillagePlaced,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.PILLAGE_PERFORMED,this.onPillagePerformed,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.FADEOUT_MARKER,this.onPillageFadeOut,false,0,true);
         owner.eventDispatcher.addEventListener(PLACING_VALID,this.onPlacementValid,false,0,true);
         owner.eventDispatcher.addEventListener(PLACING_VALID_PROTECTED,this.onPlacementValidProtected,false,0,true);
         owner.eventDispatcher.addEventListener(PLACING_INVALID,this.onPlacementInvalid,false,0,true);
         attemptLoadPick();
         if(m_exists)
         {
            Logger.print(this,"Error, can\'t have more than one pillage marker!");
         }
         m_exists = true;
      }
      
      override protected function onRemove() : void
      {
         this.setPillageable(false,false);
         super.onRemove();
         PVPManager.instance.removeEventListener(PVPManager.PILLAGE_ENABLED,this.onPillageEnabled);
         PVPManager.instance.removeEventListener(PVPManager.PILLAGE_PLACED,this.onPillagePlaced);
         PVPManager.instance.removeEventListener(PVPManager.PILLAGE_PERFORMED,this.onPillagePerformed);
         PVPManager.instance.removeEventListener(PVPManager.FADEOUT_MARKER,this.onPillageFadeOut);
         owner.eventDispatcher.removeEventListener(PLACING_VALID,this.onPlacementValid);
         owner.eventDispatcher.removeEventListener(PLACING_VALID_PROTECTED,this.onPlacementValidProtected);
         owner.eventDispatcher.removeEventListener(PLACING_INVALID,this.onPlacementInvalid);
         if(!m_exists)
         {
            Logger.print(this,"Error removing component that doesn\'t seem to be added");
         }
         m_exists = false;
      }
      
      override protected function get assetClassString() : String
      {
         return "invasionToken_mc";
      }
      
      private function onPlacementValid(param1:Event) : void
      {
         this.state = STATE_PLACING_VALID;
      }
      
      private function onPlacementValidProtected(param1:Event) : void
      {
         this.state = STATE_PLACING_VALID_PROTECTED;
      }
      
      private function onPlacementInvalid(param1:Event) : void
      {
         this.state = STATE_PLACING_INVALID;
      }
      
      private function onPillageEnabled(param1:WorldEvent) : void
      {
         this.state = STATE_ACTIVE;
         if(!m_pick && param1.eventData == pickPlayer.uid)
         {
            attemptLoadPick();
         }
      }
      
      private function onPillagePlaced(param1:Event) : void
      {
         this.state = STATE_PLACED;
      }
      
      private function onPillagePerformed(param1:WorldEvent) : void
      {
         if(param1.eventData == pickPlayer.uid)
         {
            this.setPillageable(false,true);
         }
      }
      
      override protected function onPickLoadComplete(param1:SWFResource) : void
      {
         super.onPickLoadComplete(param1);
         m_pick.mc.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.setPillageable(PVPManager.instance.canPillage().canPillage,false);
      }
      
      override protected function disposePick() : void
      {
         if(m_pick)
         {
            m_pick.mc.removeEventListener(MouseEvent.CLICK,this.onClicked);
         }
         super.disposePick();
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         if(PVPManager.instance.canPillage().canPillage)
         {
            PVPManager.instance.doPillage();
         }
         else
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackPillageCooldown"),owner);
         }
      }
      
      private function set state(param1:int) : void
      {
         this.m_state = param1;
         createOrUpdateRect();
      }
      
      override protected function get shouldOutline() : Boolean
      {
         if(this.m_state == STATE_ACTIVE)
         {
            return false;
         }
         return true;
      }
      
      override protected function get rectColor() : int
      {
         switch(this.m_state)
         {
            case STATE_PLACING_VALID:
            case STATE_PLACED:
               return 65344;
            case STATE_PLACING_VALID_PROTECTED:
               return PVPAreaImmuneMarkerComponent.AOE_COLOR;
            case STATE_PLACING_INVALID:
            case STATE_ACTIVE:
               return 16711680;
            default:
               return 16777215;
         }
      }
      
      override protected function shouldLoadPick() : Boolean
      {
         return this.m_state == STATE_ACTIVE;
      }
      
      override protected function get initialPickPortrait() : String
      {
         var _loc1_:Object = PVPManager.instance.canPillage();
         if(_loc1_.canPillage)
         {
            return this.dooberIconURL;
         }
         return null;
      }
      
      private function onPillageFadeOut(param1:WorldEvent) : void
      {
         GMSell.clearObject(owner,true);
      }
      
      private function get dooberIconURL() : String
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("PVPPillageAvailableIcon");
         return ZGlobal.getAssetURL(_loc1_);
      }
      
      private function updatePickPortrait() : void
      {
         var _loc1_:Object = null;
         if(m_pick)
         {
            _loc1_ = PVPManager.instance.canPillage();
            if(_loc1_.canPillage)
            {
               m_pick.overridePortrait(this.dooberIconURL);
            }
            else
            {
               m_pick.overridePortrait(null);
            }
         }
      }
      
      private function onPillageCoolDown() : void
      {
         this.setPillageable(PVPManager.instance.canPillage().canPillage,false);
      }
      
      private function setPillageable(param1:Boolean, param2:Boolean) : void
      {
         if(param1)
         {
            if(m_pick)
            {
               Tooltip.subscribe(m_pick.mc,ZGameUtils.ZlocT("Dialogs","PVPPillageActivePickTooltip"));
            }
            param2 = true;
         }
         else
         {
            Zlab.processManager.schedule(1000,this,this.onPillageCoolDown);
            if(m_pick)
            {
               Tooltip.unsubscribe(m_pick.mc);
            }
         }
         if(param2)
         {
            this.updatePickPortrait();
         }
      }
   }
}

