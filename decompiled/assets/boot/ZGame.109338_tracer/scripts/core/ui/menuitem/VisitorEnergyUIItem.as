package core.ui.menuitem
{
   import com.greensock.TweenLite;
   import core.*;
   import core.managers.PVPManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.rewardPickupManager.SocialXpBadRewardPickup;
   import core.managers.rewardPickupManager.SocialXpGoodRewardPickup;
   import core.managers.visitorManager.VisitorManager;
   import core.ui.Tooltip;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.UIDispatcher;
   import events.ExperienceUpdatedEvent;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class VisitorEnergyUIItem extends MenuItem
   {
      
      public static const ITEM_ID:String = "visitorEnergyItem";
      
      public static const SHOW_VISITORENERGY:String = "showVisitorEnergy";
      
      public static const HIDE_VISITORENERGY:String = "hideVisitorEnergy";
      
      private static const URL:String = "assets/game/visiting/FriendEnergy.swf";
      
      private static const UI_MARGIN_X:int = 5;
      
      private var m_mc:MovieClip = null;
      
      private var m_tf:TextField = null;
      
      public function VisitorEnergyUIItem()
      {
         super(ITEM_ID);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition,false,0,true);
         UIDispatcher.instance.addEventListener(SHOW_VISITORENERGY,this.onShow,false,0,true);
         UIDispatcher.instance.addEventListener(HIDE_VISITORENERGY,this.onHide,false,0,true);
         var _loc1_:String = ZGlobal.getAssetURL(URL);
         if(Zlab.resourceManager.validUrl(_loc1_))
         {
            Zlab.resourceManager.load(_loc1_,SWFResource,this.onLoadComplete,this.onLoadFail);
         }
      }
      
      override public function removeItem() : void
      {
         super.removeItem();
         VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
         VisitorManager.instance.removeEventListener(VisitorManager.VISITOR_ENERGY_SPENT,this.onEnergySpent);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition);
         UIDispatcher.instance.removeEventListener(SHOW_VISITORENERGY,this.onShow);
         UIDispatcher.instance.removeEventListener(HIDE_VISITORENERGY,this.onHide);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.GOOD_XP,this.onGoodExperienceUpdated);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.BAD_XP,this.onBadExperienceUpdated);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.GOOD_LEVEL,this.onGoodLevelUpdated);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.BAD_LEVEL,this.onBadLevelUpdated);
         if(this.m_mc)
         {
            this.m_mc.redHeart_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onGoodExperienceRollOver);
            this.m_mc.redHeart_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onGoodExperienceRollOut);
            this.m_mc.blackHeart_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onBadExperienceRollOver);
            this.m_mc.blackHeart_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onBadExperienceRollOut);
         }
      }
      
      protected function onReposition(param1:RepositionEvent) : void
      {
         x = param1.x + UI_MARGIN_X;
         y = param1.height;
      }
      
      private function onWorldLoaded(param1:Event = null) : void
      {
         if(ZGlobal.isVisiting())
         {
            ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.GOOD_XP,this.onGoodExperienceUpdated,false,0,true);
            ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.BAD_XP,this.onBadExperienceUpdated,false,0,true);
            ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.GOOD_LEVEL,this.onGoodLevelUpdated,false,0,true);
            ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.BAD_LEVEL,this.onBadLevelUpdated,false,0,true);
            RewardPickupManager.instance.registerUIElement(this.m_mc.redHeart_mc,0,SocialXpGoodRewardPickup.NAME);
            RewardPickupManager.instance.registerUIElement(this.m_mc.blackHeart_mc,0,SocialXpBadRewardPickup.NAME);
            this.m_mc.redHeart_mc.addEventListener(MouseEvent.ROLL_OVER,this.onGoodExperienceRollOver,false,0,true);
            this.m_mc.redHeart_mc.addEventListener(MouseEvent.ROLL_OUT,this.onGoodExperienceRollOut,false,0,true);
            this.m_mc.blackHeart_mc.addEventListener(MouseEvent.ROLL_OVER,this.onBadExperienceRollOver,false,0,true);
            this.m_mc.blackHeart_mc.addEventListener(MouseEvent.ROLL_OUT,this.onBadExperienceRollOut,false,0,true);
            this.updateGoodXP(ZGlobal.player.socialXpGood);
            this.updateBadXP(ZGlobal.player.socialXpBad);
            this.updateGoodLevel(ZGlobal.player.socialLevelGood);
            this.updateBadLevel(ZGlobal.player.socialLevelBad);
            if(PVPManager.instance.isNormalVisit())
            {
               this.m_mc.redHeart_mc.visible = true;
               this.m_mc.blackHeart_mc.visible = false;
               this.m_mc.main_mc.visible = true;
               this.m_mc.main_mc.addEventListener(MouseEvent.ROLL_OVER,this.onEnergyRollOver,false,0,true);
               this.m_mc.main_mc.addEventListener(MouseEvent.ROLL_OUT,this.onEnergyRollOut,false,0,true);
               VisitorManager.instance.addEventListener(VisitorManager.VISITOR_ENERGY_SPENT,this.onEnergySpent,false,0,true);
               this.updateValue(ZGlobal.player.visitorEnergy,true);
            }
            else
            {
               this.m_mc.redHeart_mc.visible = false;
               this.m_mc.blackHeart_mc.visible = true;
               this.m_mc.main_mc.visible = false;
               this.m_mc.main_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onEnergyRollOver);
               this.m_mc.main_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onEnergyRollOut);
               VisitorManager.instance.removeEventListener(VisitorManager.VISITOR_ENERGY_SPENT,this.onEnergySpent);
               this.updateValue(0,true);
            }
            addChild(this.m_mc);
         }
         else if(this.m_mc.parent)
         {
            ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.GOOD_XP,this.onGoodExperienceUpdated);
            ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.BAD_XP,this.onBadExperienceUpdated);
            ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.GOOD_LEVEL,this.onGoodLevelUpdated);
            ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.BAD_LEVEL,this.onBadLevelUpdated);
            this.m_mc.redHeart_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onGoodExperienceRollOver);
            this.m_mc.redHeart_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onGoodExperienceRollOut);
            this.m_mc.blackHeart_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onBadExperienceRollOver);
            this.m_mc.blackHeart_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onBadExperienceRollOut);
            VisitorManager.instance.removeEventListener(VisitorManager.VISITOR_ENERGY_SPENT,this.onEnergySpent);
            if(this.m_mc.parent == this)
            {
               this.m_mc.parent.removeChild(this.m_mc);
            }
         }
      }
      
      private function onGoodLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.updateGoodLevel(param1.newAmount);
      }
      
      private function onBadLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.updateBadLevel(param1.newAmount);
      }
      
      private function updateGoodLevel(param1:int) : void
      {
         TextFieldUtil.processTextField(this.m_mc.redHeart_mc.icon_mc.level_tf,param1.toString());
      }
      
      private function updateBadLevel(param1:int) : void
      {
         TextFieldUtil.processTextField(this.m_mc.blackHeart_mc.icon_mc.level_tf,param1.toString());
      }
      
      private function onGoodExperienceUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.updateGoodXP(param1.newAmount);
      }
      
      private function onBadExperienceUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.updateBadXP(param1.newAmount);
      }
      
      private function updateGoodXP(param1:int) : void
      {
         var levels:XMLList = null;
         var currentLevelXml:XMLList = null;
         var nextLevelXml:XMLList = null;
         var currentRequiredXP:int = 0;
         var nextRequiredXP:int = 0;
         var newWidth:int = 0;
         var value:int = param1;
         TextFieldUtil.processTextField(this.m_mc.redHeart_mc.label_tf,value.toString());
         levels = ZGlobal.gameSettings.getXML().reputationGood.level;
         currentLevelXml = levels.(@num == ZGlobal.player.socialLevelGood);
         nextLevelXml = levels.(@num == ZGlobal.player.socialLevelGood + 1);
         if(Boolean(currentLevelXml) && Boolean(nextLevelXml))
         {
            currentRequiredXP = parseInt(currentLevelXml.@requiredXP);
            nextRequiredXP = parseInt(nextLevelXml.@requiredXP);
            newWidth = this.m_mc.redHeart_mc.base_mc.width * Number((ZGlobal.player.socialXpGood - currentRequiredXP) / (nextRequiredXP - currentRequiredXP));
            TweenLite.to(this.m_mc.redHeart_mc.energyBar_mc,0.5,{"width":newWidth});
         }
      }
      
      private function updateBadXP(param1:int) : void
      {
         var levels:XMLList = null;
         var currentLevelXml:XMLList = null;
         var nextLevelXml:XMLList = null;
         var currentRequiredXP:int = 0;
         var nextRequiredXP:int = 0;
         var newWidth:int = 0;
         var value:int = param1;
         TextFieldUtil.processTextField(this.m_mc.blackHeart_mc.label_tf,value.toString());
         levels = ZGlobal.gameSettings.getXML().reputationBad.level;
         currentLevelXml = levels.(@num == ZGlobal.player.socialLevelBad);
         nextLevelXml = levels.(@num == ZGlobal.player.socialLevelBad + 1);
         if(Boolean(currentLevelXml) && Boolean(nextLevelXml))
         {
            currentRequiredXP = parseInt(currentLevelXml.@requiredXP);
            nextRequiredXP = parseInt(nextLevelXml.@requiredXP);
            newWidth = this.m_mc.blackHeart_mc.base_mc.width * Number((ZGlobal.player.socialXpBad - currentRequiredXP) / (nextRequiredXP - currentRequiredXP));
            TweenLite.to(this.m_mc.blackHeart_mc.energyBar_mc,0.5,{"width":newWidth});
         }
      }
      
      private function onEnergyRollOver(param1:MouseEvent) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("maxVisitingEnergy",15);
         var _loc3_:String = ZGameUtils.ZlocT("Main","VisitorEnergy_Tooltip",{
            "energy":ZGlobal.player.visitorEnergy,
            "energyMax":_loc2_
         });
         Tooltip.show(_loc3_,null,this.m_mc.main_mc);
      }
      
      private function onEnergyRollOut(param1:MouseEvent) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_mc.main_mc))
         {
            Tooltip.hide();
         }
      }
      
      private function onGoodExperienceRollOver(param1:MouseEvent) : void
      {
         Tooltip.show(this.generateGoodExperienceString(),null,this.m_mc.redHeart_mc.energyBar_mc);
      }
      
      private function onGoodExperienceRollOut(param1:MouseEvent) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_mc.redHeart_mc.energyBar_mc))
         {
            Tooltip.hide();
         }
      }
      
      private function generateGoodExperienceString() : String
      {
         var experienceString:String = null;
         var levels:XMLList = null;
         var nextLevelXml:XMLList = null;
         var requiredXp:int = 0;
         levels = ZGlobal.gameSettings.getXML().reputationGood.level;
         nextLevelXml = levels.(@num == ZGlobal.player.socialLevelGood + 1);
         if(nextLevelXml[0])
         {
            requiredXp = parseInt(nextLevelXml[0].@requiredXP);
            experienceString = ZGameUtils.ZlocT("Main","goodXP_Tooltip",{
               "xp":ZGlobal.player.socialXpGood,
               "xpNext":requiredXp
            });
         }
         else
         {
            experienceString = ZGameUtils.ZlocT("Main","goodXP_TooltipCapped",{"xp":ZGlobal.player.socialXpGood});
         }
         return experienceString;
      }
      
      private function onBadExperienceRollOver(param1:MouseEvent) : void
      {
         Tooltip.show(this.generateBadExperienceString(),null,this.m_mc.blackHeart_mc.energyBar_mc);
      }
      
      private function onBadExperienceRollOut(param1:MouseEvent) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_mc.blackHeart_mc.energyBar_mc))
         {
            Tooltip.hide();
         }
      }
      
      private function generateBadExperienceString() : String
      {
         var experienceString:String = null;
         var levels:XMLList = null;
         var nextLevelXml:XMLList = null;
         var requiredXp:int = 0;
         levels = ZGlobal.gameSettings.getXML().reputationBad.level;
         nextLevelXml = levels.(@num == ZGlobal.player.socialLevelBad + 1);
         if(nextLevelXml[0])
         {
            requiredXp = parseInt(nextLevelXml[0].@requiredXP);
            experienceString = ZGameUtils.ZlocT("Main","badXP_Tooltip",{
               "xp":ZGlobal.player.socialXpBad,
               "xpNext":requiredXp
            });
         }
         else
         {
            experienceString = ZGameUtils.ZlocT("Main","badXP_TooltipCapped",{"xp":ZGlobal.player.socialXpBad});
         }
         return experienceString;
      }
      
      private function onEnergySpent(param1:Event) : void
      {
         this.updateValue(ZGlobal.player.visitorEnergy,false);
      }
      
      private function updateValue(param1:Number, param2:Boolean) : void
      {
         this.m_tf.text = String(param1);
         if(param2)
         {
            TweenLite.killTweensOf(this.m_tf,true);
            this.m_tf.alpha = 1;
         }
         else
         {
            this.m_tf.alpha = 0;
            TweenLite.to(this.m_tf,0.5,{"alpha":1});
         }
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         this.m_mc = param1.clip as MovieClip;
         this.m_tf = this.m_mc.main_mc.num_tf;
         param1.destroy();
         VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded,false,0,true);
         this.onWorldLoaded();
      }
      
      private function onLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load image \'" + URL + "\'");
      }
      
      private function onShow(param1:Event) : void
      {
         if(this.m_mc)
         {
            this.m_mc.visible = true;
         }
      }
      
      private function onHide(param1:Event) : void
      {
         if(this.m_mc)
         {
            this.m_mc.visible = false;
         }
      }
   }
}

