attribute vec4 position;
attribute vec2 texCoords;

uniform mat4 mvpMatrix;

varying vec2 texCoordsVarying;

void main()
{
	gl_Position = mvpMatrix * position;
	texCoordsVarying = texCoords;
}
