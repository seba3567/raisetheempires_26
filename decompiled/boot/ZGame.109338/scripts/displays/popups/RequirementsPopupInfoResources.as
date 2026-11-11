package displays.popups
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.resource.ResourceInfo;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class RequirementsPopupInfoResources implements RequirementsPopupInterface
   {
      
      private var m_resource:String;
      
      private var m_token:LocalizationObjectToken;
      
      public function RequirementsPopupInfoResources(param1:Array)
      {
         super();
         this.m_resource = param1 ? this.calculateBestResource(param1) : "";
         this.m_token = ZGameUtils.ZlocTk("Items",this.m_resource + "_sentenceName","plural");
      }
      
      public function callback(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "out_of_" + this.m_resource;
            ViralsManager.instance.sendFeed(_loc2_,{"resource":ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",this.m_resource + "_sentenceName","plural"))});
         }
      }
      
      public function get mainButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","AskFriends");
      }
      
      public function get titleText() : String
      {
         return ZGameUtils.ZlocT("FeedPopups","out_of_resource_title",{"resource":this.m_token});
      }
      
      public function get bubbleText() : String
      {
         var _loc1_:Number = Number(ZGlobal.player.resources.resourceAmounts[this.m_resource]);
         return ZGameUtils.ZlocT("FeedPopups",_loc1_ > 0 ? "almost_out_of_resource_bubble" : "out_of_resource_bubble",{"resource":this.m_token});
      }
      
      public function get descriptionText() : String
      {
         var _loc1_:ResourceInfo = WorldResourceManager.instance.getResourceInfoByType(this.m_resource);
         if(!_loc1_)
         {
            return null;
         }
         switch(this.m_resource)
         {
            case "coins":
            case "wood":
            case "oil":
               return ZGameUtils.ZlocT("FeedPopups",_loc1_.productionPromptToken);
            default:
               return ZGameUtils.ZlocT("FeedPopups",_loc1_.productionPromptToken,{
                  "rare":this.m_token,
                  "secondrare":this.m_token
               });
         }
      }
      
      public function get iconArray() : Array
      {
         var _loc1_:ResourceInfo = WorldResourceManager.instance.getResourceInfoByType(this.m_resource);
         if(_loc1_)
         {
            return [_loc1_.productionInputIcon,_loc1_.productionFactoryIcon,_loc1_.productionOutputIcon];
         }
         return null;
      }
      
      private function calculateBestResource(param1:Array) : String
      {
         var _loc3_:String = null;
         var _loc2_:Array = ["coins","wood","oil","aluminum","copper","gold","iron","uranium"];
         if(param1.length > 1)
         {
            for each(_loc3_ in _loc2_)
            {
               if(param1.indexOf(_loc3_) >= 0)
               {
                  return _loc3_;
               }
            }
         }
         return param1[0];
      }
   }
}

