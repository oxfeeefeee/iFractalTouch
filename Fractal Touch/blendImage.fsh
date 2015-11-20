#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D texture;
uniform sampler2D blendTexture;

varying vec2 texCoordsVarying0;
varying vec2 texCoordsVarying1;

void main()
{
	gl_FragColor = texture2D(texture, texCoordsVarying0) * texture2D(blendTexture, texCoordsVarying1);
}
