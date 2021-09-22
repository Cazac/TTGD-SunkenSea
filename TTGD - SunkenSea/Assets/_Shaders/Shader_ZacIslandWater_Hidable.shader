Shader "Custom/BasicShader_ZacHideableWater"
{
	Properties
	{
		Vector1_69B48606("Wave Rotate X", Float) = 1
		Vector1_1923AEDE("Wave Rotate Z", Float) = 1
		Vector1_80A02785("Wave Scale", Float) = 1
		Vector1_E187C34("Wave Speed", Float) = 1
		Vector1_630D71D8("Wave Power", Float) = 1
		Vector1_EEF89253("Wave Height", Float) = 1
		[ToggleUI]Boolean_752BD26D("IsTopWave", Float) = 1
		[HDR]Color_A5FBF550("TopRippleColor", Color) = (0.3021537, 1.830189, 1.179541, 1)
		Color_9BC50DA7("TopWaterColor", Color) = (0, 0.3863957, 1, 0)
		Color_3F2719E("BottomWaterColor", Color) = (0, 0.3863957, 1, 0)
		Vector1_DAC37871("RippleSize", Float) = 3
		Vector1_65024720("RippleDensity", Float) = 10
		Vector1_AB4D1482("RippleSpeed", Float) = 1.2
		Vector1_E7EEAB37("TopWaterAlpha", Float) = 0.8
		Vector1_5565EB0D("BottomWaterAlpha", Float) = 0.1
		[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}
	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Transparent"
			"UniversalMaterialType" = "Lit"
			"Queue" = "Transparent"
		}

		//This is my Code - Zac
		Stencil
		{
			Ref 0
			Comp Equal
			Pass keep
		}


		Pass
		{
			Name "Universal Forward"
			Tags
			{
				"LightMode" = "UniversalForward"
			}

		// Render State
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
		ZTest LEqual
		ZWrite Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma multi_compile_instancing
	#pragma multi_compile_fog
	#pragma multi_compile _ DOTS_INSTANCING_ON
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
	#pragma multi_compile _ LIGHTMAP_ON
	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
	#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
	#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
	#pragma multi_compile _ _SHADOWS_SOFT
	#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
	#pragma multi_compile _ SHADOWS_SHADOWMASK
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define VARYINGS_NEED_POSITION_WS
		#define VARYINGS_NEED_NORMAL_WS
		#define VARYINGS_NEED_TANGENT_WS
		#define VARYINGS_NEED_TEXCOORD0
		#define VARYINGS_NEED_VIEWDIRECTION_WS
		#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_FORWARD
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float3 positionWS;
		float3 normalWS;
		float4 tangentWS;
		float4 texCoord0;
		float3 viewDirectionWS;
		#if defined(LIGHTMAP_ON)
		float2 lightmapUV;
		#endif
		#if !defined(LIGHTMAP_ON)
		float3 sh;
		#endif
		float4 fogFactorAndVertexLight;
		float4 shadowCoord;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float3 TangentSpaceNormal;
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float3 interp0 : TEXCOORD0;
		float3 interp1 : TEXCOORD1;
		float4 interp2 : TEXCOORD2;
		float4 interp3 : TEXCOORD3;
		float3 interp4 : TEXCOORD4;
		#if defined(LIGHTMAP_ON)
		float2 interp5 : TEXCOORD5;
		#endif
		#if !defined(LIGHTMAP_ON)
		float3 interp6 : TEXCOORD6;
		#endif
		float4 interp7 : TEXCOORD7;
		float4 interp8 : TEXCOORD8;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyz = input.positionWS;
		output.interp1.xyz = input.normalWS;
		output.interp2.xyzw = input.tangentWS;
		output.interp3.xyzw = input.texCoord0;
		output.interp4.xyz = input.viewDirectionWS;
		#if defined(LIGHTMAP_ON)
		output.interp5.xy = input.lightmapUV;
		#endif
		#if !defined(LIGHTMAP_ON)
		output.interp6.xyz = input.sh;
		#endif
		output.interp7.xyzw = input.fogFactorAndVertexLight;
		output.interp8.xyzw = input.shadowCoord;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.positionWS = input.interp0.xyz;
		output.normalWS = input.interp1.xyz;
		output.tangentWS = input.interp2.xyzw;
		output.texCoord0 = input.interp3.xyzw;
		output.viewDirectionWS = input.interp4.xyz;
		#if defined(LIGHTMAP_ON)
		output.lightmapUV = input.interp5.xy;
		#endif
		#if !defined(LIGHTMAP_ON)
		output.sh = input.interp6.xyz;
		#endif
		output.fogFactorAndVertexLight = input.interp7.xyzw;
		output.shadowCoord = input.interp8.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float3 NormalTS;
	float3 Emission;
	float3 Specular;
	float Smoothness;
	float Occlusion;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.NormalTS = IN.TangentSpaceNormal;
	surface.Emission = float3(0, 0, 0);
	surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
	surface.Smoothness = 0.5;
	surface.Occlusion = 1;
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



	output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "GBuffer"
	Tags
	{
		"LightMode" = "UniversalGBuffer"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma multi_compile_instancing
	#pragma multi_compile_fog
	#pragma multi_compile _ DOTS_INSTANCING_ON
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		#pragma multi_compile _ LIGHTMAP_ON
	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
	#pragma multi_compile _ _SHADOWS_SOFT
	#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
	#pragma multi_compile _ _GBUFFER_NORMALS_OCT
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define VARYINGS_NEED_POSITION_WS
		#define VARYINGS_NEED_NORMAL_WS
		#define VARYINGS_NEED_TANGENT_WS
		#define VARYINGS_NEED_TEXCOORD0
		#define VARYINGS_NEED_VIEWDIRECTION_WS
		#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_GBUFFER
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float3 positionWS;
		float3 normalWS;
		float4 tangentWS;
		float4 texCoord0;
		float3 viewDirectionWS;
		#if defined(LIGHTMAP_ON)
		float2 lightmapUV;
		#endif
		#if !defined(LIGHTMAP_ON)
		float3 sh;
		#endif
		float4 fogFactorAndVertexLight;
		float4 shadowCoord;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float3 TangentSpaceNormal;
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float3 interp0 : TEXCOORD0;
		float3 interp1 : TEXCOORD1;
		float4 interp2 : TEXCOORD2;
		float4 interp3 : TEXCOORD3;
		float3 interp4 : TEXCOORD4;
		#if defined(LIGHTMAP_ON)
		float2 interp5 : TEXCOORD5;
		#endif
		#if !defined(LIGHTMAP_ON)
		float3 interp6 : TEXCOORD6;
		#endif
		float4 interp7 : TEXCOORD7;
		float4 interp8 : TEXCOORD8;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyz = input.positionWS;
		output.interp1.xyz = input.normalWS;
		output.interp2.xyzw = input.tangentWS;
		output.interp3.xyzw = input.texCoord0;
		output.interp4.xyz = input.viewDirectionWS;
		#if defined(LIGHTMAP_ON)
		output.interp5.xy = input.lightmapUV;
		#endif
		#if !defined(LIGHTMAP_ON)
		output.interp6.xyz = input.sh;
		#endif
		output.interp7.xyzw = input.fogFactorAndVertexLight;
		output.interp8.xyzw = input.shadowCoord;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.positionWS = input.interp0.xyz;
		output.normalWS = input.interp1.xyz;
		output.tangentWS = input.interp2.xyzw;
		output.texCoord0 = input.interp3.xyzw;
		output.viewDirectionWS = input.interp4.xyz;
		#if defined(LIGHTMAP_ON)
		output.lightmapUV = input.interp5.xy;
		#endif
		#if !defined(LIGHTMAP_ON)
		output.sh = input.interp6.xyz;
		#endif
		output.fogFactorAndVertexLight = input.interp7.xyzw;
		output.shadowCoord = input.interp8.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float3 NormalTS;
	float3 Emission;
	float3 Specular;
	float Smoothness;
	float Occlusion;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.NormalTS = IN.TangentSpaceNormal;
	surface.Emission = float3(0, 0, 0);
	surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
	surface.Smoothness = 0.5;
	surface.Occlusion = 1;
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



	output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "ShadowCaster"
	Tags
	{
		"LightMode" = "ShadowCaster"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On
	ColorMask 0

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma multi_compile_instancing
	#pragma multi_compile _ DOTS_INSTANCING_ON
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_SHADOWCASTER
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "DepthOnly"
	Tags
	{
		"LightMode" = "DepthOnly"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On
	ColorMask 0

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma multi_compile_instancing
	#pragma multi_compile _ DOTS_INSTANCING_ON
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_DEPTHONLY
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "DepthNormals"
	Tags
	{
		"LightMode" = "DepthNormals"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma multi_compile_instancing
	#pragma multi_compile _ DOTS_INSTANCING_ON
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define VARYINGS_NEED_NORMAL_WS
		#define VARYINGS_NEED_TANGENT_WS
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float3 normalWS;
		float4 tangentWS;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float3 TangentSpaceNormal;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float3 interp0 : TEXCOORD0;
		float4 interp1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyz = input.normalWS;
		output.interp1.xyzw = input.tangentWS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.normalWS = input.interp0.xyz;
		output.tangentWS = input.interp1.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 NormalTS;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.NormalTS = IN.TangentSpaceNormal;
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



	output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "Meta"
	Tags
	{
		"LightMode" = "Meta"
	}

		// Render State
		Cull Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define ATTRIBUTES_NEED_TEXCOORD2
		#define VARYINGS_NEED_TEXCOORD0
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_META
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		float4 uv2 : TEXCOORD2;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float4 texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float4 interp0 : TEXCOORD0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyzw = input.texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.texCoord0 = input.interp0.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float3 Emission;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.Emission = float3(0, 0, 0);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

	ENDHLSL
}
Pass
{
		// Name: <None>
		Tags
		{
			"LightMode" = "Universal2D"
		}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 4.5
	#pragma exclude_renderers gles gles3 glcore
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define VARYINGS_NEED_TEXCOORD0
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_2D
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float4 texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float4 interp0 : TEXCOORD0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyzw = input.texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.texCoord0 = input.interp0.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

	ENDHLSL
}
	}
		SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Transparent"
			"UniversalMaterialType" = "Lit"
			"Queue" = "Transparent"
		}
		Pass
		{
			Name "Universal Forward"
			Tags
			{
				"LightMode" = "UniversalForward"
			}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 2.0
	#pragma only_renderers gles gles3 glcore d3d11
	#pragma multi_compile_instancing
	#pragma multi_compile_fog
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
	#pragma multi_compile _ LIGHTMAP_ON
	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
	#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
	#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
	#pragma multi_compile _ _SHADOWS_SOFT
	#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
	#pragma multi_compile _ SHADOWS_SHADOWMASK
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define VARYINGS_NEED_POSITION_WS
		#define VARYINGS_NEED_NORMAL_WS
		#define VARYINGS_NEED_TANGENT_WS
		#define VARYINGS_NEED_TEXCOORD0
		#define VARYINGS_NEED_VIEWDIRECTION_WS
		#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_FORWARD
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float3 positionWS;
		float3 normalWS;
		float4 tangentWS;
		float4 texCoord0;
		float3 viewDirectionWS;
		#if defined(LIGHTMAP_ON)
		float2 lightmapUV;
		#endif
		#if !defined(LIGHTMAP_ON)
		float3 sh;
		#endif
		float4 fogFactorAndVertexLight;
		float4 shadowCoord;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float3 TangentSpaceNormal;
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float3 interp0 : TEXCOORD0;
		float3 interp1 : TEXCOORD1;
		float4 interp2 : TEXCOORD2;
		float4 interp3 : TEXCOORD3;
		float3 interp4 : TEXCOORD4;
		#if defined(LIGHTMAP_ON)
		float2 interp5 : TEXCOORD5;
		#endif
		#if !defined(LIGHTMAP_ON)
		float3 interp6 : TEXCOORD6;
		#endif
		float4 interp7 : TEXCOORD7;
		float4 interp8 : TEXCOORD8;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyz = input.positionWS;
		output.interp1.xyz = input.normalWS;
		output.interp2.xyzw = input.tangentWS;
		output.interp3.xyzw = input.texCoord0;
		output.interp4.xyz = input.viewDirectionWS;
		#if defined(LIGHTMAP_ON)
		output.interp5.xy = input.lightmapUV;
		#endif
		#if !defined(LIGHTMAP_ON)
		output.interp6.xyz = input.sh;
		#endif
		output.interp7.xyzw = input.fogFactorAndVertexLight;
		output.interp8.xyzw = input.shadowCoord;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.positionWS = input.interp0.xyz;
		output.normalWS = input.interp1.xyz;
		output.tangentWS = input.interp2.xyzw;
		output.texCoord0 = input.interp3.xyzw;
		output.viewDirectionWS = input.interp4.xyz;
		#if defined(LIGHTMAP_ON)
		output.lightmapUV = input.interp5.xy;
		#endif
		#if !defined(LIGHTMAP_ON)
		output.sh = input.interp6.xyz;
		#endif
		output.fogFactorAndVertexLight = input.interp7.xyzw;
		output.shadowCoord = input.interp8.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float3 NormalTS;
	float3 Emission;
	float3 Specular;
	float Smoothness;
	float Occlusion;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.NormalTS = IN.TangentSpaceNormal;
	surface.Emission = float3(0, 0, 0);
	surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
	surface.Smoothness = 0.5;
	surface.Occlusion = 1;
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



	output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "ShadowCaster"
	Tags
	{
		"LightMode" = "ShadowCaster"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On
	ColorMask 0

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 2.0
	#pragma only_renderers gles gles3 glcore d3d11
	#pragma multi_compile_instancing
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_SHADOWCASTER
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "DepthOnly"
	Tags
	{
		"LightMode" = "DepthOnly"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On
	ColorMask 0

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 2.0
	#pragma only_renderers gles gles3 glcore d3d11
	#pragma multi_compile_instancing
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_DEPTHONLY
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "DepthNormals"
	Tags
	{
		"LightMode" = "DepthNormals"
	}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 2.0
	#pragma only_renderers gles gles3 glcore d3d11
	#pragma multi_compile_instancing
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define VARYINGS_NEED_NORMAL_WS
		#define VARYINGS_NEED_TANGENT_WS
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float3 normalWS;
		float4 tangentWS;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float3 TangentSpaceNormal;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float3 interp0 : TEXCOORD0;
		float4 interp1 : TEXCOORD1;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyz = input.normalWS;
		output.interp1.xyzw = input.tangentWS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.normalWS = input.interp0.xyz;
		output.tangentWS = input.interp1.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 NormalTS;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.NormalTS = IN.TangentSpaceNormal;
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



	output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

	ENDHLSL
}
Pass
{
	Name "Meta"
	Tags
	{
		"LightMode" = "Meta"
	}

		// Render State
		Cull Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 2.0
	#pragma only_renderers gles gles3 glcore d3d11
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define ATTRIBUTES_NEED_TEXCOORD2
		#define VARYINGS_NEED_TEXCOORD0
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_META
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		float4 uv2 : TEXCOORD2;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float4 texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float4 interp0 : TEXCOORD0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyzw = input.texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.texCoord0 = input.interp0.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float3 Emission;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.Emission = float3(0, 0, 0);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

	ENDHLSL
}
Pass
{
		// Name: <None>
		Tags
		{
			"LightMode" = "Universal2D"
		}

		// Render State
		Cull Back
	Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
	ZTest LEqual
	ZWrite Off

		// Debug
		// <None>

		// --------------------------------------------------
		// Pass

		HLSLPROGRAM

		// Pragmas
		#pragma target 2.0
	#pragma only_renderers gles gles3 glcore d3d11
	#pragma multi_compile_instancing
	#pragma vertex vert
	#pragma fragment frag

		// DotsInstancingOptions: <None>
		// HybridV1InjectedBuiltinProperties: <None>

		// Keywords
		// PassKeywords: <None>
		// GraphKeywords: <None>

		// Defines
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _AlphaClip 1
		#define _NORMALMAP 1
		#define _SPECULAR_SETUP
		#define _NORMAL_DROPOFF_TS 1
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define VARYINGS_NEED_TEXCOORD0
		#define FEATURES_GRAPH_VERTEX
		/* WARNING: $splice Could not find named fragment 'PassInstancing' */
		#define SHADERPASS SHADERPASS_2D
		/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

		// Includes
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

		// --------------------------------------------------
		// Structs and Packing

		struct Attributes
	{
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL;
		float4 tangentOS : TANGENT;
		float4 uv0 : TEXCOORD0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif
	};
	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float4 texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};
	struct SurfaceDescriptionInputs
	{
		float4 uv0;
		float3 TimeParameters;
	};
	struct VertexDescriptionInputs
	{
		float3 ObjectSpaceNormal;
		float3 ObjectSpaceTangent;
		float3 ObjectSpacePosition;
		float3 WorldSpacePosition;
		float3 TimeParameters;
	};
	struct PackedVaryings
	{
		float4 positionCS : SV_POSITION;
		float4 interp0 : TEXCOORD0;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif
	};

		PackedVaryings PackVaryings(Varyings input)
	{
		PackedVaryings output;
		output.positionCS = input.positionCS;
		output.interp0.xyzw = input.texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}
	Varyings UnpackVaryings(PackedVaryings input)
	{
		Varyings output;
		output.positionCS = input.positionCS;
		output.texCoord0 = input.interp0.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif
		#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
		output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
		#endif
		#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
		output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
		#endif
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif
		return output;
	}

	// --------------------------------------------------
	// Graph

	// Graph Properties
	CBUFFER_START(UnityPerMaterial)
float Vector1_69B48606;
float Vector1_1923AEDE;
float Vector1_80A02785;
float Vector1_E187C34;
float Vector1_630D71D8;
float Vector1_EEF89253;
float Boolean_752BD26D;
float4 Color_A5FBF550;
float4 Color_9BC50DA7;
float4 Color_3F2719E;
float Vector1_DAC37871;
float Vector1_65024720;
float Vector1_AB4D1482;
float Vector1_E7EEAB37;
float Vector1_5565EB0D;
CBUFFER_END

// Object and Global properties

	// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
	Out = A * B;
}

void Unity_Add_float(float A, float B, out float Out)
{
	Out = A + B;
}

void Unity_Sine_float(float In, out float Out)
{
	Out = sin(In);
}

void Unity_Absolute_float(float In, out float Out)
{
	Out = abs(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
	Out = 1 - In;
}

void Unity_Power_float(float A, float B, out float Out)
{
	Out = pow(A, B);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
	RGBA = float4(R, G, B, A);
	RGB = float3(R, G, B);
	RG = float2(R, G);
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)));
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
	float2 g = floor(UV * CellDensity);
	float2 f = frac(UV * CellDensity);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x,y);
			float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);

			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Out = res.x;
				Cells = res.y;
			}
		}
	}
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
	Out = A * B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
	Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
	Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
	Out = Predicate ? True : False;
}

// Graph Vertex
struct VertexDescription
{
	float3 Position;
	float3 Normal;
	float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
	VertexDescription description = (VertexDescription)0;
	float _Split_60792a6be44852819fc09b8816918440_R_1 = IN.ObjectSpacePosition[0];
	float _Split_60792a6be44852819fc09b8816918440_G_2 = IN.ObjectSpacePosition[1];
	float _Split_60792a6be44852819fc09b8816918440_B_3 = IN.ObjectSpacePosition[2];
	float _Split_60792a6be44852819fc09b8816918440_A_4 = 0;
	float _Property_a9ae68db760bff84a923d7d86950c705_Out_0 = Vector1_69B48606;
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1 = IN.WorldSpacePosition[0];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_G_2 = IN.WorldSpacePosition[1];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3 = IN.WorldSpacePosition[2];
	float _Split_4c9c4d7ffb3c658882d89e4ad158940a_A_4 = 0;
	float _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2;
	Unity_Multiply_float(_Property_a9ae68db760bff84a923d7d86950c705_Out_0, _Split_4c9c4d7ffb3c658882d89e4ad158940a_R_1, _Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2);
	float _Property_f645cdad217c5384ae4618591d279ae2_Out_0 = Vector1_1923AEDE;
	float _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2;
	Unity_Multiply_float(_Split_4c9c4d7ffb3c658882d89e4ad158940a_B_3, _Property_f645cdad217c5384ae4618591d279ae2_Out_0, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2);
	float _Add_768c02884b866e809169aa94286a84ef_Out_2;
	Unity_Add_float(_Multiply_f3f98b23e9cece858559a84dab5a2fbe_Out_2, _Multiply_50dcb1282307f2868c47a7e1e54c4de2_Out_2, _Add_768c02884b866e809169aa94286a84ef_Out_2);
	float _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0 = Vector1_80A02785;
	float _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2;
	Unity_Multiply_float(_Add_768c02884b866e809169aa94286a84ef_Out_2, _Property_53acebcdafa9ae8ab7dd4de2052ba094_Out_0, _Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2);
	float _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0 = Vector1_E187C34;
	float _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_42bd153534f9ed8fbbfadbbc5f46faea_Out_0, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2);
	float _Add_88041d0f65eba28980a325ceb289435d_Out_2;
	Unity_Add_float(_Multiply_e2d9d2a2743a7585951045060f85a27f_Out_2, _Multiply_83bd88cef1da6b87b7c0479ac25224a0_Out_2, _Add_88041d0f65eba28980a325ceb289435d_Out_2);
	float _Sine_8a59f9a1774fb983a59bed8195759109_Out_1;
	Unity_Sine_float(_Add_88041d0f65eba28980a325ceb289435d_Out_2, _Sine_8a59f9a1774fb983a59bed8195759109_Out_1);
	float _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1;
	Unity_Absolute_float(_Sine_8a59f9a1774fb983a59bed8195759109_Out_1, _Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1);
	float _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1;
	Unity_OneMinus_float(_Absolute_3b73ba2d244ac288ae3a1418ab102d31_Out_1, _OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1);
	float _Property_459ca789526000859595ed657d5c87a7_Out_0 = Vector1_630D71D8;
	float _Power_144ed3b81dfd5183a0440caa37afa017_Out_2;
	Unity_Power_float(_OneMinus_6f6ee4ad03b12786a3296c9b3484494b_Out_1, _Property_459ca789526000859595ed657d5c87a7_Out_0, _Power_144ed3b81dfd5183a0440caa37afa017_Out_2);
	float _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0 = Vector1_EEF89253;
	float _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	Unity_Multiply_float(_Power_144ed3b81dfd5183a0440caa37afa017_Out_2, _Property_5329ff15c35fee8daebfd42e52d05ae0_Out_0, _Multiply_7406e1134be77b8abb1541045539eacf_Out_2);
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1 = _Multiply_7406e1134be77b8abb1541045539eacf_Out_2;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_G_2 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3 = 0;
	float _Split_1558ace52efca58fbb9f6fd343ab3cd1_A_4 = 0;
	float _Add_f3cad1db9ebda588a6315d1338527c13_Out_2;
	Unity_Add_float(_Split_1558ace52efca58fbb9f6fd343ab3cd1_R_1, _Split_1558ace52efca58fbb9f6fd343ab3cd1_B_3, _Add_f3cad1db9ebda588a6315d1338527c13_Out_2);
	float _Add_13aa48af27870f87b4cba9e2947120d0_Out_2;
	Unity_Add_float(_Add_f3cad1db9ebda588a6315d1338527c13_Out_2, _Split_60792a6be44852819fc09b8816918440_G_2, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2);
	float4 _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4;
	float3 _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	float2 _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6;
	Unity_Combine_float(_Split_60792a6be44852819fc09b8816918440_R_1, _Add_13aa48af27870f87b4cba9e2947120d0_Out_2, _Split_60792a6be44852819fc09b8816918440_B_3, 0, _Combine_c07199f52edac18cb452af4e3477e0ab_RGBA_4, _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5, _Combine_c07199f52edac18cb452af4e3477e0ab_RG_6);
	description.Position = _Combine_c07199f52edac18cb452af4e3477e0ab_RGB_5;
	description.Normal = IN.ObjectSpaceNormal;
	description.Tangent = IN.ObjectSpaceTangent;
	return description;
}

// Graph Pixel
struct SurfaceDescription
{
	float3 BaseColor;
	float Alpha;
	float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
	SurfaceDescription surface = (SurfaceDescription)0;
	float _Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0 = Boolean_752BD26D;
	float _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0 = Vector1_AB4D1482;
	float _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2;
	Unity_Multiply_float(IN.TimeParameters.x, _Property_0c12f7aa9d5ad48bb316f188eb2fd41a_Out_0, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2);
	float _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0 = Vector1_65024720;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3;
	float _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4;
	Unity_Voronoi_float(IN.uv0.xy, _Multiply_457a89ef46bcc5819e9a836e4e74b960_Out_2, _Property_463a52c223a670889eb1644a5ee1bcd8_Out_0, _Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Voronoi_d5375cc6665b0884ba91c929744b832d_Cells_4);
	float _Property_2faab610918c8e83a1fc43123d566a59_Out_0 = Vector1_DAC37871;
	float _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2;
	Unity_Power_float(_Voronoi_d5375cc6665b0884ba91c929744b832d_Out_3, _Property_2faab610918c8e83a1fc43123d566a59_Out_0, _Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2);
	float4 _Property_e299ceb4986efc8c9d540587bc350f21_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_A5FBF550) : Color_A5FBF550;
	float4 _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2;
	Unity_Multiply_float((_Power_40352cf1a964ee86ab75da76ee4d2fec_Out_2.xxxx), _Property_e299ceb4986efc8c9d540587bc350f21_Out_0, _Multiply_edcc763321e13d84a1f370f01548d64b_Out_2);
	float4 _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0 = Color_9BC50DA7;
	float4 _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2;
	Unity_Add_float4(_Multiply_edcc763321e13d84a1f370f01548d64b_Out_2, _Property_4807d64c00758a84a86a5fd6bbcf61e0_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2);
	float4 _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0 = Color_3F2719E;
	float4 _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3;
	Unity_Branch_float4(_Property_02a700f7f3c06c86aabaa3f12bf20e8d_Out_0, _Add_04d8fa42c0ea58878ae8f46e66d19861_Out_2, _Property_1f80099af0d22c889c0d2cf4dce35d0e_Out_0, _Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3);
	float _Property_368ca6f9eccad48f8e0654703c855393_Out_0 = Boolean_752BD26D;
	float _Property_f7fe66b04090a684a3829103ab783a7f_Out_0 = Vector1_E7EEAB37;
	float _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0 = Vector1_5565EB0D;
	float _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	Unity_Branch_float(_Property_368ca6f9eccad48f8e0654703c855393_Out_0, _Property_f7fe66b04090a684a3829103ab783a7f_Out_0, _Property_db9113dd1552da8cb6d465cc6edf3dab_Out_0, _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3);
	surface.BaseColor = (_Branch_49dcc713f5c3ac81b3b75a22035645b2_Out_3.xyz);
	surface.Alpha = _Branch_d0c37408a375348d8b5ed9d657fb49b7_Out_3;
	surface.AlphaClipThreshold = 0;
	return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
	VertexDescriptionInputs output;
	ZERO_INITIALIZE(VertexDescriptionInputs, output);

	output.ObjectSpaceNormal = input.normalOS;
	output.ObjectSpaceTangent = input.tangentOS.xyz;
	output.ObjectSpacePosition = input.positionOS;
	output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
	output.TimeParameters = _TimeParameters.xyz;

	return output;
}
	SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
	SurfaceDescriptionInputs output;
	ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





	output.uv0 = input.texCoord0;
	output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

	return output;
}

	// --------------------------------------------------
	// Main

	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

	ENDHLSL
}
	}
		CustomEditor "ShaderGraph.PBRMasterGUI"
		FallBack "Hidden/Shader Graph/FallbackError"
}
