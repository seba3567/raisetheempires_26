package core.managers.campaignManager
{
   import core.ZGlobal;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import utils.CriteriaUtil;
   import utils.ZGameUtils;
   
   public class CampaignManager extends EventDispatcher
   {
      
      private static var m_instance:CampaignManager = null;
      
      private var m_chapterXML:Dictionary = null;
      
      private var m_chapterLists:Dictionary = null;
      
      private var m_campaignXML:Dictionary = null;
      
      private var m_orderedCampaignNames:Array = null;
      
      private var m_villainCodeToIslands:Dictionary = null;
      
      public function CampaignManager()
      {
         super();
      }
      
      public static function get instance() : CampaignManager
      {
         if(!m_instance)
         {
            m_instance = new CampaignManager();
         }
         return m_instance;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:XML = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         this.m_chapterXML = new Dictionary();
         this.m_chapterLists = new Dictionary();
         this.m_campaignXML = new Dictionary();
         this.m_orderedCampaignNames = new Array();
         this.m_villainCodeToIslands = new Dictionary();
         var _loc2_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("IslandGroup");
         for each(_loc3_ in _loc2_)
         {
            _loc6_ = _loc3_.@code;
            this.m_chapterXML[_loc6_] = _loc3_;
         }
         _loc4_ = param1;
         for each(_loc5_ in _loc4_.campaign)
         {
            _loc7_ = _loc5_.@name;
            this.m_orderedCampaignNames.push(_loc7_);
            this.m_campaignXML[_loc7_] = _loc5_;
            _loc8_ = new Array();
            _loc9_ = _loc5_.@startChapter;
            while(Boolean(_loc9_) && Boolean(_loc9_.length))
            {
               _loc8_.push(this.m_chapterXML[_loc9_]);
               if(this.m_chapterXML[_loc9_].@villain != undefined)
               {
                  _loc11_ = this.m_chapterXML[_loc9_].@villain;
                  if(this.m_villainCodeToIslands[_loc11_] != null)
                  {
                     this.m_villainCodeToIslands[_loc11_].push(_loc9_);
                  }
                  else
                  {
                     this.m_villainCodeToIslands[_loc11_] = new Array();
                     this.m_villainCodeToIslands[_loc11_].push(_loc9_);
                  }
               }
               _loc9_ = this.m_chapterXML[_loc9_].@unlocks;
            }
            for each(_loc10_ in _loc5_.skipChapter)
            {
               _loc12_ = _loc10_.@name;
               _loc8_.push(this.m_chapterXML[_loc12_]);
            }
            this.m_chapterLists[_loc7_] = _loc8_;
         }
      }
      
      public function getVillainIslandCount(param1:String) : int
      {
         return this.m_villainCodeToIslands[param1] ? int((this.m_villainCodeToIslands[param1] as Array).length) : 0;
      }
      
      public function getIslandsForVillain(param1:String) : Array
      {
         return this.m_villainCodeToIslands[param1] ? this.m_villainCodeToIslands[param1] : null;
      }
      
      public function get campaignNamesArray() : Array
      {
         return this.m_orderedCampaignNames;
      }
      
      public function get eligibleCampaignCount() : int
      {
         var _loc4_:XML = null;
         var _loc1_:int = 0;
         var _loc2_:Array = this.campaignNamesArray;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = this.getCampaignDefinition(_loc2_[_loc3_]);
            if(CriteriaUtil.meetsCriteria(_loc4_.criteria))
            {
               _loc1_++;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function defaultCampaignName() : String
      {
         var _loc1_:String = null;
         var _loc2_:XML = null;
         for each(_loc1_ in this.m_orderedCampaignNames)
         {
            _loc2_ = this.m_campaignXML[_loc1_];
            if(_loc2_.@§default§.toString().length > 0 && _loc2_.@§default§.toString() == "true")
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      public function getChaptersArray(param1:String) : Array
      {
         return this.m_chapterLists[param1];
      }
      
      public function getCampaignDefinition(param1:String) : XML
      {
         return this.m_campaignXML[param1];
      }
      
      public function getCampaignForChapter(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         loop0:
         for(_loc2_ in this.m_chapterLists)
         {
            var _loc6_:int = 0;
            var _loc7_:* = this.m_chapterLists[_loc2_];
            do
            {
               for each(_loc3_ in _loc7_)
               {
               }
               continue loop0;
            }
            while(_loc3_.@code != param1);
            return _loc2_;
         }
         return null;
      }
      
      public function getCampaignMenuName(param1:String) : String
      {
         return ZGameUtils.localizedStringForToken(this.getCampaignDefinition(param1).@menuName,"Campaign");
      }
      
      public function isEligibleCampaign(param1:String) : Boolean
      {
         var _loc2_:XML = this.getCampaignDefinition(param1);
         return Boolean(_loc2_) && CriteriaUtil.meetsCriteria(_loc2_.criteria);
      }
      
      public function nextEligibleCampaign(param1:String) : String
      {
         return this.findEligibleCampaign(param1,1);
      }
      
      public function prevEligibleCampaign(param1:String) : String
      {
         return this.findEligibleCampaign(param1,-1);
      }
      
      private function findEligibleCampaign(param1:String, param2:int) : String
      {
         var _loc3_:Array = this.campaignNamesArray;
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            if(param1 == _loc3_[_loc5_])
            {
               _loc4_ = _loc5_;
               break;
            }
            _loc5_++;
         }
         if(_loc4_ >= 0)
         {
            _loc4_ += param2;
            while(_loc4_ >= 0 && _loc4_ < _loc3_.length)
            {
               if(this.isEligibleCampaign(_loc3_[_loc4_]))
               {
                  return _loc3_[_loc4_];
               }
               _loc4_ += param2;
            }
         }
         return null;
      }
   }
}

