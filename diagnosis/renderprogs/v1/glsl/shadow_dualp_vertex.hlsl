uniform float4 rpMVPmatrixX : register(c21);
uniform float4 rpMVPmatrixY : register(c22);
uniform float4 rpMVPmatrixZ : register(c23);
uniform float4 rpMVPmatrixW : register(c24);
uniform float4 rpShadowMapInfo : register(c64);
static float dot4 (float4 a , float4 b )  {return dot ( a , b ) ; } 
static float dot4 (float2 a , float4 b )  {return dot ( float4 ( a , 0 , 1 ) , b ) ; } 
struct VS_IN {
float4 position : POSITION ; 
} ;
struct VS_OUT {
float4 position : POSITION ; 
float2 texcoord0 : TEXCOORD0 ; 
} ;
void main (VS_IN vertex , out VS_OUT result )  {
float4 shadowVert ; 
float g_fNear = rpShadowMapInfo . y ; 
float g_fFar = rpShadowMapInfo . z ; 
float4 vertXyz = float4 ( vertex . position . xyz , 1.0 ) ; 

shadowVert . x = dot4 ( vertXyz , rpMVPmatrixX ) ; 
shadowVert . y = dot4 ( vertXyz , rpMVPmatrixY ) ; 
shadowVert . z = dot4 ( vertXyz , rpMVPmatrixZ ) ; 
shadowVert . w = dot4 ( vertXyz , rpMVPmatrixW ) ; 

shadowVert /= shadowVert . w ; 

shadowVert . z *= rpShadowMapInfo . x ; 



float fLength = length ( shadowVert . xyz ) ; 


shadowVert /= fLength ; 


result . texcoord0 . x = shadowVert . z ; 




shadowVert . x /= shadowVert . z + 1.0 ; 
shadowVert . y /= shadowVert . z + 1.0 ; 


shadowVert . z = ( fLength - g_fNear ) / ( g_fFar - g_fNear ) ; 
shadowVert . w = 1.0 ; 

result . texcoord0 . y = shadowVert . z ; 

result . position = shadowVert ; 
} 
