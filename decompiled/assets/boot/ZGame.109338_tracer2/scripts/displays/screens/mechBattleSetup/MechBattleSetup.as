package displays.screens.mechBattleSetup
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gamemode.prebattle.TitanUI;
   import core.gameobjects.Fleet;
   import core.managers.ExperimentsManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class MechBattleSetup extends Sprite
   {
      
      public static var ENABLED:Boolean = false;
      
      private var m_clip:MovieClip = null;
      
      private var m_parent:DisplayObjectContainer = null;
      
      private var m_locations:Array = null;
      
      private var m_cancel:Function = null;
      
      private var m_titanUI:TitanUI = null;
      
      private var m_numUnits:int = 0;
      
      public function MechBattleSetup(param1:DisplayObjectContainer, param2:Function, param3:TitanUI, param4:int)
      {
         super();
         this.m_parent = param1;
         this.m_cancel = param2;
         this.m_titanUI = param3;
         this.m_numUnits = param4;
         this.m_parent.addChild(this);
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/displays/screens/MechCombatSetup.swf"),SWFResource,this.onLoadComplete,this.onLoadFail);
      }
      
      public static function isEnabled() : Boolean
      {
         if(ENABLED)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_TITAN_FIGHT_MASTER) == ExperimentsManager.VARIANT_TITAN_FIGHT_ACTIVE)
            {
               return true;
            }
         }
         return false;
      }
      
      public function dispose() : void
      {
         var _loc1_:Location = null;
         this.m_parent.removeChild(this);
         if(this.m_locations)
         {
            for each(_loc1_ in this.m_locations)
            {
               _loc1_.dispose();
            }
            this.m_locations = null;
         }
         if(this.m_clip)
         {
            TweenLite.killTweensOf(this.m_clip);
            removeChild(this.m_clip);
            this.m_clip = null;
         }
         this.m_titanUI = null;
         this.m_parent = null;
         this.m_cancel = null;
      }
      
      public function updateUI(param1:TitanUI) : void
      {
         var _loc2_:Location = null;
         for each(_loc2_ in this.m_locations)
         {
            _loc2_.updateUIState(param1);
         }
         if(this.m_clip)
         {
            this.updateLights();
         }
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         if(this.m_parent)
         {
            this.m_clip = param1.clip;
            this.m_clip.screen.frame_mc.mouseEnabled = false;
            this.m_clip.screen.frame_mc.mouseChildren = false;
            this.m_locations = new Array();
            this.m_locations.push(new Location(TitanUI.ARM1,this.m_clip.screen.armRight_mc,this.onLocationCancel));
            this.m_locations.push(new Location(TitanUI.SHOULDER1,this.m_clip.screen.shoulderRight_mc,this.onLocationCancel));
            this.m_locations.push(new Location(TitanUI.HEAD,this.m_clip.screen.head_mc,this.onLocationCancel));
            this.m_locations.push(new Location(TitanUI.SHOULDER2,this.m_clip.screen.shoulderLeft_mc,this.onLocationCancel));
            this.m_locations.push(new Location(TitanUI.ARM2,this.m_clip.screen.armLeft_mc,this.onLocationCancel));
            this.m_clip.y += this.m_clip.height;
            this.initLights();
            TweenLite.to(this.m_clip,0.75,{"y":0});
            addChild(this.m_clip);
         }
      }
      
      private function initLights() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Array = this.getLights(Fleet.MAX_UNITS);
         for each(_loc1_ in _loc2_)
         {
            _loc1_.visible = false;
         }
         _loc2_ = this.getLights(this.m_numUnits);
         for each(_loc1_ in _loc2_)
         {
            _loc1_.visible = true;
         }
         this.updateLights();
      }
      
      private function onLoadFail(param1:SWFResource) : void
      {
      }
      
      private function onLocationCancel(param1:int) : void
      {
         this.m_cancel(param1);
      }
      
      private function updateLights() : void
      {
         var _loc1_:Array = this.getLights(this.m_numUnits);
         var _loc2_:int = this.m_titanUI.getNumOccupied();
         var _loc3_:int = int(_loc1_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_[_loc4_].gotoAndStop(_loc4_ < _loc2_ ? 2 : 1);
            _loc4_++;
         }
      }
      
      private function getLights(param1:int) : Array
      {
         switch(param1)
         {
            case 5:
               return [this.m_clip.screen.light1,this.m_clip.screen.light2,this.m_clip.screen.light3,this.m_clip.screen.light4,this.m_clip.screen.light5];
            case 4:
               return [this.m_clip.screen.light1,this.m_clip.screen.light2,this.m_clip.screen.light4,this.m_clip.screen.light5];
            case 3:
               return [this.m_clip.screen.light2,this.m_clip.screen.light3,this.m_clip.screen.light4];
            case 2:
               return [this.m_clip.screen.light2,this.m_clip.screen.light4];
            case 1:
               return [this.m_clip.screen.light3];
            default:
               return null;
         }
      }
   }
}

