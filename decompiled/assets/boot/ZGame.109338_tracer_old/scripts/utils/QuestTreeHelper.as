package utils
{
   import ZLocalization.LocalizationName;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.MercenaryItem;
   import flash.utils.Dictionary;
   
   public class QuestTreeHelper
   {
      
      public function QuestTreeHelper()
      {
         super();
      }
      
      public static function getMiniSeriesNameTokens(param1:String, param2:Array, param3:String) : Object
      {
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:LocalizationName = null;
         var _loc9_:Object = null;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc13_:MercenaryItem = null;
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:Array = GlobalEngine.socialNetwork.getFriendUsers();
         for each(_loc6_ in _loc5_)
         {
            _loc4_[_loc6_.uid] = _loc6_;
         }
         _loc7_ = ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(param1)["allies"];
         _loc9_ = new Object();
         _loc10_ = param2;
         _loc11_ = 0;
         while(_loc11_ < _loc10_.length)
         {
            _loc12_ = ZGlobal.player.neighbors[_loc7_[_loc11_]];
            if(Boolean(_loc4_[_loc7_[_loc11_]]) && Boolean(_loc4_[_loc7_[_loc11_]].hasOwnProperty("name")) && Boolean(_loc4_[_loc7_[_loc11_]].hasOwnProperty("firstName")) && Boolean(_loc4_[_loc7_[_loc11_]].hasOwnProperty("gender")))
            {
               _loc8_ = ZGameUtils.ZlocTn(param3 == "firstName" ? _loc4_[_loc7_[_loc11_]].firstName : _loc4_[_loc7_[_loc11_]].name,_loc4_[_loc7_[_loc11_]].gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC);
               _loc9_[_loc10_[_loc11_]] = _loc8_;
            }
            else if(_loc12_)
            {
               _loc8_ = ZGameUtils.ZlocTn(_loc12_.name,ZGlobal.localizer.MASC);
               _loc9_[_loc10_[_loc11_]] = _loc8_;
            }
            else
            {
               _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc7_[_loc11_],MercenaryItem) as MercenaryItem;
               if(_loc13_)
               {
                  _loc8_ = ZGameUtils.ZlocTn(_loc13_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),_loc13_.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC);
                  _loc9_[_loc10_[_loc11_]] = _loc8_;
               }
            }
            _loc11_++;
         }
         return _loc9_;
      }
      
      public static function getMiniSeriesPlayerPic(param1:String, param2:int) : String
      {
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         var _loc7_:MercenaryItem = null;
         var _loc3_:Array = ZGlobal.player.questTrees.getQuestTreeDataForQuestTree(param1)["allies"];
         if(param2 < _loc3_.length)
         {
            _loc4_ = null;
            _loc5_ = GlobalEngine.socialNetwork.getFriendUsers();
            for each(_loc6_ in _loc5_)
            {
               if(_loc6_.uid == _loc3_[param2])
               {
                  _loc4_ = _loc6_;
                  break;
               }
            }
            if(_loc4_)
            {
               return _loc4_.picture;
            }
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc3_[param2],MercenaryItem) as MercenaryItem;
            if(_loc7_)
            {
               return _loc7_.imageUrl;
            }
         }
         return null;
      }
   }
}

