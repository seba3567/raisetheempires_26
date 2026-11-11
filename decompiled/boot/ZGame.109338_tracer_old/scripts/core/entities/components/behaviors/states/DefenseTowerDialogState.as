package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.ui.PlayerFeedbackManager;
   import displays.screens.immunityExtend.DefenseTowerImmunityExtend;
   import displays.screens.immunityExtend.ImmunityExtend;
   import events.CloseEvent;
   import flash.events.MouseEvent;
   import transactions.TDefenseTowerTimeExtend;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class DefenseTowerDialogState extends DialogState
   {
      
      private var controllerTooltip:PropertyReference = new PropertyReference("@controller.toolTip");
      
      private var overlayIconNameProperty:PropertyReference = new PropertyReference("@Overlay.iconName");
      
      private var m_expTS:Number = 0;
      
      private var m_activeImageName:String = null;
      
      private var m_inactiveTooltip:String = null;
      
      private var m_actionTooltip:String = null;
      
      private var m_inactiveIconUrl:String = null;
      
      private var m_actionIconUrl:String = null;
      
      private var m_totalSlots:int = 0;
      
      private var m_extensionSeconds:Number = 0;
      
      public function DefenseTowerDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@activeImageType.toString().length > 0)
         {
            this.m_activeImageName = m_data.@activeImageType.toString();
         }
         if(m_data.@tooltip.toString().length > 0)
         {
            this.m_inactiveTooltip = m_data.@tooltip.toString();
         }
         if(m_data.@actionTooltip.toString().length > 0)
         {
            this.m_actionTooltip = m_data.@actionTooltip.toString();
         }
         if(m_data.@inactiveIcon.toString().length > 0)
         {
            this.m_inactiveIconUrl = m_data.@inactiveIcon.toString();
         }
         if(m_data.@actionIcon.toString().length > 0)
         {
            this.m_actionIconUrl = m_data.@actionIcon.toString();
         }
         if(param1.m_gameObject != null)
         {
            if(!isNaN(param1.m_gameObject.defenseTowerExpTS))
            {
               this.m_expTS = param1.m_gameObject.defenseTowerExpTS;
            }
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         this.m_totalSlots = _loc1_.extensionTimeSlots();
         var _loc2_:String = _loc1_.extensionTimeItem();
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
         this.m_extensionSeconds = _loc3_.extensionTimeSeconds();
         if(this.isActive())
         {
            Zlab.processManager.schedule(1000,this,this.onTimer);
         }
         this.updateOverlayIconsAndTooltips();
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverDefenseTower,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutDefenseTower,false,0,true);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onTimer() : void
      {
         if(this.m_expTS > 0 && !this.isActive())
         {
            this.m_expTS = 0;
            this.updateAnimation();
            this.updateOverlayIconsAndTooltips();
         }
         else if(this.isActive())
         {
            Zlab.processManager.schedule(1000,this,this.onTimer);
            this.updateOverlayIconsAndTooltips();
         }
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:ImmunityExtend = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = new DefenseTowerImmunityExtend(this.m_expTS,IEntity(stateMachine.propertyBag));
            stateMachine.propertyBag.eventDispatcher.addEventListener(DefenseTowerImmunityExtend.BUY_ITEM,this.onItemPurchased,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(DefenseTowerImmunityExtend.USE_ITEM,this.onItemUsed,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
            WindowManager.instance.push(_loc1_);
         }
         else
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackPVPAreaImmunityBlocked"),owner);
         }
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(DefenseTowerImmunityExtend.BUY_ITEM,this.onItemPurchased);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(DefenseTowerImmunityExtend.USE_ITEM,this.onItemUsed);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
      }
      
      private function onItemUsed(param1:WorldEvent) : void
      {
         this.updateState();
         TransactionManager.addTransaction(new TDefenseTowerTimeExtend(IEntity(stateMachine.propertyBag),false),true);
      }
      
      private function onItemPurchased(param1:WorldEvent) : void
      {
         this.updateState();
         TransactionManager.addTransaction(new TDefenseTowerTimeExtend(IEntity(stateMachine.propertyBag),true),true);
      }
      
      private function updateState() : void
      {
         if(!this.isActive())
         {
            this.m_expTS = GlobalEngine.serverTime / 1000 + this.m_extensionSeconds;
            this.updateAnimation();
            Zlab.processManager.schedule(1000,this,this.onTimer);
         }
         else
         {
            this.m_expTS += this.m_extensionSeconds;
         }
         this.updateOverlayIconsAndTooltips();
         stateMachine.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(DefenseTowerImmunityExtend.DEFENSE_TIME_CHANGED,this.m_expTS));
      }
      
      override protected function get imageName() : String
      {
         if(this.isActive())
         {
            return this.m_activeImageName;
         }
         return super.imageName;
      }
      
      private function updateAnimation() : void
      {
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         setImage(_loc1_,this.imageName);
      }
      
      private function updateOverlayIconsAndTooltips() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:Number = NaN;
         var _loc3_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty);
            if(this.isActive())
            {
               if(this.hasEmptySlots())
               {
                  stateMachine.propertyBag.setProperty(this.overlayIconNameProperty,this.m_actionIconUrl);
               }
               else
               {
                  stateMachine.propertyBag.setProperty(overlayDataProperty,null);
               }
               _loc2_ = this.m_expTS - GlobalEngine.serverTime / 1000;
               _loc3_ = ZGameTimeUtil.instance.getTimeString(_loc2_);
               stateMachine.propertyBag.setProperty(this.controllerTooltip,ZGameUtils.ZlocT("Tooltips","Compound_Tooltip",{
                  "firstPart":_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                  "secondPart":ZGameUtils.ZlocT("Tooltips",this.m_actionTooltip)
               }) + ": " + _loc3_);
            }
            else
            {
               stateMachine.propertyBag.setProperty(this.overlayIconNameProperty,this.m_inactiveIconUrl);
               stateMachine.propertyBag.setProperty(this.controllerTooltip,ZGameUtils.ZlocT("Tooltips","Compound_Tooltip",{
                  "firstPart":_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                  "secondPart":ZGameUtils.ZlocT("Tooltips",this.m_inactiveTooltip)
               }));
            }
         }
      }
      
      public function isActive() : Boolean
      {
         if(this.m_expTS > GlobalEngine.serverTime / 1000)
         {
            return true;
         }
         return false;
      }
      
      public function hasEmptySlots() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         if(this.m_extensionSeconds > 0)
         {
            _loc1_ = this.m_expTS - GlobalEngine.serverTime / 1000;
            _loc2_ = _loc1_ <= 0 ? 0 : int(Math.ceil(_loc1_ / this.m_extensionSeconds));
            if(_loc2_ < this.m_totalSlots)
            {
               return true;
            }
         }
         return false;
      }
      
      private function onMouseOverDefenseTower(param1:MouseEvent) : void
      {
         var _loc2_:IEntity = null;
         if(!ZGlobal.isHome())
         {
            return;
         }
         if(this.isActive())
         {
            _loc2_ = IEntity(stateMachine.propertyBag);
            PVPManager.instance.clearAreaImmunity();
            PVPManager.instance.updateAreaImmunitySingle(_loc2_);
            PVPManager.instance.updateAreaImmunityBuildings();
            PVPManager.instance.updateAreaImmunityMarkers();
         }
      }
      
      private function onMouseOutDefenseTower(param1:MouseEvent) : void
      {
         if(!ZGlobal.isHome())
         {
            return;
         }
         PVPManager.instance.clearAreaImmunity();
      }
   }
}

