package core.gamemode
{
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.states.AutoDialogState;
   import core.entities.components.behaviors.states.DialogState;
   import core.entities.components.states.IState;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.GameItem;
   import core.ui.PickManager;
   import core.ui.menuitem.OptionUIItem;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   
   public class GMContract extends GMIsland
   {
      
      private var m_entityCode:String = null;
      
      private var m_referenceItem:GameItem = null;
      
      private var m_cursorTypes:Array;
      
      public function GMContract(param1:String, param2:GameItem)
      {
         var contractCursor:String = null;
         var cursorClass:Class = null;
         var entityCode:String = param1;
         var referenceItem:GameItem = param2;
         this.m_cursorTypes = [Cursor_Mushroom,Cursor_PeppersRed,Cursor_MauiOnion,Cursor_Strawberry,Cursor_Watermelon,Cursor_Eggplant,Cursor_Corn,Cursor_SweetPotato,Cursor_Wheat,Cursor_Pineapple,Cursor_Pumpkin,Cursor_Sunflower,Cursor_Artichoke,Cursor_Tomatoes,Cursor_PeppersYellow,Cursor_OilBarrel,Cursor_Wood,Cursor_Ingots,Cursor_Cabbage,Cursor_RedOnion,Cursor_ChiliPepper,Cursor_Poppy];
         super();
         this.m_entityCode = entityCode;
         this.m_referenceItem = referenceItem;
         contractCursor = this.m_referenceItem.contractCursor;
         if(contractCursor != null && contractCursor != "")
         {
            try
            {
               cursorClass = getDefinitionByName(contractCursor) as Class;
               m_cursorImage = new cursorClass(1,1);
            }
            catch(er:Error)
            {
               Logger.error(this,"GMContract","could not find cursor: " + contractCursor);
            }
         }
      }
      
      override public function enableMode() : void
      {
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         PickManager.picksEnabled = false;
         super.enableMode();
      }
      
      override protected function getCursor() : Object
      {
         return null;
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:BuildingFSMComponent = null;
         var _loc4_:IState = null;
         if(param1)
         {
            _loc2_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
            _loc3_ = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
            if(_loc2_ != null && _loc3_ != null)
            {
               if(_loc2_.gameData.isMultiContract() && _loc2_.gameData.code == this.m_entityCode)
               {
                  _loc4_ = _loc3_.stateMachine.currentState;
                  if(!(_loc4_ is AutoDialogState))
                  {
                     if(_loc4_ is DialogState)
                     {
                        return true;
                     }
                  }
               }
            }
         }
         return false;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:BuildingFSMComponent = null;
         if(Boolean(m_highlightedObject) && this.canBeSelected(m_highlightedObject))
         {
            _loc2_ = BuildingFSMComponent(m_highlightedObject.lookupComponentByType(BuildingFSMComponent));
            DialogState(_loc2_.stateMachine.currentState).buy(this.m_referenceItem,true);
         }
         else
         {
            exitMode();
            GameModeManager.instance.getTopGameMode().updatePointer();
         }
      }
      
      override protected function deselectObject() : void
      {
         GridPointer.instance.highlight = false;
         super.deselectObject();
      }
      
      override public function disableMode() : void
      {
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
         PickManager.picksEnabled = true;
         super.disableMode();
      }
   }
}

