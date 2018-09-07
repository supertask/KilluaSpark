Shader "Unlit/Spark"
{
	Properties
	{
        _Color ("Color", Color) = (1,1,1,1)
        _ScaleX ("Scale X", Float) = 1
        _ScaleY ("Scale Y", Float) = 1
        _Speed ("Speed",Float) = 1

        _Throttle ("Throttle",Float) = 0.8 //0.1~1.0
        _Seed ("Seed",int) = 20
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

        //Pass {
			CGPROGRAM

            //#pragma surface surf Standard nolightmap
			//#pragma vertex vert
            #pragma surface surf Standard vertex:vert nolightmap

			//#pragma fragment frag

			// make fog work
			#pragma multi_compile_fog
            #pragma target 3.5
			
			#include "UnityCG.cginc"
            #include "SimplexNoise2D.cginc"
            //#include "ClassicNoise3D.cginc"

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR; 
            };
            struct Input { fixed4 color : COLOR; }; //追加

            float _Throttle;
            float _Seed;
            float2 _Interval;
            float2 _Length;
            float3 _Point0;
            float3 _Point1;
            float2 _NoiseFrequency;
            float2 _NoiseMotion;
            float2 _NoiseAmplitude;
            float _Distance;
            float3 _Asis0;
            float3 _Asis1;
            float3 _Asis2;

            float4 _Color;
            int _VertexNum;
            float _ScaleX;
            float _ScaleY;
            float _Speed;

            // pseudo random number generator
            float nrand01(float seed, float salt)
            {
                float2 uv = float2(seed, salt);
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            // vertex intensity function
            float intensity(float seed)
            {
                return (nrand01(seed, 4) < _Throttle) * nrand01(seed, 5) - 0.01;
            }

            // displacement function (今はclassic noise)
            float displace(float p, float t, float offs) {
                float2 np1 = float2(_NoiseFrequency.x * p + offs, t * _NoiseMotion.x);
                float2 np2 = float2(_NoiseFrequency.y * p + offs, t * _NoiseMotion.y);
                return snoise(np1) * _NoiseAmplitude.x + snoise(np2) * _NoiseAmplitude.y;
            }

			//v2f vert (uint id : SV_VertexID)
            void vert(inout appdata_full v)
			{
                //float pp01 = (float)id / _VertexNum; // position on the line segment [0-1]
                float pp01 = v.vertex.x; 
                float seed = (v.vertex.y + _Seed) * 131.1; // random seed

                //
                // ピカピカさせる（電気の法則っぽい）
                //
                // interval (length of cycle)
                float interval = lerp(_Interval.x, _Interval.y, nrand01(seed, 0));
                //_Time.x:t/20[秒] _Time.y:t[秒] _Time.z:2×t[秒] _Time.w:3×t[秒] 
                float t = _Time.y;          // absolute time
                float tpi = t / interval;
                float tp01 = frac(tpi);     // time parameter [0-1]
                float cycle = floor(tpi);   // cycle count
                // modify the random seed with the cycle count
                seed += fmod(cycle, 9973) * 3.174;

                //
                // 光を飛ばす感じ
                //
                // modify pp01 with the bolt length parameter
                float bolt_len = lerp(_Length.x, _Length.y, nrand01(seed, 1));
                pp01 = lerp(tp01, pp01, bolt_len);

                float d0 = displace(pp01 * _Distance, t, seed *  13.45);
                float d1 = displace(pp01 * _Distance, t, seed * -21.73);
                //float3 pos = lerp(_Point0, _Point1, pp01) + d0 * _Asis1 + d1 * _Asis2;
                float3 pos = lerp(_Point0, _Point1, pp01) + float3(1,7,4) * d0 + float3(1,7,4) * d1;

                /*
                float timex = _Time.y * _Speed * 0.1365143f;
                float timey = _Time.y * _Speed * 1.21688f;
                float timez = _Time.y * _Speed * 2.5564f;
                float x = cnoise(float3(timex + pos.x, timex + pos.y, timex + pos.z));
                float y = cnoise(float3(timey + pos.x, timey + pos.y, timey + pos.z));
                float z = cnoise(float3(timez + pos.x, timez + pos.y, timez + pos.z));
                float3 offset = float3(x, y, z);
                pos+=offset;
                */


                // vertex position
                //v.vertex.xyz = lerp(p0, p1, pp01);

                // vertex color (indensity)
                //v.color = _Color * intensity(seed);

                v.vertex.xyz = pos;
                v.color = _Color;
                //v.color = _Color * intensity(seed);
                //return o;
			}

            /*
            fixed4 frag (v2f i) : SV_Target {
                clip(i.color.r);
                return i.color;
            }
            */

            void surf(Input IN, inout SurfaceOutputStandard o) {
                clip(IN.color.r);
                //o.Albedo = IN.color.rgb;
                o.Emission = IN.color.rgb;
            }
			ENDCG
		//}
	}
}
