#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D texture;

varying vec2 texCoordsVarying;

void main()
{
	gl_FragColor = texture2D(texture, texCoordsVarying);
}
