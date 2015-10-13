Shader "Custom/Light"
{
	Properties
	{
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_Particles ("Particles Texture even", 2D) = "black" {}
		_Particles2 ("Particles Texture odd", 2D) = "black" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_ContrastFactor ("Contrast Factor", Float) = 1.0
		_ColorFactor ("Color Factor", Float) = 0.5
		_IntensityFactor ("Intensity Variation Factor", Float) = 0.5
		_ParticleFactor ("Particle Factor", Float) = 1.0
	}
    
	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"ForceNoShadowCasting"="True" 
		}
		
	    Pass
	    {
			AlphaTest Greater 0.0	 // Pixel with an alpha of 0 should be ignored
			Blend DstColor One // Keep deep black values
			
			CGPROGRAM
		     
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// User-specified properties
			uniform sampler2D _MainTex;
			uniform fixed4 _Color;
			uniform float _ContrastFactor;
			uniform float _IntensityFactor;


			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			struct VertexOutput
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float intensity : TEXCOORD1;
			};

			VertexOutput vert(VertexInput input)
			{
				VertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				output.uv = input.uv;
				output.color = input.color;
				output.intensity = _IntensityFactor * _ContrastFactor * cos(_Time.z) * sin(_Time.w) * _CosTime.w 
									+ 1.0 * _ContrastFactor;

				return output;
			}

			fixed4 frag(VertexOutput input) : COLOR
			{
				fixed4 diffuseColor = tex2D(_MainTex, input.uv);
				// Retrieve color from texture and multiply it by tint color and by sprite color
				// Multiply everything by texture alpha to emulate transparency
				diffuseColor.rgb = diffuseColor.rgb * _Color.rgb * input.color.rgb;
				diffuseColor.rgb *= diffuseColor.a * _Color.a * input.color.a;
				diffuseColor *= input.intensity;

				return fixed4(diffuseColor);
			}

			ENDCG
		}

		Pass
		{
			AlphaTest Greater 0.0	 // Pixel with an alpha of 0 should be ignored
			Blend SrcAlpha One // Add colours to the previous pixels

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// User-specified properties
			uniform sampler2D _MainTex;
			uniform sampler2D _Particles;
			uniform sampler2D _Particles2;
			uniform float4 _Particles_ST;
			uniform float4 _Particles2_ST;
			uniform fixed4 _Color;
			uniform float _ColorFactor;
			uniform float _ParticleFactor;

			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct VertexOutput
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_part : TEXCOORD1;
				float2 uv_part2 : TEXCOORD2;
				fixed4 color : COLOR;
			};

			VertexOutput vert(VertexInput input)
			{
				VertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				output.uv = input.uv;

				float u = input.uv.x + _SinTime.x * 0.1f;
				float v = input.uv.y + _SinTime.x * _CosTime.y * _SinTime.x * 0.1f;
				output.uv_part = TRANSFORM_TEX(float2(u, v), _Particles);

				float u2 = input.uv.x + _SinTime.x * 0.05f;
				float v2 = input.uv.y + _SinTime.y * _CosTime.x * _SinTime.x * 0.1f;
				output.uv_part2 = TRANSFORM_TEX(float2(u2, v2), _Particles2);
				output.color = input.color;

				return output;
			}

			fixed4 frag(VertexOutput input) : COLOR
			{
				fixed4 diffuseColor = tex2D(_MainTex, input.uv);
				diffuseColor.rgb = _Color.rgb * diffuseColor.rgb * input.color.rgb * diffuseColor.a;
				diffuseColor *= _ColorFactor;

				fixed4 partColor = tex2D(_Particles, input.uv_part);
				fixed4 part2Color = tex2D(_Particles2, input.uv_part2);

				partColor.rgb = partColor.rgb * input.color.rgb * partColor.a;
				part2Color.rgb = part2Color.rgb * input.color.rgb * part2Color.a;

				fixed4 finalColor;
				finalColor = diffuseColor + (partColor + part2Color) * _ParticleFactor;
				finalColor.a = _Color.a * input.color.a;

				return fixed4(finalColor);
			}

			ENDCG
		}
	}
}

