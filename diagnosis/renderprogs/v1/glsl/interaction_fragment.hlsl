uniform float4 rpDiffuseModifier : register(c2);
uniform float4 rpSpecularModifier : register(c3);
uniform float4 rpLocalLightOrigin : register(c4);
uniform float4 rpVirtualMapping : register(c62);
uniform float4 rpVirtualPageInfo : register(c63);
static float dot3 (float3 a , float3 b )  {return dot ( a , b ) ; } 
static float dot3 (float3 a , float4 b )  {return dot ( a , b . xyz ) ; } 
static float dot3 (float4 a , float3 b )  {return dot ( a . xyz , b ) ; } 
static float dot3 (float4 a , float4 b )  {return dot ( a . xyz , b . xyz ) ; } 
static int2 ComputeMipMapLevel (sampler2D pageOffsetTexture , float2 texCoords , float width , float height )  {
texCoords = texCoords * float2 ( width , height ) ; 

float2 mipMapLevel = texQueryLOD ( pageOffsetTexture , texCoords ) ; 
return int2 ( 0 , 0 ) ; 
} 
static int2 ComputeMipMapLevel (isampler2D pageOffsetTexture , float2 texCoords , float width , float height )  {
texCoords = texCoords * float2 ( width , height ) ; 

return int2 ( 0 , 0 ) ; 
} 
float DistributionGGX (float3 N , float3 H , float roughness )  {
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
float GeometrySchlickGGX (float NdotV , float roughness )  {
float r = ( roughness + 1.0 ) ; 
float k = ( r * r ) / 8.0 ; 

float num = NdotV ; 
float denom = NdotV * ( 1.0 - k ) + k ; 

return num / denom ; 
} 
float GeometrySmith (float3 N , float3 V , float3 L , float roughness )  {
float NdotV = max ( dot ( N , V ) , 0.0 ) ; 
float NdotL = max ( dot ( N , L ) , 0.0 ) ; 
float ggx2 = GeometrySchlickGGX ( NdotV , roughness ) ; 
float ggx1 = GeometrySchlickGGX ( NdotL , roughness ) ; 

return ggx1 * ggx2 ; 
} 
float3 fresnelSchlick (float cosTheta , float3 F0 )  {
return F0 + ( 1.0 - F0 ) * pow ( 1.0 - cosTheta , 5.0 ) ; 
} 
static float4 idtex2Dproj (sampler2D samp , float4 texCoords )  {return tex2Dproj ( samp , texCoords . xyw ) ; } 
uniform sampler2D samp0 : register(s0);
uniform sampler2D samp1 : register(s1);
uniform sampler2D samp2 : register(s2);
uniform sampler2D samp3 : register(s3);
uniform sampler2D samp4 : register(s4);
uniform isampler2D samp5 : register(s5);
struct PS_IN {
half4 position : WPOS ; 
half4 texcoord0 : TEXCOORD0_centroid ; 
half4 texcoord1 : TEXCOORD1_centroid ; 
half4 texcoord2 : TEXCOORD2_centroid ; 
half4 texcoord3 : TEXCOORD3_centroid ; 
half4 texcoord4 : TEXCOORD4_centroid ; 
half4 texcoord5 : TEXCOORD5_centroid ; 
half4 texcoord6 : TEXCOORD6_centroid ; 
half4 texcoord7 : TEXCOORD7_centroid ; 
half4 color : COLOR0 ; 
} ;
struct PS_OUT {
half4 color : COLOR ; 
half4 color1 : COLOR1 ; 
} ;
float2 GetPhysicalTexCoords (float2 texCoords , int isNormal )  {
float2 deviceTexCoords = frac ( texCoords ) ; 


if ( isNormal == 0 ) 
{ 
deviceTexCoords . y = 1.0 - deviceTexCoords . y ; 
} 

int2 feedbackMipLevel = ComputeMipMapLevel ( samp5 , deviceTexCoords , rpVirtualPageInfo . x , rpVirtualPageInfo . y ) ; 

ivec2 pageOffsetTextureSizeMip = textureSize ( samp5 , feedbackMipLevel . x ) . xy ; 

float widthInPages = pageOffsetTextureSizeMip . x ; 
float heightInPages = pageOffsetTextureSizeMip . y ; 


float2 pageId ; 

pageId . x = deviceTexCoords . x * widthInPages ; 
pageId . y = deviceTexCoords . y * heightInPages ; 

int2 lookup ; 
lookup . x = int ( mod ( pageId . x , widthInPages ) ) ; 
lookup . y = int ( mod ( pageId . y , heightInPages ) ) ; 

float2 texPages = texelFetch ( samp5 , lookup , feedbackMipLevel . x ) . xy ; 


float vt_scale = rpVirtualMapping . z / rpVirtualMapping . y ; 
float2 physicalTexCoords = fract ( deviceTexCoords * float2 ( pageOffsetTextureSizeMip . x , pageOffsetTextureSizeMip . y ) ) ; 
physicalTexCoords . xy /= vt_scale ; 
return ( physicalTexCoords ) + ( texPages / vt_scale ) ; 
} 
void main (PS_IN fragment , out PS_OUT result )  {
half2 bumpST = fragment . texcoord1 . xy ; 
half2 albedoST = fragment . texcoord4 . xy ; 
half2 specST = fragment . texcoord5 . xy ; 


if ( rpVirtualMapping . x >= 1 ) 
{ 
bumpST = GetPhysicalTexCoords ( bumpST , 1 ) ; 
albedoST = GetPhysicalTexCoords ( albedoST , 0 ) ; 
specST = GetPhysicalTexCoords ( specST , 0 ) ; 
} 


if ( rpLocalLightOrigin . w == 1 ) 
{ 
half4 YCoCG = tex2D ( samp3 , albedoST ) ; 
half4 bumpMap = tex2D ( samp0 , bumpST ) ; 

half3 localNormal ; 
localNormal . xy = bumpMap . wy - 0.5 ; 
localNormal . z = sqrt ( abs ( dot ( localNormal . xy , localNormal . xy ) - 0.25 ) ) ; 
localNormal = normalize ( localNormal ) ; 

half lightColor = dot ( localNormal , float3 ( 0 , 0 , 1 ) ) ; 
result . color . xyz = YCoCG . xyz * lightColor * rpDiffuseModifier . xyz * 0.2 ; 
result . color . w = 1 ; 
return ; 
} 

half4 bumpMap = tex2D ( samp0 , bumpST ) ; 
half4 lightFalloff = idtex2Dproj ( samp1 , fragment . texcoord2 ) ; 
half4 lightProj = idtex2Dproj ( samp2 , fragment . texcoord3 ) ; 
half4 YCoCG = tex2D ( samp3 , albedoST ) ; 
half4 specTex = tex2D ( samp4 , specST ) ; 

half3 lightVector = normalize ( fragment . texcoord0 . xyz ) ; 
half3 diffuseMap = YCoCG . xyz ; 

half3 localNormal ; 
localNormal . xy = bumpMap . wy - 0.5 ; 
localNormal . z = sqrt ( abs ( dot ( localNormal . xy , localNormal . xy ) - 0.25 ) ) ; 
localNormal = normalize ( localNormal ) ; 






half3 diffuseColor = diffuseMap * rpDiffuseModifier . xyz ; 
half3 lightColor = dot3 ( lightVector , localNormal ) * lightProj . xyz * lightFalloff . xyz ; 

float3 H = normalize ( fragment . texcoord6 . xyz ) ; 
float NdotH = clamp ( dot ( localNormal , H ) , 0 , 1 ) ; 


float4 roughness = float4 ( specTex . r , specTex . r , specTex . r , specTex . r ) ; 
float4 metallic = float4 ( specTex . g , specTex . g , specTex . g , specTex . g ) ; 

float3 V = normalize ( fragment . texcoord7 . xyz ) ; 

float3 F0 = float3 ( 0.04 ) ; 
F0 = mix ( F0 , diffuseMap . xyz , metallic . xyz ) ; 


float NDF = DistributionGGX ( localNormal , H , roughness . x ) ; 
float G = GeometrySmith ( localNormal , V , lightVector , roughness . x ) ; 
float3 F = fresnelSchlick ( max ( dot ( H , V ) , 0.0 ) , F0 ) ; 

float3 kS = F ; 
float3 kD = float3 ( 1.0 ) - kS ; 
kD *= 1.0 - metallic . xyz ; 

float3 numerator = NDF * G * F ; 
float denominator = 4.0 * max ( dot ( localNormal , V ) , 0.0 ) * max ( dot ( localNormal , lightVector ) , 0.0 ) ; 
float3 pbr = numerator / max ( denominator , 0.001 ) ; 
pbr *= rpSpecularModifier . xyz ; 

result . color . xyz = ( diffuseColor + pbr ) * lightColor ; 
result . color . w = 1.0 ; 
} 
