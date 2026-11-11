package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import flash.events.Event;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   
   public class AnimationState extends AutoDialogState
   {
      
      private var m_images:Array = new Array();
      
      private var m_index:int = -1;
      
      private var m_forcedImageIndexOffset:int = 0;
      
      private var m_active:Boolean = true;
      
      public function AnimationState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         super.enter(param1);
         this.m_index = -1;
         this.m_forcedImageIndexOffset = 0;
         var _loc2_:String = m_data.@animation.toString();
         var _loc3_:Array = _loc2_.split(",");
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = _loc4_.split(":");
            this.m_images.push({
               "name":_loc5_[0],
               "duration":parseFloat(_loc5_[1])
            });
         }
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onShow,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onHide,false,0,true);
         this.updateAnims(0);
      }
      
      override public function exit(param1:IMachine) : void
      {
         this.removeEventListeners();
         super.exit(param1);
      }
      
      override public function stop() : void
      {
         this.removeEventListeners();
         super.stop();
      }
      
      override protected function onProgress(param1:Number) : void
      {
         super.onProgress(param1);
         if(this.m_active)
         {
            this.updateAnims(param1);
         }
      }
      
      private function removeEventListeners() : void
      {
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onShow);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onHide);
      }
      
      private function setImageByIndex(param1:int) : void
      {
         param1 += this.m_forcedImageIndexOffset;
         param1 = Math.min(param1,this.m_images.length - 1);
         var _loc2_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         setImage(_loc2_,this.m_images[param1].name);
      }
      
      private function updateAnims(param1:Number) : void
      {
         var _loc2_:* = int(this.m_images.length - 1);
         while(_loc2_ >= 0)
         {
            if(param1 >= this.m_images[_loc2_].duration)
            {
               if(this.m_index != _loc2_)
               {
                  this.m_index = _loc2_;
                  this.setImageByIndex(_loc2_);
               }
               break;
            }
            _loc2_--;
         }
      }
      
      private function advanceImageOrState() : void
      {
         if(this.m_index + 1 >= this.m_images.length)
         {
            autoNextState();
         }
         else
         {
            this.m_forcedImageIndexOffset = 1;
            this.setImageByIndex(this.m_index);
         }
      }
      
      override public function onVisitHelpSuccess() : void
      {
         super.onVisitHelpSuccess();
         this.advanceImageOrState();
      }
      
      private function onShow(param1:Event) : void
      {
         this.m_active = true;
      }
      
      private function onHide(param1:Event) : void
      {
         this.m_active = false;
      }
   }
}

