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


uniform vec4 _fa_[5];

float dot3 (vec3 a , vec3 b ) {return dot ( a , b ) ; }
float dot3 (vec3 a , vec4 b ) {return dot ( a , b. xyz ) ; }
float dot3 (vec4 a , vec3 b ) {return dot ( a. xyz , b ) ; }
float dot3 (vec4 a , vec4 b ) {return dot ( a. xyz , b. xyz ) ; }
ivec2 ComputeMipMapLevel (sampler2D pageOffsetTexture , vec2 texCoords , float width , float height ) {
	texCoords = texCoords * vec2 ( width , height ) ;
	vec2 mipMapLevel = texQueryLOD ( pageOffsetTexture , texCoords ) ;
	return ivec2 ( 0 , 0 ) ;
}
ivec2 ComputeMipMapLevel (isampler2D pageOffsetTexture , vec2 texCoords , float width , float height ) {
	texCoords = texCoords * vec2 ( width , height ) ;
	return ivec2 ( 0 , 0 ) ;
}
float DistributionGGX (vec3 N , vec3 H , float roughness ) {
	float a = roughness * roughness ;
	float a2 = a * a ;
	float NdotH = max ( dot ( N , H ) , 0.0 ) ;
	float NdotH2 = NdotH * NdotH ;
	float PI = 3.14159265359 ;
	float num = a2 ;
	float denom = ( NdotH2 * ( a2 - 1.0 ) + 1.0 ) ;
	denom = PI * denom * denom ;
	return num / denom ;
}
float GeometrySchlickGGX (float NdotV , float roughness ) {
	float r = ( roughness + 1.0 ) ;
	float k = ( r * r ) / 8.0 ;
	float num = NdotV ;
	float denom = NdotV * ( 1.0 - k ) + k ;
	return num / denom ;
}
float GeometrySmith (vec3 N , vec3 V , vec3 L , float roughness ) {
	float NdotV = max ( dot ( N , V ) , 0.0 ) ;
	float NdotL = max ( dot ( N , L ) , 0.0 ) ;
	float ggx2 = GeometrySchlickGGX ( NdotV , roughness ) ;
	float ggx1 = GeometrySchlickGGX ( NdotL , roughness ) ;
	return ggx1 * ggx2 ;
}
vec3 fresnelSchlick (float cosTheta , vec3 F0 ) {
	return F0 + ( 1.0 - F0 ) * pow ( 1.0 - cosTheta , 5.0 ) ;
}
vec4 idtex2Dproj (sampler2D samp , vec4 texCoords ) {return tex2Dproj ( samp , texCoords. xyw ) ; }
uniform sampler2D samp0;
uniform sampler2D samp1;
uniform sampler2D samp2;
uniform sampler2D samp3;
uniform sampler2D samp4;
uniform isampler2D samp5;

in vec4 gl_FragCoord;
in vec4 vofi_TexCoord0;
in vec4 vofi_TexCoord1;
in vec4 vofi_TexCoord2;
in vec4 vofi_TexCoord3;
in vec4 vofi_TexCoord4;
in vec4 vofi_TexCoord5;
in vec4 vofi_TexCoord6;
in vec4 vofi_TexCoord7;
in vec4 d3_Color;

layout(location = 0) out vec4 d3_FragColor;

vec2 GetPhysicalTexCoords (vec2 texCoords , int isNormal ) {
	vec2 deviceTexCoords = fract ( texCoords ) ;
	if ( isNormal == 0 )
	{
		deviceTexCoords. y = 1.0 - deviceTexCoords. y ;
	}
	ivec2 feedbackMipLevel = ComputeMipMapLevel ( samp5 , deviceTexCoords , _fa_[4 /* rpVirtualPageInfo */] . x , _fa_[4 /* rpVirtualPageInfo */] . y ) ;
	ivec2 pageOffsetTextureSizeMip = textureSize ( samp5 , feedbackMipLevel. x ). xy ;
	float widthInPages = pageOffsetTextureSizeMip. x ;
	float heightInPages = pageOffsetTextureSizeMip. y ;
	vec2 pageId ;
	pageId. x = deviceTexCoords. x * widthInPages ;
	pageId. y = deviceTexCoords. y * heightInPages ;
	ivec2 lookup ;
	lookup. x = int ( mod ( pageId. x , widthInPages ) ) ;
	lookup. y = int ( mod ( pageId. y , heightInPages ) ) ;
	vec2 texPages = texelFetch ( samp5 , lookup , feedbackMipLevel. x ). xy ;
	float vt_scale = _fa_[3 /* rpVirtualMapping */] . z / _fa_[3 /* rpVirtualMapping */] . y ;
	vec2 physicalTexCoords = fract ( deviceTexCoords * vec2 ( pageOffsetTextureSizeMip. x , pageOffsetTextureSizeMip. y ) ) ;
	physicalTexCoords. xy /= vt_scale ;
	return ( physicalTexCoords ) + ( texPages / vt_scale ) ;
}
void main() {
	vec2 bumpST = vofi_TexCoord1 . xy ;
	vec2 albedoST = vofi_TexCoord4 . xy ;
	vec2 specST = vofi_TexCoord5 . xy ;
	if ( _fa_[3 /* rpVirtualMapping */] . x >= 1 )
	{
		bumpST = GetPhysicalTexCoords ( bumpST , 1 ) ;
		albedoST = GetPhysicalTexCoords ( albedoST , 0 ) ;
		specST = GetPhysicalTexCoords ( specST , 0 ) ;
	}
	if ( _fa_[2 /* rpLocalLightOrigin */] . w == 1 )
	{
		vec4 YCoCG = tex2D ( samp3 , albedoST ) ;
		vec4 bumpMap = tex2D ( samp0 , bumpST ) ;
		vec3 localNormal ;
		localNormal. xy = bumpMap. wy - 0.5 ;
		localNormal. z = sqrt ( abs ( dot ( localNormal. xy , localNormal. xy ) - 0.25 ) ) ;
		localNormal = normalize ( localNormal ) ;
		float lightColor = dot ( localNormal , vec3 ( 0 , 0 , 1 ) ) ;
		d3_FragColor . xyz = YCoCG. xyz * lightColor * _fa_[0 /* rpDiffuseModifier */] . xyz * 0.2 ;
		d3_FragColor . w = 1 ;
		return ;
	}
	vec4 bumpMap = tex2D ( samp0 , bumpST ) ;
	vec4 lightFalloff = idtex2Dproj ( samp1 , vofi_TexCoord2 ) ;
	vec4 lightProj = idtex2Dproj ( samp2 , vofi_TexCoord3 ) ;
	vec4 YCoCG = tex2D ( samp3 , albedoST ) ;
	vec4 specTex = tex2D ( samp4 , specST ) ;
	vec3 lightVector = normalize ( vofi_TexCoord0 . xyz ) ;
	vec3 diffuseMap = YCoCG. xyz ;
	vec3 localNormal ;
	localNormal. xy = bumpMap. wy - 0.5 ;
	localNormal. z = sqrt ( abs ( dot ( localNormal. xy , localNormal. xy ) - 0.25 ) ) ;
	localNormal = normalize ( localNormal ) ;
	vec3 diffuseColor = diffuseMap * _fa_[0 /* rpDiffuseModifier */] . xyz ;
	vec3 lightColor = dot3 ( lightVector , localNormal ) * lightProj. xyz * lightFalloff. xyz ;
	vec3 H = normalize ( vofi_TexCoord6 . xyz ) ;
	float NdotH = clamp ( dot ( localNormal , H ) , 0 , 1 ) ;
	vec4 roughness = vec4 ( specTex. r , specTex. r , specTex. r , specTex. r ) ;
	vec4 metallic = vec4 ( specTex. g , specTex. g , specTex. g , specTex. g ) ;
	vec3 V = normalize ( vofi_TexCoord7 . xyz ) ;
	vec3 F0 = vec3 ( 0.04 ) ;
	F0 = mix ( F0 , diffuseMap. xyz , metallic. xyz ) ;
	float NDF = DistributionGGX ( localNormal , H , roughness. x ) ;
	float G = GeometrySmith ( localNormal , V , lightVector , roughness. x ) ;
	vec3 F = fresnelSchlick ( max ( dot ( H , V ) , 0.0 ) , F0 ) ;
	vec3 kS = F ;
	vec3 kD = vec3 ( 1.0 ) - kS ;
	kD *= 1.0 - metallic. xyz ;
	vec3 numerator = NDF * G * F ;
	float denominator = 4.0 * max ( dot ( localNormal , V ) , 0.0 ) * max ( dot ( localNormal , lightVector ) , 0.0 ) ;
	vec3 pbr = numerator / max ( denominator , 0.001 ) ;
	pbr *= _fa_[1 /* rpSpecularModifier */] . xyz ;
	d3_FragColor . xyz = ( diffuseColor + pbr ) * lightColor ;
	d3_FragColor . w = 1.0 ;
}
