#version 400
#define PC

float saturate( float v ) { return clamp( v, 0.0, 1.0 ); }
vec2 saturate( vec2 v ) { return clamp( v, 0.0, 1.0 ); }
vec3 saturate( vec3 v ) { return clamp( v, 0.0, 1.0 ); }
vec4 saturate( vec4 v ) { return clamp( v, 0.0, 1.0 ); }
vec4 tex2Dlod( sampler2D sampler, vec4 texcoord ) { return textureLod( sampler, texcoord.xy, texcoord.w ); }


uniform vec4 _va_[5];

float dot4 (vec4 a , vec4 b ) {return dot ( a , b ) ; }
float dot4 (vec2 a , vec4 b ) {return dot ( vec4 ( a , 0 , 1 ) , b ) ; }

in vec4 in_Position;

out vec4 gl_Position;
out vec2 vofi_TexCoord0;

void main() {
	vec4 shadowVert ;
	float g_fNear = _va_[4 /* rpShadowMapInfo */] . y ;
	float g_fFar = _va_[4 /* rpShadowMapInfo */] . z ;
	vec4 vertXyz = vec4 ( in_Position . xyz , 1.0 ) ;
	shadowVert. x = dot4 ( vertXyz , _va_[0 /* rpMVPmatrixX */] ) ;
	shadowVert. y = dot4 ( vertXyz , _va_[1 /* rpMVPmatrixY */] ) ;
	shadowVert. z = dot4 ( vertXyz , _va_[2 /* rpMVPmatrixZ */] ) ;
	shadowVert. w = dot4 ( vertXyz , _va_[3 /* rpMVPmatrixW */] ) ;
	shadowVert /= shadowVert. w ;
	shadowVert. z *= _va_[4 /* rpShadowMapInfo */] . x ;
	float fLength = length ( shadowVert. xyz ) ;
	shadowVert /= fLength ;
	vofi_TexCoord0 . x = shadowVert. z ;
	shadowVert. x /= shadowVert. z + 1.0 ;
	shadowVert. y /= shadowVert. z + 1.0 ;
	shadowVert. z = ( fLength - g_fNear ) / ( g_fFar - g_fNear ) ;
	shadowVert. w = 1.0 ;
	vofi_TexCoord0 . y = shadowVert. z ;
	gl_Position = shadowVert ;
}
