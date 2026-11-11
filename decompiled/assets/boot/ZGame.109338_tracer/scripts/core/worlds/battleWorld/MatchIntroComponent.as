package core.worlds.battleWorld
{
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.GameItem;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.player.IPVPPlayer;
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import rendering.rendering2d.MovieController;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class MatchIntroComponent extends EntityComponent
   {
      
      private const NUM_PLAYERS:int = 2;
      
      private var m_battleRendererComponent:BattleRendererComponent = null;
      
      private var m_movieClip:MovieClip = null;
      
      private var m_movieController:MovieController = null;
      
      private var m_enemyFleetName:String = null;
      
      private var m_images:int = 0;
      
      private var m_battleStarted:Boolean = false;
      
      public function MatchIntroComponent(param1:BattleRendererComponent)
      {
         super();
         this.m_battleRendererComponent = param1;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PRE_START,this.onPreStart);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PRE_START,this.onPreStart);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         this.dispose();
      }
      
      private function onPreStart(param1:Event) : void
      {
         this.m_enemyFleetName = null;
         BattleDispatcher.instance.addEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onQuestBattleStarted);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onBattleStart);
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Versus.swf"),SWFResource,this.onLoadComplete);
      }
      
      private function onQuestBattleStarted(param1:WorldEvent) : void
      {
         this.m_enemyFleetName = param1.eventData as String;
      }
      
      private function onBattleStart(param1:Event) : void
      {
         this.m_battleStarted = true;
         this.tryToPlay();
      }
      
      private function onBattleComplete(param1:Event) : void
      {
         this.m_battleStarted = false;
      }
      
      private function tryToPlay() : void
      {
         if(this.m_battleStarted && null != this.m_movieClip)
         {
            this.play();
            this.m_battleStarted = false;
         }
      }
      
      private function dispose() : void
      {
         if(null != this.m_movieController)
         {
            this.m_movieController.dispose();
            this.m_movieController = null;
         }
         if(null != this.m_movieClip)
         {
            this.m_movieClip.parent.removeChild(this.m_movieClip);
            this.m_movieClip = null;
         }
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onBattleStart);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onQuestBattleStarted);
      }
      
      private function loadPlayerOne() : void
      {
         ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.m_movieClip.matchIntro.player1.player1_container.player1_icon,this.onImageLoaded,this.onPlayerImageFailed);
         TextFieldUtil.processTextField(this.m_movieClip.matchIntro.player1.player1_container.player1_name,ZGlobal.player.snUser.firstName);
      }
      
      private function loadPlayerTwo() : void
      {
         var _loc3_:String = null;
         var _loc4_:IPVPPlayer = null;
         var _loc5_:String = null;
         var _loc6_:IPVPPlayer = null;
         var _loc7_:GameItem = null;
         var _loc8_:GameItem = null;
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(DominationModeManager.instance.isInDominationBattle())
         {
            _loc3_ = DominationModeManager.instance.getDominationEnemyUID();
            _loc4_ = DominationModeManager.instance.getDominationPlayer(_loc3_);
            if(_loc4_)
            {
               _loc1_ = _loc4_.firstName;
               _loc2_ = _loc4_.portraitURL;
            }
            else
            {
               _loc1_ = "";
               _loc2_ = "";
            }
         }
         else if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            _loc5_ = ChallengeModeManager.instance.currentChallengerID();
            _loc6_ = PVPManager.instance.getPVPPlayer(_loc5_);
            _loc1_ = _loc6_.firstName;
            _loc2_ = _loc6_.portraitURL;
         }
         else if(SurvivalModeManager.instance.isInSurvivalBattle())
         {
            _loc1_ = "";
            _loc2_ = "";
         }
         else if(QuestSurvivalModeManager.instance.isInQuestSurvivalBattle())
         {
            _loc7_ = (QuestManager.getInstance() as ZGameQuestManager).getCurrentVillain(this.m_enemyFleetName);
            if(null != _loc7_)
            {
               _loc1_ = ZGameUtils.ZlocT("Items",_loc7_.name + "_firstName");
               _loc2_ = ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon");
            }
         }
         else if(DeathMatchManager.instance.isInDeathMatchBattle())
         {
            _loc1_ = "";
            _loc2_ = "";
         }
         else
         {
            _loc8_ = (QuestManager.getInstance() as ZGameQuestManager).getCurrentVillain(this.m_enemyFleetName);
            if(null == _loc8_)
            {
               if(ZGlobal.player.campaign.currentMap.villain.length > 0)
               {
                  _loc8_ = ZGlobal.gameSettings.getItemByCode(ZGlobal.player.campaign.currentMap.villain,GameItem) as GameItem;
               }
            }
            if(null != _loc8_)
            {
               _loc1_ = ZGameUtils.ZlocT("Items",_loc8_.name + "_firstName");
               _loc2_ = ZGlobal.gameSettings.getImageByName(_loc8_.name,"icon");
            }
         }
         this.m_enemyFleetName = null;
         ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_movieClip.matchIntro.player2.player2_container.player2_icon,this.onImageLoaded);
         TextFieldUtil.processTextField(this.m_movieClip.matchIntro.player2.player2_container.player2_name,_loc1_);
      }
      
      private function play() : void
      {
         this.m_images = 0;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onBattleStart);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onQuestBattleStarted);
         this.loadPlayerOne();
         this.loadPlayerTwo();
         this.tryPlayMovie();
      }
      
      private function tryPlayMovie() : void
      {
         var _loc1_:Sprite = null;
         if(this.m_images == this.NUM_PLAYERS)
         {
            this.m_movieClip.visible = true;
            this.m_movieClip.x = (BattleRendererComponent.WIDTH - 400) * 0.5;
            this.m_movieClip.y = (BattleRendererComponent.WIDTH - this.m_movieClip.height) * 0.35;
            this.m_movieController = new MovieController(this.m_movieClip);
            this.m_movieController.fps = 15;
            this.m_movieController.mode = MovieController.ONCE;
            this.m_movieController.onComplete = this.dispose;
            _loc1_ = this.m_battleRendererComponent.displayObject as Sprite;
            _loc1_.addChild(this.m_movieClip);
         }
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         this.m_movieClip = param1.clip;
         this.m_movieClip.gotoAndStop(1);
         this.m_movieClip.visible = false;
         this.m_movieClip.mouseChildren = false;
         this.m_movieClip.mouseEnabled = false;
         TextFieldUtil.processTextField(this.m_movieClip.matchIntro.versus.textBox.versus,ZGameUtils.ZlocT("Combat","Versus"));
         this.tryToPlay();
      }
      
      private function onPlayerImageFailed() : void
      {
         ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl),this.m_movieClip.matchIntro.player1.player1_container.player1_icon,this.onImageLoaded);
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         ++this.m_images;
         this.tryPlayMovie();
      }
   }
}

