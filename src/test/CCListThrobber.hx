package test;

import draw.AST.LineCap;
import haxe.Timer;
import sketcher.export.*;

class CCListThrobber extends test.VBase {
	var isGoogleFontLoaded:Bool = false;

	var radiusSmall:Float = 100;

	// time
	var startTimer:Float;
	var isStartTimerSet:Bool = false;
	// frames
	var seconds:Float = 30; // 60; // 10;
	var FPS:Int = 60;
	var frameTotal:Float = Math.POSITIVE_INFINITY; // 60 fps * 60 seconden = 3600
	var frameCounter:Int = 0;
	//
	var grid:GridUtil;

	// canvas
	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	var downloadButton:AnchorElement;
	// export
	var videoExport:VideoExport;

	public function new() {
		Text.embedGoogleFont('Inconsolata:400,700', onEmbedHandler);
		super();
	}

	// ____________________________________ fonts embedded ____________________________________

	function onEmbedHandler(e) {
		trace('onEmbedHandler: "${e}"');
		isGoogleFontLoaded = true;
		initRecording();
		haxe.Timer.delay(function() {
			//
		}, 500);
	}

	// ____________________________________ override setup ____________________________________

	override function setup() {
		description = 'NineThrobber';

		if (isDebug)
			console.info('SETUP :: ${toString()} -> override public function setup()');

		frameCounter = 0;
		frameTotal = FPS * seconds;

		// isDebug = true;

		grid = new GridUtil();
		grid.setNumbered(3, 3); // 3 horizontal, 3 vertical
		grid.setIsCenterPoint(true); // default true, but can be set if needed

		initElements();

		drawShape();
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

	function initRecording() {
		startTimer = Timer.stamp();
		isStartTimerSet = true;
		videoExport.start();
		trace('initRecording: ${frameCounter}, ${frameTotal}');
	}

	function drawShape() {
		// if (!isStartTimerSet && !isDebug) {
		// 	initRecording();
		// }

		// reset previous sketch
		sketch.clear();

		// background gradient
		var gradient = sketch.makeGradient('#B993D6', '#8CA6DB');
		gradient.id = 'dirty-fog';

		// background color
		var bg = sketch.makeRectangle(0, 0, w, h, false);
		bg.id = "bg color";
		var bg1 = sketch.makeRectangle(0, 0, w, h, false);
		bg1.id = "gradient color yoda";
		// bg1.fillColor = 'url(#dirty-fog)'; // works
		bg1.fillGradientColor = 'dirty-fog';

		// group
		var bgGroup = sketch.makeGroup([bg, bg1]);
		bgGroup.id = "sketch background";
		bgGroup.fill = getColourObj(BLACK);
		// bgGroup.opacity = 0;

		// vector files groups
		var _posArray:Array<draw.IBase> = [];
		var _linesArray:Array<draw.IBase> = [];
		var _circleArray:Array<draw.IBase> = [];

		// grid
		for (i in 0...grid.array.length) {
			var p = grid.array[i];
			var c = sketch.makeCircle(p.x, p.y, radiusSmall);
			_posArray.push(c);
		}

		// quick generate grid
		if (isDebug) {
			util.TestUtil.gridDots(sketch, grid);
		}

		// var pct = 0.35;
		var pct = frameCounter / frameTotal;
		// setup throbbers
		throbberOne(grid.array[0], pct);
		throbberTwo(grid.array[1], pct);
		throbberThree(grid.array[2], pct);
		throbberFour(grid.array[3], pct);
		throbberFive(grid.array[4], pct);
		throbberSix(grid.array[5], pct);
		throbberSeven(grid.array[6], pct);
		throbberEight(grid.array[7], pct);
		throbberNine(grid.array[8], pct);

		// groups
		var posG = sketch.makeGroup(_posArray);
		posG.id = "position of throbbers";
		posG.fillColor = getColourObj(WHITE);
		posG.opacity = 0;
		// if (isDebug)
		// 	posG.opacity = 0.2;

		// draw the create svg
		sketch.update();

		// update canvas
		convertSVG2Canvas();

		// console.info('$frameCounter >= $frameTotal');
		if (frameCounter >= frameTotal) {
			console.warn('stop animation');
			console.warn('start ${startTimer}');
			console.warn('current ${Timer.stamp()}');
			console.warn('current ${Timer.stamp() - startTimer}');
			videoExport.stop();
			stop();
		}

		frameCounter++;
	}

	/**
	 * @param p 		point (x,y)
	 * @param pct 		percentage (between 0 and 1)
	 */
	function throbberOne(p:Point, pct:Float) {
		var _stroke = 30;
		var _r = radiusSmall - (_stroke * 0.5);
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = _stroke;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top
	}

	// see two
	function throbberTwo(p:Point, pct:Float) {
		var _r = radiusSmall * 0.5;
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = radiusSmall;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top
	}

	// see one
	function throbberThree(p:Point, pct:Float) {
		var _stroke = 30;
		var _r = radiusSmall - (_stroke * 0.5);
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = _stroke;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		var circle2 = sketch.makeCircle(p.x, p.y, _r);
		// circle2.lineCap = LineCap.Round;
		circle2.fillOpacity = 0;
		circle2.strokeColor = getColourObj(WHITE);
		circle2.strokeWeight = _stroke;
		circle2.strokeOpacity = 0.2;
		// circle2.dash = [dashLine, dashNoLine];
		circle2.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top
	}

	// see one
	function throbberFour(p:Point, pct:Float) {
		var _stroke = 30;
		var _r = radiusSmall - (_stroke * 0.5);
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = _stroke;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		var circle2 = sketch.makeCircle(p.x, p.y, _r - (_stroke * 0.5));
		circle2.fillOpacity = 0;
		circle2.strokeColor = getColourObj(WHITE);
		circle2.strokeWeight = 1;
		circle2.strokeOpacity = .5;

		var circle3 = sketch.makeCircle(p.x, p.y, _r + (_stroke * 0.5));
		circle3.fillOpacity = 0;
		circle3.strokeColor = getColourObj(WHITE);
		circle3.strokeWeight = 1;
		circle3.strokeOpacity = .5;
	}

	// see one
	function throbberFive(p:Point, pct:Float) {
		var _stroke = 3;
		var _r = radiusSmall;
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = _stroke;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		var dot = sketch.makeCircle(p.x, p.y, 10);
		dot.fillOpacity = 0;
		dot.strokeColor = getColourObj(WHITE);
		dot.strokeWeight = _stroke;
		dot.setRotate(-90 + (360 * pct), p.x, p.y);
		dot.setPosition(_r, 0);
	}

	// see two
	function throbberSix(p:Point, pct:Float) {
		var _r = radiusSmall * 0.5;
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = radiusSmall;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		var circle = sketch.makeCircle(p.x, p.y, radiusSmall * .85);
		circle.fillColor = getColourObj(WHITE);
		circle.fillOpacity = .9;
	}

	// see one
	function throbberSeven(p:Point, pct:Float) {
		var _stroke = 20;
		var _r = radiusSmall - (_stroke * 0.5);
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = _stroke;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		var circle = sketch.makeCircle(p.x, p.y, _r - (_stroke * 0.6));
		circle.fillColor = getColourObj(WHITE);
		// circle.fillOpacity = .9;

		var total = 100;
		var str = Std.string(Math.ceil(100 * pct)) + "%";
		var txt1 = Text.create(sketch, str)
			.font("Inconsolata")
			.size(50)
			.fontWeight('400')
			.color(BLACK)
			.centerAlign()
			.middleBaseline()
			.pos(p.x, p.y + 3)
			.draw();
	}

	function throbberEight(p:Point, pct:Float) {
		var _stroke = 30;
		var _r = radiusSmall - (_stroke * 0.5);
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = _stroke;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		// calculate new dash
		var devide = 8;
		var dashStroke = 2;
		var noDash = (omtrek / devide) - dashStroke;
		// dashed line
		var dashed = sketch.makeCircle(p.x, p.y, _r);
		// dashed.lineCap = LineCap.Round;
		dashed.fillOpacity = 0;
		dashed.strokeColor = getColourObj(WHITE);
		dashed.strokeWeight = _stroke;
		// dashed.dash = [1, 179];
		dashed.dash = [dashStroke, noDash];
		dashed.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top
	}

	function throbberNine(p:Point, pct:Float) {
		var _stroke = 30;
		var _r = radiusSmall * 0.5;
		var omtrek = MathUtil.circumferenceCircle(_r);
		var dashLine = omtrek * pct;
		var dashNoLine = omtrek - dashLine;

		var circle = sketch.makeCircle(p.x, p.y, _r);
		// circle.lineCap = LineCap.Round;
		circle.fillOpacity = 0;
		circle.strokeColor = getColourObj(WHITE);
		circle.strokeWeight = radiusSmall;
		circle.dash = [dashLine, dashNoLine];
		circle.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top

		// calculate new dash
		var devide = 8;
		var dashStroke = 2;
		var noDash = (omtrek / devide) - dashStroke;
		// dashed line
		var dashed = sketch.makeCircle(p.x, p.y, radiusSmall - (_stroke * 0.5));
		// dashed.lineCap = LineCap.Round;
		dashed.fillOpacity = 0;
		dashed.strokeColor = getColourObj(WHITE);
		dashed.strokeWeight = _stroke;
		// dashed.dash = [1, 179];
		dashed.dash = [dashStroke, noDash];
		dashed.setRotate(-90, p.x, p.y); // rotate it 90 degree to start on top
	}

	// ____________________________________ override ____________________________________

	/**
	 * the magic happens here, every class should have a `draw` function
	 */
	override function draw() {
		if (isDebug)
			trace('DRAW :: ${toString()} -> override public function draw()');

		if (isGoogleFontLoaded && isStartTimerSet) {
			drawShape();
		}
		if (isDebug) {
			stop();
		}
	}
}
