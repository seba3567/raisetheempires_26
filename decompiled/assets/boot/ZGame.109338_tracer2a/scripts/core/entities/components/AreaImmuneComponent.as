package core.entities.components
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.ui.feedbacktext.AreaImmuneFeedbackText;
   import zlabs.events.WorldEvent;
   
   public class AreaImmuneComponent extends ObjectHighlightComponent
   {
      
      public static const AREA_IMMUNITY_ACTIVATED:String = "immunityActivated";
      
      public static const AREA_IMMUNITY_DEACTIVATED:String = "immunityDeactivated";
      
      private var m_isAreaImmune:Boolean = false;
      
      private var m_isMarkerActivated:Boolean = false;
      
      public function AreaImmuneComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(AREA_IMMUNITY_ACTIVATED,this.onImmunityActivated,false,0,true);
         owner.eventDispatcher.addEventListener(PVPManager.MARKER_ACTIVATED,this.onMarkerActivated,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(AREA_IMMUNITY_ACTIVATED,this.onImmunityActivated);
         owner.eventDispatcher.removeEventListener(PVPManager.MARKER_ACTIVATED,this.onMarkerActivated);
         PVPManager.instance.removeEventListener(AREA_IMMUNITY_DEACTIVATED,this.onImmunityDeactivated);
         cleanupTextFields();
      }
      
      private function onImmunityActivated(param1:WorldEvent) : void
      {
         this.m_isAreaImmune = true;
         PVPManager.instance.addEventListener(AREA_IMMUNITY_DEACTIVATED,this.onImmunityDeactivated,false,0,true);
         this.updateFeedback();
      }
      
      private function onImmunityDeactivated(param1:WorldEvent) : void
      {
         this.m_isAreaImmune = false;
         PVPManager.instance.removeEventListener(AREA_IMMUNITY_DEACTIVATED,this.onImmunityDeactivated);
         this.updateFeedback();
      }
      
      private function onMarkerActivated(param1:WorldEvent) : void
      {
         this.m_isMarkerActivated = true;
         PVPManager.instance.addEventListener(PVPManager.MARKER_DEACTIVATED,this.onMarkerDeactivated,false,0,true);
         this.updateFeedback();
      }
      
      private function onMarkerDeactivated(param1:WorldEvent) : void
      {
         this.m_isMarkerActivated = false;
         PVPManager.instance.removeEventListener(PVPManager.MARKER_DEACTIVATED,this.onMarkerDeactivated);
         this.updateFeedback();
      }
      
      public function isAreaImmune() : Boolean
      {
         return this.m_isAreaImmune;
      }
      
      private function updateFeedback() : void
      {
         var _loc1_:String = UIControllerComponent.EVENT_FILTER_EFFECT;
         if(this.isAreaImmune())
         {
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc1_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_ON));
            removeFeedback();
            if(ZGlobal.isHome() || this.m_isMarkerActivated)
            {
               addFeedback(new AreaImmuneFeedbackText());
            }
         }
         else
         {
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc1_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_OFF));
            removeFeedback();
         }
      }
      
      public function getFeedbackTextHeight() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_textFields)
         {
            _loc1_ += _loc2_.tf.height;
         }
         return _loc1_;
      }
      
      public function shiftText(param1:int, param2:int) : int
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_textFields)
         {
            _loc4_.tf.x += param1;
            _loc4_.tf.y += param2;
         }
         return _loc3_;
      }
   }
}

