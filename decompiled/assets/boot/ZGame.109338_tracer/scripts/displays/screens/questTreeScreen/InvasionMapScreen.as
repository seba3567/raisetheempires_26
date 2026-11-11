package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.miniSeriesFinalReward.CashMysteryCrateFinalReward;
   import displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class InvasionMapScreen extends QuestTreeScreen
   {
      
      private static var dialogTypes:Array = [CashMysteryCrateFinalReward,MiniSeriesFinalReward];
      
      protected var m_loaders:Array = new Array();
      
      public function InvasionMapScreen(param1:String)
      {
         super(param1);
      }
      
      public static function getInvasionMap001Tokens(param1:String = "") : Object
      {
         var _loc2_:Object = new Object();
         _loc2_["user"] = ZGameUtils.ZlocTn(ZGlobal.player.name,ZGlobal.localizer.MASC);
         return _loc2_;
      }
      
      public static function getInvasionMap001FinalRewardPopup(param1:String) : ZGamePopUp
      {
         var _loc2_:String = null;
         var _loc3_:Class = null;
         if(getMainRewardType(param1) == "item")
         {
            _loc2_ = "assets/displays/miniseries/maps/Map_FinalReward.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.MiniSeriesFinalReward") as Class;
         }
         else
         {
            _loc2_ = "assets/displays/miniseries/maps/Map_FinalReward_mystery.swf";
            _loc3_ = getDefinitionByName("displays.popups.miniSeriesFinalReward.MysteryCrateFinalReward") as Class;
         }
         return new _loc3_(param1,_loc2_);
      }
      
      public static function getMainRewardType(param1:String) : String
      {
         var _loc3_:ZGameQuest = null;
         var _loc4_:XML = null;
         var _loc2_:String = null;
         if(_loc2_ == null)
         {
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
            if(_loc3_)
            {
               for each(_loc4_ in _loc3_.xml.reward)
               {
                  if(_loc4_.@mainReward != undefined)
                  {
                     return _loc4_.@type;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      override protected function initializeUI() : void
      {
         var _loc5_:ImageLoader = null;
         var _loc6_:ImageLoader = null;
         m_progressBarContainer = screen.progressBar_mc;
         super.initializeUI();
         this.contentWidth = screen.bg_mc.width;
         this.contentHeight = screen.bg_mc.height;
         screen.hintTitle_tf.visible = false;
         screen.hint_tf.visible = false;
         TextFieldUtil.compactTextField(screen.progressTitle_tf,ZGameUtils.ZlocT("QuestTrees","QT08_Progress"));
         TextFieldUtil.compactTextField(screen.header_tf,ZGameUtils.ZlocT("QuestTrees","TimeLeft"));
         var _loc1_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_questTree.xml.ui.mainScreen.@rewardGameItem2.toString(),UnitItem) as UnitItem;
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_questTree.xml.ui.mainScreen.@rewardGameItem.toString(),UnitItem) as UnitItem;
         TextFieldUtil.compactTextField(screen.tree_mc1.name_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(screen.tree_mc1.name_tf2,_loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc3_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc2_.unitClass);
         var _loc4_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc1_.unitClass);
         if(_loc3_)
         {
            _loc5_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc3_.getIconURL()),screen.tree_mc1.strength_mc.icon);
            _loc5_.smooth = true;
            this.m_loaders.push(_loc5_);
         }
         if(_loc3_)
         {
            _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_.getIconURL()),screen.tree_mc1.strength_mc2.icon);
            _loc6_.smooth = true;
            this.m_loaders.push(_loc6_);
         }
         TextFieldUtil.compactTextField(screen.tree_mc1.tierRating_mc.tier_tf,String(_loc2_.tier));
         TextFieldUtil.compactTextField(screen.tree_mc1.tierRating2_mc.tier_tf,String(_loc1_.tier));
      }
      
      override protected function createTree() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:MapNode = null;
         var _loc8_:ZGameQuest = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc1_:Dictionary = getLines();
         m_nodes = new Array();
         var _loc2_:Dictionary = new Dictionary();
         for each(_loc3_ in m_questTree.nodes)
         {
            _loc6_ = _loc3_.@screenId;
            _loc7_ = new MapNode(tree[_loc6_],_loc1_[_loc6_],_loc3_,m_questTree.id,Boolean(_loc3_.@noScale.toString()),Boolean(_loc3_.@center.toString()));
            m_nodes.push(_loc7_);
            if(tree[_loc6_] != null)
            {
               m_buttonSounds.addButton(tree[_loc6_],ButtonSound.DEFAULT);
            }
            _loc2_[_loc7_.questName] = _loc7_;
         }
         for(_loc4_ in _loc2_)
         {
            _loc8_ = QuestSettingsInit.getInstance().getItemByName(_loc4_) as ZGameQuest;
            if(_loc8_)
            {
               _loc9_ = _loc8_.sequels;
               for each(_loc10_ in _loc9_)
               {
                  if(_loc2_[_loc10_] != undefined)
                  {
                     addSequel(_loc2_[_loc4_],_loc2_[_loc10_]);
                  }
               }
            }
         }
         for(_loc5_ in _loc2_)
         {
            _loc2_[_loc5_].updateState();
         }
         updateProgress();
         updatePlayAgainButton();
      }
      
      override protected function enablePlayAgainButton(param1:Boolean) : void
      {
         super.enablePlayAgainButton(false);
      }
      
      protected function getMainReward(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:XML = new XML(_loc2_.xml.reward.toXMLString());
         var _loc4_:RewardHelper = new RewardHelper(_loc3_);
         return _loc4_.modifiedReward();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         _loc1_ = null;
         super.deinitDialog();
      }
   }
}

