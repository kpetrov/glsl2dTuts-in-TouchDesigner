// GLSL 2D Tutorials | https://www.shadertoy.com/view/Md23DV
// Uğur Güney

/*
	by Uğur Güney. March 8, 2014. 

	Hi! I started learning GLSL a month ago. The speedup gained by using
	GPU to draw real-time graphics amazed me. If you want to learn
	how to write shaders, this tutorial written by a beginner can be
	a starting place for you.

	Please fix my coding errors and grammar errors. :-)
*/

// Ported to TouchDesigner by Matthew Ragan
// matthewragan.com

/*
	Getting your bearings with GLSL can be a bit of a rodeo when
	you're first getting started. Uğur's 2D tuts were a huge help to me
	when I was first getting started, and they often show examples
	that are a little more granular than The Book of Shaders. 

	Hopefully this set of examples will help you get started and 
	get your gl bearings here in Touch.

	When possible, I've copied the examples as faithfully as possible.
	What that means is that there may be better ways to approach some
	challenges - but what you'll find here is as close to the original
	tutorial as I can manage.
*/

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Tutorial 23
// SUCCESSIVE COORDINATE TRANSFORMATIONS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Drawing a shape on the desired location, with desired size, and
// desired orientation needs mastery of succesive application of
// transformations.
//
// In general, transformations do not commute. Which means that
// if you change their order, you get different results.
//
// Let's try application of transformations in different orders.

#define PI 3.14159265359
#define TWOPI 6.28318530718

// uniforms
uniform float uTime;
uniform vec2 uRes;

// functions
float coordinateGrid(vec2 r) {
	vec3 axesCol = vec3(0.0, 0.0, 1.0);
	vec3 gridCol = vec3(0.5);
	float ret = 0.0;
	
	// Draw grid lines
	const float tickWidth = 0.1;
	for(float i=-2.0; i<2.0; i+=tickWidth) {
		// "i" is the line coordinate.
		ret += 1.-smoothstep(0.0, 0.008, abs(r.x-i));
		ret += 1.-smoothstep(0.0, 0.008, abs(r.y-i));
	}
	// Draw the axes
	ret += 1.-smoothstep(0.001, 0.015, abs(r.x));
	ret += 1.-smoothstep(0.001, 0.015, abs(r.y));
	return ret;
}
// returns 1.0 if inside circle
float disk(vec2 r, vec2 center, float radius) {
	return 1.0 - smoothstep( radius-0.005, radius+0.005, length(r-center));
}
// returns 1.0 if inside the disk
float rectangle(vec2 r, vec2 topLeft, vec2 bottomRight) {
	float ret;
	float d = 0.005;
	ret = smoothstep(topLeft.x-d, topLeft.x+d, r.x);
	ret *= smoothstep(topLeft.y-d, topLeft.y+d, r.y);
	ret *= 1.0 - smoothstep(bottomRight.y-d, bottomRight.y+d, r.y);
	ret *= 1.0 - smoothstep(bottomRight.x-d, bottomRight.x+d, r.x);
	return ret;
}

out vec4 fragColor;
void main()
{

	// Uğur Güney
	// vec2 r = vec2( fragCoord.xy / iResolution.xy );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Matthew Ragan
	// TouchDesigner provides us with a built in variable
	// that already holds the uvs for our texutre. Normally we'd 
	// you'll see this done other places with fragcoord and the
	// resolution of the scene. We could similarly derive this value
	// like this:
	// vec2 r 		= gl_FragCoord.xy / uTD2DInfos[0].res.zw;
	// here gl_FragCoord provides the pixel value, and uTD2DInfos[0].res.zw
	// provides the xy resolution of our first input.
	//
	// Lucky for us, TouchDesigner provides a built in uniform that 
	// already does this for us - vUV.st
	// for now we'll continue to use Ugur's method, but in the future
	// you'll see that I replace this computation with the line below.
	//
	// Sometimes we need values scaled between -1 and 1 rather than 0 and 1.
	// Since vUV.st is already normalized, we can do this fiarly eaisly 
	// by multiplying this value by 2, and subracting 1.
	//
	// Additionally, we don't always have square viewports, here we can construct
	// a vec2 that will hold an aspect multiplier for both x an y.
	// Next we need to multiply r by aspect. 
	//
	// The results of this will be hard to see here in our square examples, 
	// but try it on your own to see how it works.
	vec2 p 							= vUV.st;
	vec2 r 							= ( vUV.st * 2 ) - 1;
	vec2 aspect 					= uRes/uRes.x;
	r 								*= aspect;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	float xMax 						= uRes.x/uRes.y;

	vec3 bgCol 						= vec3(1.0);
	vec3 col1 						= vec3(0.216, 0.471, 0.698); // blue
	vec3 col2 						= vec3(1.00, 0.329, 0.298); // yellow
	vec3 col3 						= vec3(0.867, 0.910, 0.247); // red
		
	vec3 ret 						= bgCol;

	float angle 					= 0.6;
	mat2 rotationMatrix 			= mat2(cos(angle), -sin(angle),
                        			       sin(angle),  cos(angle));	

	if(p.x < 1./2.) { // Part I
		// put the origin at the center of Part I
		r 							= r - vec2(-xMax/2.0, 0.0); 

		vec2 rotated 				= rotationMatrix*r;
		vec2 rotatedTranslated 		= rotated - vec2(0.4, 0.5);
		ret 						= mix(ret, col1, coordinateGrid(r)*0.3);
		ret 						= mix(ret, col2, coordinateGrid(rotated)*0.3);
		ret 						= mix(ret, col3, coordinateGrid(rotatedTranslated)*0.3);
						
		ret 						= mix(ret, col1, rectangle(r, vec2(-.1, -.2), vec2(0.1, 0.2)) );
		ret 						= mix(ret, col2, rectangle(rotated, vec2(-.1, -.2), vec2(0.1, 0.2)) );
		ret 						= mix(ret, col3, rectangle(rotatedTranslated, vec2(-.1, -.2), vec2(0.1, 0.2)) );
	} 
	else if(p.x < 2./2.) { // Part II
		r 							= r - vec2(xMax*0.5, 0.0); 

		vec2 translated 			= r - vec2(0.4, 0.5);
		vec2 translatedRotated 		= rotationMatrix*translated;
		
		ret 						= mix(ret, col1, coordinateGrid(r)*0.3);
		ret 						= mix(ret, col2, coordinateGrid(translated)*0.3);
		ret 						= mix(ret, col3, coordinateGrid(translatedRotated)*0.3);
						
		ret 						= mix(ret, col1, rectangle(r, vec2(-.1, -.2), vec2(0.1, 0.2)) );
		ret 						= mix(ret, col2, rectangle(translated, vec2(-.1, -.2), vec2(0.1, 0.2)) );
		ret 						= mix(ret, col3, rectangle(translatedRotated, vec2(-.1, -.2), vec2(0.1, 0.2)) );		
	} 	
	
	vec3 pixel = ret;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	// Matthew Ragan
	// TDOutputSwizzle is a TouchDesigner function that helps ensure 
	// consistent behavior between mac and pc versions of touch. What's
	// important to know here is that you need to provide this function
	// with a vec4. Because our example above doesn't consider alpha, 
	// we can construct a vec4 out of our variable color, and an additional
	// value of 1.0 for the alpha channel.
	fragColor 						= TDOutputSwizzle(vec4(pixel, 1.0));
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
}