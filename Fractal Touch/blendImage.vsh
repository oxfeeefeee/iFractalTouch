attribute vec4 position;
attribute vec2 texCoords0;
attribute vec2 texCoords1;

uniform mat4 mvpMatrix;

varying vec2 texCoordsVarying0;
varying vec2 texCoordsVarying1;

void main()
{
	gl_Position = mvpMatrix * position;
	texCoordsVarying0 = texCoords0;
    texCoordsVarying1 = texCoords1;
}
