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
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class _02_TransformQuad extends Sprite
	{

		private var context3D:Context3D;

		private var vertexBuffer:VertexBuffer3D;

		private var indexBuffer:IndexBuffer3D;

		private var program:Program3D;
		
		public function _02_TransformQuad()
		{
			super();
			
			this.init();
		}
		
		private function init():void
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			
			this.stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, onCreated );
			this.stage.stage3Ds[0].requestContext3D();
		}
		
		protected function onCreated(e:Event):void
		{
			this.context3D = this.stage.stage3Ds[0].context3D;
			this.context3D.configureBackBuffer( this.stage.stageWidth, this.stage.stageHeight, 2, true );
		
			this.createBufferAndUpload();
			this.createProgramAndUpload();
			
			this.addEventListener( Event.ENTER_FRAME, onRender );
		}
		
		
		private function createBufferAndUpload():void
		{
			this.vertexBuffer = this.context3D.createVertexBuffer( 4, 6 );
			this.indexBuffer = this.context3D.createIndexBuffer( 6 );
			
			var r: Number = 0.2;
			
			var vertices:Vector.<Number> = Vector.<Number>([
				-r, r, 0, 	1, 0, 0,
				r, r, 0,	0, 1, 0,
				r, -r, 0,	0, 0, 1,
				-r, -r, 0,	1, 0, 1
			]);
			
			var indices:Vector.<uint> = Vector.<uint>([
				0, 1, 2, 	0, 2, 3
			]);
			
			this.vertexBuffer.uploadFromVector( vertices, 0, 4 );
			this.indexBuffer.uploadFromVector( indices, 0, 6 );
		}
		
		private function createProgramAndUpload():void
		{
			this.program = this.context3D.createProgram();
			
			var va: AGALMiniAssembler = new AGALMiniAssembler( true );
			var vs:ByteArray = va.assemble( Context3DProgramType.VERTEX, 
				"m44 op, va0, vc0 \n" +
				"mov v0, va1"
			);
			
			var fa: AGALMiniAssembler = new AGALMiniAssembler( true );
			var fs:ByteArray = fa.assemble( Context3DProgramType.FRAGMENT, 
				"mov oc, v0"
			);
			
			this.program.upload( vs, fs );
		}
		
		protected function onRender(e:Event):void
		{
			this.context3D.clear();
			
			this.context3D.setProgram( this.program );
			this.context3D.setVertexBufferAt( 0, this.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			this.context3D.setVertexBufferAt( 1, this.vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3 );
			
			var mat:Matrix3D = new Matrix3D();
			mat.appendTranslation( Math.sin( getTimer() / 500 ), 0, 0 );
			
			this.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, mat, true );
			this.context3D.drawTriangles( this.indexBuffer );
			this.context3D.present();
		}
		
	}//c
}//p