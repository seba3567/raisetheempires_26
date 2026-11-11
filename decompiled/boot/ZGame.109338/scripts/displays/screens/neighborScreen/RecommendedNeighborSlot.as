package displays.screens.neighborScreen
{
   import core.ZGameStats;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.menuitem.FriendsBarUIItem;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class RecommendedNeighborSlot extends InviteNeighborSlot
   {
      
      private var m_zid:String = null;
      
      private var m_loader:ImageLoader = null;
      
      public function RecommendedNeighborSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int)
      {
         super(param1,param2,param3,param4);
      }
      
      public function startRotation() : void
      {
         var _loc1_:Array = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).recommendedNeighbors;
         var _loc2_:int = FriendsBarUIItem.recommendedNeighborOffset;
         if(Boolean(_loc1_) && Boolean(_loc1_.length > 0) && _loc2_ < _loc1_.length)
         {
            TextFieldUtil.processTextField(slot.profilename_tf,_loc1_[_loc2_].first_name);
            this.m_zid = _loc1_[_loc2_].zid;
            if(this.m_loader)
            {
               this.m_loader.destroy();
            }
            this.m_loader = ImageLoaderFactory.CreateImageLoader(_loc1_[_loc2_].pic,slot.profileloader_mc);
            FriendsBarUIItem.recommendedNeighborOffset = (FriendsBarUIItem.recommendedNeighborOffset + 1) % _loc1_.length;
         }
         if(Boolean(_loc1_) && _loc1_.length > 1)
         {
            Zlab.processManager.schedule(60000,this,this.startRotation);
         }
      }
      
      override protected function get buttonLabel() : String
      {
         return "NeighborAdd";
      }
      
      override protected function onButtonClicked(param1:MouseEvent) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
         {
            PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_NEIGHBOR_SLOT));
         }
         else
         {
            ZGameStats.instance.dispatchEvent(new Event(ZGameStats.STATS_FRIEND_ADD));
            ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_REC_NEIGHBOR_SLOT,null,"slot",[this.m_zid]);
         }
      }
      
      private function onPlayerImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(null != slot)
         {
            slot.manIcon_mc.visible = false;
         }
      }
   }
}

