uniform float4 rpVirtualTextureFeedback : register(c61);
static int2 ComputeMipMapLevel (sampler2D pageOffsetTexture , float2 texCoords , float width , float height )  {
texCoords = texCoords * float2 ( width , height ) ; 

float2 mipMapLevel = texQueryLOD ( pageOffsetTexture , texCoords ) ; 
return int2 ( 0 , 0 ) ; 
} 
static int2 ComputeMipMapLevel (isampler2D pageOffsetTexture , float2 texCoords , float width , float height )  {
texCoords = texCoords * float2 ( width , height ) ; 

return int2 ( 0 , 0 ) ; 
} 
uniform isampler2D samp0 : register(s0);
struct PS_IN {
float4 position : WPOS ; 
float2 texcoord0 : TEXCOORD0_centroid ; 
} ;
struct PS_OUT {
float4 color : COLOR ; 
float4 color1 : COLOR1 ; 
} ;
void main (PS_IN fragment , out PS_OUT result )  {
float2 texCoords = frac ( fragment . texcoord0 . xy ) ; 
texCoords . y = 1.0 - texCoords . y ; 

int feedbackMipLevel = ComputeMipMapLevel ( samp0 , texCoords * 0.05 , rpVirtualTextureFeedback . y , rpVirtualTextureFeedback . z ) . x ; 

ivec2 pageOffsetTextureSizeMip = textureSize ( samp0 , feedbackMipLevel ) . xy ; 

float widthInPages = pageOffsetTextureSizeMip . x ; 
float heightInPages = pageOffsetTextureSizeMip . y ; 

float2 pageId ; 
pageId . x = fragment . texcoord0 . x * widthInPages ; 
pageId . y = fragment . texcoord0 . y * heightInPages ; 

int2 lookup , texeluv ; 
lookup . x = int ( mod ( pageId . x , widthInPages ) ) ; 
lookup . y = int ( mod ( pageId . y , heightInPages ) ) ; 

result . color . x = lookup . x ; 
result . color . y = lookup . y ; 
result . color . z = rpVirtualTextureFeedback . x ; 
result . color . w = feedbackMipLevel ; 
} 
