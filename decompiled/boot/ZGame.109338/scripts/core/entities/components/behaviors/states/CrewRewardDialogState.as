package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import displays.screens.CrewRewardGatherOwnerPartial;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class CrewRewardDialogState extends CrewDialogState
   {
      
      private var OVERLAY_STATE_CREW:int = 0;
      
      private var OVERLAY_STATE_HARVEST:int = 1;
      
      private var m_harvestImageName:String = null;
      
      public function CrewRewardDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@imageTypeHarvest.toString().length > 0)
         {
            this.m_harvestImageName = m_data.@imageTypeHarvest.toString();
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         this.updateAnimation();
      }
      
      override public function onMouseOver(param1:MouseEvent) : void
      {
      }
      
      override protected function get textInfo() : Object
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc1_:String = m_data.@description;
         if(m_data.@experimentalDescription != undefined)
         {
            _loc2_ = m_data.@experimentalDescription.toString().split(",");
            _loc3_ = ExperimentsManager.instance.getExperimentVariant(_loc2_[0]);
            _loc4_ = _loc2_[1].split("|");
            for each(_loc5_ in _loc4_)
            {
               if(_loc3_ == parseInt(_loc5_.split(":")[0]))
               {
                  _loc1_ = _loc5_.split(":")[1];
                  break;
               }
            }
         }
         return {
            "title":m_data.@title,
            "desc":_loc1_,
            "button":{
               "hire":m_data.@buttonHire,
               "finish":m_data.@buttonFinish
            }
         };
      }
      
      override protected function createPopup(param1:IEntity) : PopUpBase
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         _loc2_ = m_data.@fourInALine.toString() == "true" ? true : false;
         _loc3_ = m_data.@overrideWidth.toString() == "true" ? true : false;
         _loc4_ = m_data.@paddingLeft != undefined ? int(m_data.@paddingLeft) : 0;
         return new CrewRewardGatherOwnerPartial(param1,m_wrapper,m_item,m_crewInfo,this.textInfo,m_data.@crewBackgroundSWF,m_data.@teaserIcon,m_data.@crewPopupValue,m_data.@crewPopupChance,m_data.@paddingTop,m_data.@kingdom,_loc2_,_loc3_,_loc4_);
      }
      
      override public function onClick(param1:Event) : void
      {
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            super.onClick(param1);
         }
      }
      
      override public function clickNextState() : void
      {
         super.clickNextState();
         m_crewInfo = new Array();
         addEmptySlots();
      }
      
      protected function get numStaff() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(m_crewInfo)
         {
            while(_loc2_ < m_crewInfo.length)
            {
               if(m_crewInfo[_loc2_])
               {
                  _loc1_++;
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      private function get overlayState() : int
      {
         if(this.numStaff >= m_wrapper.numPositions)
         {
            return this.OVERLAY_STATE_HARVEST;
         }
         return this.OVERLAY_STATE_CREW;
      }
      
      private function get overlayXML() : XML
      {
         var _loc1_:XML = null;
         if(m_data.@iconCrew == undefined || m_data.@iconHarvest == undefined)
         {
            if(m_data.@icon != undefined)
            {
               _loc1_ = <data icon={m_data.@icon} background={m_data.@background} backgroundOffset={m_data.@backgroundOffset} iconOffset={m_data.@iconOffset}/>;
            }
         }
         else
         {
            switch(this.overlayState)
            {
               case this.OVERLAY_STATE_CREW:
                  _loc1_ = <data icon={m_data.@iconCrew} background={m_data.@background} backgroundOffset={m_data.@backgroundOffset} iconOffset={m_data.@iconOffset}/>;
                  break;
               case this.OVERLAY_STATE_HARVEST:
                  _loc1_ = <data icon={m_data.@iconHarvest} background={m_data.@background} backgroundOffset={m_data.@backgroundOffset} iconOffset={m_data.@iconOffset}/>;
            }
         }
         return _loc1_;
      }
      
      override protected function updateOverlay() : void
      {
         var _loc1_:XML = null;
         if(!ZGlobal.isVisiting() && CrewManager.isCrewBuilding(owner))
         {
            _loc1_ = this.overlayXML;
            if(_loc1_)
            {
               owner.setProperty(overlayDataProperty,{"xml":_loc1_});
            }
            else
            {
               removeOverlay();
            }
         }
      }
      
      override protected function get imageName() : String
      {
         if(Boolean(this.m_harvestImageName) && this.overlayState == this.OVERLAY_STATE_HARVEST)
         {
            return this.m_harvestImageName;
         }
         return super.imageName;
      }
      
      private function updateAnimation() : void
      {
         var _loc1_:GameItem = owner.getProperty(dataProperty,null) as GameItem;
         setImage(_loc1_,this.imageName);
      }
      
      override protected function onPurchasedSlotFull(param1:WorldEvent) : void
      {
         super.onPurchasedSlotFull(param1);
         this.updateOverlay();
         this.updateAnimation();
      }
      
      override protected function onCrewUpdated(param1:WorldEvent) : void
      {
         super.onCrewUpdated(param1);
         this.updateOverlay();
         this.updateAnimation();
      }
   }
}

