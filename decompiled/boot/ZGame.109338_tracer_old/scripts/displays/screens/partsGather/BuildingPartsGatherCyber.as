package displays.screens.partsGather
{
   import ZLocalization.LocalizationObjectToken;
   import flash.events.EventDispatcher;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   
   public class BuildingPartsGatherCyber extends BuildingPartsGather
   {
      
      public static const FINISHED:String = "finished";
      
      protected var m_desc2:String = null;
      
      public function BuildingPartsGatherCyber(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null)
      {
         m_desc = param3 ? param3 : "BuildingPartsGatherDescription";
         this.m_desc2 = param6 ? param6 : "BuildingPartsGatherDescription";
         m_title = param5.length != 0 ? param5 : "BuildingPartsGatherTitle";
         super(param1,param2,param3,param4,param5);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null) : void
      {
         WindowManager.instance.push(new BuildingPartsGatherCyber(param1,param2,param3,param4,param5,param6));
      }
      
      override protected function setDescriptionText() : void
      {
         var _loc1_:LocalizationObjectToken = m_partsItem.getSentenceNameLocalizationObject("singular",false);
         TextFieldUtil.compactTextField(m_partsWindow.description2_tf,ZGameUtils.ZlocT("Dialogs",this.m_desc2,{"item":_loc1_}));
         if(!canFinish())
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs",m_desc,{"item":_loc1_}));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","BuildingPartsGatherComplete"));
         }
      }
   }
}

