package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class MessageDispatcher extends EventDispatcher
   {
      
      public static var instance:MessageDispatcher = new MessageDispatcher();
      
      public static const RESOURCE_DIALOG_UPDATE:String = "resourcedialogupdate";
      
      public static const SET_DESTINATION:String = "setdestination";
      
      public static const ITEM_SET_STATE:String = "itemsetstate";
      
      public static const ITEM_REMOVED:String = "itemremoved";
      
      public static const SPEEDUP:String = "speedup";
      
      public static const ITEM_GIFT:String = "itemgift";
      
      public static const RESOURCE_GIFT:String = "resourcegift";
      
      public static const XP_GIFT:String = "xpgift";
      
      public static const NEIGHBOR:String = "messageneighbor";
      
      public static const VISITOR_HELP_UPDATE:String = "visitorHelpUpdate";
      
      public static const LEVEL_UP:String = "messagelevelup";
      
      public static const INFAMY:String = "messageinfamy";
      
      public static const HONOR:String = "messagehonor";
      
      public static const PVP_INVADED:String = "messagepvpinvaded";
      
      public static const PVP_REPELLED:String = "messagepvprepelled";
      
      public static const PVP_ASSIST_REPELLED:String = "messagepvpassistrepelled";
      
      public static const ORE_NEIGHBOR_INFO_SEEN:String = "oreNeighborInfoSeen";
      
      public static const STARTER_PACK_COMPLETE:String = "starterPackComplete";
      
      public static const GRANT_EP:String = "grantep";
      
      public static const GRANT_FACEBOOK_CREDIT_OFFER1:String = "grantFacebookCreditOffer1";
      
      public static const GRANT_FACEBOOK_CREDIT_OFFER2:String = "grantFacebookCreditOffer2";
      
      public static const ALLIANCE_DATA_UPDATED:String = "allianceDataUpdated";
      
      public static const MFSP2_REWARDBAR_UPDATED:String = "mfsp2_rewardbar_updated";
      
      public function MessageDispatcher()
      {
         super();
      }
   }
}

