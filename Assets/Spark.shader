Shader "Unlit/Spark"
{
	Properties
	{
        _Color ("Color", Color) = (1,1,1,1)
        _ScaleX ("Scale X", Float) = 1
        _ScaleY ("Scale Y", Float) = 1
        _Speed ("Speed",Float) = 1
        _StartPos ("Start pos",Vector) = (-7,0,0,0)
        _EndPos ("End pos",Vector) = (7,0,0,0)
        _StartDir ("Start direction",Vector) = (1,1,0,0)
        _EndDir ("End direction",Vector) = (-1,1,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
            #pragma target 3.5
			
			#include "UnityCG.cginc"
            #include "ClassicNoise3D.cginc"
            #define PI 3.14159265359
            ///#define EPS 0.0001
            //#define EPS 1e-10

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

            float4 _Color;
            int _VertexNum;
            float _ScaleX;
            float _ScaleY;
            float _Speed;
            float4 _StartPos;
            float4 _StartDir;
            float4 _EndPos;
            float4 _EndDir;

            //bool is_intersected_l( float4 a0, float4 a1, float4 b0, float4 b1 ) {
            //    return !( abs(cross( a0.xyz-a1.xyz, b0.xyz-b1.xyz) - 0.0 ) < EPS );
            //}
			
			v2f vert (uint id : SV_VertexID)
			{
                //is_intersected_l(_StartPos, _StartDir, _EndPos, _EndDir);
                //_StartPos _EndPos _StartDir _EndDir

                float div = (float)id / _VertexNum;
                float4 pos = lerp(_StartPos, _EndPos, div);
                //float4 pos = float4((div - 0.5) * _ScaleX, 0, 0, 1);
                //_Time

                float timex = _Time.x * _Speed * 0.1365143f;
                float timey = _Time.x * _Speed * 1.21688f;
                float timez = _Time.x * _Speed * 2.5564f;
                float x = cnoise(float3(timex + pos.x, timex + pos.y, timex + pos.z));
                float y = cnoise(float3(timey + pos.x, timey + pos.y, timey + pos.z));
                float z = cnoise(float3(timez + pos.x, timez + pos.y, timez + pos.z));
                float4 offset = float4(x, y, z, 0);
                pos+=offset;


                v2f o;
                o.vertex = UnityObjectToClipPos(pos);
                return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}
