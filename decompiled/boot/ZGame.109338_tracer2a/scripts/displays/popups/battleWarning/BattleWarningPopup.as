package displays.popups.battleWarning
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.combatchain.CombatChain;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class BattleWarningPopup extends GallantPopup
   {
      
      private var m_callback:Function = null;
      
      private var m_buttons:Array = null;
      
      private var m_loaders:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_enemyFleet:Fleet = null;
      
      private var m_theatre:String = null;
      
      private var m_numUnits:uint = 0;
      
      public function BattleWarningPopup(param1:Fleet, param2:String, param3:uint, param4:Function)
      {
         this.m_callback = param4;
         this.m_enemyFleet = param1;
         this.m_theatre = param2;
         this.m_numUnits = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_battleWarning.swf"));
      }
      
      public static function shouldShowWarning(param1:Array, param2:Fleet) : Boolean
      {
         var _loc3_:Array = getBattleObjectFromArray(param1);
         var _loc4_:Array = getBattleObjectFromFleet(param2);
         var _loc5_:CombatChain = new CombatChain();
         var _loc6_:Number = getScoreAgainst(_loc5_,_loc3_,_loc4_);
         var _loc7_:Number = getScoreAgainst(_loc5_,_loc4_,_loc3_);
         var _loc8_:Number = _loc6_ / _loc7_;
         return _loc8_ <= ZGlobal.gameSettings.getNumber("combatWarningPercentage",0.5);
      }
      
      private static function getBattleObjectFromFleet(param1:Fleet) : Array
      {
         var _loc3_:Unit = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in param1.units)
         {
            _loc2_.push(new BattleObject(_loc3_,param1,null));
         }
         return _loc2_;
      }
      
      private static function getBattleObjectFromArray(param1:Array) : Array
      {
         var _loc3_:String = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in param1)
         {
            _loc2_.push(new BattleObject(new Unit(_loc3_ + ",0",0,null),null,null));
         }
         return _loc2_;
      }
      
      private static function getScoreAgainst(param1:CombatChain, param2:Array, param3:Array) : Number
      {
         var _loc5_:BattleObject = null;
         var _loc6_:BattleObject = null;
         var _loc7_:uint = 0;
         var _loc4_:Number = 0;
         for each(_loc5_ in param2)
         {
            for each(_loc6_ in param3)
            {
               if(_loc5_.unitItem.secondaryAbility)
               {
                  _loc4_ += 1;
               }
               else
               {
                  _loc7_ = param1.GetAttackingHitChance(_loc5_,_loc6_);
                  if(_loc7_ == CombatChain.GREAT)
                  {
                     _loc4_ += 2;
                  }
                  else if(_loc7_ == CombatChain.GOOD)
                  {
                     _loc4_ += 1;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      override protected function initializeScreen() : void
      {
         this.contentWidth = 520;
         super.initializeScreen();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttons = new Array(2);
         var _loc1_:ZGameButton = new ZGameButton(this.screen.green_bt,this.onGreenButtonClicked);
         _loc1_.text = ZGameUtils.ZlocT("Dialogs","BattleWarning_Redeploy");
         this.m_buttons.push(_loc1_);
         this.m_buttonSounds.addButton(_loc1_.m_overlay,ButtonSound.DEFAULT);
         var _loc2_:ZGameButton = new ZGameButton(this.screen.red_bt,this.onRedButtonClicked);
         _loc2_.text = ZGameUtils.ZlocT("Dialogs","BattleWarning_Fight");
         this.m_buttons.push(_loc2_);
         this.m_buttonSounds.addButton(_loc2_.m_overlay,ButtonSound.DEFAULT);
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","BattleWarning_Title"));
         TextFieldUtil.processTextField(this.screen.description_tf,ZGameUtils.ZlocT("Dialogs","BattleWarning_Desc"));
         this.fillOutSuggestion();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ZGameButton = null;
         var _loc2_:ImageLoader = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         for each(_loc1_ in this.m_buttons)
         {
            _loc1_.dispose();
         }
         this.m_buttons = null;
         for each(_loc2_ in this.m_loaders)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
            }
         }
         this.m_loaders = null;
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_callback = null;
         super.deinitDialog();
      }
      
      private function getOrderedItems() : Array
      {
         var _loc5_:uint = 0;
         var _loc6_:UnitItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:Unit = null;
         var _loc3_:UnitItem = null;
         var _loc4_:Dictionary = new Dictionary();
         for each(_loc2_ in this.m_enemyFleet.units)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,UnitItem) as UnitItem;
            if(_loc4_[_loc3_.code] == null)
            {
               _loc4_[_loc3_.code] = _loc3_.getStrength(this.m_enemyFleet);
            }
         }
         for each(_loc2_ in this.m_enemyFleet.units)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,UnitItem) as UnitItem;
            _loc5_ = 0;
            for each(_loc6_ in _loc1_)
            {
               if(_loc4_[_loc3_.code] > _loc4_[_loc6_.code])
               {
                  break;
               }
               _loc5_++;
            }
            _loc1_.splice(_loc5_,0,_loc3_);
         }
         return _loc1_;
      }
      
      private function getGoodAgainst(param1:UnitItem) : UnitClass
      {
         var _loc3_:UnitClass = null;
         var _loc2_:Array = UnitClassManager.instance.getCountersFor(param1);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.getTheatre() == this.m_theatre)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      private function getOrder(param1:uint) : Array
      {
         switch(param1)
         {
            case 1:
               return [2];
            case 2:
               return [1,2];
            case 3:
               return [1,2,3];
            case 4:
               return [0,1,2,3];
            case 5:
               return [0,1,2,3,4];
            default:
               return [];
         }
      }
      
      private function getDisplayOrder(param1:uint) : Array
      {
         var _loc2_:Array = new Array();
         var _loc3_:uint = 0;
         while(_loc3_ < this.m_numUnits)
         {
            _loc2_.push(_loc3_ % param1);
            _loc3_++;
         }
         _loc2_.sort();
         return _loc2_;
      }
      
      private function fillOutSuggestion() : void
      {
         var _loc6_:UnitItem = null;
         var _loc7_:MovieClip = null;
         var _loc8_:Array = null;
         var _loc9_:uint = 0;
         var _loc10_:ImageLoader = null;
         var _loc1_:Array = null;
         var _loc2_:Array = this.getOrder(this.m_numUnits);
         if(this.m_numUnits % 2 == 0)
         {
            this.screen.cards.even.visible = true;
            this.screen.cards.odd.visible = false;
            _loc1_ = [this.screen.cards.even.card01,this.screen.cards.even.card02,this.screen.cards.even.card03,this.screen.cards.even.card04];
         }
         else
         {
            this.screen.cards.even.visible = false;
            this.screen.cards.odd.visible = true;
            _loc1_ = [this.screen.cards.odd.card01,this.screen.cards.odd.card02,this.screen.cards.odd.card03,this.screen.cards.odd.card04,this.screen.cards.odd.card05];
         }
         var _loc3_:Array = new Array();
         var _loc4_:Array = this.getOrderedItems();
         var _loc5_:UnitClass = null;
         for each(_loc6_ in _loc4_)
         {
            _loc3_.push(this.getGoodAgainst(_loc6_));
         }
         for each(_loc7_ in _loc1_)
         {
            _loc7_.class_tf.text = "";
         }
         _loc8_ = this.getDisplayOrder(_loc3_.length);
         this.m_loaders = new Array();
         _loc9_ = 0;
         while(_loc9_ < this.m_numUnits)
         {
            _loc5_ = _loc3_[_loc8_[_loc9_]];
            _loc10_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc5_.getIconURL()),_loc1_[_loc2_[_loc9_]].icon);
            if(_loc10_)
            {
               this.m_loaders.push(_loc10_);
            }
            TextFieldUtil.processTextField(_loc1_[_loc2_[_loc9_]].class_tf,_loc5_.getName());
            _loc9_++;
         }
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen;
      }
      
      private function onGreenButtonClicked(param1:MouseEvent) : void
      {
         this.m_callback(GenericPopup.YES);
         close();
      }
      
      private function onRedButtonClicked(param1:MouseEvent) : void
      {
         this.m_callback(GenericPopup.NO);
         close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.m_callback(GenericPopup.YES);
         close();
      }
   }
}

