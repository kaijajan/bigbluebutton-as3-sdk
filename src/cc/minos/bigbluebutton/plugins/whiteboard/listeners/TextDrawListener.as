/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 *
 * Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 3.0 of the License, or (at your option) any later
 * version.
 *
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 *
 */
package cc.minos.bigbluebutton.plugins.whiteboard.listeners
{
	import cc.minos.bigbluebutton.plugins.whiteboard.IWhiteboard;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.ShapeFactory;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.TextDrawAnnotation;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.TextObject;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.WhiteboardConstants;
	
	public class TextDrawListener implements IDrawListener
	{
		private var _wbCanvas:IWhiteboard;
		private var _sendFrequency:int;
		private var _shapeFactory:ShapeFactory;
		private var _textStatus:String = TextObject.TEXT_CREATED;
		private var _mouseXDown:Number = 0;
		private var _mouseYDown:Number = 0;
		private var _mousedDown:Boolean = false;
		private var _curID:String;
		
		//private var feedback:RectangleFeedbackTextBox = new RectangleFeedbackTextBox();
		//private var _wbModel:WhiteboardModel;
		
		public function TextDrawListener( wbCanvas:IWhiteboard, sendShapeFrequency:int, shapeFactory:ShapeFactory )
		{
			_wbCanvas = wbCanvas;
			_sendFrequency = sendShapeFrequency;
			_shapeFactory = shapeFactory;
		}
		
		public function ctrlKeyDown( down:Boolean ):void
		{
			// Ignore
		}
		
		public function onMouseDown( mouseX:Number, mouseY:Number, tool:WhiteboardTool ):void
		{
			if ( tool.graphicType == WhiteboardConstants.TYPE_TEXT )
			{
				_mouseXDown = mouseX;
				_mouseYDown = mouseY;
				
				// We have to keep track if the user has pressed the mouse. A mouseup event is
				// dispatched when the mouse goes out of the canvas, theu we end up sending a new text
				// even if the user has mousedDown yet.
				_mousedDown = true;
			}
		}
		
		public function onMouseMove( mouseX:Number, mouseY:Number, tool:WhiteboardTool ):void
		{
			if ( tool.graphicType == WhiteboardConstants.TYPE_TEXT && _mousedDown )
			{
				if ( _wbCanvas.contains( feedback ) )
				{
					_wbCanvas.removeRawChild( feedback );
				}
				
				feedback.draw( _mouseXDown, _mouseYDown, mouseX - _mouseXDown, mouseY - _mouseYDown );
				_wbCanvas.addRawChild( feedback );
			}
		
		}
		
		public function onMouseUp( mouseX:Number, mouseY:Number, tool:WhiteboardTool ):void
		{
			if ( tool.graphicType == WhiteboardConstants.TYPE_TEXT && _mousedDown )
			{
				feedback.clear();
				if ( _wbCanvas.contains( feedback ) )
				{
					_wbCanvas.removeRawChild( feedback );
				}
				
				_mousedDown = false;
				
				var tbWidth:Number = mouseX - _mouseXDown;
				var tbHeight:Number = mouseY - _mouseYDown;
				
				if ( tbHeight < 15 || tbWidth < 50 )
					return;
				
				var tobj:TextDrawAnnotation = _shapeFactory.createTextObject( "", 0x000000, _mouseXDown, _mouseYDown, tbWidth, tbHeight, 18 );
				
				sendTextToServer( TextObject.TEXT_CREATED, tobj );
			}
		}
		
		private function sendTextToServer( status:String, tobj:TextDrawAnnotation ):void
		{
			switch ( status )
			{
				case TextObject.TEXT_CREATED: 
					tobj.status = TextObject.TEXT_CREATED;
					_textStatus = TextObject.TEXT_UPDATED;
					_curID = _idGenerator.generateID();
					tobj.id = _curID;
					break;
				case TextObject.TEXT_UPDATED: 
					tobj.status = TextObject.TEXT_UPDATED;
					tobj.id = _curID;
					break;
				case TextObject.TEXT_PUBLISHED: 
					tobj.status = TextObject.TEXT_PUBLISHED;
					_textStatus = TextObject.TEXT_CREATED;
					tobj.id = _curID;
					break;
			}
			_wbCanvas.sendGraphicToServer( tobj );
		}
	}
}