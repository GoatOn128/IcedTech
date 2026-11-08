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

uniform sampler2D samp0;
uniform sampler2D samp1;

in vec4 gl_FragCoord;
in vec2 vofi_TexCoord0;

layout(location = 0) out vec4 d3_FragColor;

vec4 blur13 (sampler2D image , vec2 uv , vec2 resolution , vec2 direction ) {
	vec4 color = vec4 ( 0.0 ) ;
	vec2 off1 = vec2 ( 1.411764705882353 ) * direction ;
	vec2 off2 = vec2 ( 3.2941176470588234 ) * direction ;
	vec2 off3 = vec2 ( 5.176470588235294 ) * direction ;
	color += texture2D ( image , uv ) * 0.1964825501511404 ;
	color += texture2D ( image , uv + ( off1 / resolution ) ) * 0.2969069646728344 ;
	color += texture2D ( image , uv - ( off1 / resolution ) ) * 0.2969069646728344 ;
	color += texture2D ( image , uv + ( off2 / resolution ) ) * 0.09447039785044732 ;
	color += texture2D ( image , uv - ( off2 / resolution ) ) * 0.09447039785044732 ;
	color += texture2D ( image , uv + ( off3 / resolution ) ) * 0.010381362401148057 ;
	color += texture2D ( image , uv - ( off3 / resolution ) ) * 0.010381362401148057 ;
	return color ;
}
float Min3 (float x , float y , float z ) {
	return min ( x , min ( y , z ) ) ;
}
float Max3 (float x , float y , float z ) {
	return max ( x , max ( y , z ) ) ;
}
float rcp (float v ) {
	return 1.0 / v ;
}
vec4 CaSUpSample (sampler2D diffuseImage , vec2 diffuseST ) {
	vec2 texcoord = diffuseST. xy ;
	float Sharpness = 1 ;
	ivec2 bufferSize = textureSize ( diffuseImage , 0 ) ;
	float pixelX = ( 1.0 / bufferSize. x ) ;
	float pixelY = ( 1.0 / bufferSize. y ) ;
	vec3 a = tex2D ( diffuseImage , texcoord + vec2 ( - pixelX , - pixelY ) ). rgb ;
	vec3 b = tex2D ( diffuseImage , texcoord + vec2 ( 0.0 , - pixelY ) ). rgb ;
	vec3 c = tex2D ( diffuseImage , texcoord + vec2 ( pixelX , - pixelY ) ). rgb ;
	vec3 d = tex2D ( diffuseImage , texcoord + vec2 ( - pixelX , 0.0 ) ). rgb ;
	vec3 e = tex2D ( diffuseImage , texcoord ). rgb ;
	vec3 f = tex2D ( diffuseImage , texcoord + vec2 ( pixelX , 0.0 ) ). rgb ;
	vec3 g = tex2D ( diffuseImage , texcoord + vec2 ( - pixelX , pixelY ) ). rgb ;
	vec3 h = tex2D ( diffuseImage , texcoord + vec2 ( 0.0 , pixelY ) ). rgb ;
	vec3 i = tex2D ( diffuseImage , texcoord + vec2 ( pixelX , pixelY ) ). rgb ;
	float mnR = Min3 ( Min3 ( d. r , e. r , f. r ) , b. r , h. r ) ;
	float mnG = Min3 ( Min3 ( d. g , e. g , f. g ) , b. g , h. g ) ;
	float mnB = Min3 ( Min3 ( d. b , e. b , f. b ) , b. b , h. b ) ;
	float mnR2 = Min3 ( Min3 ( mnR , a. r , c. r ) , g. r , i. r ) ;
	float mnG2 = Min3 ( Min3 ( mnG , a. g , c. g ) , g. g , i. g ) ;
	float mnB2 = Min3 ( Min3 ( mnB , a. b , c. b ) , g. b , i. b ) ;
	mnR = mnR + mnR2 ;
	mnG = mnG + mnG2 ;
	mnB = mnB + mnB2 ;
	float mxR = Max3 ( Max3 ( d. r , e. r , f. r ) , b. r , h. r ) ;
	float mxG = Max3 ( Max3 ( d. g , e. g , f. g ) , b. g , h. g ) ;
	float mxB = Max3 ( Max3 ( d. b , e. b , f. b ) , b. b , h. b ) ;
	float mxR2 = Max3 ( Max3 ( mxR , a. r , c. r ) , g. r , i. r ) ;
	float mxG2 = Max3 ( Max3 ( mxG , a. g , c. g ) , g. g , i. g ) ;
	float mxB2 = Max3 ( Max3 ( mxB , a. b , c. b ) , g. b , i. b ) ;
	mxR = mxR + mxR2 ;
	mxG = mxG + mxG2 ;
	mxB = mxB + mxB2 ;
	float rcpMR = rcp ( mxR ) ;
	float rcpMG = rcp ( mxG ) ;
	float rcpMB = rcp ( mxB ) ;
	float ampR = saturate ( min ( mnR , 2.0 - mxR ) * rcpMR ) ;
	float ampG = saturate ( min ( mnG , 2.0 - mxG ) * rcpMG ) ;
	float ampB = saturate ( min ( mnB , 2.0 - mxB ) * rcpMB ) ;
	ampR = sqrt ( ampR ) ;
	ampG = sqrt ( ampG ) ;
	ampB = sqrt ( ampB ) ;
	float peak = - rcp ( mix ( 8.0 , 5.0 , saturate ( Sharpness ) ) ) ;
	float wR = ampR * peak ;
	float wG = ampG * peak ;
	float wB = ampB * peak ;
	float rcpWeightR = rcp ( 1.0 + 4.0 * wR ) ;
	float rcpWeightG = rcp ( 1.0 + 4.0 * wG ) ;
	float rcpWeightB = rcp ( 1.0 + 4.0 * wB ) ;
	vec3 outColor = vec3 ( saturate ( ( b. r * wR + d. r * wR + f. r * wR + h. r * wR + e. r ) * rcpWeightR ) ,
	saturate ( ( b. g * wG + d. g * wG + f. g * wG + h. g * wG + e. g ) * rcpWeightG ) ,
	saturate ( ( b. b * wB + d. b * wB + f. b * wB + h. b * wB + e. b ) * rcpWeightB ) ) ;
	return vec4 ( outColor , 1.0 ) ;
}
void main() {
	vec2 tCoords = vofi_TexCoord0 ;
	vec4 albedo = CaSUpSample ( samp0 , tCoords ) ;
	vec4 emissive_mask = tex2D ( samp1 , tCoords ) ;
	vec2 imageSize = _fa_[0 /* rpRenderTargetSize */] . xy * 0.1 ;
	vec4 emissive = blur13 ( samp0 , tCoords , imageSize , vec2 ( 0 , 1 ) ) ;
	emissive += blur13 ( samp0 , tCoords , imageSize , vec2 ( 1 , 0 ) ) ;
	d3_FragColor = ( albedo ) + ( emissive_mask * emissive ) ;
}
