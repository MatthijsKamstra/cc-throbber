package test;

import draw.AST.LineCap;
import haxe.Timer;
import sketcher.export.*;

class CCThrobber extends test.VBase {
	var isGoogleFontLoaded:Bool = false;

	var radius:Float = 180; // 200
	var dashLine:Float = 0.0;
	var omtrek:Float;
	var dashBumb:Float;
	// time
	var seconds:Float = 60; // 60; // 10;
	var FPS = 60;
	var frameTotal:Float = 60 * 60; // 60 fps * 60 seconden = 3600
	var frameCounter:Int = 0;

	// canvas
	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	var downloadButton:AnchorElement;
	// export
	var videoExport:VideoExport;

	public function new() {
		Text.embedGoogleFont('Six+Caps|Medula+One|Dosis:200,300,400,500,600,700,800|Source+Code+Pro:200,300,400,500,600,700,900|Roboto+Mono:100,100i,300,300i,400,400i,500,500i,700,700i',
			onEmbedHandler);
		super();
	}

	// ____________________________________ setup ____________________________________

	function initElements() {
		console.log('initElement');

		// create canvas wrapper
		// var div = document.createDivElement();
		// div.id = 'canvas-wrapper';
		// document.body.appendChild(div);

		// create canvas
		canvas = document.createCanvasElement();
		canvas.width = this.settings.width;
		canvas.height = this.settings.height;

		// ctx
		ctx = canvas.getContext2d();
		// add it to the wrapper... might not be needed for export (isdebug?)
		// div.appendChild(canvas);

		// create a download button
		var downloadButton = document.createAnchorElement();
		downloadButton.className = 'btn';
		downloadButton.href = '#';
		downloadButton.innerText = 'download';
		document.body.appendChild(downloadButton);

		// setup video exporter of sketcher
		videoExport = new VideoExport();
		videoExport.setCanvas(canvas);
		// videoExport.setSvg(mysvg);
		// videoExport.setAudio(audioEl);
		videoExport.setDownload(downloadButton); // optional
		// videoExport.setVideo(mypreviewvideo); // optional
		videoExport.setup(); // activate everything
	}

	// ____________________________________ convert svg to image/canvas ____________________________________

	function convertSVG2Canvas() {
		var image = new js.html.Image();
		image.onload = function() {
			ctx.drawImage(image, 0, 0, this.settings.width, this.settings.height);
			// cc.tool.ExportFile.downloadImageBg(ctx, isJpg, filename, isTransparant);
		}
		image.onerror = function(e) {
			console.warn(e);
		}
		// image.src = 'data:image/svg+xml,${sketch.svg}';
		image.src = 'data:image/svg+xml;base64,${window.btoa(sketch.svg)}';
	}

	// ____________________________________ create animation ____________________________________
	var startTimer:Float;
	var isStartTimerSet:Bool = false;

	function initDraw() {
		startTimer = Timer.stamp();
		isStartTimerSet = true;
		videoExport.start();
	}

	function drawShape() {
		if (!isStartTimerSet) {
			initDraw();
		}

		// reset previous sketch
		sketch.clear();

		// console.info('omtrek circle: ' + MathUtil.circumferenceCircle(radius));
		var dashBumb = omtrek / frameTotal;
		if (isDebug) {
			dashLine = omtrek * 0.66;
		}
		var dashNoLine = omtrek - dashLine;

		// background gradient
		var gradient = sketch.makeGradient('#FF0099', '#493240');
		gradient.id = 'yoda-gradient';

		// background color
		var bg = sketch.makeRectangle(0, 0, w, h, false);
		bg.id = "bg color";
		var bg1 = sketch.makeRectangle(0, 0, w, h, false);
		bg1.id = "gradient color yoda";
		// bg1.fillColor = 'url(#yoda-gradient)'; // works
		bg1.fillGradientColor = 'yoda-gradient';

		// group
		var bgGroup = sketch.makeGroup([bg, bg1]);
		bgGroup.id = "sketch background";
		bgGroup.fill = getColourObj(BLACK);
		// bgGroup.opacity = 0;

		// vector files groups
		var _polyArray:Array<draw.IBase> = [];
		var _linesArray:Array<draw.IBase> = [];

		var cirkel = sketch.makeCircle(w2, h2, radius);
		// cirkel.lineCap = LineCap.Round;
		cirkel.fillOpacity = 0;
		cirkel.strokeColor = getColourObj(WHITE);
		cirkel.strokeWeight = 30; // radius * 2; // 10;
		cirkel.dash = [dashLine, dashNoLine];
		cirkel.setRotate(-90, w2, h2); // rotate it 90 degree to start on top

		var c = sketch.makeCircle(w2, h2, radius * .85);
		c.fillOpacity = 1;
		c.fillColor = getColourObj(WHITE);
		// c.strokeWeight = 10;
		// c.strokeColor = getColourObj(BLACK);

		// var str = Std.string((seconds + 0) - Math.floor(Timer.stamp() - startTimer)); // time based.... not a good idea when recording data
		var str = Std.string(Math.ceil((frameTotal - frameCounter) / FPS));
		var txt1 = Text.create(sketch, str)
			.font("Source+Code+Pro")
			.size(200)
			.fontWeight('300')
			.color(BLACK)
			.centerAlign()
			.middleBaseline()
			.pos(w2, h2 + 20)
			.draw();

		if (isDebug) {
			var x = sketch.makeX(w2, h2);
		}

		// draw the create svg
		sketch.update();

		// update canvas
		convertSVG2Canvas();

		if (frameCounter >= frameTotal) {
			console.warn('stop animation');
			console.warn('start ${startTimer}');
			console.warn('current ${Timer.stamp()}');
			console.warn('current ${Timer.stamp() - startTimer}');
			videoExport.stop();
			stop();
		}

		// next!
		dashLine += dashBumb;
		frameCounter++;
	}

	// ____________________________________ override ____________________________________

	override function setup() {
		description = 'Throbber SVG ';
		trace('SETUP :: ${toString()} -> override public function setup()');
		frameCounter = 0;
		frameTotal = FPS * seconds;
		omtrek = MathUtil.circumferenceCircle(radius);
		// isDebug = true;

		initElements();
	}

	function onEmbedHandler(e) {
		trace('onEmbedHandler: "${e}"');
		isGoogleFontLoaded = true;
		haxe.Timer.delay(function() {
			// setDate();
		}, 500);
	}

	/**
	 * the magic happens here, every class should have a `draw` function
	 */
	override function draw() {
		// trace('DRAW :: ${toString()} -> override public function draw()');
		drawShape();
		if (isDebug) {
			stop();
		}
	}
}
