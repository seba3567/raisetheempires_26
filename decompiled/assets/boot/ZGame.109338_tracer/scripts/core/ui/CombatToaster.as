package core.ui
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.viralSurfacingManager.ViralSurfacingManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class CombatToaster extends SurvivalModePopUp
   {
      
      private var m_type:String;
      
      private const NO_ENEGRY_ICON_PATH:String = "assets/game/buildables/Buildables_Icons_1.swf/NoEnergy_01_96.png";
      
      private const DOUBLE_XP_ICON_PATH:String = "assets/game/buildables/Buildables_Icons_1.swf/DoubleXP_01_96.png";
      
      private const HALF_RANSOM_ICON_PATH:String = "assets/game/buildables/Buildables_Icons_1.swf/OrangeFlag_01_96.png";
      
      public function CombatToaster(param1:int, param2:String)
      {
         this.m_type = param2;
         super(param1);
      }
      
      public static function create(param1:int, param2:String) : CombatToaster
      {
         return new CombatToaster(param1,param2);
      }
      
      override protected function get assetClass() : String
      {
         return "CodeRed_mc";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         if(m_forceClose)
         {
            close(IMMEDIATE);
            return;
         }
         var _loc2_:Class = param1.getAssetClass(this.assetClass);
         if(_loc2_)
         {
            m_mc = new _loc2_();
            addChild(m_mc);
         }
         this.initialize();
         m_date = new Date();
         ZGlobal.player.m_survialModeToasterTime = m_date.time / 60000;
         Zlab.processManager.schedule(m_durationSeconds * 1000,this,onDurationExpired);
      }
      
      override protected function initialize() : void
      {
         var _loc1_:ImageLoader = null;
         y = m_mc.height;
         TweenLite.to(this,1,{"y":-20});
         alpha = 0;
         TweenLite.to(this,1,{"alpha":1});
         m_mc.icon.visible = true;
         switch(this.m_type)
         {
            case ViralSurfacingManager.COMBAT_NO_ENERGY:
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.NO_ENEGRY_ICON_PATH),m_mc.icon);
               m_placeholder = ZGameUtils.ZlocT("Dialogs","combatcodered_no_energy_toaster");
               break;
            case ViralSurfacingManager.COMBAT_HALF_RANSOM:
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.HALF_RANSOM_ICON_PATH),m_mc.icon);
               m_placeholder = ZGameUtils.ZlocT("Dialogs","combatcodered_half_ransom_toaster");
               break;
            case ViralSurfacingManager.COMBAT_DOUBLE_XP:
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.DOUBLE_XP_ICON_PATH),m_mc.icon);
               m_placeholder = ZGameUtils.ZlocT("Dialogs","combatcodered_double_xp_toaster");
         }
         TextFieldUtil.processTextField(m_mc.message_tf,m_placeholder);
         _loc1_.smooth = true;
         this.exit_bt.addEventListener(MouseEvent.CLICK,onExitClicked,false,0,true);
      }
      
      override protected function get exit_bt() : EventDispatcher
      {
         return m_mc.messageTabR_mc.exit_bt;
      }
   }
}

