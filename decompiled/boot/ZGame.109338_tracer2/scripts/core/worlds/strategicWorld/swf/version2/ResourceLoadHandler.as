package core.worlds.strategicWorld.swf.version2
{
   import core.ZGlobal;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class ResourceLoadHandler
   {
      
      private var m_assetComplete:Function = null;
      
      public function ResourceLoadHandler(param1:Function)
      {
         super();
         this.m_assetComplete = param1;
         Zlab.resourceManager.load(ZGlobal.getAssetURL(ZGlobal.player.campaign.currentCampaignMapAsset),SWFResource,this.onSWFLoadComplete,this.onSWFLoadFailed);
      }
      
      private function onSWFLoadComplete(param1:SWFResource) : void
      {
         if(this.m_assetComplete != null)
         {
            this.m_assetComplete(param1);
            this.dispose();
         }
      }
      
      private function onSWFLoadFailed(param1:SWFResource) : void
      {
         Logger.error(this,"onSWFLoadFailed ","failed to load: " + param1.filename);
      }
      
      public function dispose() : void
      {
         this.m_assetComplete = null;
      }
   }
}

