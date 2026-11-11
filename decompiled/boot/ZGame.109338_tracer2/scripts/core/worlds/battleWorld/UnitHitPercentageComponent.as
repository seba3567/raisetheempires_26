package core.worlds.battleWorld
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.combatchain.CombatChain;
   import core.views.ViewManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   
   public class UnitHitPercentageComponent extends EntityComponent
   {
      
      private var m_highlightedUnit:Boolean = false;
      
      private var m_pairChosen:Boolean = false;
      
      private var m_text:MovieClip = null;
      
      private var m_combatChain:CombatChain = null;
      
      public function UnitHitPercentageComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.addEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.removeEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
      }
      
      private function onActivated(param1:Event) : void
      {
         this.m_combatChain = new CombatChain();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_HIT_PERCENT_CLASS,this.onHitPercentageClass);
      }
      
      private function onDeactivated(param1:WorldEvent) : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_HIT_PERCENT_CLASS,this.onHitPercentageClass);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onHighlightUnit);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,this.onHighlightUnit);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,this.onPairChosen);
         Zlab.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this.m_combatChain.dispose();
         this.m_combatChain = null;
         if(null != this.m_text)
         {
            Zlab.mainStage.removeChild(this.m_text);
            this.m_text = null;
         }
      }
      
      private function onHitPercentageClass(param1:WorldEvent) : void
      {
         if(null != this.m_combatChain)
         {
            this.m_text = new param1.eventData();
            this.m_text.mouseEnabled = false;
            this.m_text.mouseChildren = false;
            this.m_text.visible = false;
            this.m_text.desc_tf.visible = false;
            Zlab.mainStage.addChild(this.m_text);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,this.onHighlightUnit);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,this.onHighlightUnit);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,this.onPairChosen);
            Zlab.mainStage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         }
      }
      
      private function onHighlightUnit(param1:WorldEvent) : void
      {
         this.m_highlightedUnit = null != param1.eventData;
         this.updated();
         this.updateTextPosition(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         this.updateTextPosition(param1.stageX,param1.stageY);
      }
      
      private function updateTextPosition(param1:int, param2:int) : void
      {
         if(this.m_highlightedUnit && Boolean(this.m_text))
         {
            this.m_text.x = Math.min(param1 + 32,Zlab.mainStage.stageWidth - this.m_text.width);
            this.m_text.y = param2 + 16;
            Zlab.mainStage.setChildIndex(this.m_text,Zlab.mainStage.numChildren - 1);
         }
      }
      
      private function onPairChosen(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = null;
         var _loc3_:BattleObject = null;
         var _loc4_:uint = 0;
         this.m_pairChosen = false;
         if(null != param1.eventData)
         {
            _loc2_ = param1.eventData.player;
            _loc3_ = param1.eventData.enemy;
            if(null != _loc2_ && null != _loc3_)
            {
               _loc4_ = this.m_combatChain.GetAttackingHitChance(_loc2_,_loc3_);
               if(_loc4_ == CombatChain.GREAT)
               {
                  TextFieldUtil.processTextField(this.m_text.text_tf,ZGameUtils.ZlocT("Combat","GreatTarget"));
               }
               else if(_loc4_ == CombatChain.GOOD)
               {
                  TextFieldUtil.processTextField(this.m_text.text_tf,ZGameUtils.ZlocT("Combat","GoodTarget"));
               }
               else
               {
                  TextFieldUtil.processTextField(this.m_text.text_tf,ZGameUtils.ZlocT("Combat","PoorTarget"));
               }
               this.m_pairChosen = true;
            }
         }
         if(!this.m_pairChosen)
         {
            TextFieldUtil.processTextField(this.m_text.text_tf,"");
         }
         this.updated();
      }
      
      private function updated() : void
      {
         this.m_text.visible = this.m_highlightedUnit && this.m_pairChosen;
      }
   }
}

