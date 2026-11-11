package core
{
   import Engine.Managers.TransactionManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.managers.AlliancesManager;
   import core.managers.CrewManager;
   import core.managers.PVPManager;
   import core.managers.RaffleManager;
   import core.managers.promoManager.PromoManager;
   import dispatchers.MessageDispatcher;
   import entity.GameDataComponent;
   import transactions.TGetAllChallenges;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class ZlingshotEmpires extends Zlingshot
   {
      
      public function ZlingshotEmpires()
      {
         super(GlobalEngine.getFlashVar("zlingshot_zoom") != null,true);
      }
      
      override protected function debugLog(param1:String) : void
      {
         Logger.print(this,param1);
      }
      
      override protected function get playerUid() : String
      {
         return ZGlobal.player.uid;
      }
      
      override protected function get hostPlayerUid() : String
      {
         return ZGlobal.hostPlayer.uid;
      }
      
      private function validForThisWorld(param1:Object) : Boolean
      {
         if(!param1.world)
         {
            return true;
         }
         if(param1.world == ZGlobal.hostPlayer.uid)
         {
            return true;
         }
         if(param1.id == "pvp.setDefended")
         {
            return true;
         }
         return false;
      }
      
      override protected function handle(param1:Object, param2:Number) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         super.handle(param1,param2);
         if(this.validForThisWorld(param1))
         {
            if(param1.id == "market.buy" || param1.id == "market.add" || param1.id == "market.remove")
            {
               if(param1.id == "market.buy")
               {
                  if(param1.targetUser == ZGlobal.player.uid)
                  {
                     ZGlobal.player.coins += parseInt(param1.spent);
                     if(!param1.world && param1.targetUser != ZGlobal.hostPlayer.uid)
                     {
                        return;
                     }
                  }
               }
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.RESOURCE_DIALOG_UPDATE,param1));
            }
            else if(param1.id == "object.move")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.SET_DESTINATION,param1));
               this.debugLog(param1.name + " object move to: " + param1.locX + ", " + param1.locY + " Timestamp: " + param2);
            }
            else if(param1.id == "item.setState")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.ITEM_SET_STATE,param1));
            }
            else if(param1.id == "item.removed")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.ITEM_REMOVED,param1));
            }
            else if(param1.id == "battle.resolve" || param1.id == "battle.exit")
            {
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UPDATE,param1));
               this.debugLog(" Battle msg! msg.id = " + param1.id + ". fleets " + param1.playerFleetName + " vs " + param1.enemyFleetName + ". Timestamp: " + param2);
            }
            else if(param1.id == "fleet.deploy")
            {
               if(ZGlobal.hostPlayer.fleets)
               {
                  ZGlobal.hostPlayer.fleets.teleportFleet(param1.fleet,param1.ownerID,param1.locX,param1.locY);
                  this.debugLog(param1.ownerID + " has deployed fleet: " + " Timestamp: " + param2);
               }
            }
            else if(param1.id == "item.speedup")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.SPEEDUP,param1));
            }
            else if(param1.id == "item.gift")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.ITEM_GIFT,param1));
            }
            else if(param1.id == "resource.gift")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.RESOURCE_GIFT,param1));
            }
            else if(param1.id == "xp.gift")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.XP_GIFT,param1));
            }
            else if(param1.id == "pvp.updatelist")
            {
               TransactionManager.addTransaction(new TGetAllChallenges(false),true);
            }
            else if(param1.id == "pvp.neighborRepelled")
            {
               PVPManager.instance.neighborRepelled(param1.victim,param1.invasion);
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.PVP_REPELLED,param1));
            }
            else if(param1.id == "pvp.repelledInvasion" || param1.id == "pvp.invasionComment")
            {
               PVPManager.instance.updateInvasion(param1.invasionID,param1.invader);
            }
            else if(param1.id == "pvp.occupationActive")
            {
               if(param1.invader.userData)
               {
                  PVPManager.instance.updateGlobalPVPInfo(param1.invader.userData);
               }
               PVPManager.instance.updateInvasion(param1.invasionID,param1.invader.invaderData);
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.PVP_INVADED,param1));
            }
            else if(param1.id == "pvp.setDefended" || param1.id == "pvp.defenderComment")
            {
               if(param1.world == ZGlobal.hostPlayer.uid)
               {
                  PVPManager.instance.setDefended(param1.invasionID,param1.invader);
               }
               if(param1.id == "pvp.setDefended")
               {
                  MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.PVP_ASSIST_REPELLED,param1));
               }
            }
            else if(param1.id == "pvp.rejectDefended")
            {
               PVPManager.instance.rejectDefended(param1.invasionID,param1.invader);
            }
            else if(param1.id == "pvp.lastMinuteImmunity")
            {
               PVPManager.instance.lastMinuteImmunity(param1);
            }
            else if(param1.id == "pvp.strikeTeamNotification")
            {
               PVPManager.instance.strikeTeamNotification(param1.victim,param1.notification);
            }
            else if(param1.id == "tending.requestPlaced")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.VISITOR_HELP_UPDATE,param1));
            }
            else if(param1.id == "crew")
            {
               CrewManager.instance.dispatchEvent(new WorldEvent(GameDataComponent.ZLINGSHOT_CREW_ADDED,param1));
            }
            else if(param1.id == "crewReplace")
            {
               CrewManager.instance.dispatchEvent(new WorldEvent(CrewManager.CREW_REPLACED,param1));
            }
            else if(param1.id == "crewNeighborJoined")
            {
               CrewManager.instance.dispatchEvent(new WorldEvent(CrewManager.CREW_NEIGHBORS_JOINED,param1));
            }
            else if(param1.id == "crewNeighborRemoved")
            {
               CrewManager.instance.dispatchEvent(new WorldEvent(CrewManager.CREW_NEIGHBORS_REMOVED,param1));
            }
            else if(param1.id == "neighbor")
            {
               Logger.print(this,"neighbor handle");
               for(_loc3_ in param1.neighbor)
               {
                  Logger.print(this,_loc3_ + ":" + param1.neighbor[_loc3_]);
               }
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.NEIGHBOR,param1));
            }
            else if(param1.id == "player.level")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.LEVEL_UP,param1));
            }
            else if(param1.id == "player.infamy")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.INFAMY,param1));
            }
            else if(param1.id == "player.honor")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.HONOR,param1));
            }
            else if(param1.id == "pvp.immCrew")
            {
               PVPManager.instance.addImmunityCrew(param1);
            }
            else if(param1.id == "pvp.repelCrew")
            {
               PVPManager.instance.addRepelCrew(param1);
            }
            else if(param1.id == "sentGifts")
            {
               if(param1.ineligible as Array)
               {
                  ZGlobal.initIneligibleGiftRecipients(param1.ineligible);
               }
            }
            else if(param1.id == "starterPack.complete")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.STARTER_PACK_COMPLETE,param1));
            }
            else if(param1.id == "grant.ep")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.GRANT_EP,param1));
            }
            else if(param1.id == "grant.giftable.ep")
            {
               PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.GIFTABLE_EP_GRANTED,param1));
            }
            else if(param1.id == "grant.item")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.ITEM_GIFT,param1));
            }
            else if(param1.id == "grant.FBCredit.offer2")
            {
               Logger.print(this,"**** ZlingshotEmpires/handle(), received message id \'grant.FBCredit.offer2\'");
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.GRANT_FACEBOOK_CREDIT_OFFER2,param1));
            }
            else if(param1.id == "raffleTicketReceived")
            {
               RaffleManager.instance.dispatchEvent(new WorldEvent(RaffleManager.NEW_TICKET,param1));
            }
            else if(param1.id == "MFSRewardPointUpdate")
            {
               ZGlobal.player.MFSRewardPoints = param1.MFSRewardPoints;
               ZGlobal.player.MFSRewardClaimed = param1.MFSRewardClaimed;
               ZGlobal.player.MFSRewardLap = param1.MFSRewardLap;
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.MFSP2_REWARDBAR_UPDATED));
            }
            else
            {
               _loc4_ = param1.id as String;
               if(_loc4_ != null && _loc4_.search("clan") == 0)
               {
                  MessageDispatcher.instance.dispatchEvent(new WorldEvent(AlliancesManager.CLANS_ZLINGSHOT_MSG,param1));
               }
            }
         }
      }
   }
}

