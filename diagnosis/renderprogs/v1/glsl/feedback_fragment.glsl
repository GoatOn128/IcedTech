#version 400
#extension GL_ARB_explicit_attrib_location : enable
#define PC

void clip( float v ) { if ( v < 0.0 ) { discard; } }
void clip( vec2 v ) { if ( any( lessThan( v, vec2( 0.0 ) ) ) ) { discard; } }
void clip( vec3 v ) { if ( any( lessThan( v, vec3( 0.0 ) ) ) ) { discard; } }
void clip( vec4 v ) { if ( any( lessThan( v, vec4( 0.0 ) ) ) ) { discard; } }

float saturate( float v ) { return clamp( v, 0.0, 1.0 ); }
vec2 saturate( vec2 v ) { return clamp( v, 0.0, 1.0 ); }
vec3 saturate( vec3 v ) { return clamp( v, 0.0, 1.0 ); }
vec4 saturate( vec4 v ) { return clamp( v, 0.0, 1.0 ); }

vec4 tex2D( sampler2D sampler, vec2 texcoord ) { return texture( sampler, texcoord.xy ); }
vec4 tex2D( sampler2DShadow sampler, vec3 texcoord ) { return vec4( texture( sampler, texcoord.xyz ) ); }

vec4 tex2D( sampler2D sampler, vec2 texcoord, vec2 dx, vec2 dy ) { return textureGrad( sampler, texcoord.xy, dx, dy ); }
vec4 tex2D( sampler2DShadow sampler, vec3 texcoord, vec2 dx, vec2 dy ) { return vec4( textureGrad( sampler, texcoord.xyz, dx, dy ) ); }

vec4 texCUBE( samplerCube sampler, vec3 texcoord ) { return texture( sampler, texcoord.xyz ); }
vec4 texCUBE( samplerCubeShadow sampler, vec4 texcoord ) { return vec4( texture( sampler, texcoord.xyzw ) ); }

vec2 texQueryLOD( sampler2D sampler, vec2 texCoord ) { return textureQueryLod(sampler, texCoord).xy; }
vec2 texQueryLOD( isampler2D sampler, vec2 texCoord ) { return textureQueryLod(sampler, texCoord).xy; }

vec4 tex1Dproj( sampler1D sampler, vec2 texcoord ) { return textureProj( sampler, texcoord ); }
vec4 tex2Dproj( sampler2D sampler, vec3 texcoord ) { return textureProj( sampler, texcoord ); }
vec4 tex3Dproj( sampler3D sampler, vec4 texcoord ) { return textureProj( sampler, texcoord ); }

vec4 tex1Dbias( sampler1D sampler, vec4 texcoord ) { return texture( sampler, texcoord.x, texcoord.w ); }
vec4 tex2Dbias( sampler2D sampler, vec4 texcoord ) { return texture( sampler, texcoord.xy, texcoord.w ); }
vec4 tex3Dbias( sampler3D sampler, vec4 texcoord ) { return texture( sampler, texcoord.xyz, texcoord.w ); }
vec4 texCUBEbias( samplerCube sampler, vec4 texcoord ) { return texture( sampler, texcoord.xyz, texcoord.w ); }

vec4 tex1Dlod( sampler1D sampler, vec4 texcoord ) { return textureLod( sampler, texcoord.x, texcoord.w ); }
vec4 tex2Dlod( sampler2D sampler, vec4 texcoord ) { return textureLod( sampler, texcoord.xy, texcoord.w ); }
vec4 tex3Dlod( sampler3D sampler, vec4 texcoord ) { return textureLod( sampler, texcoord.xyz, texcoord.w ); }
vec4 texCUBElod( samplerCube sampler, vec4 texcoord ) { return textureLod( sampler, texcoord.xyz, texcoord.w ); }


uniform vec4 _fa_[1];

ivec2 ComputeMipMapLevel (sampler2D pageOffsetTexture , vec2 texCoords , float width , float height ) {
	texCoords = texCoords * vec2 ( width , height ) ;
	vec2 mipMapLevel = texQueryLOD ( pageOffsetTexture , texCoords ) ;
	return ivec2 ( 0 , 0 ) ;
}
ivec2 ComputeMipMapLevel (isampler2D pageOffsetTexture , vec2 texCoords , float width , float height ) {
	texCoords = texCoords * vec2 ( width , height ) ;
	return ivec2 ( 0 , 0 ) ;
}
uniform sampler2D samp0;

in vec4 gl_FragCoord;
in vec2 vofi_TexCoord0;

layout(location = 0) out vec4 d3_FragColor;

void main() {
	vec2 texCoords = fract ( vofi_TexCoord0 . xy ) ;
	texCoords. y = 1.0 - texCoords. y ;
	int feedbackMipLevel = ComputeMipMapLevel ( samp0 , texCoords * 0.05 , _fa_[0 /* rpVirtualTextureFeedback */] . y , _fa_[0 /* rpVirtualTextureFeedback */] . z ). x ;
	ivec2 pageOffsetTextureSizeMip = textureSize ( samp0 , feedbackMipLevel ). xy ;
	float widthInPages = pageOffsetTextureSizeMip. x ;
	float heightInPages = pageOffsetTextureSizeMip. y ;
	vec2 pageId ;
	pageId. x = vofi_TexCoord0 . x * widthInPages ;
	pageId. y = vofi_TexCoord0 . y * heightInPages ;
	ivec2 lookup , texeluv ;
	lookup. x = int ( mod ( pageId. x , widthInPages ) ) ;
	lookup. y = int ( mod ( pageId. y , heightInPages ) ) ;
	d3_FragColor . x = lookup. x ;
	d3_FragColor . y = lookup. y ;
	d3_FragColor . z = _fa_[0 /* rpVirtualTextureFeedback */] . x ;
	d3_FragColor . w = feedbackMipLevel ;
}
