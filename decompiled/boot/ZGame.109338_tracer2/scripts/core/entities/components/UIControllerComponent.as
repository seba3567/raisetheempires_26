package core.entities.components
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.RaffleManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.managers.visitorManager.VisitorManager;
   import core.ui.Tooltip;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.utils.getDefinitionByName;
   import utils.ZGameUtils;
   import zlabs.Constants;
   import zlabs.components.TickedComponent;
   import zlabs.debug.Logger;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.utils.ColorsUtil;
   
   public class UIControllerComponent extends TickedComponent
   {
      
      public static const HIGHLIGHT:String = "uihighlight";
      
      public static const SET_TEMP_STATE_CURSOR:String = "iucgetcursor";
      
      public static const EVENT_SPRITE_EFFECT:String = "spriteEffectEvent";
      
      public static const EVENT_FILTER_EFFECT:String = "filterEffectEvent";
      
      public static const SPRITE_EFFECT_SELECTED_ON:String = "spriteEffectSelectedOn";
      
      public static const SPRITE_EFFECT_SELECTED_OFF:String = "spriteEffectSelectedOff";
      
      public static const SPRITE_EFFECT_GHOST_ON:String = "spriteEffectGhostOn";
      
      public static const SPRITE_EFFECT_GHOST_OFF:String = "spriteEffectGhostOff";
      
      public static const SPRITE_EFFECT_VISITOR_HELPING_ON:String = "spriteEffectVisitorHelpingOn";
      
      public static const SPRITE_EFFECT_VISITOR_HELPING_OFF:String = "spriteEffectVisitorHelpingOff";
      
      public static const SPRITE_EFFECT_ENABLED_ON:String = "spriteEffectEnabledOn";
      
      public static const SPRITE_EFFECT_ENABLED_OFF:String = "spriteEffectEnabledOff";
      
      public static const FILTER_MULTIHARVEST_HIGHLIGHT_ON:String = "filterMultiHarvestHighlightOn";
      
      public static const FILTER_MULTIHARVEST_HIGHLIGHT_OFF:String = "filterMultiHarvestHighlightOff";
      
      public static const FILTER_EFFECT_PILLAGEABLE_ON:String = "filterEffectPillageableOn";
      
      public static const FILTER_EFFECT_PILLAGEABLE_OFF:String = "filterEffectPillageableOff";
      
      public static const FILTER_EFFECT_PILLAGE_PLACEMENT_ON:String = "filterEffectPillagePlacementOn";
      
      public static const FILTER_EFFECT_PILLAGE_PLACEMENT_OFF:String = "filterEffectPillagePlacementOff";
      
      public static const FILTER_EFFECT_PROTECTED_ON:String = "filterEffectProtectedOn";
      
      public static const FILTER_EFFECT_PROTECTED_OFF:String = "filterEffectProtectedOff";
      
      public static const FILTER_EFFECT_PROTECTOR_ON:String = "filterEffectProtectorOn";
      
      public static const FILTER_EFFECT_PROTECTOR_OFF:String = "filterEffectProtectorOff";
      
      public static const FILTER_EFFECT_AREA_IMMUNE_ON:String = "filterEffectAreaImmuneOn";
      
      public static const FILTER_EFFECT_AREA_IMMUNE_OFF:String = "filterEffectAreaImmuneOff";
      
      public static const FILTER_EFFECT_AREA_IMMUNE_PILLAGE_PLACEMENT_ON:String = "filterEffectAreaImmunePillagePlacementOn";
      
      public static const FILTER_EFFECT_AREA_IMMUNE_PILLAGE_PLACEMENT_OFF:String = "filterEffectAreaImmunePillagePlacementOff";
      
      private static const FILTER_MULTIHARVEST_INDEX:uint = 0;
      
      private static const FILTER_PILLAGE_PLACEMENT_INDEX:uint = 1;
      
      private static const FILTER_PILLAGE_INDEX:uint = 2;
      
      private static const FILTER_PROTECTED_INDEX:uint = 3;
      
      private static const FILTER_PROTECTOR_INDEX:uint = 4;
      
      private static const FILTER_AREA_IMMUNE_INDEX:uint = 5;
      
      private static const FILTER_AREA_IMMUNE_PILLAGE_PLACEMENT_INDEX:uint = 6;
      
      public static const EVENT_TOOLTIP_UPDATE:String = "tooltipUpdateEvent";
      
      public static const TOOLTIP_TYPE_CONTRACT:String = "contract";
      
      private static var m_tempStateCursorName:String = null;
      
      private static var m_filterEffects:Array = new Array(new GlowFilter(5592575,1,9,9,4),new GlowFilter(65344,1,8,8,2),new GlowFilter(16711680,1,8,8,2),new GlowFilter(255,1,8,8,2),new GlowFilter(16711680,1,8,8,2),new GlowFilter(PVPAreaImmuneMarkerComponent.GLOW_COLOR,1,8,8,2),new GlowFilter(PVPAreaImmuneMarkerComponent.GLOW_COLOR,1,8,8,2));
      
      public var imageReference:PropertyReference;
      
      private var m_selected:Boolean = false;
      
      private var m_highlighted:Boolean = false;
      
      private var m_tooltipText:String = null;
      
      private var m_tooltipData:String = null;
      
      private var m_cachedObjName:String = null;
      
      private var m_cachedObjFriendlyName:String = null;
      
      private var m_cachedDisplayObject:DisplayObject = null;
      
      private var m_deferredLocalize:Boolean = false;
      
      private var m_tooltipKey:String = null;
      
      private var m_tooltipReplacements:Object = null;
      
      private var m_tooltipUnlocalizedReplacements:String = null;
      
      private var m_highlightColor:uint = 0;
      
      private var m_objectEnabled:Boolean = true;
      
      private var m_visitorTargetLock:Boolean;
      
      private var m_visitorTargetMouseHoverLock:Boolean;
      
      private var m_filterEffectBits:uint = 0;
      
      private var m_ignoreExpansionEffects:Boolean = false;
      
      private var m_tooltipInfo:Object = null;
      
      public function UIControllerComponent(param1:Boolean)
      {
         var _loc2_:Array = [Cursor_Attack,Cursor_Shovel,Cursor_HandSaw,Cursor_Coins_49,Cursor_Hoe];
         this.m_ignoreExpansionEffects = param1;
         super();
      }
      
      override protected function onAdd() : void
      {
         owner.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         owner.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         owner.eventDispatcher.addEventListener(HIGHLIGHT,this.onHighlight,false,0,true);
         owner.eventDispatcher.addEventListener(EVENT_SPRITE_EFFECT,this.onSpriteEffect,false,0,true);
         owner.eventDispatcher.addEventListener(EVENT_FILTER_EFFECT,this.onFilterEffect,false,0,true);
         owner.eventDispatcher.addEventListener(VisitorManager.VISITOR_TARGET_HIGHLIGHT,this.onVisitorTargetHighlight,false,0,true);
         owner.eventDispatcher.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         owner.eventDispatcher.addEventListener(ProgressBarEvent.START_PROGRESS_BAR,this.onStartProgressBar,false,0,true);
         owner.eventDispatcher.addEventListener(EVENT_TOOLTIP_UPDATE,this.onToolTipUpdate,false,0,true);
         owner.eventDispatcher.addEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onUpdateProgressTooltip,false,0,true);
         this.m_cachedDisplayObject = owner.getProperty(this.imageReference) as DisplayObject;
      }
      
      override protected function onRemove() : void
      {
         owner.eventDispatcher.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         owner.eventDispatcher.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         owner.eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         owner.eventDispatcher.removeEventListener(HIGHLIGHT,this.onHighlight);
         owner.eventDispatcher.removeEventListener(EVENT_TOOLTIP_UPDATE,this.onToolTipUpdate);
         owner.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onUpdateProgressTooltip);
         owner.eventDispatcher.removeEventListener(ProgressBarEvent.START_PROGRESS_BAR,this.onStartProgressBar);
         this.m_cachedObjName = null;
         this.m_cachedObjFriendlyName = null;
         this.m_cachedDisplayObject = null;
      }
      
      public function setGameData(param1:String, param2:String) : void
      {
         this.m_cachedObjName = param1;
         this.m_cachedObjFriendlyName = param2;
      }
      
      private function onMouseOver(param1:Event) : void
      {
         this.setHighlighted(true,true,Constants.COLOR_HIGHLIGHT);
      }
      
      private function onMouseOut(param1:Event) : void
      {
         this.hideOurTooltip();
         this.setHighlighted(false,false,0);
      }
      
      private function onMouseUp(param1:Event) : void
      {
         this.hideOurTooltip();
      }
      
      private function onStartProgressBar(param1:ProgressBarEvent) : void
      {
         this.hideOurTooltip();
      }
      
      private function hideOurTooltip() : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_cachedDisplayObject))
         {
            Tooltip.hide();
         }
      }
      
      public function onSpriteEffect(param1:WorldEvent) : void
      {
         var _loc2_:ColorTransform = null;
         switch(param1.eventData)
         {
            case SPRITE_EFFECT_SELECTED_ON:
               _loc2_ = ColorsUtil.rgbColorTransform(3324410);
               _loc2_.alphaMultiplier = 0.5;
               break;
            case SPRITE_EFFECT_SELECTED_OFF:
               _loc2_ = ZGameUtils.ClearTransform;
               break;
            case SPRITE_EFFECT_GHOST_ON:
               _loc2_ = new ColorTransform();
               _loc2_.alphaMultiplier = 0.5;
               break;
            case SPRITE_EFFECT_GHOST_OFF:
               _loc2_ = ZGameUtils.ClearTransform;
               break;
            case SPRITE_EFFECT_VISITOR_HELPING_ON:
               _loc2_ = new ColorTransform();
               _loc2_.alphaMultiplier = 0.5;
               break;
            case SPRITE_EFFECT_VISITOR_HELPING_OFF:
               _loc2_ = ZGameUtils.ClearTransform;
               break;
            case SPRITE_EFFECT_ENABLED_ON:
               if(!this.m_ignoreExpansionEffects)
               {
                  _loc2_ = ZGameUtils.ExpansionTransform;
                  this.m_objectEnabled = false;
               }
               break;
            case SPRITE_EFFECT_ENABLED_OFF:
               if(!this.m_objectEnabled)
               {
                  _loc2_ = ZGameUtils.ClearTransform;
                  this.m_objectEnabled = true;
               }
         }
         if(null != _loc2_)
         {
            this.m_cachedDisplayObject.transform.colorTransform = _loc2_;
         }
      }
      
      private function onFilterEffect(param1:WorldEvent) : void
      {
         var _loc2_:uint = this.m_filterEffectBits;
         switch(param1.eventData)
         {
            case FILTER_EFFECT_PILLAGEABLE_ON:
               this.m_filterEffectBits |= 1 << FILTER_PILLAGE_INDEX;
               break;
            case FILTER_EFFECT_PILLAGEABLE_OFF:
               this.m_filterEffectBits &= ~(1 << FILTER_PILLAGE_INDEX);
               break;
            case FILTER_EFFECT_PILLAGE_PLACEMENT_ON:
               this.m_filterEffectBits |= 1 << FILTER_PILLAGE_PLACEMENT_INDEX;
               break;
            case FILTER_EFFECT_PILLAGE_PLACEMENT_OFF:
               this.m_filterEffectBits &= ~(1 << FILTER_PILLAGE_PLACEMENT_INDEX);
               break;
            case FILTER_EFFECT_PROTECTED_ON:
               this.m_filterEffectBits |= 1 << FILTER_PROTECTED_INDEX;
               break;
            case FILTER_EFFECT_PROTECTED_OFF:
               this.m_filterEffectBits &= ~(1 << FILTER_PROTECTED_INDEX);
               break;
            case FILTER_EFFECT_PROTECTOR_ON:
               this.m_filterEffectBits |= 1 << FILTER_PROTECTOR_INDEX;
               break;
            case FILTER_EFFECT_PROTECTOR_OFF:
               this.m_filterEffectBits &= ~(1 << FILTER_PROTECTOR_INDEX);
               break;
            case FILTER_EFFECT_AREA_IMMUNE_ON:
               this.m_filterEffectBits |= 1 << FILTER_AREA_IMMUNE_INDEX;
               break;
            case FILTER_EFFECT_AREA_IMMUNE_OFF:
               this.m_filterEffectBits &= ~(1 << FILTER_AREA_IMMUNE_INDEX);
               break;
            case FILTER_MULTIHARVEST_HIGHLIGHT_ON:
               this.m_filterEffectBits |= 1 << FILTER_MULTIHARVEST_INDEX;
               break;
            case FILTER_MULTIHARVEST_HIGHLIGHT_OFF:
               this.m_filterEffectBits &= ~(1 << FILTER_MULTIHARVEST_INDEX);
         }
         if(_loc2_ != this.m_filterEffectBits)
         {
            this.updateHighlight(this.m_highlighted,this.m_highlightColor);
         }
      }
      
      private function onVisitorTargetHighlight(param1:WorldEvent) : void
      {
         if(param1.eventData.actionLock)
         {
            this.m_visitorTargetLock = param1.eventData.enable;
         }
         else if(param1.eventData.mouseHoverLock)
         {
            this.m_visitorTargetMouseHoverLock = param1.eventData.enable;
         }
         this.updateHighlight(this.m_highlighted,this.m_highlightColor);
      }
      
      private function onToolTipUpdate(param1:WorldEvent) : void
      {
         var _loc3_:BehaviorStateMachine = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:GameDataComponent = null;
         if(Boolean(param1.eventData.mayhem) || Boolean(param1.eventData.raffle))
         {
            if(!this.m_tooltipInfo)
            {
               return;
            }
            param1.eventData = this.m_tooltipInfo;
         }
         else
         {
            this.m_tooltipInfo = param1.eventData;
         }
         this.m_tooltipKey = ZGlobal.isVisiting() ? param1.eventData.visitTooltip : param1.eventData.tooltip;
         this.m_tooltipData = param1.eventData.tooltipData;
         var _loc2_:String = this.m_cachedObjName;
         if(this.m_cachedObjFriendlyName != null)
         {
            this.m_tooltipText = this.m_cachedObjFriendlyName;
         }
         if(!ZGlobal.isVisiting() && param1.eventData.tooltipType == TOOLTIP_TYPE_CONTRACT)
         {
            if(param1.eventData.label == "idle")
            {
               if(_loc2_ != null && _loc2_.length > 0)
               {
                  this.m_tooltipKey = _loc2_ + "_tooltip";
               }
            }
            _loc3_ = BehaviorStateMachine(owner.getProperty(new PropertyReference("@StateMachine.stateMachine")));
            if(_loc3_.referenceItemName != null && _loc3_.referenceItemName.length > 0)
            {
               if(ZLoc.instance != null)
               {
                  _loc4_ = ZGlobal.gameSettings.getItemFriendlyName(_loc3_.referenceItemName,GameItem.SENTENCE_FRIENDLYNAME);
                  if(_loc4_ != null)
                  {
                     this.m_tooltipData += "resource:" + _loc4_;
                  }
               }
               else
               {
                  this.m_tooltipUnlocalizedReplacements = _loc3_.referenceItemName;
                  this.m_deferredLocalize = true;
               }
            }
         }
         if(this.m_tooltipData != null && this.m_tooltipData.length > 0)
         {
            this.m_tooltipReplacements = new Object();
            _loc5_ = this.m_tooltipData.split(",");
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               _loc6_ = _loc5_[_loc7_];
               _loc6_ = _loc6_.replace("$","");
               _loc8_ = _loc6_.split(":",2);
               if(_loc8_.length == 2 && (_loc8_[1] as String).length > 0)
               {
                  this.m_tooltipReplacements[_loc8_[0]] = _loc8_[1];
               }
               _loc7_++;
            }
         }
         if(ZLoc.instance != null)
         {
            if(this.m_tooltipKey.length)
            {
               if(Boolean(this.m_tooltipReplacements != null) && Boolean(this.m_tooltipReplacements["CollectingTaxesCoins"]) && !ZGlobal.isVisiting())
               {
                  if(MayhemManager.instance.isParliamentDestroyed)
                  {
                     this.m_tooltipReplacements["CollectingTaxesCoins"] = String((9 * this.m_tooltipReplacements["CollectingTaxesCoins"] as int) / 10 as int);
                  }
                  MayhemManager.instance.addEventListener(EVENT_TOOLTIP_UPDATE,this.onToolTipUpdate);
               }
               else if(this.m_tooltipReplacements != null && Boolean(this.m_tooltipReplacements["totalTickets"]))
               {
                  _loc10_ = GameDataComponent.getGameDataComponent(owner);
                  if((Boolean(_loc10_)) && Boolean(_loc10_.userData.tickets))
                  {
                     this.m_tooltipReplacements["totalTickets"] = _loc10_.userData.tickets.length.toString();
                  }
                  else
                  {
                     this.m_tooltipReplacements["totalTickets"] = "0";
                  }
                  RaffleManager.instance.addEventListener(EVENT_TOOLTIP_UPDATE,this.onToolTipUpdate);
               }
               _loc9_ = ZGameUtils.ZlocT("Tooltips",this.m_tooltipKey,this.m_tooltipReplacements);
            }
            if(_loc9_)
            {
               this.m_tooltipText = ZGameUtils.ZlocT("Tooltips","Compound_Tooltip",{
                  "firstPart":this.m_tooltipText,
                  "secondPart":_loc9_
               });
            }
            if(this.m_highlighted)
            {
               this.hideOurTooltip();
               Tooltip.show(this.m_tooltipText,null,this.m_cachedDisplayObject);
            }
         }
         else
         {
            this.m_deferredLocalize = true;
         }
      }
      
      private function onUpdateProgressTooltip(param1:ProgressBarEvent) : void
      {
         var _loc2_:String = null;
         if(this.m_highlighted && Tooltip.isInstanced() && Tooltip.getInstance().visible == true)
         {
            _loc2_ = null;
            if(this.m_tooltipText != null)
            {
               _loc2_ = this.m_tooltipText;
            }
            else
            {
               _loc2_ = this.m_cachedObjFriendlyName;
            }
            _loc2_ += " " + param1.timeRemaining + (param1.isPercent ? "%" : "");
            Tooltip.getInstance().setCurrentProps(_loc2_,null,this.m_cachedDisplayObject);
            Tooltip.getInstance().updateText();
         }
      }
      
      public function set toolTip(param1:String) : void
      {
         this.m_tooltipText = param1;
         if(this.m_highlighted && Tooltip.getInstance().visible && Boolean(Tooltip.getInstance(this.m_cachedDisplayObject)))
         {
            Tooltip.getInstance().setCurrentProps(this.m_tooltipText,null,this.m_cachedDisplayObject);
            Tooltip.getInstance().updateText();
         }
      }
      
      public function set stateCursor(param1:String) : void
      {
         m_tempStateCursorName = param1;
      }
      
      public function getCursor(param1:String) : Object
      {
         var str:String = null;
         var type:String = param1;
         var cursor:Object = null;
         var cursorClass:Class = null;
         var dataComp:GameDataComponent = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
         if(Boolean(dataComp) && Boolean(dataComp.gameData))
         {
            str = dataComp.gameData.cursor(type);
            if(null != str)
            {
               try
               {
                  cursorClass = getDefinitionByName(str) as Class;
                  cursor = new cursorClass(1,1);
               }
               catch(er:Error)
               {
                  Logger.error(this,"getcursor","could not find cursor: " + str);
               }
            }
         }
         if(null == cursor)
         {
            if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
            {
               owner.eventDispatcher.dispatchEvent(new WorldEvent(SET_TEMP_STATE_CURSOR,this));
               if(null != m_tempStateCursorName)
               {
                  cursorClass = getDefinitionByName(m_tempStateCursorName) as Class;
                  cursor = new cursorClass(1,1);
                  m_tempStateCursorName = null;
               }
            }
         }
         return cursor;
      }
      
      private function onHighlight(param1:WorldEvent) : void
      {
         this.setHighlighted(param1.eventData,false,Constants.COLOR_HIGHLIGHT);
      }
      
      private function updateHighlight(param1:Boolean, param2:uint) : void
      {
         var _loc3_:int = 0;
         this.m_highlightColor = param2;
         if(this.m_visitorTargetLock || this.m_visitorTargetMouseHoverLock)
         {
            this.m_cachedDisplayObject.filters = [new GlowFilter(711625,1,20,20,2)];
         }
         else if(param1)
         {
            this.m_cachedDisplayObject.filters = [new GlowFilter(this.m_highlightColor,1,8,8,20)];
         }
         else
         {
            while(_loc3_ < m_filterEffects.length)
            {
               if(this.m_filterEffectBits & 1 << _loc3_)
               {
                  this.m_cachedDisplayObject.filters = [m_filterEffects[_loc3_]];
                  break;
               }
               _loc3_++;
            }
            if(_loc3_ == m_filterEffects.length)
            {
               this.m_cachedDisplayObject.filters = [];
            }
         }
      }
      
      private function setHighlighted(param1:Boolean, param2:Boolean, param3:uint) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(param1 && !this.m_highlighted)
         {
            if(param2)
            {
               _loc4_ = null;
               if(this.m_deferredLocalize && ZLoc.instance != null)
               {
                  if(this.m_tooltipUnlocalizedReplacements != null && this.m_tooltipUnlocalizedReplacements.length > 0)
                  {
                     _loc6_ = ZGlobal.gameSettings.getItemFriendlyName(this.m_tooltipUnlocalizedReplacements,GameItem.SENTENCE_FRIENDLYNAME);
                     if(_loc6_ != null)
                     {
                        this.m_tooltipReplacements["resource"] = _loc6_;
                     }
                  }
                  this.m_tooltipText += ZGameUtils.ZlocT("Tooltips",this.m_tooltipKey,this.m_tooltipReplacements);
                  this.m_deferredLocalize = false;
               }
               _loc5_ = GameModeManager.instance.getTopGameMode().tooltip;
               if(null != _loc5_)
               {
                  _loc4_ = ZGameUtils.ZlocT("Tooltips",_loc5_,{"obj":this.m_cachedObjFriendlyName});
               }
               else if(this.m_tooltipText != null)
               {
                  _loc4_ = this.m_tooltipText;
               }
               else
               {
                  _loc4_ = this.m_cachedObjFriendlyName;
               }
               Tooltip.show(_loc4_,null,this.m_cachedDisplayObject);
            }
            this.updateHighlight(true,param3);
         }
         else if(!param1 && this.m_highlighted)
         {
            this.updateHighlight(false,param3);
         }
         this.m_highlighted = param1;
      }
      
      public function get highlighted() : Boolean
      {
         return this.m_highlighted;
      }
   }
}

