// forked from makc3d's forked from: delaunay triangulation
// forked from nicoptere's delaunay triangulation
package 
{
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.getTimer;
	
    /**
     * @author nicolas barradeau
     * http://en.nicoptere.net/
     */
    public class delaunayTriangulationSrc extends Sprite 
    {
        private var tf:TextField = new TextField();
        private var delaunay:Delaunay;
        private var indices:Vector.<int>;
        private var nodes:Vector.<Node> = new Vector.<Node>(150);
        
        private var red:Shape;
        
        private var start:Node;
        private var finish:Node;
        
        public function delaunayTriangulationSrc():void 
        {
            red = new Shape();
            addChild(red);
            
            delaunay = new Delaunay();
            addChild( tf );
            stage.addEventListener( "enterFrame", onMouseDownHandler );
            reset();
            
            stage.addEventListener("click", function(e:*= null):void { start = finish = null; } );
            stage.addEventListener("rightClick", function(e:*= null):void
            {
                if ( stage.hasEventListener('enterFrame'))
                {
                    red.alpha = 0.2;
                    //red.blendMode = BlendMode.DIFFERENCE;
                    stage.removeEventListener( "enterFrame", onMouseDownHandler );
                    
                }else {
                    red.alpha = 1;
                    //red.blendMode = BlendMode.NORMAL;
                    stage.addEventListener( "enterFrame", onMouseDownHandler );
                }
            });
        }
        
        private function onMouseDownHandler(e:*):void 
        {
            reset();
        }
        
        private function reset():void 
        {
            graphics.clear();
            
            for (var i:int = 0; i < nodes.length; i++) 
            {
                if (nodes[i] == null) 
                
                nodes[i] = new Node
                ( 
                    Math.random() * stage.stageWidth, 
                    Math.random() * stage.stageHeight 
                ); 
                
                else 
                {
                    nodes[i].x += Math.sin(i)*2;                 nodes[i].y += Math.cos(i)*2;
                    
                    while (nodes[i].x > stage.stageWidth) nodes[i].x -= stage.stageWidth;
                    while (nodes[i].x < 0) nodes[i].x += stage.stageWidth;
                    while (nodes[i].y > stage.stageHeight) nodes[i].y -= stage.stageHeight;
                    while (nodes[i].y < 0) nodes[i].y += stage.stageHeight;
                }
                
                n = nodes[i];
                
                graphics.beginFill( (n == start || n == finish) ? 0xCC0000 :0x00ADCC );
                graphics.drawCircle( n.x, n.y, 4 );
                graphics.endFill();
            }
            
            var t:uint = getTimer();
            
            indices = delaunay.compute( nodes );
            
            graphics.lineStyle( 0, 0xDDDDDD );
            
            if ( start == null ) start = nodes[ int(Math.random() * (nodes.length - 1)) ];
            
            while( finish == null || finish == start ) finish = nodes[ int(Math.random() * (nodes.length - 1)) ];
            
            start.connected = new Vector.<Node>();
            finish.connected = new Vector.<Node>();
            
            delaunay.render( graphics, nodes, indices );
            
            var n:Node = AStar.solve( start, finish );
            
            if( n != null ) drawPath( n );
            
            tf.text = 'Click - Reset\nRight Click - Pause\ntime: ' + ( getTimer() - t ) + ' ms';
            
            /*
            //alternate rendering
            var vertices:Vector.<Number> = new Vector.<Number>();
            for (var i:int = 0; i < Nodes.length; i++) vertices.push( Nodes[ i ].x, Nodes[ i ].y );
            graphics.drawTriangles( vertices, indices );
            **/
        }
        
        private function drawPath( n:Node ):void
        {
            red.graphics.clear();
            red.graphics.lineStyle(4, 0xFF0000, 0.8);
            red.graphics.moveTo( n.x, n.y );
            
            var overflow:int = 50;
            
            while ( n.parent )
            {
                n = n.parent;
                
                red.graphics.lineTo( n.x, n.y );
                
                // Just in case 
                overflow--;  if ( overflow < 0 ) break; 
            }
        }
        
    }
    
}
import flash.display.Graphics;
import flash.geom.Point;
class Delaunay    
{
    static public var EPSILON:Number = Number.MIN_VALUE;
    static public var SUPER_TRIANGLE_RADIUS:Number = 1000000000;
    private var indices:Vector.<int>;
    private var circles:Vector.<Number>;
    public function compute( nodes:Vector.<Node> ):Vector.<int>
    {
        var nv:int = nodes.length;
        if (nv < 3) return null;
        var d:Number = SUPER_TRIANGLE_RADIUS;
        nodes.push(     new Node( 0, -d ), new Node( d, d ), new Node( -d, d )    );
        indices = Vector.<int>( [ nodes.length-3, nodes.length-2, nodes.length-1 ] );
        circles = Vector.<Number>( [ 0, 0, d ] );
        var edgeIds:Vector.<int> = new Vector.<int>();
        var i:int, j:int, k:int, id0:int, id1:int, id2:int;
        for ( i = 0; i < nv; i++)
        {
            for ( j = 0; j < indices.length; j+=3 )
            {
                if (     circles[ j + 2 ] > EPSILON         &&         circleContains( j, nodes[ i ] )    )
                {
                    id0 = indices[ j ];
                    id1 = indices[ j + 1 ];
                    id2 = indices[ j + 2 ];
                    edgeIds.push( id0, id1, id1, id2, id2, id0 );
                    
                    // XX
                    indices.splice( j, 3 );
                    
                    circles.splice( j, 3 );
                    j -= 3;
                }
            }
            for ( j = 0; j < edgeIds.length; j+=2 )
            {
                for ( k = j + 2; k < edgeIds.length; k+=2 )
                {
                    if(    (    edgeIds[ j ] == edgeIds[ k ] && edgeIds[ j + 1 ] == edgeIds[ k + 1 ]    )
                    ||    (    edgeIds[ j + 1 ] == edgeIds[ k ] && edgeIds[ j ] == edgeIds[ k + 1 ]    )    )
                    {
                        edgeIds.splice( k, 2 );
                        edgeIds.splice( j, 2 );
                        j -= 2;
                        k -= 2;
                        if ( j < 0 ) break;
                        if ( k < 0 ) break;
                    }
                }
            }
            for ( j = 0; j < edgeIds.length; j+=2 )
            {
                indices.push( edgeIds[ j ], edgeIds[ j + 1 ], i );
                computeCircle( nodes, edgeIds[ j ], edgeIds[ j + 1 ], i );
            }
            edgeIds.length = 0;
            
        }
        id0 = nodes.length - 3;
        id1 = nodes.length - 2;
        id2 = nodes.length - 1;
        for ( i = 0; i < indices.length; i+= 3 )
        {
            if ( indices[ i ] == id0 || indices[ i ] == id1 || indices[ i ] == id2 
            ||     indices[ i + 1 ] == id0 || indices[ i + 1 ] == id1 || indices[ i + 1 ] == id2 
            ||     indices[ i + 2 ] == id0 || indices[ i + 2 ] == id1 || indices[ i + 2 ] == id2 )
            {
                indices.splice( i, 3 );
                i-=3;
                continue;
            }
        }
        nodes.pop();
        nodes.pop();
        nodes.pop();
        
        // A Star Path finding
        //AStar.solve(
        
        return indices;
    }
    
    private function circleContains( circleId:int, p:Node ):Boolean 
    {
        var dx:Number = circles[ circleId ] - p.x;
        var dy:Number = circles[ circleId + 1 ] - p.y;
        return circles[ circleId + 2 ] > dx * dx + dy * dy;
    }
    
    private function computeCircle( Nodes:Vector.<Node>, id0:int, id1:int, id2:int ):void
    {
        var p0:Node = Nodes[ id0 ];
        var p1:Node = Nodes[ id1 ];
        var p2:Node = Nodes[ id2 ];
        var A:Number = p1.x - p0.x;
        var B:Number = p1.y - p0.y;
        var C:Number = p2.x - p0.x;
        var D:Number = p2.y - p0.y;
        var E:Number = A * (p0.x + p1.x) + B * (p0.y + p1.y);
        var F:Number = C * (p0.x + p2.x) + D * (p0.y + p2.y);
        var G:Number = 2.0 * (A * (p2.y - p1.y) - B * (p2.x - p1.x));
        var x:Number = (D * E - B * F) / G;
        circles.push( x );
        var y:Number = (A * F - C * E) / G;
        circles.push( y );
        x -= p0.x;
        y -= p0.y;
        circles.push( x * x + y * y );
    }
    
    public function render( graphics:Graphics, nodes:Vector.<Node>, indices:Vector.<int> ):void
    {
        var id0:uint, id1:uint, id2:uint;
        
        for ( var i:int = 0; i < nodes.length; i++)
        {
            nodes[ i ].connected = new Vector.<Node>();
        }
        
        for ( i = 0; i < indices.length; i+=3 ) 
        {
            id0 = indices[ i ];
            id1 = indices[ i + 1 ];
            id2 = indices[ i + 2 ];
            
            // A Star
            nodes[ id0 ].connect( nodes[ id1 ] );
            nodes[ id1 ].connect( nodes[ id2 ] );
            nodes[ id2 ].connect( nodes[ id0 ] );
            
            
            graphics.moveTo( nodes[ id0 ].x, nodes[ id0 ].y );
            graphics.lineTo( nodes[ id1 ].x, nodes[ id1 ].y );
            graphics.lineTo( nodes[ id2 ].x, nodes[ id2 ].y );
            graphics.lineTo( nodes[ id0 ].x, nodes[ id0 ].y );
        }
    }
}


class Node 
{
    /// Unique identity number - optional
    public var id:int = 0;
    
    /// x position of the node
    public var x:Number = 0;
    /// y position of the node
    public var y:Number = 0;
    
    /// F - force ( the sum of g and h )
    public var f:Number = 0;
    /// G - distance of the current node to the starting node
    public var g:Number = 0;
    /// H - linear distance to the goal ( approximation )
    public var h:Number = 0;        
    
    public var parent:Node = null;
    
    public var connected:Vector.<Node> = null;
    
    public function Node( x:Number = 0, y:Number = 0 ) 
    {
        this.x = x; this.y = y;
        
        connected = new Vector.<Node>();
    }
    
    public function distance( to:Node ):Number
    {
        return Point.distance( to.position, position );
    }
    
    public function get position():Point
    {
        return new Point( x, y );
    }
    
    public function connectMany( nodes:Vector.<Node> ):void
    {
        for each( var n:Node in nodes ) connect( n );
    }
    
    public function connect( n:Node ):void
    {
        var double:Boolean = false;
        
        for ( var i:int = 0; i < connected.length; ++i )
            if ( connected[i] == n ) double = true
        
        if ( !double ) {
            connected.push( n );
            n.connect( this );
        }
    }
    
    public function toString():String
    {
        //return "<Node[3]:(x:23, y:64), F(100) = G(30) + H(70), ParentId[23], Connected[1,4,5,6,7]>";
        
        var nodes:String = connected == null ? "null" : (connected.length == 0 ? "nun" : "");
        if ( nodes == "" ) for each (var n:Node in connected) nodes += n.id.toString() + (connected.indexOf(n) < connected.length - 1? ", " : "");
        
        return "< Node[" + id.toString() + "]:(X:" + x.toFixed(1) + 
            ", Y:" + y.toFixed(1) + "), F(" + f.toFixed(1) + 
            ") = G(" + g.toFixed(1) + ") + H(" + h.toFixed(1) + 
            "), ParentId[" + (parent == null ? "null" : parent.id.toString()) +
            "], Connected[" + nodes + "] >";
        
        return "Node[" + id.toString() + "]"
    }
}

class AStar 
{
    /**
     * ...
     * @author vladik.voina@gmail.com
     */
    public function AStar() {}
    
    /**
     * @param    start node
     * @param    finish node
     * @return  The starting node that is connected threw it's parent to the finish node, null will be returned if no path was found
     */
    public static function solve( start:Node, finish:Node ) : Node
    {
        // http://web.mit.edu/eranki/www/tutorials/search/
        
        //initialize the open list
        var open:Vector.<Node> = new Vector.<Node>();
        
        //initialize the closed list
        var closed:Vector.<Node> = new Vector.<Node>();
        
        // Put the starting node on the open list (you can leave its f at zero)
        open.push( start );
        
        // Clear any connected parent to the starting node
        start.parent = null;
        
        // Clac the distance
        start.f = start.h = finish.distance( start );
        
        // Set g as zero
        start.g = 0;
        
        // while the open list is not empty
        while ( open.length > 0 )
        {
            var n:Node = null; 
            var index:int = 0;
            
            // Find the node with the least f on the open list, call it "n"
            for (var i:int = 0; i < open.length; ++i) 
            {
                if ( n == null ) n = open[i];
                else { if ( n.f > open[i].f ) 
                { 
                    n = open[i]; 
                    index = i; 
                } }
            }
            
            // *Edited* Pop "n" from the open list and add to the closed list
            closed.push( open.splice(index, 1)[0] );
            
            var successor:Node;
            
            //generate n's successors and set their parents to "n"
            for ( i = 0; i < n.connected.length; ++i)
            {
                successor = n.connected[ i ];
                
                var successorClosedIndex:int = closed.indexOf( successor );
                var successorOpenIndex:int = open.indexOf( successor );
                
                // *Edited* : Validate the successor, make shure nan of the list containes it
                if ( successorClosedIndex >= 0 || successorOpenIndex >= 0) continue;
                
                // After the successor was validated add "n" as the parent node to the successor
                successor.parent = n;
                
                // if successor is the goal, stop the search
                if ( successor == finish ) return successor;
                
                // Calculate successor's force 
                successor.g = n.g + n.distance( successor );
                successor.h = finish.distance( successor );
                successor.f = successor.g + successor.h;
                
                // Add the valid successor to the open list
                open.push( successor );
            }
        }
        
        // If no path was found return null
        return null;
    }
}