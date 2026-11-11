package displays.popups.quest
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class MiniSeries008DetailsPopup extends QuestDetailsPopup
   {
      
      public function MiniSeries008DetailsPopup(param1:String)
      {
         super(param1);
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         var _loc1_:MovieClip = screen;
         TextFieldUtil.compactTextField(_loc1_.panelTop_mc.title_tf,textObj.title,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
      }
      
      override protected function getTasks() : Array
      {
         var _loc1_:MovieClip = screen;
         return [_loc1_.panelBottomAssets_mc.requirement1_mc,_loc1_.panelBottomAssets_mc.requirement2_mc,_loc1_.panelBottomAssets_mc.requirement3_mc];
      }
      
      override protected function setUpQuestUI() : void
      {
         if(null == textObj.taskText)
         {
            close();
            return;
         }
         root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth * 0.5,stage.stageHeight * 0.5);
         var _loc1_:MovieClip = screen;
         var _loc2_:Object = {"maxLines":4};
         if(_loc1_.panelBottomAssets_mc.hasOwnProperty("hint_tf"))
         {
            TextFieldUtil.compactTextField(_loc1_.panelBottomAssets_mc.hint_tf,textObj.hint,_loc2_);
         }
         if(_loc1_.panelTop_mc.hasOwnProperty("desc_tf"))
         {
            TextFieldUtil.compactTextField(_loc1_.panelTop_mc.desc_tf,textObj.desc,{
               "maxLines":3,
               "filter":"ignore"
            });
         }
         if(_loc1_.panelBottomAssets_mc.hasOwnProperty("hintTitle_tf"))
         {
            TextFieldUtil.compactTextField(_loc1_.panelBottomAssets_mc.hintTitle_tf,ZGameUtils.ZlocT("QuestTrees","Hint"),{"minScale":0.7});
         }
         super.setUpQuestUI();
         contentWidth = 790;
         contentHeight = 930;
         centerWithinStage(Zlab.mainStage);
      }
      
      override protected function enableAcceptButtonArt(param1:Boolean) : void
      {
         var _loc2_:MovieClip = screen.panelBottomAssets_mc;
         _loc2_.accept_bt.visible = param1;
         _loc2_.accept_bt.mouseEnabled = param1;
         _loc2_.accept_bt.useHandCursor = param1;
         _loc2_.accept_bt.buttonMode = param1;
      }
      
      override protected function setupDialogType() : void
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:ItemImage = null;
         var _loc6_:MovieClip = null;
         var _loc1_:String = null;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(id) as ZGameQuest;
         if(m_isQuestTree)
         {
            if(_loc2_.advisorQuestPopupIconOverride != null && _loc2_.advisorQuestPopupIconOverride.length > 0)
            {
               _loc1_ = ZGlobal.getAssetURL(_loc2_.advisorQuestPopupIconOverride);
            }
            else
            {
               _loc1_ = ZGameQuestManager.instance.getButtonIconPath(id);
            }
         }
         else
         {
            _loc3_ = null;
            if(_loc2_.advisorId)
            {
               _loc3_ = _loc2_.advisorId;
            }
            else
            {
               _loc3_ = "a01";
            }
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            _loc5_ = _loc4_.getCachedImage("questHappy");
            if(_loc5_)
            {
               _loc1_ = _loc5_.url;
            }
         }
         if(_loc1_)
         {
            _loc6_ = screen;
            m_avatarLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,_loc6_.panelTop_mc.uiloader_mc);
            m_avatarLoader.smooth = true;
         }
      }
   }
}

