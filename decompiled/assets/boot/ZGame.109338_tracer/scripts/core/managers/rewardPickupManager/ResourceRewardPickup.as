package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.managers.WorldResourceManager;
   import core.resource.ResourceInfo;
   import core.ui.feedbacktext.ResourceFeedbackText;
   
   public class ResourceRewardPickup extends RewardPickup
   {
      
      private var m_resource:String = null;
      
      public function ResourceRewardPickup(param1:String, param2:int, param3:Boolean)
      {
         super(param2,param1,param3);
         m_feedbackText = new ResourceFeedbackText(param1,param2);
         this.m_resource = param1;
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.resources.updateResourceAmount(this.m_resource,param1);
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return WorldResourceManager.instance.getLootImageURLByType(this.m_resource,param1);
      }
      
      override protected function get uiName() : String
      {
         return this.m_resource;
      }
      
      override public function get pickupName() : String
      {
         var _loc1_:ResourceInfo = WorldResourceManager.instance.getResourceInfoByType(this.m_resource);
         return _loc1_.isRare ? "rare" : this.m_resource;
      }
      
      override protected function get soundEvent() : String
      {
         return WorldResourceManager.instance.getResourceSoundEvent(this.m_resource);
      }
   }
}

