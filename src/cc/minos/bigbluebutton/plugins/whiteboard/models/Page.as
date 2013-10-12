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
package cc.minos.bigbluebutton.plugins.whiteboard.models
{
	
	public class Page
	{
		private var _num:int;
		private var _annotations:Array = new Array();
		
		public function Page( num:int )
		{
			_num = num;
		}
		
		public function addAnnotation( annotation:Annotation ):void
		{
			_annotations.push( annotation );
		}
		
		public function updateAnnotation( annotation:Annotation ):void
		{
			var a:Annotation = getAnnotation( annotation.id );
			if ( a != null )
			{
				a.annotation = annotation.annotation;
			}
		}
		
		public function undo():void
		{
			//_annotations.removeItemAt( _annotations.length - 1 );
			_annotations.splice( _annotations.length - 1 , 1);
		}
		
		public function clear():void
		{
			_annotations.length = 0;
		}
		
		public function get number():int
		{
			return _num;
		}
		
		public function getAnnotations():Array
		{
			var a:Array = new Array();
			for ( var i:int = 0; i < _annotations.length; i++ )
			{
				a.push( _annotations[ i ] as Annotation );
			}
			return a;
		}
		
		public function getAnnotation( id:String ):Annotation
		{
			for ( var i:int = 0; i < _annotations.length; i++ )
			{
				if (( _annotations[ i ] as Annotation ).id == id )
				{
					return _annotations[ i ] as Annotation;
				}
			}
			
			return null;
		}
	}
}