iFractalTouch
=====

AppStore url: https://appsto.re/cn/_YXqJ.i

A fast Mandelbrot set zoomer, which uses CPU SIMD to calulate tiled images and then uses OpenGL to render it at high FPS, so that the UI interaction is smooth.

What might be interesting
----
- Google-Map-like image rendering. CPU generates tiles with different level-of-detail and then upload them to GPU to render it at 60FPS.
- Fast Mandelbrot set iteration with assembly code on Apple A6 and A8 processors, especially the double precision part.
- The “Grid Algorithm” to speed up Mandelbrot set image generation.

Why written and released
----
This was my first iOS project to learn iOS development back in 2012. I do not intend to maintain the code anymore, I decided to release the code (which might be a bit messy) so that it doesn’t get lost, Even better if anyone finds it interesting.

Note
----
The code didn't compile with the latest XCode, so I made a few quick & dirty changes to fix that, and the side effect is some UI issues.

License
----
iFractalTouch is released under the MIT license.
