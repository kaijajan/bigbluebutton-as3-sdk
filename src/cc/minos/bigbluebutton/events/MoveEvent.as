/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 *
 * Copyright (c) 2010 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 2.1 of the License, or (at your option) any later
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
package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    public class MoveEvent extends Event {
        public static const MOVE:String = "MOVE_SLIDE";
        public static const CUR_SLIDE_SETTING:String = "CUR_SLIDE_SETTING";

        public var xOffset:Number;
        public var yOffset:Number;

        public var slideToCanvasWidthRatio:Number;
        public var slideToCanvasHeightRatio:Number;

        public function MoveEvent(type:String)
        {
            super(type, true, false);
        }

        override public function clone():Event
        {
            var evt:MoveEvent = new MoveEvent(type);
            evt.xOffset = xOffset;
            evt.yOffset = yOffset;
            evt.slideToCanvasHeightRatio = slideToCanvasHeightRatio;
            evt.slideToCanvasWidthRatio = slideToCanvasWidthRatio;
            return evt;
        }

    }
}