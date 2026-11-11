package transactions
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import displays.screens.requests.RequestDialog;
   import displays.screens.requests.RequestGiftDialog;
   import displays.screens.requests.RequestGiftsSelectDialog;
   import displays.screens.requests.RequestNeighborDialog;
   import zlabs.managers.PopupManager;
   
   public class TInitRequestFriends extends TZGameTransaction
   {
      
      private var m_dominance:Boolean;
      
      public function TInitRequestFriends(param1:Boolean)
      {
         this.m_dominance = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DataServicesService.getRequestFriends");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc15_:Boolean = false;
         var _loc16_:Object = null;
         var _loc17_:Boolean = false;
         var _loc18_:Object = null;
         super.onComplete(param1);
         var _loc2_:Array = param1.recommendedFriends.data;
         var _loc3_:Array = param1.zyngaFriends.data;
         var _loc4_:Array = param1.empireFriends.data;
         var _loc5_:Array = param1.sevenDayFriends.data;
         var _loc6_:Array = param1.fourteenDayFriends.data;
         var _loc7_:Array = param1.thirtyDayFriends.data;
         var _loc8_:Array = param1.payerFriends.data;
         var _loc9_:Array = param1.allFriends.data;
         var _loc10_:Array = param1.zyngaFriendsByEngagement.data;
         var _loc11_:Array = param1.empireFriendsByEngagement.data;
         var _loc12_:Array = new Array();
         _loc12_ = _loc12_.concat(_loc11_);
         ZGlobal.player.setCategorizedFriends(_loc2_,Player.FRIENDS_RECOMMENDED);
         ZGlobal.player.setCategorizedFriends(_loc3_,Player.FRIENDS_ZYNGA);
         ZGlobal.player.setCategorizedFriends(_loc4_,Player.FRIENDS_EMPIRES);
         ZGlobal.player.setCategorizedFriends(_loc5_,Player.FRIENDS_7DAY);
         ZGlobal.player.setCategorizedFriends(_loc6_,Player.FRIENDS_14DAY);
         ZGlobal.player.setCategorizedFriends(_loc7_,Player.FRIENDS_30DAY);
         ZGlobal.player.setCategorizedFriends(_loc8_,Player.FRIENDS_PAYERS);
         ZGlobal.player.setCategorizedFriends(_loc9_,Player.FRIENDS_ALL_SNAPI);
         _loc9_.sortOn("name",Array.CASEINSENSITIVE);
         for each(_loc13_ in _loc10_)
         {
            _loc15_ = false;
            for each(_loc16_ in _loc12_)
            {
               if(_loc13_.uid == _loc16_.uid)
               {
                  _loc15_ = true;
                  break;
               }
            }
            if(_loc15_ != true)
            {
               _loc12_.push(_loc13_);
            }
         }
         for each(_loc14_ in _loc9_)
         {
            _loc17_ = false;
            for each(_loc18_ in _loc12_)
            {
               if(_loc14_.uid == _loc18_.uid)
               {
                  _loc17_ = true;
                  break;
               }
            }
            if(_loc17_ != true)
            {
               _loc12_.push(_loc14_);
            }
         }
         ZGlobal.player.setCategorizedFriends(_loc12_,Player.FRIENDS_ALL_ENGAGEMENT);
         ZGlobal.player.setCategorizedFriends(_loc10_,Player.FRIENDS_ZYNGA_ENGAGEMENT);
         ZGlobal.player.setCategorizedFriends(_loc11_,Player.FRIENDS_EMPIRE_ENGAGEMENT);
         ZGlobal.player.requestFriendsLoaded();
         this.checkInterstitial();
      }
      
      private function checkInterstitial() : void
      {
         var _loc1_:RequestNeighborDialog = null;
         var _loc2_:RequestGiftDialog = null;
         if(!this.m_dominance)
         {
            switch(ZGlobal.interstitial)
            {
               case "neighbor":
                  if(!RequestNeighborDialog.instanceExists())
                  {
                     _loc1_ = new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_INTERSTITIAL,ExperimentsManager.EXPERIMENT_REQUEST2_MFS_GIFT_INTERSTITIAL,RequestDialog.SUBTYPE_INTERSTITIAL);
                     if(_loc1_.numFriends > 0)
                     {
                        PopupManager.instance.push(_loc1_);
                     }
                  }
                  break;
               case "gift":
                  if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MECH_LAB_GIFT_PARTS) == ExperimentsManager.VARIANT_MECH_LAB_GIFT_PARTS_ENABLED || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MECH_LAB_GIFT_PARTS) == ExperimentsManager.VARIANT_MECH_LAB_GIFT_PARTS_PACK_ENABLED)
                  {
                     if(!RequestGiftsSelectDialog.instanceExists())
                     {
                        PopupManager.instance.push(new RequestGiftsSelectDialog());
                     }
                  }
                  else if(!RequestGiftDialog.instanceExists())
                  {
                     _loc2_ = new RequestGiftDialog("mysterygift",RequestGiftDialog.DEFAULT_GIFTTYPE,RequestDialog.TYPE_GIFT,ExperimentsManager.EXPERIMENT_REQUEST2_MFS_GIFT_INTERSTITIAL,RequestDialog.SUBTYPE_INTERSTITIAL);
                     if(_loc2_.numFriends > 0)
                     {
                        PopupManager.instance.push(_loc2_);
                     }
                  }
            }
         }
      }
   }
}

