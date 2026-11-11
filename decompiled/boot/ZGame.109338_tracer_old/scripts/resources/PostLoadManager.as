package resources
{
   import core.ZGlobal;
   import core.managers.ZPreloaderManager;
   import displays.cinema.IntroCinematics;
   import utils.CriteriaUtil;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   import zlabs.sound.SoundManager;
   
   public class PostLoadManager
   {
      
      public static var instance:PostLoadManager = new PostLoadManager();
      
      private var m_data:XMLList = null;
      
      private var m_xmlList:XMLList = null;
      
      private var m_index:uint = 0;
      
      public function PostLoadManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_data = param1;
      }
      
      private function getList() : XMLList
      {
         if(!ZGlobal.player.getSeenFlag(IntroCinematics.INTRO))
         {
            return this.m_data.newuser.load;
         }
         return this.m_data.§default§.load;
      }
      
      public function start() : void
      {
         this.m_xmlList = this.getList();
         this.m_index = 0;
         this.onLoadNext(null);
      }
      
      private function meetsCriteria(param1:XML) : Boolean
      {
         var _loc2_:Boolean = true;
         if(param1.criteria != undefined)
         {
            if(!CriteriaUtil.meetsCriteria(param1.criteria))
            {
               return false;
            }
         }
         if(param1.@audio != undefined && param1.@audio == "true")
         {
            if(Zlab.soundManager.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY))
            {
               return false;
            }
         }
         return true;
      }
      
      private function onLoadNext(param1:SWFResource) : void
      {
         var _loc2_:XML = null;
         if(this.m_index < this.m_xmlList.length())
         {
            _loc2_ = this.m_xmlList[this.m_index];
            ++this.m_index;
            if(this.meetsCriteria(_loc2_))
            {
               Logger.print(this,"Loading resource: " + _loc2_.@asset);
               Zlab.resourceManager.load(ZGlobal.getAssetURL(_loc2_.@asset),SWFResource,this.onLoadNext,null,null,false,true);
            }
            else
            {
               Logger.print(this,"Skipping resource: " + _loc2_.@asset);
            }
         }
         else
         {
            this.m_data = null;
            this.m_xmlList = null;
            instance = null;
            ZPreloaderManager.init();
         }
      }
   }
}

