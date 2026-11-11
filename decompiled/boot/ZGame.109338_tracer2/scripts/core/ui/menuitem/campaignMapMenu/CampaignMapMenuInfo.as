package core.ui.menuitem.campaignMapMenu
{
   import core.managers.campaignManager.CampaignManager;
   
   public class CampaignMapMenuInfo
   {
      
      private var m_campaignData:Vector.<CampaignMapMenuMapData> = null;
      
      public function CampaignMapMenuInfo()
      {
         var _loc2_:String = null;
         super();
         this.m_campaignData = new Vector.<CampaignMapMenuMapData>();
         var _loc1_:Array = CampaignManager.instance.campaignNamesArray;
         for each(_loc2_ in _loc1_)
         {
            this.m_campaignData.push(new CampaignMapMenuMapData(CampaignManager.instance.getCampaignDefinition(_loc2_)));
         }
      }
      
      public function get count() : int
      {
         return this.m_campaignData.length;
      }
      
      public function getCampaignMapData(param1:int) : CampaignMapMenuMapData
      {
         if(param1 < this.count)
         {
            return this.m_campaignData[param1];
         }
         return null;
      }
   }
}

