package 
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.utils.ByteArray;

	/**
	 * @author kim.jinhoon
	 */
	public class _01_HelloTriangle extends Sprite
	{

		private var context3D:Context3D;

		private var vertexBuffer:VertexBuffer3D;

		private var indexBuffer:IndexBuffer3D;

		private var program:Program3D;
		
		
		public function _01_HelloTriangle()
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, onCreated );
			this.stage.stage3Ds[0].requestContext3D();
		}
		
		protected function onCreated(e:Event):void
		{
			this.context3D = this.stage.stage3Ds[0].context3D;
			this.context3D.configureBackBuffer( this.stage.stageWidth, this.stage.stageHeight, 2, true );
		
			this.vertexBuffer = this.context3D.createVertexBuffer( 3, 6 );
			this.indexBuffer = this.context3D.createIndexBuffer( 3 );
			this.program = this.context3D.createProgram();
			
			var r: Number = 0.5;
			
			var vertices:Vector.<Number> = Vector.<Number>([
				-r, -r, 0, 	1, 0, 0,
				0, r, 0,	0, 1, 0,
				r, -r, 0,	0, 0, 1
			]);
			
			this.vertexBuffer.uploadFromVector( vertices, 0, 3 );
			
			var indices:Vector.<uint> = Vector.<uint>([
				0, 1, 2
			]);
			
			this.indexBuffer.uploadFromVector( indices, 0, 3 );
			
			
			var vertexAssembler: AGALMiniAssembler = new AGALMiniAssembler( true );
			var vs:ByteArray = vertexAssembler.assemble( Context3DProgramType.VERTEX, 
				"mov op, va0 \n" +
				"mov v0, va1"
			);
			
			
			var fragmentAssembler: AGALMiniAssembler = new AGALMiniAssembler( true );
			var fs:ByteArray = fragmentAssembler.assemble( Context3DProgramType.FRAGMENT,
				"mov oc, v0"
			);
			
			this.program.upload( vs, fs );   
			
			this.addEventListener( Event.ENTER_FRAME, onRender );
		}
		
		protected function onRender(e:Event):void
		{
			this.context3D.clear();
			
			this.context3D.setProgram( this.program );
			this.context3D.setVertexBufferAt( 0, this.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			this.context3D.setVertexBufferAt( 1, this.vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3 );
			
			this.context3D.drawTriangles( this.indexBuffer, 0, 1 );
			
			this.context3D.present();
		}
		
	}//c
}//p